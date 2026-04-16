#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"
source "$SCRIPT_DIR/../lib/vocastock_ci_helpers.sh"

vocas_require_command docker
vocas_ensure_artifact_directories

artifact_path="${VOCAS_PREPARED_IMAGE_ARTIFACT:-}"
output_file=""
require_existing="0"
allow_pull="1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --artifact-path)
      artifact_path="${2:?missing artifact path}"
      shift 2
      ;;
    --output-file)
      output_file="${2:?missing output file path}"
      shift 2
      ;;
    --require-existing)
      require_existing="1"
      shift
      ;;
    --skip-pull)
      allow_pull="0"
      shift
      ;;
    *)
      vocas_die "unknown argument: $1"
      ;;
  esac
done

stage_namespace="${VOCAS_STAGE_NAMESPACE:-}"
if [[ -n "$stage_namespace" ]]; then
  vocas_stage_start "$stage_namespace" "image-resolution" "artifact=${artifact_path:-none}"
fi

baseline_hash="$(vocas_emulator_baseline_hash)"
image_reference="$(vocas_emulator_image_reference "$baseline_hash")"
resolved_source=""
resolution_message=""
resolved_artifact=""

if [[ -n "$artifact_path" && -f "$artifact_path" ]]; then
  resolved_source="workflow-artifact"
  resolved_artifact="$artifact_path"
  resolution_message="resolved prepared image from artifact ${artifact_path}"
elif docker image inspect "$image_reference" >/dev/null 2>&1; then
  resolved_source="existing-ghcr"
  resolution_message="resolved prepared image from local cache ${image_reference}"
elif [[ "$allow_pull" == "1" ]] && docker pull "$image_reference" >/dev/null 2>&1; then
  resolved_source="existing-ghcr"
  resolution_message="resolved prepared image from registry ${image_reference}"
else
  resolved_source="failed"
  resolution_message="baseline ${baseline_hash} expects ${image_reference}, but neither workflow artifact nor prepared registry image was available"
fi

if [[ "$resolved_source" == "failed" ]]; then
  if [[ -n "$stage_namespace" ]]; then
    vocas_stage_finish "$stage_namespace" "image-resolution" "failed" "$resolution_message"
  fi
  if [[ "$require_existing" == "1" ]]; then
    vocas_die "$resolution_message"
  fi
else
  if [[ -n "$stage_namespace" ]]; then
    vocas_stage_finish "$stage_namespace" "image-resolution" "succeeded" "$resolution_message"
  fi
fi

result_payload="$(cat <<EOF
$(printf 'VOCAS_BASELINE_HASH=%q\n' "$baseline_hash")
$(printf 'VOCAS_BASELINE_IMAGE_REFERENCE=%q\n' "$image_reference")
$(printf 'VOCAS_RESOLVED_IMAGE_SOURCE=%q\n' "$resolved_source")
$(printf 'VOCAS_RESOLVED_IMAGE_REFERENCE=%q\n' "$image_reference")
$(printf 'VOCAS_RESOLVED_IMAGE_ARTIFACT=%q\n' "$resolved_artifact")
$(printf 'VOCAS_RESOLUTION_MESSAGE=%q\n' "$resolution_message")
EOF
)"

if [[ -n "$output_file" ]]; then
  printf "%s\n" "$result_payload" > "$output_file"
else
  printf "%s\n" "$result_payload"
fi

[[ "$resolved_source" != "failed" ]]
