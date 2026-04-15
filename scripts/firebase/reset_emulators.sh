#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command docker

env_file="$(vocas_repo_root)/docker/firebase/env/.env"
if [[ ! -f "$env_file" ]]; then
  env_file="$(vocas_repo_root)/docker/firebase/env/.env.example"
fi

docker compose \
  --env-file "$env_file" \
  -f "$(vocas_repo_root)/docker/firebase/compose.yaml" \
  down -v

rm -rf "$(vocas_repo_root)/.artifacts/firebase/export" "$(vocas_repo_root)/.artifacts/firebase/import"
mkdir -p "$(vocas_repo_root)/.artifacts/firebase/export" "$(vocas_repo_root)/.artifacts/firebase/import"

vocas_log "firebase emulator state reset"
