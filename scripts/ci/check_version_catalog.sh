#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

catalog_file="$(vocas_repo_root)/tooling/versions/approved-components.md"
[[ -f "$catalog_file" ]] || vocas_die "missing version catalog: tooling/versions/approved-components.md"

required_header='| Component | approvedVersion | observedBaselineVersion | supersededVersion | releaseChannel | supportStatus | supportSource | vulnerability-source | severity | finding | disposition | reviewedAt | reviewCadence | baselineChangeReason | rationale |'
grep -F "$required_header" "$catalog_file" >/dev/null || vocas_die "version catalog header does not match the approved schema"

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

host_baseline_components=(
  "Flutter SDK"
  "Xcode"
  "Android Studio"
  "CocoaPods"
  "Docker Desktop"
)

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf "%s" "$value"
}

for component_name in "${required_components[@]}"; do
  row="$(grep -F "| ${component_name} |" "$catalog_file" | head -n 1 || true)"
  [[ -n "$row" ]] || vocas_die "missing version catalog row for ${component_name}"

  IFS='|' read -r _ component approved observed superseded release_channel support_status support_source vulnerability_source severity finding disposition reviewed_at review_cadence baseline_change_reason rationale _ <<< "$row"
  approved="$(trim "$approved")"
  observed="$(trim "$observed")"
  superseded="$(trim "$superseded")"
  release_channel="$(trim "$release_channel")"
  support_status="$(trim "$support_status")"
  support_source="$(trim "$support_source")"
  vulnerability_source="$(trim "$vulnerability_source")"
  severity="$(trim "$severity")"
  finding="$(trim "$finding")"
  disposition="$(trim "$disposition")"
  reviewed_at="$(trim "$reviewed_at")"
  review_cadence="$(trim "$review_cadence")"
  baseline_change_reason="$(trim "$baseline_change_reason")"
  rationale="$(trim "$rationale")"

  [[ -n "$approved" ]] || vocas_die "approvedVersion is required for ${component_name}"
  [[ -n "$release_channel" ]] || vocas_die "releaseChannel is required for ${component_name}"
  [[ -n "$support_status" ]] || vocas_die "supportStatus is required for ${component_name}"
  [[ -n "$support_source" ]] || vocas_die "supportSource is required for ${component_name}"
  [[ -n "$vulnerability_source" ]] || vocas_die "vulnerability-source is required for ${component_name}"
  [[ -n "$severity" ]] || vocas_die "severity is required for ${component_name}"
  [[ -n "$finding" ]] || vocas_die "finding is required for ${component_name}"
  [[ -n "$disposition" ]] || vocas_die "disposition is required for ${component_name}"
  [[ -n "$reviewed_at" ]] || vocas_die "reviewedAt is required for ${component_name}"
  [[ -n "$review_cadence" ]] || vocas_die "reviewCadence is required for ${component_name}"
  [[ -n "$rationale" ]] || vocas_die "rationale is required for ${component_name}"

  for host_component in "${host_baseline_components[@]}"; do
    if [[ "$component_name" == "$host_component" && -z "$observed" ]]; then
      vocas_die "observedBaselineVersion is required for host baseline component ${component_name}"
    fi
  done

  if [[ -n "$superseded" && -z "$baseline_change_reason" ]]; then
    vocas_die "baselineChangeReason is required when supersededVersion is recorded for ${component_name}"
  fi

  if [[ -n "$observed" && "$observed" != "$approved" ]]; then
    [[ -n "$superseded" && -n "$baseline_change_reason" ]] || vocas_die "baseline delta fields are incomplete for ${component_name}"
  fi
done

if grep -En "TBD|TODO|<placeholder>|pending" "$catalog_file" >/dev/null; then
  vocas_die "version catalog contains unresolved placeholders"
fi

vocas_log "version catalog validation passed"
