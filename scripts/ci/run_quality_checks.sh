#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

mode="${1:-run}"
start_epoch="$(date +%s)"
vocas_ensure_artifact_directories

log_dir="$(vocas_repo_root)/.artifacts/ci/logs"
summary_file="$log_dir/flutter-static-checks.summary.md"
doctor_log="$log_dir/flutter-doctor.log"
analyze_log="$log_dir/dart-analyze.log"
test_log="$log_dir/flutter-test.log"
trivy_summary_file="$log_dir/trivy-policy.summary.md"
trivy_config="$(vocas_repo_root)/.github/trivy.yaml"

mkdir -p "$log_dir"

if [[ "$mode" == "--validate-trivy-policy" ]]; then
  [[ -f "$trivy_config" ]] || vocas_die "missing Trivy config: $trivy_config"
  grep -Eq '^exit-code:[[:space:]]*1$' "$trivy_config" || vocas_die "Trivy config must fail the job with exit-code 1"
  grep -Eq '^[[:space:]]*-[[:space:]]*MEDIUM$' "$trivy_config" || vocas_die "Trivy config must include MEDIUM severity"
  grep -Eq '^[[:space:]]*-[[:space:]]*HIGH$' "$trivy_config" || vocas_die "Trivy config must include HIGH severity"
  grep -Eq '^[[:space:]]*-[[:space:]]*CRITICAL$' "$trivy_config" || vocas_die "Trivy config must include CRITICAL severity"
  {
    echo "# trivy-policy"
    echo
    echo "- Config: \`$trivy_config\`"
    echo "- Exit code: 1"
    echo "- Severity threshold: MEDIUM / HIGH / CRITICAL"
  } > "$trivy_summary_file"
  elapsed="$(( $(date +%s) - start_epoch ))"
  vocas_write_duration "trivy-policy-validate" "$elapsed"
  vocas_print_budget_summary "trivy-policy-validate" "$elapsed" "$VOCAS_CI_RUNTIME_BUDGET_SECONDS"
  exit 0
fi

{
  echo "# flutter-static-checks"
  echo
} > "$summary_file"

if project_dir="$(vocas_find_flutter_project_dir)"; then
  if vocas_have_command flutter; then
    flutter doctor --verbose 2>&1 | tee "$doctor_log"
  else
    vocas_die "flutter is required when a Flutter project is present"
  fi
  (
    cd "$project_dir"
    dart analyze . 2>&1 | tee "$analyze_log"
    flutter test 2>&1 | tee "$test_log"
  )
  {
    echo "- Flutter project: \`$project_dir\`"
    echo "- Static analysis: passed"
    echo "- Tests: passed"
  } >> "$summary_file"
else
  {
    echo "- Flutter project: not yet present"
    echo "- Flutter doctor: skipped at repository bootstrap stage"
    echo "- Static analysis: skipped at repository bootstrap stage"
    echo "- Tests: skipped at repository bootstrap stage"
  } >> "$summary_file"
  vocas_warn "no Flutter project detected; flutter doctor, static analysis, and tests were skipped"
fi

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "flutter-static-checks" "$elapsed"
vocas_print_budget_summary "flutter-static-checks" "$elapsed" "$VOCAS_CI_RUNTIME_BUDGET_SECONDS"
