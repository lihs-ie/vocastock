#!/usr/bin/env bash
# Guard against regressions of the "no mocks in production" policy
# (constitution principle #7 in CLAUDE.md). The script scans the
# release code paths for the names of known in-memory / stub
# implementations and fails the build if any of them reappear.
#
# Inclusions:
# - Rust backend `src/` trees for the three service crates
# - Rust backend `src/` trees for the shared crates
# - Haskell worker `src/` trees (sub-libraries under `tests/support-lib/`
#   are permitted and exempted by construction)
# - Flutter mobile `lib/src/`
#
# Exclusions: bash strings like panic messages that only name the type
# (e.g. `"... StubTokenVerifier is test-only"`) are allowed — the
# script matches **identifier uses** with word boundaries, and only
# prohibits code-level uses such as `StubTokenVerifier;` or
# `InMemoryCommandStore::default()`. Purely mentioning the identifier
# inside a comment or string literal does not match.

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

FAILURES=0

report() {
  local label="$1"
  local pattern="$2"
  shift 2
  local paths=("$@")
  local matches
  matches=$(grep -rEn "$pattern" "${paths[@]}" 2>/dev/null || true)
  if [[ -n "$matches" ]]; then
    echo "[no-mocks-in-production] ✗ ${label}" >&2
    echo "$matches" >&2
    FAILURES=$((FAILURES + 1))
  else
    echo "[no-mocks-in-production] ✓ ${label}"
  fi
}

# Rust: identifiers like `InMemoryCommandStore::default()`,
# `let x = InMemoryDispatchPort::...`, `Box::new(InMemoryCatalogProjectionSource...)`.
# Match a punctuation follower so comments / panic strings are skipped.
RUST_INMEMORY_USE='\b(InMemoryCommandStore|InMemoryDispatchPort|InMemoryCatalogProjectionSource|StubTokenVerifier)[[:space:]]*[:({;,]'

report "rust-backend src/ — production in-memory identifiers" \
  "$RUST_INMEMORY_USE" \
  applications/backend/command-api/src \
  applications/backend/query-api/src \
  applications/backend/graphql-gateway/src

report "rust-shared — production in-memory identifiers" \
  "$RUST_INMEMORY_USE" \
  packages/rust

# Haskell: usage of `emptyBillingStore`, `emptyExplanationStore`,
# `emptyImageStore` inside production `src/` trees.
HASKELL_INMEMORY_USE='\b(emptyBillingStore|emptyExplanationStore|emptyImageStore)\b'

report "haskell-workers src/ — empty stores" \
  "$HASKELL_INMEMORY_USE" \
  applications/backend/billing-worker/src \
  applications/backend/explanation-worker/src \
  applications/backend/image-worker/src

# Flutter: lib/src/ must not import or instantiate the test stubs.
# Allow the literal string "stub" inside paths under tests/support/.
FLUTTER_STUB_IMPORT='^import .*infrastructure/stub/|\bStub(ActorHandoffController|VocabularyCatalog|CompletedDetails|SubscriptionState|LearningStateReader)\b'

report "flutter-mobile lib/src/ — stub adapters" \
  "$FLUTTER_STUB_IMPORT" \
  applications/mobile/lib/src

if [[ "$FAILURES" -gt 0 ]]; then
  echo "[no-mocks-in-production] ${FAILURES} categor(ies) leaked mock/in-memory types into production." >&2
  echo "See CLAUDE.md \"Core Architectural Principle #7\" for the policy." >&2
  exit 1
fi

echo "[no-mocks-in-production] production code is clear of synthetic adapters."
