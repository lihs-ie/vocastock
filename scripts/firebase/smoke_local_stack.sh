#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command docker
vocas_require_command curl

env_file="$(vocas_repo_root)/docker/firebase/env/.env"
if [[ ! -f "$env_file" ]]; then
  env_file="$(vocas_repo_root)/docker/firebase/env/.env.example"
fi
set -a
source "$env_file"
set +a

timeout_seconds="${1:-$VOCAS_EMULATOR_READY_BUDGET_SECONDS}"
start_epoch="$(date +%s)"
log_file="$(vocas_repo_root)/.artifacts/firebase/logs/emulators.log"
ui_port="${FIREBASE_UI_PORT:-14000}"

while true; do
  if curl -fsS "http://127.0.0.1:${ui_port}/" >/dev/null 2>&1; then
    break
  fi

  if [[ -f "$log_file" ]] && grep -q "All emulators ready" "$log_file"; then
    break
  fi

  now_epoch="$(date +%s)"
  if (( now_epoch - start_epoch >= timeout_seconds )); then
    vocas_die "firebase emulator smoke timed out after ${timeout_seconds}s"
  fi
  sleep 5
done

vocas_log "firebase emulator smoke passed"
