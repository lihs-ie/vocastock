#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

base_ref=""
head_ref="HEAD"

while (($# > 0)); do
  case "$1" in
    --base)
      base_ref="${2:-}"
      shift 2
      ;;
    --head)
      head_ref="${2:-}"
      shift 2
      ;;
    *)
      vocas_die "unsupported argument: $1"
      ;;
  esac
done

vocas_ensure_artifact_directories

detected_paths_file="$(vocas_rust_quality_detected_paths_file)"
mkdir -p "$(dirname "$detected_paths_file")"
: > "$detected_paths_file"

resolve_base_ref() {
  local candidate="$1"

  if [[ -n "$candidate" && ! "$candidate" =~ ^0+$ ]]; then
    printf "%s\n" "$candidate"
    return 0
  fi

  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    git merge-base origin/main "$head_ref"
    return 0
  fi

  printf "%s\n" ""
}

collect_changed_paths() {
  local resolved_base="$1"

  if [[ -n "$resolved_base" ]] && git rev-parse --verify "${resolved_base}^{commit}" >/dev/null 2>&1; then
    git diff --name-only "$resolved_base" "$head_ref"
    return 0
  fi

  if git rev-parse --verify "${head_ref}^" >/dev/null 2>&1; then
    git diff --name-only "${head_ref}^" "$head_ref"
    return 0
  fi

  git ls-tree --name-only -r "$head_ref"
}

is_rust_related_path() {
  local changed_path="$1"

  case "$changed_path" in
    Cargo.toml|Cargo.lock|.github/workflows/ci.yml|scripts/lib/vocastock_env.sh)
      return 0
      ;;
    docker/applications/*|docker/firebase/*|scripts/ci/*|scripts/firebase/*)
      return 0
      ;;
    *)
      ;;
  esac

  if [[ "$changed_path" == applications/backend/* ]]; then
    case "$changed_path" in
      *.rs|*/Cargo.toml)
        return 0
        ;;
    esac
  fi

  if [[ "$changed_path" == packages/rust/* ]]; then
    case "$changed_path" in
      *.rs|*/Cargo.toml)
        return 0
        ;;
    esac
  fi

  return 1
}

resolved_base_ref="$(resolve_base_ref "$base_ref")"

matched_paths=()
while IFS= read -r changed_path; do
  [[ -n "$changed_path" ]] || continue
  if is_rust_related_path "$changed_path"; then
    matched_paths+=("$changed_path")
  fi
done < <(collect_changed_paths "$resolved_base_ref")

if ((${#matched_paths[@]} > 0)); then
  mapfile -t matched_paths < <(printf "%s\n" "${matched_paths[@]}" | sort -u)
fi

execution_mode="noop"
rust_changed="false"
if ((${#matched_paths[@]} > 0)); then
  execution_mode="full"
  rust_changed="true"
  printf "%s\n" "${matched_paths[@]}" > "$detected_paths_file"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    printf "execution_mode=%s\n" "$execution_mode"
    printf "rust_changed=%s\n" "$rust_changed"
    printf "matched_path_count=%s\n" "${#matched_paths[@]}"
  } >> "$GITHUB_OUTPUT"
fi

printf "execution_mode=%s\n" "$execution_mode"
printf "rust_changed=%s\n" "$rust_changed"
printf "matched_path_count=%s\n" "${#matched_paths[@]}"
if ((${#matched_paths[@]} > 0)); then
  printf "matched_paths_file=%s\n" "$detected_paths_file"
  printf "matched_paths:\n"
  printf "%s\n" "${matched_paths[@]}"
else
  printf "matched_paths:\n"
  printf "(none)\n"
fi
