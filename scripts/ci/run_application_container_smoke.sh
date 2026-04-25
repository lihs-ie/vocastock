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

# Backend services (query-api / command-api) now require the production
# Firestore + PubSub adapters to be wired — there is no in-memory
# fallback in the release binary. Launch the Firebase emulator stack +
# seed fixtures here so the compose containers have real adapter
# dependencies to talk to, then expose the emulator host ports via env
# so the smoke env file inherits them.
firebase_env_file="$(vocas_repo_root)/docker/firebase/env/.env"
if [[ ! -f "$firebase_env_file" ]]; then
  firebase_env_file="$(vocas_repo_root)/docker/firebase/env/.env.example"
fi
# shellcheck disable=SC1090
set -a
source "$firebase_env_file"
set +a

export VOCAS_PRODUCTION_ADAPTERS=true
export FIRESTORE_EMULATOR_HOST="host.docker.internal:${FIREBASE_FIRESTORE_PORT}"
export STORAGE_EMULATOR_HOST="host.docker.internal:${FIREBASE_STORAGE_PORT}"
export FIREBASE_AUTH_EMULATOR_HOST="host.docker.internal:${FIREBASE_AUTH_PORT}"
export PUBSUB_EMULATOR_HOST="host.docker.internal:${FIREBASE_PUBSUB_PORT}"
# Workers require their external-API credentials at startup (the real
# API calls are only made when a PubSub message arrives; during smoke
# the queue stays empty, so sentinel values are sufficient to pass the
# startup validation and let the pull loop idle).
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-sk-ant-smoke-placeholder}"
export STABILITY_API_KEY="${STABILITY_API_KEY:-sk-stability-smoke-placeholder}"
export STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:-sk_test_smoke_placeholder}"

env_file="$(vocas_prepare_application_smoke_env_file "$base_env_file")"
# vocas_prepare_application_smoke_env_file appends FIRESTORE/STORAGE/AUTH/PUBSUB
# entries only when the corresponding host env vars are non-empty, so the
# exports above make them land in $env_file.
printf "VOCAS_PRODUCTION_ADAPTERS=%s\n" "$VOCAS_PRODUCTION_ADAPTERS" >> "$env_file"
printf "ANTHROPIC_API_KEY=%s\n" "$ANTHROPIC_API_KEY" >> "$env_file"
printf "STABILITY_API_KEY=%s\n" "$STABILITY_API_KEY" >> "$env_file"
printf "STRIPE_SECRET_KEY=%s\n" "$STRIPE_SECRET_KEY" >> "$env_file"

vocas_load_env_file "$env_file"

docker info >/dev/null
docker compose --env-file "$env_file" -f "$compose_file" config >/dev/null

failure_stage="firebase-emulators-start"
bash "$SCRIPT_DIR/../firebase/start_emulators.sh"
bash "$SCRIPT_DIR/../firebase/smoke_local_stack.sh" "${VOCAS_EMULATOR_READY_BUDGET_SECONDS:-300}"
# seed runs in host node(1) and talks to 127.0.0.1:{port}; the
# `host.docker.internal` values above are only valid from within the
# compose containers. Unset them for the seed subshell so firebase-admin
# resolves to localhost.
(
  unset FIRESTORE_EMULATOR_HOST STORAGE_EMULATOR_HOST \
    FIREBASE_AUTH_EMULATOR_HOST PUBSUB_EMULATOR_HOST \
    FIREBASE_STORAGE_EMULATOR_HOST
  bash "$SCRIPT_DIR/../firebase/seed_emulators.sh"
)

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
    bash "$SCRIPT_DIR/../firebase/stop_emulators.sh" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

if (( reuse_running == 0 )); then
  if (( skip_build == 0 )); then
    # Pre-build Haskell worker images via explicit `docker buildx build`
    # so the GHA cache backend actually receives the cache_to flag.
    # `docker compose --build` silently drops cache_from/cache_to with
    # the docker-container builder set up by setup-buildx-action; see
    # scripts/ci/build_haskell_worker_images.sh for the working pattern.
    bash "$SCRIPT_DIR/build_haskell_worker_images.sh"
  fi

  up_args=(--env-file "$env_file" -f "$compose_file" up -d)
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

elapsed="$(( $(date +%s) - start_epoch ))"
vocas_write_duration "application-container-smoke" "$elapsed"
vocas_print_budget_summary "application-container-smoke" "$elapsed" "$ready_budget"
failure_stage="completed"
