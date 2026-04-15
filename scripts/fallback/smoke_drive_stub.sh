#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_ensure_artifact_directories
vocas_load_local_env

fixture_path="${DRIVE_FALLBACK_REFERENCE:-$(vocas_drive_fallback_fixture)}"
asset_root="${DRIVE_FALLBACK_ASSET_ROOT:-$(vocas_repo_root)/.artifacts/fallback/drive-assets}"
[[ -f "$fixture_path" ]] || vocas_die "missing Google Drive fallback fixture: ${fixture_path}"

mkdir -p "$asset_root"
grep -q '"asset"' "$fixture_path" || vocas_die "Google Drive fallback fixture must define asset"
grep -q '"path"' "$fixture_path" || vocas_die "Google Drive fallback fixture must define path"

printf "fixture=%s\nasset_root=%s\nmode=%s\n" "$fixture_path" "$asset_root" "${DRIVE_FALLBACK_MODE:-stubbed}" > "$(vocas_repo_root)/.artifacts/ci/logs/drive-fallback-smoke.txt"
vocas_log "Google Drive fallback smoke passed"
