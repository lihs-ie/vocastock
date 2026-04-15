#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

start_epoch="$(date +%s)"
vocas_ensure_artifact_directories
log_dir="$(vocas_repo_root)/.artifacts/ci/logs"
mkdir -p "$log_dir"

java -version 2>&1 | tee "$log_dir/android-java.log"

if project_dir="$(vocas_find_flutter_project_dir)"; then
  if [[ -d "$project_dir/android" ]]; then
    [[ -n "${ANDROID_SDK_ROOT:-}" ]] || vocas_die "ANDROID_SDK_ROOT is required for Android build smoke"
    (
      cd "$project_dir"
      flutter build apk --debug 2>&1 | tee "$log_dir/android-build.log"
    )
  else
    vocas_warn "android directory not found; skipping Android build smoke"
  fi
else
  vocas_warn "no Flutter project detected; Android build smoke completed with Java validation only"
fi

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "android-build-smoke" "$elapsed"
vocas_print_budget_summary "android-build-smoke" "$elapsed" "$VOCAS_CI_RUNTIME_BUDGET_SECONDS"
