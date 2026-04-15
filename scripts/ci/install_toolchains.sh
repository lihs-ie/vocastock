#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_ensure_artifact_directories
vocas_enable_workspace_npm_global

vocas_require_command node
vocas_require_command npm
vocas_require_command java

if vocas_have_command flutter; then
  current_flutter="$(flutter --version 2>/dev/null | head -n 1 | awk '{print $2}' || true)"
  if [[ -z "$current_flutter" ]]; then
    vocas_warn "flutter is installed but its version could not be read; continuing without Flutter pin validation"
  elif [[ "$current_flutter" != "$VOCAS_APPROVED_FLUTTER_VERSION" ]]; then
    vocas_warn "expected Flutter ${VOCAS_APPROVED_FLUTTER_VERSION}, got ${current_flutter:-missing}"
  fi
else
  vocas_warn "flutter is not available; install it before running Flutter-specific checks"
fi

firebase_bin="$(vocas_npm_global_bin)/firebase"
firebase_package_dir="$(vocas_npm_global_prefix)/lib/node_modules/firebase-tools"
firebase_package_manifest="$firebase_package_dir/package.json"
firebase_version=""
if [[ -f "$firebase_package_manifest" ]]; then
  firebase_version="$(node -p "require(process.argv[1]).version" "$firebase_package_manifest" 2>/dev/null || true)"
fi

if [[ "$firebase_version" != "$VOCAS_APPROVED_FIREBASE_TOOLS_VERSION" ]]; then
  rm -rf "$firebase_package_dir" "$firebase_bin"
  find "$(dirname "$firebase_package_dir")" -maxdepth 1 -type d -name '.firebase-tools-*' -exec rm -rf {} +
  npm install --global --no-fund --no-audit "firebase-tools@${VOCAS_APPROVED_FIREBASE_TOOLS_VERSION}"
fi

firebase_version="$(node -p "require(process.argv[1]).version" "$firebase_package_manifest" 2>/dev/null || true)"
if [[ "$firebase_version" != "$VOCAS_APPROVED_FIREBASE_TOOLS_VERSION" ]]; then
  vocas_die "expected firebase-tools ${VOCAS_APPROVED_FIREBASE_TOOLS_VERSION}, got ${firebase_version:-missing}"
fi

vocas_log "CI toolchain installation and verification completed"
