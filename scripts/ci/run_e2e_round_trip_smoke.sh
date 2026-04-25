#!/usr/bin/env bash
# E2E round-trip smoke test covering:
#   command accept -> Pub/Sub dispatch -> worker consume -> Firestore write -> query-api read
#
# Runs the full 6-service compose stack plus the Firebase emulator, sends a
# `registerVocabularyExpression` mutation through graphql-gateway, waits for
# the explanation-worker to process the dispatch and update Firestore, then
# asserts the final completed state via query-api.
#
# See `specs/025-e2e-round-trip-smoke/` for the full contract.

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command docker
vocas_require_command curl
vocas_require_command node
vocas_require_command python3
vocas_ensure_artifact_directories

reuse_running=0
skip_build=0
failure_stage="init"

summary_file="$(vocas_e2e_round_trip_summary_file)"
stage_file="$(vocas_e2e_round_trip_stage_file)"
compose_logs_file="$(vocas_e2e_round_trip_compose_logs_file)"
firestore_snapshot_file="$(vocas_e2e_round_trip_firestore_snapshot_file)"
pubsub_state_file="$(vocas_e2e_round_trip_pubsub_state_file)"
stub_access_log_file="$(vocas_e2e_round_trip_stub_access_log_file)"
stub_server_log_file="$(vocas_e2e_round_trip_stub_server_log_file)"

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

epoch_suffix="$(date +%s)"
vocab_slug="smoke-round-trip-${epoch_suffix}"
vocab_text="smoke round trip ${epoch_suffix}"
vocab_identifier="vocabulary:${vocab_slug}"
idempotency_key="e2e-smoke-${epoch_suffix}-$$"
actor_uid="stub-actor-demo"
correlation_register="e2e-${epoch_suffix}-register"
correlation_catalog_lag="e2e-${epoch_suffix}-catalog-lag"
correlation_catalog_done="e2e-${epoch_suffix}-catalog-done"
correlation_detail="e2e-${epoch_suffix}-detail"

compose_project_name="vocastock-e2e-${epoch_suffix}-$$"
export COMPOSE_PROJECT_NAME="$compose_project_name"

stub_pid=""
start_epoch="$(date +%s)"
: > "$summary_file"
: > "$stub_access_log_file"
printf "%s\n" "$failure_stage" > "$stage_file"

{
  printf "epoch=%s\n" "$epoch_suffix"
  printf "vocabulary_identifier=%s\n" "$vocab_identifier"
  printf "idempotency_key=%s\n" "$idempotency_key"
  printf "actor_uid=%s\n" "$actor_uid"
  printf "compose_project_name=%s\n" "$compose_project_name"
} >> "$summary_file"

compose_file="$(vocas_application_compose_file)"
base_env_file="$(vocas_prepare_application_env_file)"

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
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-sk-ant-smoke-placeholder}"
export STABILITY_API_KEY="${STABILITY_API_KEY:-sk-stability-smoke-placeholder}"
export STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:-sk_test_smoke_placeholder}"
# Shorten the worker poll interval so the round-trip completes inside
# the 550s budget. Production defaults to 30s which is too slow here.
export VOCAS_WORKER_POLL_INTERVAL_SECONDS="${VOCAS_E2E_WORKER_POLL_INTERVAL_SECONDS:-1}"

env_file="$(vocas_prepare_application_smoke_env_file "$base_env_file")"
e2e_env_file="$(vocas_e2e_round_trip_env_file)"
cp "$env_file" "$e2e_env_file"

printf "VOCAS_PRODUCTION_ADAPTERS=%s\n" "$VOCAS_PRODUCTION_ADAPTERS" >> "$e2e_env_file"
printf "ANTHROPIC_API_KEY=%s\n" "$ANTHROPIC_API_KEY" >> "$e2e_env_file"
printf "STABILITY_API_KEY=%s\n" "$STABILITY_API_KEY" >> "$e2e_env_file"
printf "STRIPE_SECRET_KEY=%s\n" "$STRIPE_SECRET_KEY" >> "$e2e_env_file"
printf "VOCAS_WORKER_POLL_INTERVAL_SECONDS=%s\n" "$VOCAS_WORKER_POLL_INTERVAL_SECONDS" >> "$e2e_env_file"

