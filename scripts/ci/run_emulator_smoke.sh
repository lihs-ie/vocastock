#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

start_epoch="$(date +%s)"
cleanup() {
  bash "$SCRIPT_DIR/../firebase/stop_emulators.sh" >/dev/null 2>&1 || true
}
trap cleanup EXIT

bash "$SCRIPT_DIR/../firebase/start_emulators.sh"
bash "$SCRIPT_DIR/../firebase/smoke_local_stack.sh" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "emulator-smoke" "$elapsed"
vocas_print_budget_summary "emulator-smoke" "$elapsed" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"
