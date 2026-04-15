#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_ensure_artifact_directories
vocas_load_local_env

fixture_path="${PUBSUB_FALLBACK_FIXTURE:-$(vocas_pubsub_fallback_fixture)}"
[[ -f "$fixture_path" ]] || vocas_die "missing Pub/Sub fallback fixture: ${fixture_path}"

grep -q '"message"' "$fixture_path" || vocas_die "Pub/Sub fallback fixture must define message"
grep -q '"topic"' "$fixture_path" || vocas_die "Pub/Sub fallback fixture must define topic"
grep -q '"payload"' "$fixture_path" || vocas_die "Pub/Sub fallback fixture must define payload"

printf "fixture=%s\nmode=%s\n" "$fixture_path" "${PUBSUB_FALLBACK_MODE:-stubbed}" > "$(vocas_repo_root)/.artifacts/ci/logs/pubsub-fallback-smoke.txt"
vocas_log "Pub/Sub fallback smoke passed"
