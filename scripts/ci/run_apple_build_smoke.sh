#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

[[ "$(uname -s)" == "Darwin" ]] || vocas_die "apple build smoke must run on macOS"

start_epoch="$(date +%s)"
vocas_ensure_artifact_directories
log_dir="$(vocas_repo_root)/.artifacts/ci/logs"
mkdir -p "$log_dir"

xcodebuild -version 2>&1 | tee "$log_dir/apple-xcodebuild.log"
if vocas_have_command pod; then
  pod --version 2>&1 | tee "$log_dir/apple-cocoapods.log"
fi

if project_dir="$(vocas_find_flutter_project_dir)"; then
  if [[ -d "$project_dir/ios" ]]; then
    (
      cd "$project_dir"
      flutter build ios --simulator --debug --no-codesign 2>&1 | tee "$log_dir/apple-ios-build.log"
    )
  else
    vocas_warn "iOS directory not found; skipping iOS build smoke"
  fi

  if [[ -d "$project_dir/macos" ]]; then
    (
      cd "$project_dir"
      flutter build macos --debug 2>&1 | tee "$log_dir/apple-macos-build.log"
    )
  else
    vocas_warn "macOS directory not found; skipping macOS build smoke"
  fi
else
  vocas_warn "no Flutter project detected; apple build smoke completed with toolchain validation only"
fi

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "apple-build-smoke" "$elapsed"
vocas_print_budget_summary "apple-build-smoke" "$elapsed" "$VOCAS_CI_RUNTIME_BUDGET_SECONDS"
