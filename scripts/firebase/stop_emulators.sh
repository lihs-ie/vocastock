#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command docker

env_file="$(vocas_repo_root)/docker/firebase/env/.env"
if [[ ! -f "$env_file" ]]; then
  vocas_warn "docker/firebase/env/.env is missing; using example values"
  env_file="$(vocas_repo_root)/docker/firebase/env/.env.example"
fi

docker compose \
  --env-file "$env_file" \
  -f "$(vocas_repo_root)/docker/firebase/compose.yaml" \
  down

vocas_log "firebase emulators stopped"