vocas_load_env_file "$e2e_env_file"

docker info >/dev/null
docker compose --env-file "$e2e_env_file" -f "$compose_file" config >/dev/null

gateway_port="${GRAPHQL_GATEWAY_PORT:-$VOCAS_DEFAULT_GRAPHQL_GATEWAY_PORT}"
firestore_host_port="${FIREBASE_FIRESTORE_PORT}"
pubsub_host_port="${FIREBASE_PUBSUB_PORT}"
auth_host_port="${FIREBASE_AUTH_PORT}"

json_escape() {
  python3 -c 'import json,sys; sys.stdout.write(json.dumps(sys.argv[1]))' "$1"
}

catalog_visibility_matches() {
  local target="$1"
  local expected_visibility="$2"
  local response="$3"
  printf '%s' "$response" | python3 -c '
import json, sys
target = sys.argv[1]
expected = sys.argv[2]
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(1)
items = data.get("data", {}).get("vocabularyCatalog", {}).get("items", [])
for entry in items:
    if entry.get("vocabularyExpression") == target and entry.get("visibility") == expected:
        sys.exit(0)
sys.exit(1)
' "$target" "$expected_visibility"
}

firestore_explanation_fields() {
  local document_body="$1"
  printf '%s' "$document_body" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
fields = data.get("fields", {})
status = fields.get("explanationStatus", {}).get("stringValue", "")
current = fields.get("currentExplanation", {}).get("stringValue", "")
print(f"{status}|{current}")
'
}

status_only_seen="no"

cleanup() {
  local exit_code=$?
  printf "%s\n" "$failure_stage" > "$stage_file"
  vocas_log "cleanup triggered at stage=${failure_stage} (exit=${exit_code})"

  if [[ -n "$stub_pid" ]] && kill -0 "$stub_pid" 2>/dev/null; then
    kill "$stub_pid" 2>/dev/null || true
    wait "$stub_pid" 2>/dev/null || true
  fi

  if [[ -f "$e2e_env_file" ]]; then
    docker compose --env-file "$e2e_env_file" -f "$compose_file" logs \
      > "$compose_logs_file" 2>&1 || true
  fi

  if [[ -n "${firestore_host_port:-}" ]]; then
    local snapshot_url="http://127.0.0.1:${firestore_host_port}/v1/projects/${FIREBASE_PROJECT:-demo-vocastock}/databases/(default)/documents/actors/${actor_uid}/vocabularyExpressions"
    curl -fsS "$snapshot_url" > "$firestore_snapshot_file" 2>&1 || \
      printf "firestore snapshot fetch failed\n" > "$firestore_snapshot_file"
  fi

  if [[ -n "${pubsub_host_port:-}" ]]; then
    {
      for subscription in "workflow.explanation-jobs.sub" "workflow.image-jobs.sub" "workflow.retry-jobs.sub" "billing.purchase-jobs.sub"; do
        printf "\n===== %s =====\n" "$subscription"
        curl -fsS -X POST \
          -H "content-type: application/json" \
          -d '{"returnImmediately":true,"maxMessages":0}' \
          "http://127.0.0.1:${pubsub_host_port}/v1/projects/${FIREBASE_PROJECT:-demo-vocastock}/subscriptions/${subscription}:pull" \
          2>&1 || true
      done
    } > "$pubsub_state_file"
  fi

  if (( reuse_running == 0 )); then
    if [[ -f "$e2e_env_file" ]]; then
      docker compose --env-file "$e2e_env_file" -f "$compose_file" down >/dev/null 2>&1 || true
    fi
    bash "$SCRIPT_DIR/../firebase/stop_emulators.sh" >/dev/null 2>&1 || true
  fi

  local elapsed
  elapsed="$(( $(date +%s) - start_epoch ))"
  printf "elapsed_seconds=%s\n" "$elapsed" >> "$summary_file"
  printf "status_only_observed=%s\n" "$status_only_seen" >> "$summary_file"
  if (( exit_code == 0 )); then
    printf "status=completed\n" >> "$summary_file"
    vocas_write_duration "$VOCAS_E2E_ROUND_TRIP_NAMESPACE" "$elapsed"
    vocas_print_budget_summary "$VOCAS_E2E_ROUND_TRIP_NAMESPACE" "$elapsed" "$VOCAS_E2E_ROUND_TRIP_BUDGET_SECONDS"
  else
    printf "status=failed\n" >> "$summary_file"
    vocas_warn "e2e round-trip smoke failed at stage=${failure_stage}"
  fi
}

