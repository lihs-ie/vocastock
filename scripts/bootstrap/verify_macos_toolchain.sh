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

macos_actual="$(sw_vers -productVersion 2>/dev/null || true)"
check_version "macOS Host" "$VOCAS_APPROVED_MACOS_VERSION" "$macos_actual"

flutter_actual=""
if flutter_bin="$(vocas_resolve_flutter_bin 2>/dev/null || true)"; then
  flutter_root="$(CDPATH="" cd "$(dirname "$flutter_bin")/.." && pwd)"
  flutter_manifest="${flutter_root}/bin/cache/flutter.version.json"
  if [[ -f "$flutter_manifest" ]]; then
    flutter_actual="$(sed -n 's/.*"flutterVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$flutter_manifest" | head -n 1)"
  else
    flutter_output="$("$flutter_bin" --version 2>/dev/null || true)"
    flutter_actual="$(printf "%s\n" "$flutter_output" | awk 'NR == 1 { print $2 }')"
  fi
fi
check_version "Flutter SDK" "$VOCAS_APPROVED_FLUTTER_VERSION" "$flutter_actual"

xcode_actual=""
if vocas_have_command xcodebuild; then
  xcode_output="$(xcodebuild -version 2>/dev/null || true)"
  xcode_actual="$(printf "%s\n" "$xcode_output" | awk 'NR == 1 { print $2 }')"
fi
check_version "Xcode" "$VOCAS_APPROVED_XCODE_VERSION" "$xcode_actual"

android_studio_actual=""
if [[ -d "/Applications/Android Studio.app" ]]; then
  android_studio_actual="$(plutil -extract CFBundleShortVersionString raw -o - "/Applications/Android Studio.app/Contents/Info.plist" 2>/dev/null || true)"
fi
check_version "Android Studio" "$VOCAS_APPROVED_ANDROID_STUDIO_VERSION" "$android_studio_actual"

cocoapods_actual=""
if vocas_have_command pod; then
  cocoapods_actual="$(pod --version 2>/dev/null || true)"
fi
check_version "CocoaPods" "$VOCAS_APPROVED_COCOAPODS_VERSION" "$cocoapods_actual"

docker_desktop_actual=""
if [[ -d "/Applications/Docker.app" ]]; then
  docker_desktop_actual="$(plutil -extract CFBundleShortVersionString raw -o - "/Applications/Docker.app/Contents/Info.plist" 2>/dev/null || true)"
fi
check_version "Docker Desktop" "$VOCAS_APPROVED_DOCKER_DESKTOP_VERSION" "$docker_desktop_actual"

if (( failure_count > 0 )); then
  vocas_die "${failure_count} of ${check_count} host toolchain checks failed"
fi

vocas_log "all ${check_count} host toolchain checks passed"
