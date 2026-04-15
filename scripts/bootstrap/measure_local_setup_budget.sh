#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

state_file="$(vocas_repo_root)/.artifacts/local-setup.started-at"

case "${1:-finish}" in
  start)
    vocas_ensure_artifact_directories
    date +%s > "$state_file"
    vocas_log "local setup budget clock started"
    ;;
  finish)
    [[ -f "$state_file" ]] || vocas_die "start the budget clock first: bash scripts/bootstrap/measure_local_setup_budget.sh start"
    start_epoch="$(cat "$state_file")"
    bash "$SCRIPT_DIR/validate_local_setup.sh"
    end_epoch="$(date +%s)"
    elapsed="$((end_epoch - start_epoch))"
    printf "%s\n" "$elapsed" > "$(vocas_repo_root)/.artifacts/local-setup.seconds"
    vocas_print_budget_summary "local setup" "$elapsed" "$VOCAS_LOCAL_SETUP_BUDGET_SECONDS"
    ;;
  *)
    vocas_die "usage: $0 [start|finish]"
    ;;
esac
