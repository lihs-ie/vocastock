#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command docker
vocas_ensure_artifact_directories

env_template="$(vocas_repo_root)/docker/firebase/env/.env.example"
env_file="$(vocas_repo_root)/docker/firebase/env/.env"
if [[ ! -f "$env_file" ]]; then
  cp "$env_template" "$env_file"
  vocas_log "created docker/firebase/env/.env from example"
fi

set -a
source "$env_file"
set +a

vocas_log "starting firebase emulators for services: ${FIREBASE_EMULATOR_SERVICES:-$VOCAS_FIREBASE_EMULATOR_SERVICES}"

for port_var in \
  FIREBASE_UI_PORT \
  FIREBASE_HOSTING_PORT \
  FIREBASE_AUTH_PORT \
  FIREBASE_FIRESTORE_PORT \
  FIREBASE_STORAGE_PORT \
  FIREBASE_HUB_PORT \
  FIREBASE_LOGGING_PORT
do
  port_value="${!port_var:-}"
  if [[ -n "$port_value" ]] && lsof -nP -iTCP:"$port_value" -sTCP:LISTEN >/dev/null 2>&1; then
    vocas_die "port ${port_value} from ${port_var} is already in use; update docker/firebase/env/.env before starting emulators"
  fi
done

docker compose \
  --env-file "$env_file" \
  -f "$(vocas_repo_root)/docker/firebase/compose.yaml" \
  up -d --build firebase-emulators

vocas_log "firebase emulators are starting"
