#!/usr/bin/env bash
# Stops the local AI provider stub started by
# `scripts/dev/start_stub_providers.sh`. Idempotent — silent no-op if
# no PID file is present or the process is already dead.

set -euo pipefail

LOG_DIR="${VOCAS_STUB_LOG_DIR:-${TMPDIR:-/tmp}/vocastock-stub}"
PID_FILE="${LOG_DIR}/pid"

if [[ ! -f "$PID_FILE" ]]; then
  exit 0
fi

PID="$(cat "$PID_FILE")"
if ! kill -0 "$PID" 2>/dev/null; then
  rm -f "$PID_FILE"
  exit 0
fi

kill "$PID" 2>/dev/null || true
DEADLINE=$(( $(date +%s) + 5 ))
while kill -0 "$PID" 2>/dev/null; do
  if (( $(date +%s) >= DEADLINE )); then
    kill -9 "$PID" 2>/dev/null || true
    break
  fi
  sleep 0.2
done

rm -f "$PID_FILE"
printf "stopped stub-providers (pid=%s)\n" "$PID"
