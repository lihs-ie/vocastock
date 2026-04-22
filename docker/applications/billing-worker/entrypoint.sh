#!/bin/sh
set -eu

worker_name="${VOCAS_WORKER_NAME:-billing-worker}"

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
check_dependency "pubsub" "${PUBSUB_EMULATOR_HOST:-}"

export VOCAS_WORKER_NAME="${worker_name}"

exec /usr/local/bin/billing-worker "$@"
