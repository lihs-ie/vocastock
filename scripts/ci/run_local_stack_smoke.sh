#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

start_epoch="$(date +%s)"
reuse_running=0
with_application_containers=0

for arg in "$@"; do
  case "$arg" in
    --reuse-running)
      reuse_running=1
      ;;
    --with-application-containers)
      with_application_containers=1
      ;;
    *)
      vocas_die "unsupported argument: $arg"
      ;;
  esac
done

cleanup() {
  if (( reuse_running == 0 )); then
    bash "$SCRIPT_DIR/../firebase/stop_emulators.sh" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

if (( reuse_running == 0 )); then
  vocas_log "starting local stack smoke for services: ${VOCAS_FIREBASE_EMULATOR_SERVICES}"
  bash "$SCRIPT_DIR/../firebase/start_emulators.sh"
fi

bash "$SCRIPT_DIR/../firebase/smoke_local_stack.sh" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"
bash "$SCRIPT_DIR/../fallback/smoke_pubsub_stub.sh"
bash "$SCRIPT_DIR/../fallback/smoke_drive_stub.sh"

if (( with_application_containers == 1 )); then
  vocas_load_local_env
  export FIRESTORE_EMULATOR_HOST="host.docker.internal:${FIREBASE_FIRESTORE_PORT}"
  export STORAGE_EMULATOR_HOST="host.docker.internal:${FIREBASE_STORAGE_PORT}"
  export FIREBASE_AUTH_EMULATOR_HOST="host.docker.internal:${FIREBASE_AUTH_PORT}"
  vocas_log "running application container smoke after firebase stack validation"
  bash "$SCRIPT_DIR/run_application_container_smoke.sh"
fi

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "local-stack-smoke" "$elapsed"
vocas_print_budget_summary "local-stack-smoke" "$elapsed" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"