trap cleanup EXIT

# -----------------------------------------------------------------------------
# Stage 2: Launch the upstream stub server
# -----------------------------------------------------------------------------
failure_stage="stubs-up"
vocas_log "starting upstream stub server"
: > "$stub_server_log_file"
nohup node "$SCRIPT_DIR/e2e_stub_providers.mjs" \
  --access-log "$stub_access_log_file" \
  > "$stub_server_log_file" 2>&1 &
stub_pid=$!

stub_deadline=$(( $(date +%s) + 15 ))
stub_port=""
while (( $(date +%s) < stub_deadline )); do
  if ! kill -0 "$stub_pid" 2>/dev/null; then
    vocas_die "stub server exited before binding (see $stub_server_log_file)"
  fi
  if grep -Eq '^listening on [0-9]+' "$stub_server_log_file" 2>/dev/null; then
    stub_port="$(grep -Eo 'listening on [0-9]+' "$stub_server_log_file" | head -n1 | awk '{print $3}')"
    break
  fi
  sleep 0.2
done

if [[ -z "$stub_port" ]]; then
  vocas_die "stub server did not report a listening port within 15s"
fi

if ! curl -fsS "http://127.0.0.1:${stub_port}/readyz" >/dev/null 2>&1; then
  vocas_die "stub server readiness probe failed at http://127.0.0.1:${stub_port}/readyz"
fi

vocas_log "stub server listening on port ${stub_port}"
printf "stub_port=%s\n" "$stub_port" >> "$summary_file"

export ANTHROPIC_API_BASE_URL="http://host.docker.internal:${stub_port}"
export STABILITY_API_BASE_URL="http://host.docker.internal:${stub_port}"
printf "ANTHROPIC_API_BASE_URL=%s\n" "$ANTHROPIC_API_BASE_URL" >> "$e2e_env_file"
printf "STABILITY_API_BASE_URL=%s\n" "$STABILITY_API_BASE_URL" >> "$e2e_env_file"

# -----------------------------------------------------------------------------
# Stage 3: Start the Firebase emulator
# -----------------------------------------------------------------------------
failure_stage="firebase-emulators"
vocas_log "starting firebase emulator"
bash "$SCRIPT_DIR/../firebase/start_emulators.sh"
bash "$SCRIPT_DIR/../firebase/smoke_local_stack.sh" "${VOCAS_EMULATOR_READY_BUDGET_SECONDS:-300}"

# -----------------------------------------------------------------------------
# Stage 4: Seed the emulator (creates topics, subscriptions, demo users)
# -----------------------------------------------------------------------------
failure_stage="seed"
vocas_log "seeding firebase emulator"
(
  unset FIRESTORE_EMULATOR_HOST STORAGE_EMULATOR_HOST \
    FIREBASE_AUTH_EMULATOR_HOST PUBSUB_EMULATOR_HOST \
    FIREBASE_STORAGE_EMULATOR_HOST
  bash "$SCRIPT_DIR/../firebase/seed_emulators.sh"
)

# -----------------------------------------------------------------------------
# Stage 5: Launch the 6-service compose stack
# -----------------------------------------------------------------------------
services=()
while IFS= read -r service_name; do
  services+=("$service_name")
done < <(vocas_application_service_names)

failure_stage="compose-up"
vocas_log "compose up for services: ${services[*]}"
if (( reuse_running == 0 )); then
  if (( skip_build == 0 )); then
    # Pre-build Haskell worker images via explicit `docker buildx build`
    # so the GHA cache backend actually receives the cache_to flag.
    # `docker compose --build` silently drops cache_from/cache_to with
    # the docker-container builder set up by setup-buildx-action; see
    # scripts/ci/build_haskell_worker_images.sh for the working pattern.
    bash "$SCRIPT_DIR/build_haskell_worker_images.sh"
  fi

  up_args=(--env-file "$e2e_env_file" -f "$compose_file" up -d)
  up_args+=("${services[@]}")
  docker compose "${up_args[@]}"
fi

