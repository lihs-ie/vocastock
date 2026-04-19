#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

search_root="${1:-$(vocas_repo_root)/.artifacts}"
budget_seconds="${CI_RUNTIME_BUDGET_SECONDS:-$VOCAS_CI_RUNTIME_BUDGET_SECONDS}"

vocas_log "enforcing CI runtime budget for runner classes ${VOCAS_APPROVED_LINUX_RUNNER_CLASS} and ${VOCAS_APPROVED_APPLE_RUNNER_CLASS}"

duration_files=()
while IFS= read -r duration_file; do
  duration_files+=("$duration_file")
done < <(find "$search_root" -name "*.seconds" -type f | sort)
(( ${#duration_files[@]} > 0 )) || vocas_die "no CI duration files found under $search_root"

total_seconds=0
for duration_file in "${duration_files[@]}"; do
  seconds="$(tr -d ' \n' < "$duration_file")"
  [[ "$seconds" =~ ^[0-9]+$ ]] || vocas_die "invalid duration value in $duration_file"
  vocas_log "duration ${duration_file}: ${seconds}s"
  total_seconds=$((total_seconds + seconds))
done

vocas_print_budget_summary "ci runtime aggregate" "$total_seconds" "$budget_seconds"
(( total_seconds <= budget_seconds )) || vocas_die "CI runtime budget exceeded"
