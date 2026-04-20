#!/bin/sh
set -eu

worker_name="${VOCAS_WORKER_NAME:-image-worker}"
stable_window="${VOCAS_WORKER_STABLE_RUN_SECONDS:-10}"
poll_interval="${VOCAS_WORKER_POLL_INTERVAL_SECONDS:-30}"

echo "[vocastock] ${worker_name} booting as long-running consumer"

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

export VOCAS_WORKER_NAME="${worker_name}"
export VOCAS_WORKER_STABLE_RUN_SECONDS="${stable_window}"
export VOCAS_WORKER_POLL_INTERVAL_SECONDS="${poll_interval}"

exec /usr/local/bin/image-worker "$@"
