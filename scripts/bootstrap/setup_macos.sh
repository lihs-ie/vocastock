#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_macos
vocas_ensure_artifact_directories

env_template="$(vocas_repo_root)/docker/firebase/env/.env.example"
env_file="$(vocas_repo_root)/docker/firebase/env/.env"
if [[ ! -f "$env_file" ]]; then
  cp "$env_template" "$env_file"
  vocas_log "created local emulator env file at docker/firebase/env/.env"
fi

cat <<EOF
vocastock macOS bootstrap

Approved versions
- macOS Host: ${VOCAS_APPROVED_MACOS_VERSION}
- Flutter SDK: ${VOCAS_APPROVED_FLUTTER_VERSION}
- Xcode: ${VOCAS_APPROVED_XCODE_VERSION}
- Android Studio: ${VOCAS_APPROVED_ANDROID_STUDIO_LABEL}
- CocoaPods: ${VOCAS_APPROVED_COCOAPODS_VERSION}
- Docker Desktop: ${VOCAS_APPROVED_DOCKER_DESKTOP_VERSION}

Recommended install flow
1. Confirm the host is macOS ${VOCAS_APPROVED_MACOS_VERSION}
2. Install or update Homebrew: https://brew.sh/
3. Install Flutter ${VOCAS_APPROVED_FLUTTER_VERSION} from https://docs.flutter.dev/install/manual
4. Install Xcode ${VOCAS_APPROVED_XCODE_VERSION} from the App Store or Apple Downloads
5. Install Android Studio ${VOCAS_APPROVED_ANDROID_STUDIO_LABEL} from https://developer.android.com/studio
6. Install CocoaPods ${VOCAS_APPROVED_COCOAPODS_VERSION}: sudo gem install cocoapods -v ${VOCAS_APPROVED_COCOAPODS_VERSION}
7. Install Docker Desktop ${VOCAS_APPROVED_DOCKER_DESKTOP_VERSION} from https://www.docker.com/products/docker-desktop/

Bootstrap helpers
- Verify host toolchain: bash scripts/bootstrap/verify_macos_toolchain.sh
- Validate local setup: bash scripts/bootstrap/validate_local_setup.sh
- Start emulator budget clock: bash scripts/bootstrap/measure_local_setup_budget.sh start
- Finish local setup budget check: bash scripts/bootstrap/measure_local_setup_budget.sh finish
EOF

if [[ "${1:-}" == "--check" ]]; then
  exec bash "$SCRIPT_DIR/verify_macos_toolchain.sh"
fi
