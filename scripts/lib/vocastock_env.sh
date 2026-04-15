#!/usr/bin/env bash

VOCAS_APPROVED_FLUTTER_VERSION="3.41.5"
VOCAS_APPROVED_XCODE_VERSION="26.3"
VOCAS_APPROVED_ANDROID_STUDIO_VERSION="2025.3.2"
VOCAS_APPROVED_ANDROID_STUDIO_LABEL="Panda 2 (2025.3.2)"
VOCAS_APPROVED_COCOAPODS_VERSION="1.16.2"
VOCAS_APPROVED_DOCKER_DESKTOP_VERSION="4.60.1"
VOCAS_APPROVED_NODE_VERSION="24.14.1"
VOCAS_APPROVED_FIREBASE_TOOLS_VERSION="15.2.1"
VOCAS_APPROVED_TEMURIN_VERSION="21.0.10+7"
VOCAS_APPROVED_TRIVY_CLI_VERSION="0.68.2"

VOCAS_FIREBASE_PROJECT="demo-vocastock"
VOCAS_FIREBASE_EMULATOR_SERVICES="auth,firestore,storage,hosting,ui"
VOCAS_LOCAL_SETUP_BUDGET_SECONDS="3600"
VOCAS_EMULATOR_READY_BUDGET_SECONDS="300"
VOCAS_CI_RUNTIME_BUDGET_SECONDS="1800"

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

vocas_toolchain_root() {
  printf "%s/.artifacts/toolchains\n" "$(vocas_repo_root)"
}

vocas_npm_global_prefix() {
  printf "%s/npm-global\n" "$(vocas_toolchain_root)"
}

vocas_npm_global_bin() {
  printf "%s/bin\n" "$(vocas_npm_global_prefix)"
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
