#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"
source "$SCRIPT_DIR/../lib/vocastock_ci_helpers.sh"

mode=""
matched_paths_file=""

while (($# > 0)); do
  case "$1" in
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --matched-paths-file)
      matched_paths_file="${2:-}"
      shift 2
      ;;
    *)
      vocas_die "unsupported argument: $1"
      ;;
  esac
done

[[ -n "$mode" ]] || vocas_die "--mode is required"
[[ "$mode" == "full" || "$mode" == "noop" ]] || vocas_die "unsupported mode: $mode"

vocas_ensure_artifact_directories
vocas_ensure_ci_artifact_directories

namespace="$VOCAS_RUST_QUALITY_NAMESPACE"
summary_file="$(vocas_rust_quality_summary_file)"
stage_file="$(vocas_rust_quality_stage_file)"
detected_paths_file="${matched_paths_file:-$(vocas_rust_quality_detected_paths_file)}"
start_epoch="$(date +%s)"
current_stage="initializing"
run_result="success"
failure_detail=""
started_emulators=0
completed_segments=()
feature_applications=()

load_matched_paths() {
  if [[ -f "$detected_paths_file" ]]; then
    mapfile -t matched_paths < "$detected_paths_file"
  else
    matched_paths=()
  fi
}

render_summary() {
  {
    printf "# Rust Quality Summary\n\n"
    printf -- "- execution_mode: \`%s\`\n" "$mode"
    printf -- "- result: \`%s\`\n" "$run_result"
    printf -- "- current_stage: \`%s\`\n" "$current_stage"
    if [[ -n "$failure_detail" ]]; then
      printf -- "- failure_detail: \`%s\`\n" "$failure_detail"
    fi
    printf -- "- matched_paths:\n"
    if ((${#matched_paths[@]} == 0)); then
      printf -- "  - \`(none)\`\n"
      if [[ "$mode" == "noop" ]]; then
        printf -- "- noop_reason: \`Rust path changes not detected\`\n"
      fi
    else
      for matched_path in "${matched_paths[@]}"; do
        printf -- "  - \`%s\`\n" "$matched_path"
      done
    fi
    printf -- "- completed_segments:\n"
    if ((${#completed_segments[@]} == 0)); then
      printf -- "  - \`(none)\`\n"
    else
      for segment in "${completed_segments[@]}"; do
        printf -- "  - \`%s\`\n" "$segment"
      done
    fi
    if ((${#feature_applications[@]} > 0)); then
      printf -- "- feature_applications:\n"
      for application in "${feature_applications[@]}"; do
        printf -- "  - \`%s\`\n" "$application"
      done
    fi
  } > "$summary_file"
}

cleanup() {
  if (( started_emulators == 1 )); then
    bash "$SCRIPT_DIR/../firebase/stop_emulators.sh" >/dev/null 2>&1 || true
  fi

  if [[ "$run_result" != "success" ]]; then
    printf "%s\n" "$current_stage" > "$stage_file"
  fi

  render_summary
  elapsed="$(( $(date +%s) - start_epoch ))"
  vocas_write_duration "$namespace" "$elapsed"
  vocas_print_budget_summary "$namespace" "$elapsed" "$VOCAS_RUST_QUALITY_BUDGET_SECONDS"
}

trap cleanup EXIT

load_matched_paths
render_summary

run_logged_segment() {
  local segment="$1"
  shift
  local log_file
  log_file="$(vocas_rust_quality_log_file "$segment")"

  current_stage="$segment"
  vocas_stage_start "$namespace" "$segment"
  if "$@" >"$log_file" 2>&1; then
    completed_segments+=("$segment")
    vocas_stage_finish "$namespace" "$segment" success "$(basename "$log_file")"
    render_summary
    return 0
  fi

  run_result="failure"
  failure_detail="$(basename "$log_file")"
  vocas_stage_finish "$namespace" "$segment" failure "$(basename "$log_file")"
  return 1
}

run_feature_segment() {
  local segment="feature-all"
  local feature_all_log
  feature_all_log="$(vocas_rust_quality_log_file "$segment")"

  current_stage="$segment"
  vocas_stage_start "$namespace" "$segment" "graphql-gateway -> query-api -> command-api"
  : > "$feature_all_log"

  if ! docker info >>"$feature_all_log" 2>&1; then
    run_result="failure"
    failure_detail="docker info failed"
    vocas_stage_finish "$namespace" "$segment" failure "$failure_detail"
    return 1
  fi

  if ! should_reuse_running_emulators; then
    if ! bash "$SCRIPT_DIR/../firebase/start_emulators.sh" >>"$feature_all_log" 2>&1; then
      run_result="failure"
      failure_detail="start_emulators"
      vocas_stage_finish "$namespace" "$segment" failure "$failure_detail"
      return 1
    fi
    started_emulators=1

    if ! bash "$SCRIPT_DIR/../firebase/smoke_local_stack.sh" "${VOCAS_EMULATOR_READY_BUDGET_SECONDS}" >>"$feature_all_log" 2>&1; then
      run_result="failure"
      failure_detail="smoke_local_stack"
      vocas_stage_finish "$namespace" "$segment" failure "$failure_detail"
      return 1
    fi
  fi

  local application cargo_package application_log
  for application in graphql-gateway query-api command-api; do
    application_log="$(vocas_rust_quality_log_file "feature-${application}")"
    cargo_package="$application"
    feature_applications+=("$application")
    printf "## %s\n" "$application" >> "$feature_all_log"
    if ! env VOCAS_FEATURE_REUSE_RUNNING=1 cargo test -p "$cargo_package" --test feature -- --nocapture >"$application_log" 2>&1; then
      cat "$application_log" >> "$feature_all_log"
      run_result="failure"
      current_stage="${segment}:${application}"
      failure_detail="$application"
      vocas_stage_finish "$namespace" "$segment" failure "$application"
      render_summary
      return 1
    fi
    cat "$application_log" >> "$feature_all_log"
  done

  completed_segments+=("$segment")
  current_stage="$segment"
  vocas_stage_finish "$namespace" "$segment" success "graphql-gateway, query-api, command-api"
  render_summary
}

should_reuse_running_emulators() {
  if [[ "${VOCAS_FEATURE_REUSE_RUNNING:-0}" == "1" ]]; then
    return 0
  fi

  if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$VOCAS_EMULATOR_CONTAINER_NAME"; then
    return 0
  fi

  local env_file
  env_file="$(vocas_repo_root)/docker/firebase/env/.env"
  if [[ ! -f "$env_file" ]]; then
    env_file="$(vocas_repo_root)/docker/firebase/env/.env.example"
  fi

  set -a
  source "$env_file"
  set +a

  if [[ -n "${FIREBASE_AUTH_PORT:-}" ]] \
    && [[ -n "${FIREBASE_FIRESTORE_PORT:-}" ]] \
    && [[ -n "${FIREBASE_STORAGE_PORT:-}" ]] \
    && vocas_have_listening_port "${FIREBASE_AUTH_PORT}" \
    && vocas_have_listening_port "${FIREBASE_FIRESTORE_PORT}" \
    && vocas_have_listening_port "${FIREBASE_STORAGE_PORT}"; then
    return 0
  fi

  return 1
}

if [[ "$mode" == "noop" ]]; then
  current_stage="noop"
  vocas_stage_start "$namespace" "noop"
  completed_segments+=("noop")
  vocas_stage_finish "$namespace" "noop" success "rust path not matched"
  printf "%s\n" "completed" > "$stage_file"
  current_stage="completed"
  render_summary
  exit 0
fi

vocas_require_command cargo

if ! run_logged_segment "fmt" cargo fmt --all -- --check; then
  exit 1
fi

if ! run_logged_segment "clippy" cargo clippy --workspace --all-targets -- -D warnings; then
  exit 1
fi

if ! run_logged_segment "unit-query" cargo test -p query-api --test unit; then
  exit 1
fi

if ! run_logged_segment "unit-command" cargo test -p command-api --test unit; then
  exit 1
fi

if ! run_feature_segment; then
  exit 1
fi

printf "%s\n" "completed" > "$stage_file"
current_stage="completed"
run_result="success"
render_summary
