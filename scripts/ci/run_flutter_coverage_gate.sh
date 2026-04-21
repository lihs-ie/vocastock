#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

# Usage: run_flutter_coverage_gate.sh [lcov_path] [threshold_percent]
#
# Defaults:
#   lcov_path         = applications/mobile/coverage/lcov.info
#   threshold_percent = 90
#
# Exit codes:
#   0 - coverage meets or exceeds threshold (or lcov not yet produced during bootstrap)
#   1 - coverage is below threshold
#   2 - invalid arguments or lcov parse failure

repo_root="$(vocas_repo_root)"
lcov_path="${1:-"$repo_root/applications/mobile/coverage/lcov.info"}"
threshold="${2:-90}"

if [[ ! "$threshold" =~ ^[0-9]+$ ]]; then
  vocas_die "threshold must be an integer percentage (got: $threshold)"
fi

start_epoch="$(date +%s)"
vocas_ensure_artifact_directories
log_dir="$repo_root/.artifacts/ci/logs"
summary_file="$log_dir/flutter-coverage-gate.summary.md"
mkdir -p "$log_dir"

{
  echo "# flutter-coverage-gate"
  echo
  echo "- lcov path: \`$lcov_path\`"
  echo "- threshold: ${threshold}%"
} > "$summary_file"

if [[ ! -f "$lcov_path" ]]; then
  {
    echo "- status: skipped (lcov not produced yet; bootstrap stage)"
  } >> "$summary_file"
  vocas_warn "lcov file not found at $lcov_path; bootstrap stage — skipping coverage gate"
  elapsed="$(( $(date +%s) - start_epoch ))"
  vocas_write_duration "flutter-coverage-gate" "$elapsed"
  vocas_print_budget_summary "flutter-coverage-gate" "$elapsed" "$VOCAS_CI_RUNTIME_BUDGET_SECONDS"
  exit 0
fi

# Sum `LF:` (lines found) and `LH:` (lines hit) across the lcov records, ignoring
# generated files and stub adapters that the spec explicitly excludes from the gate.
read -r lines_found lines_hit <<< "$(
  awk -v exclude='\\.g\\.dart$|\\.freezed\\.dart$|\\.gql\\.dart$|\\.var\\.gql\\.dart$|\\.req\\.gql\\.dart$|\\.data\\.gql\\.dart$|/__generated__/|/infrastructure/stub/|/presentation/variant/|(^|/)lib/main\\.dart$' '
    BEGIN { include = 1; found = 0; hit = 0 }
    /^SF:/ {
      path = substr($0, 4)
      if (path ~ exclude) { include = 0 } else { include = 1 }
      next
    }
    /^LF:/ { if (include) { split($0, a, ":"); found += a[2] }; next }
    /^LH:/ { if (include) { split($0, a, ":"); hit += a[2] }; next }
    /^end_of_record/ { include = 1; next }
    END { printf "%d %d", found, hit }
  ' "$lcov_path"
)"

if (( lines_found == 0 )); then
  {
    echo "- status: failed"
    echo "- reason: no lines attributed to lcov (possible parse failure or empty report)"
  } >> "$summary_file"
  vocas_die "coverage gate: lcov reports zero lines found"
fi

# Compute percentage with integer arithmetic; multiply by 1000 for one decimal place.
percent_times_ten=$(( lines_hit * 1000 / lines_found ))
percent_int=$(( percent_times_ten / 10 ))
percent_frac=$(( percent_times_ten % 10 ))

{
  echo "- lines found: ${lines_found}"
  echo "- lines hit: ${lines_hit}"
  echo "- coverage: ${percent_int}.${percent_frac}%"
} >> "$summary_file"

if (( percent_int < threshold )); then
  {
    echo "- status: failed"
    echo "- reason: coverage below threshold"
  } >> "$summary_file"
  vocas_die "coverage gate: ${percent_int}.${percent_frac}% is below threshold ${threshold}%"
fi

{
  echo "- status: passed"
} >> "$summary_file"
vocas_log "coverage gate: ${percent_int}.${percent_frac}% meets threshold ${threshold}%"

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "flutter-coverage-gate" "$elapsed"
vocas_print_budget_summary "flutter-coverage-gate" "$elapsed" "$VOCAS_CI_RUNTIME_BUDGET_SECONDS"
