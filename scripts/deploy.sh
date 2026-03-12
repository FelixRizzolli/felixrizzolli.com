#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# deploy.sh  –  Pull a new image and redeploy a service via Docker Compose.
#
# Usage: deploy.sh <service> [version]
#
#   service  – one of: all | api | www | docs | wedding | traveling
#   version  – Docker image tag to deploy (default: latest)
#
# Examples:
#   ./deploy.sh api
#   ./deploy.sh wedding sha-abc1234
#   ./deploy.sh all
# ---------------------------------------------------------------------------

usage() {
  echo "Usage: $0 <service> [version]"
  echo ""
  echo "  service  - One of: all, api, www, docs, wedding, traveling"
  echo "  version  - Docker image tag to deploy (default: latest)"
  echo ""
  echo "Examples:"
  echo "  $0 api"
  echo "  $0 wedding sha-abc1234"
  echo "  $0 all"
  exit 1
}

SERVICE="${1:-}"
VERSION="${2:-latest}"

if [[ "$SERVICE" == "-h" || "$SERVICE" == "--help" || -z "$SERVICE" ]]; then
  usage
fi

echo "====================================================================="
echo "  Deploying [$SERVICE] – version: $VERSION"
echo "====================================================================="

# ---------------------------------------------------------------------------
# 1. Update infrastructure config from the repository
# ---------------------------------------------------------------------------
REPO_DIR="/var/www/felixrizzolli.com"
cd "$REPO_DIR"

echo "==> Syncing infrastructure files..."
git fetch origin main
git reset --hard origin/main

cd "$REPO_DIR/infrastructure"

ENV_FILE=".env.prod"
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Env file not found: $ENV_FILE" >&2
  exit 3
fi

COMPOSE_BASE=(
  "-f" "compose.yml"
  "-f" "compose.api.yml"
  "-f" "compose.www.yml"
  "-f" "compose.docs.yml"
  "-f" "compose.wedding.yml"
  "-f" "compose.traveling.yml"
  "--env-file" "$ENV_FILE"
)

# ---------------------------------------------------------------------------
# 2. Helper: deploy a single service with rollback on failure
#
#   deploy_service <compose-service-name> <version-env-var>
#
#   The version env var (e.g. PAYLOAD_VERSION) is the variable referenced
#   in the compose file image tag, e.g.:
#     image: ghcr.io/.../api:${PAYLOAD_VERSION:-latest}
# ---------------------------------------------------------------------------
deploy_service() {
  local service="$1"
  local version_var="$2"

  # Snapshot the current running image for potential rollback
  local container_id="" running_image=""
  container_id=$(docker compose "${COMPOSE_BASE[@]}" ps -q "$service" 2>/dev/null | head -1 || true)
  if [ -n "$container_id" ]; then
    running_image=$(docker inspect --format='{{.Config.Image}}' "$container_id" 2>/dev/null || true)
  fi

  echo ""
  echo "--> Pulling $service ($VERSION)..."
  (export "${version_var}=${VERSION}"; docker compose "${COMPOSE_BASE[@]}" pull "$service")

  echo "--> Starting $service..."
  if (export "${version_var}=${VERSION}"; \
      docker compose "${COMPOSE_BASE[@]}" up -d --wait --wait-timeout 120 "$service"); then
    echo "✓  $service is healthy"
  else
    echo "✗  $service failed to become healthy" >&2

    if [ -n "$running_image" ]; then
      echo "==> Rolling back $service to: $running_image" >&2
      # Re-deploy with the previous image reference (uses the digest directly)
      (export "${version_var}=${running_image}"; \
       docker compose "${COMPOSE_BASE[@]}" up -d "$service") || true
      echo "==> Rollback complete. Please investigate the failed image." >&2
    fi

    exit 1
  fi
}

# ---------------------------------------------------------------------------
# 3. Deploy the requested service(s)
# ---------------------------------------------------------------------------
case $SERVICE in
  api)
    deploy_service "api" "PAYLOAD_VERSION"
    ;;
  www)
    deploy_service "www" "WWW_VERSION"
    ;;
  docs)
    deploy_service "docs" "DOCS_VERSION"
    ;;
  wedding)
    deploy_service "wedding" "WEDDING_VERSION"
    ;;
  traveling)
    deploy_service "traveling" "TRAVELING_VERSION"
    ;;
  all)
    echo ""
    echo "--> Pulling all images ($VERSION)..."
    (
      export PAYLOAD_VERSION=$VERSION
      export WWW_VERSION=$VERSION
      export DOCS_VERSION=$VERSION
      export WEDDING_VERSION=$VERSION
      export TRAVELING_VERSION=$VERSION
      docker compose "${COMPOSE_BASE[@]}" pull
      echo "--> Starting all services..."
      docker compose "${COMPOSE_BASE[@]}" up -d --wait --wait-timeout 300 --remove-orphans
    )
    echo "✓  All services are healthy"
    ;;
  *)
    echo "Error: Unknown service '$SERVICE'" >&2
    usage
    ;;
esac

# ---------------------------------------------------------------------------
# 4. Post-deploy cleanup
# ---------------------------------------------------------------------------
echo ""
echo "==> Cleaning up dangling images..."
docker image prune -f

echo ""
echo "==> Deployment complete. Current status:"
docker compose "${COMPOSE_BASE[@]}" ps

