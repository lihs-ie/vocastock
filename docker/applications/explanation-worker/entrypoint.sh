#!/bin/sh
set -eu

worker_name="${VOCAS_WORKER_NAME:-explanation-worker}"
stable_window="${VOCAS_WORKER_STABLE_RUN_SECONDS:-10}"
poll_interval="${VOCAS_WORKER_POLL_INTERVAL_SECONDS:-30}"

echo "[vocastock] ${worker_name} booting as long-running consumer"

trap 'echo "[vocastock] ${worker_name} stopping"; exit 0' TERM INT

check_dependency() {
  dependency_name="$1"
  endpoint="$2"

  if [ -z "$endpoint" ]; then
    return 0
  fi

  dependency_host="${endpoint%:*}"
  dependency_port="${endpoint##*:}"

  if ! nc -z "$dependency_host" "$dependency_port"; then
    echo "[vocastock] ${worker_name} failed to reach ${dependency_name} at ${endpoint}" >&2
    exit 1
  fi

  echo "[vocastock] ${worker_name} verified ${dependency_name} at ${endpoint}"
}

check_dependency "firestore" "${FIRESTORE_EMULATOR_HOST:-}"
check_dependency "storage" "${STORAGE_EMULATOR_HOST:-}"
check_dependency "auth" "${FIREBASE_AUTH_EMULATOR_HOST:-}"
check_dependency "pubsub" "${PUBSUB_EMULATOR_HOST:-}"

sleep "${stable_window}"
echo "[vocastock] ${worker_name} entered stable-run mode"

while :; do
  echo "[vocastock] ${worker_name} awaiting queue/subscription work"
  sleep "${poll_interval}"
done
