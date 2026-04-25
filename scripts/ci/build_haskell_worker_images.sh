#!/usr/bin/env bash
# Pre-builds the Haskell worker Docker images with explicit `docker buildx
# build --cache-to=type=gha,mode=max --load` so the BuildKit cache mounts
# (cabal store + per-worker dist-newstyle) survive across CI runs.
#
# Compose's `cache_from`/`cache_to` are silently dropped when the build
# is invoked through `docker compose --build` on ubuntu-24.04 runners
# (verified via runs 24919496475 / 24920082015 — no `exporting cache`
# log lines, post-job cache state stayed "not set"). Pre-building each
# image directly with buildx — the same pattern that
# `scripts/ci/prepare_emulator_image.sh` already uses successfully —
# routes the cache flags through the channel that actually honors them.
#
# After this script runs, each worker image is loaded into the local
# Docker daemon under the tag the compose service references via its
# `image:` field, so a subsequent `docker compose up` (without `--build`)
# picks them up without re-running the build.
#
# Usage:
#   bash scripts/ci/build_haskell_worker_images.sh
#
# Environment knobs:
#   GITHUB_ACTIONS=true|ACT=1 — enable `type=gha` cache flags (mirrors
#     the pattern in prepare_emulator_image.sh:95-100).
#   VOCAS_HASKELL_WORKER_IMAGE_TAG — overrides the tag suffix; defaults
#     to "ci".

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command docker

build_context="$(vocas_repo_root)"
image_tag="${VOCAS_HASKELL_WORKER_IMAGE_TAG:-ci}"

cache_args=()
if [[ "${GITHUB_ACTIONS:-}" == "true" || -n "${ACT:-}" ]]; then
  in_gha="yes"
else
  in_gha="no"
fi

while IFS= read -r worker; do
  image_reference="vocastock-applications-${worker}:${image_tag}"
  dockerfile="$build_context/docker/applications/${worker}/Dockerfile"

  build_args=(
    buildx build
    --file "$dockerfile"
    --tag "$image_reference"
  )
  if [[ "$in_gha" == "yes" ]]; then
    cache_args=(
      --cache-from "type=gha,scope=vocas-${worker}"
      --cache-to "type=gha,scope=vocas-${worker},mode=max"
    )
    build_args+=("${cache_args[@]}")
  fi
  build_args+=(--load "$build_context")

  vocas_log "building haskell worker image ${image_reference} (gha-cache=${in_gha})"
  docker "${build_args[@]}"
done < <(vocas_application_worker_services)
