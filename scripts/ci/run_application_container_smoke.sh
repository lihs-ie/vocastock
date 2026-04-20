#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command docker
vocas_require_command curl
vocas_ensure_artifact_directories

reuse_running=0
skip_build=0
failure_stage="compose-config"
summary_file="$(vocas_application_smoke_summary_file)"
stage_file="$(vocas_repo_root)/.artifacts/ci/logs/application-container-smoke.stage"

for arg in "$@"; do
  case "$arg" in
    --reuse-running)
      reuse_running=1
      ;;
    --skip-build)
      skip_build=1
      ;;
    *)
      vocas_die "unsupported argument: $arg"
      ;;
  esac
done

compose_file="$(vocas_application_compose_file)"
base_env_file="$(vocas_prepare_application_env_file)"
env_file="$(vocas_prepare_application_smoke_env_file "$base_env_file")"
vocas_load_env_file "$env_file"

docker info >/dev/null
docker compose --env-file "$env_file" -f "$compose_file" config >/dev/null

services=()
while IFS= read -r service_name; do
  services+=("$service_name")
done < <(vocas_application_service_names)

{
  printf "services=%s\n" "${services[*]}"
  printf "ready_budget=%s\n" "${VOCAS_APPLICATION_READY_BUDGET_SECONDS:-$VOCAS_APPLICATION_READY_BUDGET_SECONDS}"
  printf "worker_stable_run=%s\n" "${VOCAS_WORKER_STABLE_RUN_SECONDS:-$VOCAS_APPLICATION_WORKER_STABLE_RUN_SECONDS}"
  printf "graphql_gateway_port=%s\n" "${GRAPHQL_GATEWAY_PORT:-$VOCAS_DEFAULT_GRAPHQL_GATEWAY_PORT}"
  printf "command_api_port=%s\n" "${COMMAND_API_PORT:-$VOCAS_DEFAULT_COMMAND_API_PORT}"
  printf "query_api_port=%s\n" "${QUERY_API_PORT:-$VOCAS_DEFAULT_QUERY_API_PORT}"
} > "$summary_file"

