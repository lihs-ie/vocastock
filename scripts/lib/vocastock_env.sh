#!/usr/bin/env bash

VOCAS_APPROVED_MACOS_VERSION="26.4.1"
VOCAS_APPROVED_FLUTTER_VERSION="3.41.5"
VOCAS_APPROVED_XCODE_VERSION="26.4"
VOCAS_APPROVED_ANDROID_STUDIO_VERSION="2025.3"
VOCAS_APPROVED_ANDROID_STUDIO_LABEL="2025.3"
VOCAS_APPROVED_COCOAPODS_VERSION="1.16.2"
VOCAS_APPROVED_DOCKER_DESKTOP_VERSION="4.69.0"
VOCAS_APPROVED_NODE_VERSION="24.14.1"
VOCAS_APPROVED_FIREBASE_TOOLS_VERSION="15.2.1"
VOCAS_APPROVED_TEMURIN_VERSION="21.0.10+7"
VOCAS_APPROVED_TRIVY_CLI_VERSION="0.68.2"
VOCAS_APPROVED_LINUX_RUNNER_CLASS="ubuntu-24.04"
VOCAS_APPROVED_APPLE_RUNNER_CLASS="macos-15"
VOCAS_GHCR_REGISTRY="ghcr.io"
VOCAS_FIREBASE_EMULATOR_IMAGE_NAME="firebase-emulators"
VOCAS_EMULATOR_CONTAINER_NAME="vocastock-firebase-emulators"
VOCAS_EMULATOR_STARTUP_MODE_LOCAL_BUILD="local-build"
VOCAS_EMULATOR_STARTUP_MODE_CI_PREPARED_IMAGE="ci-prepared-image"
VOCAS_EMULATOR_BASELINE_HASH_LENGTH="16"
VOCAS_EMULATOR_PREPARE_NAMESPACE="emulator-image-prepare"
VOCAS_EMULATOR_SMOKE_NAMESPACE="emulator-smoke"

VOCAS_FIREBASE_PROJECT="demo-vocastock"
VOCAS_FIREBASE_EMULATOR_SERVICES="auth,firestore,storage,hosting,ui"
VOCAS_LOCAL_SETUP_BUDGET_SECONDS="3600"
VOCAS_EMULATOR_READY_BUDGET_SECONDS="300"
VOCAS_CI_RUNTIME_BUDGET_SECONDS="1800"
VOCAS_APPLICATION_READY_BUDGET_SECONDS="120"
VOCAS_APPLICATION_WORKER_STABLE_RUN_SECONDS="10"
VOCAS_APPLICATION_WORKER_POLL_INTERVAL_SECONDS="30"
VOCAS_RUST_QUALITY_NAMESPACE="rust-quality"
VOCAS_RUST_QUALITY_BUDGET_SECONDS="1800"
VOCAS_DEFAULT_GRAPHQL_GATEWAY_PORT="18180"
VOCAS_DEFAULT_COMMAND_API_PORT="18181"
VOCAS_DEFAULT_QUERY_API_PORT="18182"
VOCAS_FIREBASE_DEPENDENCY_PATH="/dependencies/firebase"

vocas_repo_root() {
  local script_dir
  script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  printf "%s\n" "$script_dir"
}

vocas_log() {
  printf "[vocastock] %s\n" "$*"
}

vocas_warn() {
  printf "[vocastock] warning: %s\n" "$*" >&2
}

vocas_die() {
  printf "[vocastock] error: %s\n" "$*" >&2
  exit 1
}

vocas_have_command() {
  command -v "$1" >/dev/null 2>&1
}

vocas_resolve_flutter_bin() {
  if vocas_have_command flutter; then
    command -v flutter
    return 0
  fi

  if [[ -x "${HOME}/flutter/bin/flutter" ]]; then
    printf "%s/flutter/bin/flutter\n" "$HOME"
    return 0
  fi

  return 1
}

