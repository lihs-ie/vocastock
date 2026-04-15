#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

root="$(vocas_repo_root)"
env_doc="$root/docs/development/flutter-environment.md"
policy_doc="$root/docs/development/ci-policy.md"
security_doc="$root/docs/development/security-version-review.md"

grep -q 'Rust' "$env_doc" || vocas_die "flutter-environment.md must mention Rust toolchain"
grep -q 'Haskell' "$env_doc" || vocas_die "flutter-environment.md must mention Haskell toolchain"
grep -q 'Pub/Sub' "$env_doc" || vocas_die "flutter-environment.md must mention Pub/Sub fallback"
grep -q 'Google Drive' "$env_doc" || vocas_die "flutter-environment.md must mention Google Drive fallback"
grep -q '.env.example' "$env_doc" || vocas_die "flutter-environment.md must reference docker/firebase/env/.env.example"
grep -q 'stub-setting' "$policy_doc" || vocas_die "ci-policy.md must classify stub settings"
grep -q 'service family' "$security_doc" || vocas_die "security-version-review.md must explain service family governance"

vocas_log "stack alignment validation passed"
