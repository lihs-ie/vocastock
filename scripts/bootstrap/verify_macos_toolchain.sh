#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_macos

check_count=0
failure_count=0

check_version() {
  local label="$1"
  local expected="$2"
  local actual="$3"

  check_count=$((check_count + 1))
  if [[ "$actual" == "$expected" ]]; then
    printf "✓ %s: %s\n" "$label" "$actual"
  else
    printf "✗ %s: expected %s, got %s\n" "$label" "$expected" "${actual:-missing}"
    failure_count=$((failure_count + 1))
  fi
}

flutter_actual=""
if vocas_have_command flutter; then
  flutter_actual="$(flutter --version 2>/dev/null | head -n 1 | awk '{print $2}')"
fi
check_version "Flutter SDK" "$VOCAS_APPROVED_FLUTTER_VERSION" "$flutter_actual"

xcode_actual=""
if vocas_have_command xcodebuild; then
  xcode_actual="$(xcodebuild -version 2>/dev/null | head -n 1 | awk '{print $2}')"
fi
check_version "Xcode" "$VOCAS_APPROVED_XCODE_VERSION" "$xcode_actual"

android_studio_actual=""
if [[ -d "/Applications/Android Studio.app" ]]; then
  android_studio_actual="$(defaults read "/Applications/Android Studio.app/Contents/Info" CFBundleShortVersionString 2>/dev/null || true)"
fi
check_version "Android Studio" "$VOCAS_APPROVED_ANDROID_STUDIO_VERSION" "$android_studio_actual"

cocoapods_actual=""
if vocas_have_command pod; then
  cocoapods_actual="$(pod --version 2>/dev/null | head -n 1)"
fi
check_version "CocoaPods" "$VOCAS_APPROVED_COCOAPODS_VERSION" "$cocoapods_actual"

docker_desktop_actual=""
if [[ -d "/Applications/Docker.app" ]]; then
  docker_desktop_actual="$(defaults read "/Applications/Docker.app/Contents/Info" CFBundleShortVersionString 2>/dev/null || true)"
fi
check_version "Docker Desktop" "$VOCAS_APPROVED_DOCKER_DESKTOP_VERSION" "$docker_desktop_actual"

if (( failure_count > 0 )); then
  vocas_die "${failure_count} of ${check_count} host toolchain checks failed"
fi

vocas_log "all ${check_count} host toolchain checks passed"
