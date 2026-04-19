#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

vocas_require_command docker
docker info >/dev/null

compose_file="$(vocas_application_compose_file)"
env_template="$(vocas_application_env_template)"
env_file="$(vocas_prepare_application_env_file)"

[[ -f "$compose_file" ]] || vocas_die "missing application compose file: $compose_file"
[[ -f "$env_template" ]] || vocas_die "missing application env template: $env_template"

for application_name in graphql-gateway command-api query-api; do
  dockerfile_path="$(vocas_repo_root)/docker/applications/${application_name}/Dockerfile"
  [[ -f "$dockerfile_path" ]] || vocas_die "missing API Dockerfile: $dockerfile_path"
done

for worker_name in explanation-worker image-worker billing-worker; do
  dockerfile_path="$(vocas_repo_root)/docker/applications/${worker_name}/Dockerfile"
  entrypoint_path="$(vocas_repo_root)/docker/applications/${worker_name}/entrypoint.sh"
  [[ -f "$dockerfile_path" ]] || vocas_die "missing worker Dockerfile: $dockerfile_path"
  [[ -f "$entrypoint_path" ]] || vocas_die "missing worker entrypoint: $entrypoint_path"
done

docker compose --env-file "$env_file" -f "$compose_file" config >/dev/null

vocas_log "application container contract is available via ${compose_file}"
