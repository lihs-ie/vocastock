#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

catalog_file="$(vocas_repo_root)/tooling/versions/approved-components.md"
[[ -f "$catalog_file" ]] || vocas_die "missing version catalog: tooling/versions/approved-components.md"

required_components=(
  "Flutter SDK"
  "Xcode"
  "Android Studio"
  "CocoaPods"
  "Docker Desktop"
  "Node.js"
  "Temurin JDK"
  "Firebase CLI"
  "Trivy CLI"
)

for component_name in "${required_components[@]}"; do
  grep -F "| ${component_name} |" "$catalog_file" >/dev/null || vocas_die "missing version catalog row for ${component_name}"
done

grep -F "reviewedAt" "$catalog_file" >/dev/null || vocas_die "version catalog must define a reviewedAt column"
if grep -En "TBD|TODO|<placeholder>|pending" "$catalog_file" >/dev/null; then
  vocas_die "version catalog contains unresolved placeholders"
fi

vocas_log "version catalog validation passed"