# -----------------------------------------------------------------------------
# Stage 6: Wait for API readiness + worker running
# -----------------------------------------------------------------------------
failure_stage="readiness"
ready_deadline=$(( $(date +%s) + ${VOCAS_APPLICATION_READY_BUDGET_SECONDS} ))
while IFS= read -r api_service; do
  readiness_url="$(vocas_application_readiness_url "$api_service")"
  while ! curl -fsS "$readiness_url" >/dev/null 2>&1; do
    if (( $(date +%s) >= ready_deadline )); then
      vocas_die "readiness timed out for ${api_service} at ${readiness_url}"
    fi
    sleep 2
  done
  vocas_log "${api_service} readiness confirmed"
done < <(vocas_application_api_services)

running_services="$(docker compose --env-file "$e2e_env_file" -f "$compose_file" ps --services --status running)"
while IFS= read -r worker_service; do
  if ! printf "%s\n" "$running_services" | grep -qx "$worker_service"; then
    vocas_die "worker is not running: ${worker_service}"
  fi
done < <(vocas_application_worker_services)

# -----------------------------------------------------------------------------
# Stage 7: Obtain demo bearer + send registerVocabularyExpression mutation
# -----------------------------------------------------------------------------
failure_stage="mutation-accepted"
vocas_log "signing in demo user"
signin_body='{"email":"demo@vocastock.test","password":"demo1234","returnSecureToken":true}'
signin_response="$(curl -fsS -X POST \
  -H "content-type: application/json" \
  --data "$signin_body" \
  "http://127.0.0.1:${auth_host_port}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=demo-emulator-api-key")"
id_token="$(printf "%s" "$signin_response" | python3 -c 'import json,sys; print(json.load(sys.stdin)["idToken"])')"
if [[ -z "$id_token" ]]; then
  vocas_die "demo user sign-in did not return an idToken"
fi
bearer="Bearer ${id_token}"

vocas_log "sending registerVocabularyExpression mutation"
register_query='mutation RegisterVocabularyExpression($actor: String!, $idempotencyKey: String!, $text: String!, $startExplanation: Boolean) { registerVocabularyExpression(actor: $actor, idempotencyKey: $idempotencyKey, text: $text, startExplanation: $startExplanation) { acceptance target { vocabularyExpression } state { registration explanation } statusHandle message replayedByIdempotency } }'

register_payload="$(python3 - <<PY
import json
print(json.dumps({
  "query": $(json_escape "$register_query"),
  "operationName": "RegisterVocabularyExpression",
  "variables": {
    "actor": $(json_escape "$actor_uid"),
    "idempotencyKey": $(json_escape "$idempotency_key"),
    "text": $(json_escape "$vocab_text"),
    "startExplanation": True,
  }
}))
PY
)"

register_response="$(curl -fsS -X POST \
  -H "authorization: ${bearer}" \
  -H "content-type: application/json" \
  -H "x-request-correlation: ${correlation_register}" \
  --data "$register_payload" \
  "http://127.0.0.1:${gateway_port}/graphql")"

printf "register_response=%s\n" "$register_response" >> "$summary_file"

if ! printf "%s" "$register_response" | grep -q '"acceptance":"accepted"'; then
  vocas_die "registerVocabularyExpression did not return acceptance=accepted: ${register_response}"
fi
if ! printf "%s" "$register_response" | grep -q "\"vocabularyExpression\":\"${vocab_identifier}\""; then
  vocas_die "registerVocabularyExpression did not return the expected identifier (${vocab_identifier}): ${register_response}"
fi

# -----------------------------------------------------------------------------
# Stage 8: Best-effort assertion that the catalog reports status-only
# -----------------------------------------------------------------------------
failure_stage="status-only-observed"
catalog_query='query VocabularyCatalog { vocabularyCatalog { collectionState items { vocabularyExpression visibility } } }'
catalog_payload="$(python3 - <<PY
import json
print(json.dumps({
  "query": $(json_escape "$catalog_query"),
  "operationName": "VocabularyCatalog",
}))
PY
)"

