#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

start_epoch="$(date +%s)"
bash "$SCRIPT_DIR/start_emulators.sh"
bash "$SCRIPT_DIR/smoke_local_stack.sh" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"
end_epoch="$(date +%s)"
elapsed="$((end_epoch - start_epoch))"

printf "%s\n" "$elapsed" > "$(vocas_repo_root)/.artifacts/firebase/emulator-ready.seconds"
vocas_print_budget_summary "emulator ready" "$elapsed" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"