cleanup() {
  printf "%s\n" "$failure_stage" > "$stage_file"
  if (( reuse_running == 0 )); then
    docker compose --env-file "$env_file" -f "$compose_file" down >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

if (( reuse_running == 0 )); then
  up_args=(--env-file "$env_file" -f "$compose_file" up -d)
  if (( skip_build == 0 )); then
    up_args+=(--build)
  fi
  up_args+=("${services[@]}")

  vocas_log "starting application container smoke for services: ${services[*]}"
  failure_stage="compose-up"
  docker compose "${up_args[@]}"
fi

start_epoch="$(date +%s)"
ready_budget="${VOCAS_APPLICATION_READY_BUDGET_SECONDS:-$VOCAS_APPLICATION_READY_BUDGET_SECONDS}"
failure_stage="api-readiness"

while IFS= read -r api_service; do
  readiness_url="$(vocas_application_readiness_url "$api_service")"
  printf "api_readiness.%s=%s\n" "$api_service" "$readiness_url" >> "$summary_file"
  while ! curl -fsS "$readiness_url" >/dev/null 2>&1; do
    now_epoch="$(date +%s)"
    if (( now_epoch - start_epoch >= ready_budget )); then
      vocas_die "application readiness smoke timed out while waiting for ${api_service} at ${readiness_url}"
    fi
    sleep 2
  done
done < <(vocas_application_api_services)

if [[ -n "${FIRESTORE_EMULATOR_HOST:-}" || -n "${STORAGE_EMULATOR_HOST:-}" || -n "${FIREBASE_AUTH_EMULATOR_HOST:-}" || -n "${PUBSUB_EMULATOR_HOST:-}" ]]; then
  failure_stage="firebase-dependency"

  while IFS= read -r api_service; do
    dependency_url="$(vocas_application_firebase_dependency_url "$api_service")"
    printf "firebase_dependency.%s=%s\n" "$api_service" "$dependency_url" >> "$summary_file"
    if ! curl -fsS "$dependency_url" >/dev/null 2>&1; then
      vocas_die "firebase dependency probe failed for ${api_service} at ${dependency_url}"
    fi
  done < <(vocas_application_api_services)
fi

failure_stage="worker-stable-run"
sleep "${VOCAS_WORKER_STABLE_RUN_SECONDS:-$VOCAS_APPLICATION_WORKER_STABLE_RUN_SECONDS}"
running_services="$(docker compose --env-file "$env_file" -f "$compose_file" ps --services --status running)"

while IFS= read -r worker_service; do
  if ! printf "%s\n" "$running_services" | grep -qx "$worker_service"; then
    vocas_die "worker is not stably running: ${worker_service}"
  fi
done < <(vocas_application_worker_services)

failure_stage="explanation-worker-validation"
while IFS= read -r validation_scenario; do
  validation_log="$(vocas_repo_root)/.artifacts/ci/logs/explanation-worker-validation.${validation_scenario}.log"
  if ! docker compose \
    --env-file "$env_file" \
    -f "$compose_file" \
    run \
    --rm \
    --no-deps \
    -e VOCAS_WORKER_RUN_MODE=validate \
    -e VOCAS_EXPLANATION_WORKFLOW_SCENARIO="$validation_scenario" \
    explanation-worker >"$validation_log" 2>&1 </dev/null; then
    cat "$validation_log" >&2 || true
    vocas_die "explanation-worker validation failed for scenario ${validation_scenario}"
  fi

  validation_line="$(grep '^VOCAS_EXPLANATION_RESULT ' "$validation_log" | tail -n 1 || true)"
  [[ -n "$validation_line" ]] || vocas_die "missing explanation-worker validation result for ${validation_scenario}"

  case "$validation_scenario" in
    success)
      printf "%s\n" "$validation_line" | grep -q 'final_state=succeeded' \
        || vocas_die "success validation did not reach succeeded"
      ;;
    retryable-failure)
      printf "%s\n" "$validation_line" | grep -q 'final_state=retry-scheduled-1' \
        || vocas_die "retryable validation did not reach retry-scheduled"
      ;;
    terminal-failure)
      printf "%s\n" "$validation_line" | grep -q 'final_state=failed-final' \
        || vocas_die "terminal validation did not reach failed-final"
      ;;
    *)
      vocas_die "unsupported explanation-worker validation scenario: ${validation_scenario}"
      ;;
  esac

  printf "explanation_worker_validation.%s=%s\n" "$validation_scenario" "$validation_line" >> "$summary_file"
done < <(vocas_explanation_worker_validation_scenarios)

failure_stage="image-worker-validation"
while IFS= read -r validation_scenario; do
  validation_log="$(vocas_repo_root)/.artifacts/ci/logs/image-worker-validation.${validation_scenario}.log"
  if ! docker compose \
    --env-file "$env_file" \
    -f "$compose_file" \
    run \
    --rm \
    --no-deps \
    -e VOCAS_WORKER_RUN_MODE=validate \
    -e VOCAS_IMAGE_WORKFLOW_SCENARIO="$validation_scenario" \
    image-worker >"$validation_log" 2>&1 </dev/null; then
    cat "$validation_log" >&2 || true
    vocas_die "image-worker validation failed for scenario ${validation_scenario}"
  fi

  validation_line="$(grep '^VOCAS_IMAGE_RESULT ' "$validation_log" | tail -n 1 || true)"
  [[ -n "$validation_line" ]] || vocas_die "missing image-worker validation result for ${validation_scenario}"

  case "$validation_scenario" in
    success)
      printf "%s\n" "$validation_line" | grep -q 'final_state=succeeded' \
        || vocas_die "image success validation did not reach succeeded"
      ;;
    retryable-failure)
      printf "%s\n" "$validation_line" | grep -q 'final_state=retry-scheduled-1' \
        || vocas_die "image retryable validation did not reach retry-scheduled"
      ;;
    terminal-failure)
      printf "%s\n" "$validation_line" | grep -q 'final_state=failed-final' \
        || vocas_die "image terminal validation did not reach failed-final"
      ;;
    *)
      vocas_die "unsupported image-worker validation scenario: ${validation_scenario}"
      ;;
  esac

  printf "image_worker_validation.%s=%s\n" "$validation_scenario" "$validation_line" >> "$summary_file"
done < <(vocas_image_worker_validation_scenarios)

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "application-container-smoke" "$elapsed"
vocas_print_budget_summary "application-container-smoke" "$elapsed" "$ready_budget"
failure_stage="completed"
