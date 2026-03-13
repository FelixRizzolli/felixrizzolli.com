#!/bin/bash
set -euo pipefail

# =============================================================================
# init-server.sh – One-time setup for a fresh Cloud server.
#
# Run this script ONCE after cloning the repository on a new server.
# After it completes, push a commit (or trigger the deploy workflow manually)
# to perform the first full deployment.
#
# Prerequisites:
#   - Docker + Docker Compose v2 installed
#   - Git repository cloned to /var/www/felixrizzolli.com
#   - .env.prod already placed in /var/www/felixrizzolli.com/infrastructure/
#     (the deploy workflow will overwrite it on every subsequent deploy)
# =============================================================================

REPO_DIR="/var/www/felixrizzolli.com"
INFRA_DIR="$REPO_DIR/infrastructure"
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

# acme.json must exist with strict permissions before Traefik starts,
# otherwise Traefik fails to start on first run.
touch "$VOLUMES_BASE/letsencrypt/acme.json"
chmod 600 "$VOLUMES_BASE/letsencrypt/acme.json"

echo "   ✓ Volume directories ready"

# ---------------------------------------------------------------------------
# 2. Verify the environment file is present
# ---------------------------------------------------------------------------
echo ""
echo "==> Checking environment file..."
if [ ! -f "$INFRA_DIR/.env.prod" ]; then
  echo ""
  echo "  ERROR: $INFRA_DIR/.env.prod not found." >&2
  echo "  Place the environment file there before running this script," >&2
  echo "  or trigger the deploy workflow once to have GitHub write it." >&2
  exit 1
fi
echo "   ✓ .env.prod found"

# ---------------------------------------------------------------------------
# 3. Start the shared reverse proxy (Traefik)
#    This is started independently of the application services and shared
#    with ALL other projects on this server
# ---------------------------------------------------------------------------
echo ""
echo "==> Starting shared reverse proxy (Traefik)..."
cd "$INFRA_DIR"
docker compose \
  -f compose.proxy.yml \
  --env-file .env.prod \
  up -d

echo "   ✓ Traefik is running"

# ---------------------------------------------------------------------------
# 4. Done
# ---------------------------------------------------------------------------
echo ""
echo "====================================================================="
echo "  Initialization complete."
echo ""
echo "  Next steps:"
echo "    • Push a commit or trigger the GitHub Actions deploy workflow"
echo "      to perform the first full deployment of all services."
echo "    • For for other domains: add the traefik-public network to"
echo "      its compose file (see compose.proxy.yml for instructions)."
echo "====================================================================="

