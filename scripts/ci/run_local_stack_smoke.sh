#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

start_epoch="$(date +%s)"
reuse_running="${1:-}"

cleanup() {
  if [[ "$reuse_running" != "--reuse-running" ]]; then
    bash "$SCRIPT_DIR/../firebase/stop_emulators.sh" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

if [[ "$reuse_running" != "--reuse-running" ]]; then
  bash "$SCRIPT_DIR/../firebase/start_emulators.sh"
fi

bash "$SCRIPT_DIR/../firebase/smoke_local_stack.sh" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"
bash "$SCRIPT_DIR/../fallback/smoke_pubsub_stub.sh"
bash "$SCRIPT_DIR/../fallback/smoke_drive_stub.sh"

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "local-stack-smoke" "$elapsed"
vocas_print_budget_summary "local-stack-smoke" "$elapsed" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"
