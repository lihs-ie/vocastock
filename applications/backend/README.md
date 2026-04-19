# Backend Workspace

vocastock backend の初期 runtime skeleton をここに置く。

- `graphql-gateway`: client-facing unified GraphQL endpoint
- `command-api`: command acceptance / write / dispatch
- `query-api`: completed result / status-only / subscription read
- `explanation-worker`: explanation workflow consumer
- `image-worker`: image workflow consumer
- `billing-worker`: billing / restore / notification reconciliation consumer

Docker 関連ファイルは `docker/applications/<application>/` を正本とする。
API service は `HTTP readiness endpoint` を canonical success signal とし、worker は
`long-running consumer` の stable-run を canonical success signal とする。

ローカル検証:

- contract validate: `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_application_containers.sh`
- application smoke: `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`