lag_deadline=$(( $(date +%s) + VOCAS_E2E_STATUS_ONLY_WINDOW_SECONDS ))
while (( $(date +%s) < lag_deadline )); do
  lag_response="$(curl -fsS -X POST \
    -H "authorization: ${bearer}" \
    -H "content-type: application/json" \
    -H "x-request-correlation: ${correlation_catalog_lag}" \
    --data "$catalog_payload" \
    "http://127.0.0.1:${gateway_port}/graphql" 2>/dev/null || true)"

  if catalog_visibility_matches "$vocab_identifier" "status-only" "$lag_response"; then
    status_only_seen="yes"
    vocas_log "status-only visibility observed for ${vocab_identifier}"
    break
  fi
  sleep 1
done

if [[ "$status_only_seen" != "yes" ]]; then
  vocas_warn "projection lag window closed before status-only visibility was observed (best effort)"
fi

# -----------------------------------------------------------------------------
# Stage 9: Poll Firestore until the worker has updated the document
# -----------------------------------------------------------------------------
failure_stage="firestore-polling"
document_url="http://127.0.0.1:${firestore_host_port}/v1/projects/${FIREBASE_PROJECT:-demo-vocastock}/databases/(default)/documents/actors/${actor_uid}/vocabularyExpressions/${vocab_identifier}"
poll_deadline=$(( $(date +%s) + VOCAS_E2E_POLL_INTERVAL_SECONDS * VOCAS_E2E_POLL_MAX_RETRIES ))
final_status=""
final_current_explanation=""

while (( $(date +%s) < poll_deadline )); do
  document_body="$(curl -fsS "$document_url" 2>/dev/null || true)"
  if [[ -n "$document_body" ]]; then
    status_value="$(firestore_explanation_fields "$document_body")"
    current_status="${status_value%%|*}"
    current_pointer="${status_value##*|}"
    if [[ "$current_status" == "succeeded" && -n "$current_pointer" ]]; then
      final_status="$current_status"
      final_current_explanation="$current_pointer"
      break
    fi
  fi
  sleep "$VOCAS_E2E_POLL_INTERVAL_SECONDS"
done

if [[ "$final_status" != "succeeded" ]]; then
  vocas_die "firestore polling timed out before explanationStatus reached 'succeeded' for ${vocab_identifier}"
fi
printf "firestore_current_explanation=%s\n" "$final_current_explanation" >> "$summary_file"

# -----------------------------------------------------------------------------
# Stage 10: Assert query-api completed response + catalog visibility switch
# -----------------------------------------------------------------------------
failure_stage="completed-observed"
detail_query='query VocabularyExpressionDetail($identifier: String!) { vocabularyExpressionDetail(identifier: $identifier) { identifier explanationStatus currentExplanation } }'
detail_payload="$(python3 - <<PY
import json
print(json.dumps({
  "query": $(json_escape "$detail_query"),
  "operationName": "VocabularyExpressionDetail",
  "variables": {
    "identifier": $(json_escape "$vocab_identifier"),
  },
}))
PY
)"

detail_response="$(curl -fsS -X POST \
  -H "authorization: ${bearer}" \
  -H "content-type: application/json" \
  -H "x-request-correlation: ${correlation_detail}" \
  --data "$detail_payload" \
  "http://127.0.0.1:${gateway_port}/graphql")"

printf "detail_response=%s\n" "$detail_response" >> "$summary_file"

if ! printf "%s" "$detail_response" | grep -q '"explanationStatus":"SUCCEEDED"'; then
  vocas_die "vocabularyExpressionDetail did not report SUCCEEDED: ${detail_response}"
fi
if printf "%s" "$detail_response" | grep -q '"currentExplanation":null'; then
  vocas_die "vocabularyExpressionDetail returned null currentExplanation: ${detail_response}"
fi

catalog_done_response="$(curl -fsS -X POST \
  -H "authorization: ${bearer}" \
  -H "content-type: application/json" \
  -H "x-request-correlation: ${correlation_catalog_done}" \
  --data "$catalog_payload" \
  "http://127.0.0.1:${gateway_port}/graphql")"

printf "catalog_done_response=%s\n" "$catalog_done_response" >> "$summary_file"

if ! catalog_visibility_matches "$vocab_identifier" "completed-summary" "$catalog_done_response"; then
  vocas_die "vocabularyCatalog did not report completed-summary for ${vocab_identifier}: ${catalog_done_response}"
fi

failure_stage="cleanup"
vocas_log "e2e round-trip smoke completed successfully"