vocas_require_command() {
  local command_name="$1"
  vocas_have_command "$command_name" || vocas_die "required command not found: $command_name"
}

vocas_require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || vocas_die "this command supports macOS only"
}

vocas_ensure_artifact_directories() {
  local root
  root="$(vocas_repo_root)"
  mkdir -p \
    "$root/.artifacts/ci/durations" \
    "$root/.artifacts/ci/logs" \
    "$root/.artifacts/firebase/export" \
    "$root/.artifacts/firebase/import" \
    "$root/.artifacts/firebase/logs"
}

vocas_find_flutter_project_dir() {
  local root manifest
  root="$(vocas_repo_root)"
  while IFS= read -r manifest; do
    dirname "$manifest"
    return 0
  done < <(
    find "$root" \
      -path "$root/.git" -prune -o \
      -path "$root/.specify" -prune -o \
      -path "$root/specs" -prune -o \
      -path "$root/references" -prune -o \
      -name pubspec.yaml -print
  )
  return 1
}

vocas_duration_file() {
  local name="$1"
  printf "%s/.artifacts/ci/durations/%s.seconds\n" "$(vocas_repo_root)" "$name"
}

vocas_rust_quality_summary_file() {
  printf "%s/.artifacts/ci/logs/%s.summary.md\n" \
    "$(vocas_repo_root)" \
    "$VOCAS_RUST_QUALITY_NAMESPACE"
}

vocas_rust_quality_stage_file() {
  printf "%s/.artifacts/ci/logs/%s.stage\n" \
    "$(vocas_repo_root)" \
    "$VOCAS_RUST_QUALITY_NAMESPACE"
}

vocas_rust_quality_log_file() {
  local segment="$1"
  printf "%s/.artifacts/ci/logs/%s.%s.log\n" \
    "$(vocas_repo_root)" \
    "$VOCAS_RUST_QUALITY_NAMESPACE" \
    "$segment"
}

vocas_rust_quality_detected_paths_file() {
  printf "%s/.artifacts/ci/logs/%s.detected-paths.txt\n" \
    "$(vocas_repo_root)" \
    "$VOCAS_RUST_QUALITY_NAMESPACE"
}

vocas_toolchain_root() {
  printf "%s/.artifacts/toolchains\n" "$(vocas_repo_root)"
}

vocas_npm_global_prefix() {
  printf "%s/npm-global\n" "$(vocas_toolchain_root)"
}

vocas_npm_global_bin() {
  printf "%s/bin\n" "$(vocas_npm_global_prefix)"
}

vocas_local_host_baseline() {
  printf "macOS %s / Flutter %s / Xcode %s / Android Studio %s / CocoaPods %s / Docker Desktop %s\n" \
    "$VOCAS_APPROVED_MACOS_VERSION" \
    "$VOCAS_APPROVED_FLUTTER_VERSION" \
    "$VOCAS_APPROVED_XCODE_VERSION" \
    "$VOCAS_APPROVED_ANDROID_STUDIO_VERSION" \
    "$VOCAS_APPROVED_COCOAPODS_VERSION" \
    "$VOCAS_APPROVED_DOCKER_DESKTOP_VERSION"
}

vocas_load_local_env() {
  local env_file
  env_file="$(vocas_repo_root)/docker/firebase/env/.env"
  if [[ ! -f "$env_file" ]]; then
    env_file="$(vocas_repo_root)/docker/firebase/env/.env.example"
  fi
  set -a
  source "$env_file"
  set +a
}

vocas_load_env_file() {
  local env_file="$1"
  set -a
  source "$env_file"
  set +a
}

vocas_application_compose_file() {
  printf "%s/docker/applications/compose.yaml\n" "$(vocas_repo_root)"
}

vocas_application_env_template() {
  printf "%s/docker/applications/env/.env.example\n" "$(vocas_repo_root)"
}

