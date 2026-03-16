#!/bin/bash
set -euo pipefail

# =============================================================================
# init-server.sh – One-time setup for a fresh cloud server.
#
# This script is executed by the "Server Initialization" GitHub Actions
# workflow (server-init.yml). It expects the repository to already be
# cloned and .env.prod to already be present (the workflow handles both).
#
# It is safe to run multiple times (idempotent).
#
# Prerequisites:
#   - Docker + Docker Compose v2 installed on the server
#   - Repository cloned to /var/www/felixrizzolli.com
#   - .env.prod present in /var/www/felixrizzolli.com/infrastructure/
# =============================================================================

REPO_DIR="/var/www/felixrizzolli.com"
INFRA_DIR="$REPO_DIR/infrastructure"
ENV_FILE="$INFRA_DIR/.env.prod"
VOLUMES_BASE="/var/lib/docker-volumes"

echo "====================================================================="
echo "  Server initialization"
echo "====================================================================="

# ---------------------------------------------------------------------------
# 1. Create persistent volume directories
# ---------------------------------------------------------------------------
echo ""
echo "==> Creating volume directories..."
mkdir -p "$VOLUMES_BASE/felixrizzolli.com/production/postgres"
mkdir -p "$VOLUMES_BASE/felixrizzolli.com/production/payload-data"
mkdir -p "$VOLUMES_BASE/letsencrypt"

# acme.json must exist with strict permissions before Traefik starts.
touch "$VOLUMES_BASE/letsencrypt/acme.json"
chmod 600 "$VOLUMES_BASE/letsencrypt/acme.json"

echo "   ✓ Volume directories ready"

# ---------------------------------------------------------------------------
# 2. Verify the environment file exists
# ---------------------------------------------------------------------------
echo ""
echo "==> Checking environment file..."
if [ ! -f "$ENV_FILE" ]; then
  echo ""
  echo "  ERROR: $ENV_FILE not found." >&2
  echo "  The server-init.yml workflow uploads it automatically." >&2
  echo "  If you are running this manually, place .env.prod there first." >&2
  exit 1
fi
echo "   ✓ .env.prod found"

# ---------------------------------------------------------------------------
# 3. Conditionally start the shared reverse proxy (Traefik)
#
#    Controlled by the WITH_PROXY variable in .env.prod:
#      true  – This project owns Traefik. Start it here.
#      false – Another project on this server manages Traefik. Skip.
#
#    The traefik-public Docker network must exist before the first
#    deployment regardless of which project created it.
# ---------------------------------------------------------------------------
echo ""

# Read WITH_PROXY from .env.prod without sourcing the file.
# Matches  WITH_PROXY=false  /  WITH_PROXY="false"  /  WITH_PROXY='false'.
# Anything else (missing, empty, "true") is treated as the default: true.
if grep -qE "^WITH_PROXY=['\"]?false['\"]?" "$ENV_FILE" 2>/dev/null; then
  WITH_PROXY="false"
else
  WITH_PROXY="true"
fi

if [ "$WITH_PROXY" = "true" ]; then
  echo "==> Starting shared reverse proxy (Traefik)..."
  cd "$INFRA_DIR"
  # -p proxy pins this stack to its own project name, keeping it completely
  # isolated from the application project ("infrastructure").  This matches
  # the `name: proxy` directive in compose.proxy.yml and prevents Docker
  # Compose from ever treating the traefik container as an orphan of the
  # application project during deployments.
  docker compose \
    -p proxy \
    -f compose.proxy.yml \
    --env-file "$ENV_FILE" \
    up -d
  echo "   ✓ Traefik is running"
else
  echo "==> Skipping proxy setup (WITH_PROXY=false)"
  echo "   Another project on this server manages Traefik and the"
  echo "   traefik-public network. Make sure that project is running"
  echo "   before triggering the first deployment of this project."
fi

# ---------------------------------------------------------------------------
# 4. Done
# ---------------------------------------------------------------------------
echo ""
echo "====================================================================="
echo "  Initialization complete."
echo ""
echo "  Next steps:"
echo "    • Go to Actions → Automated Deployment → Run workflow to"
echo "      perform the first full deployment of all services."
echo "====================================================================="