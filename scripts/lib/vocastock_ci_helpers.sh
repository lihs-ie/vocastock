#!/usr/bin/env bash

: "${VOCAS_GHCR_REGISTRY:=ghcr.io}"
: "${VOCAS_FIREBASE_EMULATOR_IMAGE_NAME:=firebase-emulators}"
: "${VOCAS_EMULATOR_CONTAINER_NAME:=vocastock-firebase-emulators}"
: "${VOCAS_EMULATOR_STARTUP_MODE_LOCAL_BUILD:=local-build}"
: "${VOCAS_EMULATOR_STARTUP_MODE_CI_PREPARED_IMAGE:=ci-prepared-image}"
: "${VOCAS_EMULATOR_BASELINE_HASH_LENGTH:=16}"
: "${VOCAS_EMULATOR_PREPARE_NAMESPACE:=emulator-image-prepare}"
: "${VOCAS_EMULATOR_SMOKE_NAMESPACE:=emulator-smoke}"

vocas_now_epoch() {
  date +%s
}

vocas_now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

vocas_sanitize_token() {
  printf "%s" "$1" | tr ' /:' '__-' | tr -cd '[:alnum:]_.-'
}

vocas_ci_artifact_root() {
  printf "%s/.artifacts/ci\n" "$(vocas_repo_root)"
}

vocas_ci_logs_dir() {
  printf "%s/logs\n" "$(vocas_ci_artifact_root)"
}

vocas_ci_images_dir() {
  printf "%s/images\n" "$(vocas_ci_artifact_root)"
}

vocas_firebase_logs_dir() {
  printf "%s/.artifacts/firebase/logs\n" "$(vocas_repo_root)"
}

vocas_ensure_ci_artifact_directories() {
  local root
  root="$(vocas_repo_root)"
  mkdir -p \
    "$root/.artifacts/ci/images" \
    "$root/.artifacts/ci/durations/stages" \
    "$root/.artifacts/ci/logs" \
    "$root/.artifacts/firebase/logs"
}

vocas_stage_duration_file() {
  local namespace="$1"
  local stage="$2"
  printf "%s/.artifacts/ci/durations/stages/%s.%s.seconds\n" \
    "$(vocas_repo_root)" \
    "$(vocas_sanitize_token "$namespace")" \
    "$(vocas_sanitize_token "$stage")"
}

vocas_stage_report_file() {
  local namespace="$1"
  printf "%s/%s.stages.tsv\n" "$(vocas_ci_logs_dir)" "$(vocas_sanitize_token "$namespace")"
}

vocas_stage_state_file() {
  local namespace="$1"
  local stage="$2"
  printf "%s/%s.%s.state\n" \
    "$(vocas_ci_logs_dir)" \
    "$(vocas_sanitize_token "$namespace")" \
    "$(vocas_sanitize_token "$stage")"
}

vocas_stage_start() {
  local namespace="$1"
  local stage="$2"
  local details="${3:-}"
  local state_file report_file started_epoch started_at
  vocas_ensure_artifact_directories
  vocas_ensure_ci_artifact_directories
  state_file="$(vocas_stage_state_file "$namespace" "$stage")"
  report_file="$(vocas_stage_report_file "$namespace")"
  started_epoch="$(vocas_now_epoch)"
  started_at="$(vocas_now_iso)"
  printf "%s|%s\n" "$started_epoch" "$started_at" > "$state_file"
  if [[ ! -f "$report_file" ]]; then
    printf "stage\tstartedAt\tcompletedAt\tdurationSeconds\tresult\tdetails\n" > "$report_file"
  fi
  vocas_log "${namespace}:${stage}: started${details:+ - ${details}}"
}

vocas_stage_finish() {
  local namespace="$1"
  local stage="$2"
  local result="$3"
  local details="${4:-}"
  local state_file report_file started_epoch started_at completed_epoch completed_at duration sanitized_details
  vocas_ensure_artifact_directories
  vocas_ensure_ci_artifact_directories
  state_file="$(vocas_stage_state_file "$namespace" "$stage")"
  report_file="$(vocas_stage_report_file "$namespace")"
  completed_epoch="$(vocas_now_epoch)"
  completed_at="$(vocas_now_iso)"

  if [[ -f "$state_file" ]]; then
    IFS='|' read -r started_epoch started_at < "$state_file"
  else
    started_epoch="$completed_epoch"
    started_at="$completed_at"
  fi

  duration="$((completed_epoch - started_epoch))"
  sanitized_details="${details//$'\n'/ }"
  sanitized_details="${sanitized_details//$'\t'/ }"
  if [[ ! -f "$report_file" ]]; then
    printf "stage\tstartedAt\tcompletedAt\tdurationSeconds\tresult\tdetails\n" > "$report_file"
  fi
  printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
    "$stage" \
    "$started_at" \
    "$completed_at" \
    "$duration" \
    "$result" \
    "$sanitized_details" >> "$report_file"
  printf "%s\n" "$duration" > "$(vocas_stage_duration_file "$namespace" "$stage")"
  rm -f "$state_file"
  vocas_log "${namespace}:${stage}: ${result}${details:+ - ${details}}"
}

