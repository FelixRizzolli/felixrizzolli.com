#!/bin/bash
set -e

usage() {
  echo "Usage: $0 [all|api|www|docs|wedding|traveling]"
  echo "Deploys the specified service(s) via Docker Compose."
  echo ""
  echo "Examples:"
  echo "  $0 api"
  echo "  $0 www"
  echo "  $0 docs"
  echo "  $0 wedding"
  echo "  $0 traveling"
  exit 1
}

SERVICE="$1"

if [[ "$SERVICE" == "-h" || "$SERVICE" == "--help" || -z "$SERVICE" ]]; then
  usage
fi

cd /var/www/felixrizzolli.com
git pull origin main
cd infrastructure

ENV_FILE=".env.prod"
if [ ! -f "$ENV_FILE" ]; then
  echo "Env file not found: $ENV_FILE" >&2
  exit 3
fi


COMPOSE_ARGS=(
  "-f" "compose.yml"
  "-f" "compose.api.yml"
  "-f" "compose.www.yml"
  "-f" "compose.docs.yml"
  "-f" "compose.wedding.yml"
  "-f" "compose.traveling.yml"
  "--env-file" "$ENV_FILE"
)

case $SERVICE in
  api)
    docker compose "${COMPOSE_ARGS[@]}" pull api
    docker compose "${COMPOSE_ARGS[@]}" up -d api
    ;;
  www)
    docker compose "${COMPOSE_ARGS[@]}" pull www
    docker compose "${COMPOSE_ARGS[@]}" up -d www
    ;;
  docs)
    docker compose "${COMPOSE_ARGS[@]}" pull docs
    docker compose "${COMPOSE_ARGS[@]}" up -d docs
    ;;
  wedding)
    docker compose "${COMPOSE_ARGS[@]}" pull wedding
    docker compose "${COMPOSE_ARGS[@]}" up -d wedding
    ;;
  traveling)
    docker compose "${COMPOSE_ARGS[@]}" pull traveling
    docker compose "${COMPOSE_ARGS[@]}" up -d traveling
    ;;
  all)
    docker compose "${COMPOSE_ARGS[@]}" pull
    docker compose "${COMPOSE_ARGS[@]}" up -d
    ;;
  *)
    echo "Unknown service: $SERVICE"
    usage
    ;;
esac

docker system prune -f
docker compose "${COMPOSE_ARGS[@]}" ps