vocas_application_env_file() {
  printf "%s/docker/applications/env/.env\n" "$(vocas_repo_root)"
}

vocas_application_service_names() {
  printf "%s\n" \
    "graphql-gateway" \
    "command-api" \
    "query-api" \
    "explanation-worker" \
    "image-worker" \
    "billing-worker"
}

vocas_application_api_services() {
  printf "%s\n" \
    "graphql-gateway" \
    "command-api" \
    "query-api"
}

vocas_application_worker_services() {
  printf "%s\n" \
    "explanation-worker" \
    "image-worker" \
    "billing-worker"
}

vocas_prepare_application_env_file() {
  local template env_file
  template="$(vocas_application_env_template)"
  env_file="$(vocas_application_env_file)"

  if [[ ! -f "$env_file" ]]; then
    cp "$template" "$env_file"
    vocas_log "created docker/applications/env/.env from example" >&2
  fi

  printf "%s\n" "$env_file"
}

vocas_load_application_env() {
  local env_file
  env_file="$(vocas_prepare_application_env_file)"
  vocas_load_env_file "$env_file"
}

vocas_have_listening_port() {
  local port="$1"

  if ! vocas_have_command lsof; then
    return 1
  fi

  lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1
}

vocas_next_available_port() {
  local port="$1"

  while vocas_have_listening_port "$port"; do
    port="$((port + 1))"
  done

  printf "%s\n" "$port"
}

vocas_application_smoke_env_file() {
  printf "%s/.artifacts/ci/logs/application-container-smoke.env\n" "$(vocas_repo_root)"
}

vocas_prepare_application_smoke_env_file() {
  local base_env_file="$1"
  local smoke_env_file gateway_port command_port query_port
  local firestore_override storage_override auth_override pubsub_override

  firestore_override="${FIRESTORE_EMULATOR_HOST:-}"
  storage_override="${STORAGE_EMULATOR_HOST:-}"
  auth_override="${FIREBASE_AUTH_EMULATOR_HOST:-}"
  pubsub_override="${PUBSUB_EMULATOR_HOST:-}"

  smoke_env_file="$(vocas_application_smoke_env_file)"
  cp "$base_env_file" "$smoke_env_file"

  vocas_load_env_file "$base_env_file"

  gateway_port="$(vocas_next_available_port "${GRAPHQL_GATEWAY_PORT:-$VOCAS_DEFAULT_GRAPHQL_GATEWAY_PORT}")"
  command_port="$(vocas_next_available_port "${COMMAND_API_PORT:-$VOCAS_DEFAULT_COMMAND_API_PORT}")"
  while [[ "$command_port" == "$gateway_port" ]]; do
    command_port="$(vocas_next_available_port "$((command_port + 1))")"
  done

  query_port="$(vocas_next_available_port "${QUERY_API_PORT:-$VOCAS_DEFAULT_QUERY_API_PORT}")"
  while [[ "$query_port" == "$gateway_port" || "$query_port" == "$command_port" ]]; do
    query_port="$(vocas_next_available_port "$((query_port + 1))")"
  done

  cat >> "$smoke_env_file" <<EOF
GRAPHQL_GATEWAY_PORT=$gateway_port
COMMAND_API_PORT=$command_port
QUERY_API_PORT=$query_port
VOCAS_COMMAND_UPSTREAM_BASE_URL=http://command-api:$command_port
VOCAS_QUERY_UPSTREAM_BASE_URL=http://query-api:$query_port
EOF

  if [[ -n "$firestore_override" ]]; then
    printf "FIRESTORE_EMULATOR_HOST=%s\n" "$firestore_override" >> "$smoke_env_file"
  fi
  if [[ -n "$storage_override" ]]; then
    printf "STORAGE_EMULATOR_HOST=%s\n" "$storage_override" >> "$smoke_env_file"
  fi
  if [[ -n "$auth_override" ]]; then
    printf "FIREBASE_AUTH_EMULATOR_HOST=%s\n" "$auth_override" >> "$smoke_env_file"
  fi
  if [[ -n "$pubsub_override" ]]; then
    printf "PUBSUB_EMULATOR_HOST=%s\n" "$pubsub_override" >> "$smoke_env_file"
  fi

  if [[ "${GRAPHQL_GATEWAY_PORT:-$VOCAS_DEFAULT_GRAPHQL_GATEWAY_PORT}" != "$gateway_port" || "${COMMAND_API_PORT:-$VOCAS_DEFAULT_COMMAND_API_PORT}" != "$command_port" || "${QUERY_API_PORT:-$VOCAS_DEFAULT_QUERY_API_PORT}" != "$query_port" ]]; then
    vocas_warn "application smoke adjusted host ports to avoid local conflicts: gateway=${gateway_port} command=${command_port} query=${query_port}"
  fi

  printf "%s\n" "$smoke_env_file"
}