vocas_emulator_compose_file() {
  printf "%s/docker/firebase/compose.yaml\n" "$(vocas_repo_root)"
}

vocas_emulator_env_file() {
  local env_file
  env_file="$(vocas_repo_root)/docker/firebase/env/.env"
  if [[ ! -f "$env_file" ]]; then
    env_file="$(vocas_repo_root)/docker/firebase/env/.env.example"
  fi
  printf "%s\n" "$env_file"
}

vocas_default_repo_slug() {
  if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
    printf "%s\n" "$(printf "%s" "$GITHUB_REPOSITORY" | tr '[:upper:]' '[:lower:]')"
    return 0
  fi

  printf "local/%s\n" "$(basename "$(vocas_repo_root)")"
}

vocas_emulator_baseline_inputs() {
  local root
  root="$(vocas_repo_root)"
  printf "%s\n" \
    "$root/docker/firebase/Dockerfile" \
    "$root/docker/firebase/compose.yaml" \
    "$root/firebase.json" \
    "$root/scripts/lib/vocastock_env.sh"
}

vocas_emulator_baseline_hash() {
  local hash_length
  hash_length="${1:-$VOCAS_EMULATOR_BASELINE_HASH_LENGTH}"
  {
    printf "NODE_VERSION=%s\n" "$VOCAS_APPROVED_NODE_VERSION"
    printf "FIREBASE_TOOLS_VERSION=%s\n" "$VOCAS_APPROVED_FIREBASE_TOOLS_VERSION"
    printf "TEMURIN_VERSION=%s\n" "$VOCAS_APPROVED_TEMURIN_VERSION"
    printf "EMULATOR_READY_BUDGET=%s\n" "$VOCAS_EMULATOR_READY_BUDGET_SECONDS"
    while IFS= read -r input_file; do
      printf "FILE=%s\n" "${input_file#$(vocas_repo_root)/}"
      shasum -a 256 "$input_file"
    done < <(vocas_emulator_baseline_inputs)
  } | shasum -a 256 | awk -v len="$hash_length" '{print substr($1, 1, len)}'
}

vocas_local_emulator_image_reference() {
  local baseline_hash="${1:-local}"
  printf "vocas-local/%s:%s\n" "$VOCAS_FIREBASE_EMULATOR_IMAGE_NAME" "$baseline_hash"
}

vocas_emulator_image_reference() {
  local baseline_hash="${1:-$(vocas_emulator_baseline_hash)}"
  printf "%s/%s/%s:%s\n" \
    "$VOCAS_GHCR_REGISTRY" \
    "$(vocas_default_repo_slug)" \
    "$VOCAS_FIREBASE_EMULATOR_IMAGE_NAME" \
    "$baseline_hash"
}

vocas_emulator_image_artifact_name() {
  local baseline_hash="${1:-$(vocas_emulator_baseline_hash)}"
  printf "%s-%s\n" "$VOCAS_FIREBASE_EMULATOR_IMAGE_NAME" "$baseline_hash"
}

vocas_emulator_image_artifact_file() {
  local baseline_hash="${1:-$(vocas_emulator_baseline_hash)}"
  printf "%s.tar\n" "$(vocas_emulator_image_artifact_name "$baseline_hash")"
}

vocas_emulator_image_artifact_path() {
  local baseline_hash="${1:-$(vocas_emulator_baseline_hash)}"
  printf "%s/%s\n" "$(vocas_ci_images_dir)" "$(vocas_emulator_image_artifact_file "$baseline_hash")"
}

vocas_capture_compose_snapshot() {
  local namespace="${1:-compose}"
  local suffix="${2:-snapshot}"
  local output_file env_file
  vocas_ensure_artifact_directories
  vocas_ensure_ci_artifact_directories
  output_file="$(vocas_ci_logs_dir)/$(vocas_sanitize_token "$namespace").$(vocas_sanitize_token "$suffix").compose-ps.txt"
  env_file="$(vocas_emulator_env_file)"
  docker compose \
    --env-file "$env_file" \
    -f "$(vocas_emulator_compose_file)" \
    ps > "$output_file" 2>&1 || true
}

vocas_capture_container_log_tail() {
  local namespace="${1:-container}"
  local suffix="${2:-tail}"
  local lines="${3:-200}"
  local output_file
  vocas_ensure_artifact_directories
  vocas_ensure_ci_artifact_directories
  output_file="$(vocas_ci_logs_dir)/$(vocas_sanitize_token "$namespace").$(vocas_sanitize_token "$suffix").container-tail.log"
  docker logs --tail "$lines" "$VOCAS_EMULATOR_CONTAINER_NAME" > "$output_file" 2>&1 || true
}
