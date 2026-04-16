#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"
source "$SCRIPT_DIR/../lib/vocastock_ci_helpers.sh"

vocas_require_command docker
vocas_ensure_artifact_directories

allow_publish="${VOCAS_IMAGE_PREPARE_ALLOW_PUBLISH:-0}"
export_artifact="${VOCAS_IMAGE_PREPARE_EXPORT_ARTIFACT:-auto}"
force_rebuild="${VOCAS_IMAGE_PREPARE_FORCE_REBUILD:-0}"
output_file=""
start_epoch="$(vocas_now_epoch)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --publish)
      allow_publish="1"
      shift
      ;;
    --no-publish)
      allow_publish="0"
      shift
      ;;
    --export-artifact)
      export_artifact="1"
      shift
      ;;
    --no-export-artifact)
      export_artifact="0"
      shift
      ;;
    --force-rebuild)
      force_rebuild="1"
      shift
      ;;
    --output-file)
      output_file="${2:?missing output file path}"
      shift 2
      ;;
    *)
      vocas_die "unknown argument: $1"
      ;;
  esac
done

if [[ -z "${VOCAS_GHCR_TOKEN:-}" ]]; then
  allow_publish="0"
fi

if [[ "$export_artifact" == "auto" ]]; then
  if [[ "$allow_publish" == "1" ]]; then
    export_artifact="0"
  else
    export_artifact="1"
  fi
fi

stage_namespace="${VOCAS_STAGE_NAMESPACE:-$VOCAS_EMULATOR_PREPARE_NAMESPACE}"
baseline_hash="$(vocas_emulator_baseline_hash)"
image_reference="$(vocas_emulator_image_reference "$baseline_hash")"
artifact_path="$(vocas_emulator_image_artifact_path "$baseline_hash")"
artifact_file="$(basename "$artifact_path")"
artifact_name="$(vocas_emulator_image_artifact_name "$baseline_hash")"
cache_scope="firebase-emulators-${baseline_hash}"
build_context="$(vocas_repo_root)"
resolved_source=""
baseline_reason=""
cache_args=()

mkdir -p "$(dirname "$artifact_path")"

vocas_stage_start "$stage_namespace" "image-resolution" "baseline=${baseline_hash} image=${image_reference}"

if [[ "$force_rebuild" != "1" ]] && docker image inspect "$image_reference" >/dev/null 2>&1; then
  resolved_source="existing-local-image"
  baseline_reason="baseline ${baseline_hash} already available locally as ${image_reference}"
elif [[ "$force_rebuild" != "1" ]] && docker manifest inspect "$image_reference" >/dev/null 2>&1; then
  resolved_source="existing-ghcr"
  baseline_reason="baseline ${baseline_hash} already published at ${image_reference}"
fi

vocas_stage_finish "$stage_namespace" "image-resolution" "succeeded" "${baseline_reason:-baseline requires preparation}"

if [[ "$resolved_source" == "existing-ghcr" && "$export_artifact" == "1" ]]; then
  vocas_stage_start "$stage_namespace" "image-pull" "preparing same-run artifact from existing image ${image_reference}"
  docker pull "$image_reference" >/dev/null
  vocas_stage_finish "$stage_namespace" "image-pull" "succeeded" "pulled existing baseline image for artifact export"
fi

if [[ -z "$resolved_source" ]]; then
  vocas_stage_start "$stage_namespace" "image-build" "buildx scope=${cache_scope}"
  if [[ "${GITHUB_ACTIONS:-}" == "true" || -n "${ACT:-}" ]]; then
    cache_args=(
      --cache-from "type=gha,scope=${cache_scope}"
      --cache-to "type=gha,scope=${cache_scope},mode=max"
    )
  fi
  build_args=(
    buildx build
    --file "$build_context/docker/firebase/Dockerfile"
    --build-arg "NODE_VERSION=${VOCAS_APPROVED_NODE_VERSION}"
    --build-arg "FIREBASE_TOOLS_VERSION=${VOCAS_APPROVED_FIREBASE_TOOLS_VERSION}"
    --build-arg "VOCAS_EMULATOR_BASELINE_HASH=${baseline_hash}"
    --label "com.vocastock.emulator.baseline-hash=${baseline_hash}"
    --label "com.vocastock.emulator.image-reference=${image_reference}"
    --tag "$image_reference"
  )
  build_args+=("${cache_args[@]}")

  if [[ "$allow_publish" == "1" ]]; then
    docker "${build_args[@]}" --push "$build_context"
    resolved_source="rebuilt-and-published"
    vocas_stage_finish "$stage_namespace" "image-build" "succeeded" "built reusable image with buildx cache"
    vocas_stage_start "$stage_namespace" "image-publish" "published ${image_reference} to GHCR"
    vocas_stage_finish "$stage_namespace" "image-publish" "succeeded" "published baseline image ${image_reference}"
    if [[ "$export_artifact" == "1" ]]; then
      vocas_stage_start "$stage_namespace" "image-pull" "pulling published image for same-run artifact"
      docker pull "$image_reference" >/dev/null
      vocas_stage_finish "$stage_namespace" "image-pull" "succeeded" "pulled freshly published image"
    fi
  else
    docker "${build_args[@]}" --load "$build_context"
    resolved_source="rebuilt-and-artifacted"
    vocas_stage_finish "$stage_namespace" "image-build" "succeeded" "built local image for same-run reuse"
  fi
fi

if [[ "$export_artifact" == "1" ]]; then
  docker save "$image_reference" -o "$artifact_path"
fi

elapsed="$(( $(vocas_now_epoch) - start_epoch ))"
vocas_write_duration "$VOCAS_EMULATOR_PREPARE_NAMESPACE" "${elapsed}"

write_outputs() {
  local target_file="$1"
  local prepared_artifact=""
  local prepared_artifact_file=""
  local prepared_artifact_name=""
  if [[ "$export_artifact" == "1" ]]; then
    prepared_artifact="$artifact_path"
    prepared_artifact_file="$artifact_file"
    prepared_artifact_name="$artifact_name"
  fi
  {
    printf 'VOCAS_BASELINE_HASH=%q\n' "$baseline_hash"
    printf 'VOCAS_BASELINE_IMAGE_REFERENCE=%q\n' "$image_reference"
    printf 'VOCAS_RESOLVED_IMAGE_SOURCE=%q\n' "$resolved_source"
    printf 'VOCAS_RESOLVED_IMAGE_REFERENCE=%q\n' "$image_reference"
    printf 'VOCAS_PREPARED_IMAGE_ARTIFACT=%q\n' "$prepared_artifact"
    printf 'VOCAS_PREPARED_IMAGE_ARTIFACT_FILE=%q\n' "$prepared_artifact_file"
    printf 'VOCAS_PREPARED_IMAGE_ARTIFACT_NAME=%q\n' "$prepared_artifact_name"
  } > "$target_file"
}

if [[ -n "$output_file" ]]; then
  write_outputs "$output_file"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    printf 'baseline_hash=%s\n' "$baseline_hash"
    printf 'image_reference=%s\n' "$image_reference"
    printf 'resolved_source=%s\n' "$resolved_source"
    if [[ "$export_artifact" == "1" ]]; then
      printf 'image_artifact_name=%s\n' "$artifact_name"
      printf 'image_artifact_file=%s\n' "$artifact_file"
    else
      printf 'image_artifact_name=\n'
      printf 'image_artifact_file=\n'
    fi
  } >> "$GITHUB_OUTPUT"
fi

vocas_log "prepared emulator image ${image_reference} (${resolved_source})"
