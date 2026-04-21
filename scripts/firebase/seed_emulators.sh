#!/usr/bin/env bash
set -euo pipefail

# Load the vocastock env helpers and the local emulator env overrides.
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command node
vocas_require_command npm

repo_root="$(vocas_repo_root)"
env_file="$repo_root/docker/firebase/env/.env"
if [[ ! -f "$env_file" ]]; then
  env_file="$repo_root/docker/firebase/env/.env.example"
fi
# shellcheck disable=SC1090
set -a
source "$env_file"
set +a

seed_dir="$repo_root/firebase/seed"

if [[ ! -d "$seed_dir/node_modules" ]]; then
  vocas_log "installing firebase-admin in firebase/seed (first run)"
  (cd "$seed_dir" && npm install --silent --no-audit --no-fund)
fi

vocas_log "seeding Firebase emulators for project $FIREBASE_PROJECT"
FIREBASE_PROJECT="$FIREBASE_PROJECT" \
FIREBASE_AUTH_PORT="$FIREBASE_AUTH_PORT" \
FIREBASE_FIRESTORE_PORT="$FIREBASE_FIRESTORE_PORT" \
FIREBASE_STORAGE_PORT="$FIREBASE_STORAGE_PORT" \
  node "$seed_dir/seed.mjs" "$@"