vocas_application_port_for() {
  local service_name="$1"

  case "$service_name" in
    graphql-gateway)
      printf "%s\n" "${GRAPHQL_GATEWAY_PORT:-$VOCAS_DEFAULT_GRAPHQL_GATEWAY_PORT}"
      ;;
    command-api)
      printf "%s\n" "${COMMAND_API_PORT:-$VOCAS_DEFAULT_COMMAND_API_PORT}"
      ;;
    query-api)
      printf "%s\n" "${QUERY_API_PORT:-$VOCAS_DEFAULT_QUERY_API_PORT}"
      ;;
    *)
      vocas_die "unknown API service: $service_name"
      ;;
  esac
}

vocas_application_readiness_url() {
  local service_name="$1"
  local readiness_path="${VOCAS_READINESS_PATH:-/readyz}"
  printf "http://127.0.0.1:%s%s\n" \
    "$(vocas_application_port_for "$service_name")" \
    "$readiness_path"
}

vocas_application_firebase_dependency_url() {
  local service_name="$1"
  printf "http://127.0.0.1:%s%s\n" \
    "$(vocas_application_port_for "$service_name")" \
    "${VOCAS_FIREBASE_DEPENDENCY_PATH}"
}

vocas_pubsub_fallback_fixture() {
  printf "%s/tooling/fallback/pubsub/message-envelope.example.json\n" "$(vocas_repo_root)"
}

vocas_drive_fallback_fixture() {
  printf "%s/tooling/fallback/drive/asset-reference.example.json\n" "$(vocas_repo_root)"
}

vocas_prepend_path() {
  local path_entry="$1"
  case ":${PATH}:" in
    *":${path_entry}:"*) ;;
    *)
      export PATH="${path_entry}:$PATH"
      ;;
  esac
}

vocas_enable_workspace_npm_global() {
  local npm_prefix
  npm_prefix="$(vocas_npm_global_prefix)"
  mkdir -p "$npm_prefix"
  export npm_config_prefix="$npm_prefix"
  vocas_prepend_path "$(vocas_npm_global_bin)"

  if [[ -n "${GITHUB_ENV:-}" ]]; then
    {
      printf "npm_config_prefix=%s\n" "$npm_prefix"
      printf "PATH=%s:%s\n" "$(vocas_npm_global_bin)" "$PATH"
    } >> "$GITHUB_ENV"
  fi
}

vocas_write_duration() {
  local name="$1"
  local seconds="$2"
  vocas_ensure_artifact_directories
  printf "%s\n" "$seconds" > "$(vocas_duration_file "$name")"
}

vocas_print_budget_summary() {
  local label="$1"
  local elapsed="$2"
  local budget="$3"

  if (( elapsed <= budget )); then
    vocas_log "$label completed in ${elapsed}s (budget ${budget}s)"
  else
    vocas_warn "$label exceeded budget: ${elapsed}s > ${budget}s"
  fi
}
