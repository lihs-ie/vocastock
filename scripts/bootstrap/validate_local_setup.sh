#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_macos
vocas_ensure_artifact_directories

bash "$SCRIPT_DIR/verify_macos_toolchain.sh"

vocas_require_command docker
docker info >/dev/null

env_template="$(vocas_repo_root)/docker/firebase/env/.env.example"
env_file="$(vocas_repo_root)/docker/firebase/env/.env"
if [[ ! -f "$env_file" ]]; then
  cp "$env_template" "$env_file"
  vocas_log "seeded docker/firebase/env/.env from example"
fi

if vocas_have_command flutter; then
  flutter doctor --verbose
else
  vocas_die "flutter is not installed"
fi

if project_dir="$(vocas_find_flutter_project_dir)"; then
  vocas_log "detected Flutter project at ${project_dir}"
else
  vocas_warn "no Flutter project detected yet; build/test checks remain informational until app code is added"
fi

vocas_log "local setup validation passed"
