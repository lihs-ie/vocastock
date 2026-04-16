#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command gh

payload_file="$SCRIPT_DIR/github_ruleset_payload.json"
[[ -f "$payload_file" ]] || vocas_die "missing payload file: $payload_file"

vocas_log "applying required-check ruleset managed by docs/development/ci-policy.md"

repository="${1:-}"
ruleset_identifier="${2:-}"

if [[ -z "$repository" ]]; then
  repository="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
fi

owner="${repository%%/*}"
repo_name="${repository##*/}"
[[ -n "$owner" && -n "$repo_name" ]] || vocas_die "usage: $0 <owner/repo> [ruleset_identifier]"

if [[ -z "$ruleset_identifier" ]]; then
  ruleset_identifier="$(gh api "repos/${owner}/${repo_name}/rulesets" --jq '.[] | select(.name=="vocastock-protected-branches") | .id' 2>/dev/null || true)"
fi

if [[ -n "$ruleset_identifier" ]]; then
  gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "repos/${owner}/${repo_name}/rulesets/${ruleset_identifier}" \
    --input "$payload_file" >/dev/null
  vocas_log "updated GitHub ruleset ${ruleset_identifier} for ${owner}/${repo_name}"
else
  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "repos/${owner}/${repo_name}/rulesets" \
    --input "$payload_file" >/dev/null
  vocas_log "created GitHub ruleset for ${owner}/${repo_name}"
fi
