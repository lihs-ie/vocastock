#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

bash "$SCRIPT_DIR/validate_local_setup.sh"

if [[ "${1:-}" == "--reuse-running" ]]; then
  bash "$SCRIPT_DIR/../ci/run_local_stack_smoke.sh" --reuse-running
else
  bash "$SCRIPT_DIR/../ci/run_local_stack_smoke.sh"
fi

vocas_log "local stack validation passed"
