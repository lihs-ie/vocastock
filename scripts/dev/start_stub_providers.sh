#!/usr/bin/env bash
# Boots the AI provider stub for local development. The stub
# (`scripts/ci/e2e_stub_providers.mjs`) is shared with the CI e2e
# smoke; this launcher wraps it with a developer-friendly env-file
# write and PID tracking. See `docs/development/local-stub.md`.
#
# Usage:
#   bash scripts/dev/start_stub_providers.sh
#
# Env knobs:
#   VOCAS_STUB_PROVIDERS_PORT  Pin the port (default: auto-pick free).
#   VOCAS_STUB_LOG_DIR         Override log/PID dir (default: $TMPDIR/vocastock-stub).
#   VOCAS_STUB_ENV_FILE        Override env-file output (default: $REPO_ROOT/.env.stub).

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="${REPO_ROOT}/scripts/ci"
LOG_DIR="${VOCAS_STUB_LOG_DIR:-${TMPDIR:-/tmp}/vocastock-stub}"
LOG_FILE="${LOG_DIR}/stub.log"
ACCESS_LOG="${LOG_DIR}/access.log"
PID_FILE="${LOG_DIR}/pid"
ENV_FILE="${VOCAS_STUB_ENV_FILE:-${REPO_ROOT}/.env.stub}"

mkdir -p "$LOG_DIR"

if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  printf "stub already running (pid=%s); run scripts/dev/stop_stub_providers.sh first\n" \
    "$(cat "$PID_FILE")" >&2
  exit 1
fi

PORT_ARG=()
if [[ -n "${VOCAS_STUB_PROVIDERS_PORT:-}" ]]; then
  PORT_ARG=(--port "$VOCAS_STUB_PROVIDERS_PORT")
fi

: > "$LOG_FILE"
nohup node "$SCRIPT_DIR/e2e_stub_providers.mjs" \
  "${PORT_ARG[@]}" \
  --access-log "$ACCESS_LOG" \
  > "$LOG_FILE" 2>&1 &
STUB_PID=$!
disown "$STUB_PID" 2>/dev/null || true
echo "$STUB_PID" > "$PID_FILE"

DEADLINE=$(( $(date +%s) + 15 ))
PORT=""
while (( $(date +%s) < DEADLINE )); do
  if ! kill -0 "$STUB_PID" 2>/dev/null; then
    printf "stub exited before binding; see %s\n" "$LOG_FILE" >&2
    rm -f "$PID_FILE"
    exit 1
  fi
  if grep -Eq '^listening on [0-9]+' "$LOG_FILE" 2>/dev/null; then
    PORT="$(grep -Eo 'listening on [0-9]+' "$LOG_FILE" | head -n1 | awk '{print $3}')"
    break
  fi
  sleep 0.2
done

if [[ -z "$PORT" ]]; then
  printf "stub did not bind within 15s; see %s\n" "$LOG_FILE" >&2
  kill "$STUB_PID" 2>/dev/null || true
  rm -f "$PID_FILE"
  exit 1
fi

if ! curl -fsS "http://127.0.0.1:${PORT}/readyz" >/dev/null; then
  printf "stub readiness probe failed at http://127.0.0.1:%s/readyz\n" "$PORT" >&2
  kill "$STUB_PID" 2>/dev/null || true
  rm -f "$PID_FILE"
  exit 1
fi

cat > "$ENV_FILE" <<EOF
ANTHROPIC_API_KEY=stub-anthropic-key
ANTHROPIC_API_BASE_URL=http://host.docker.internal:${PORT}
STABILITY_API_KEY=stub-stability-key
STABILITY_API_BASE_URL=http://host.docker.internal:${PORT}
EOF

cat <<EOF
stub-providers listening:
  pid:        ${STUB_PID}
  port:       ${PORT}
  log:        ${LOG_FILE}
  access log: ${ACCESS_LOG}
  env file:   ${ENV_FILE}

bring up workers:
  docker compose --env-file ${ENV_FILE} -f docker/applications/compose.yaml up

or source these env vars into your shell:
  export ANTHROPIC_API_KEY=stub-anthropic-key
  export ANTHROPIC_API_BASE_URL=http://host.docker.internal:${PORT}
  export STABILITY_API_KEY=stub-stability-key
  export STABILITY_API_BASE_URL=http://host.docker.internal:${PORT}

stop with:
  bash scripts/dev/stop_stub_providers.sh
  (or: kill ${STUB_PID})
EOF
