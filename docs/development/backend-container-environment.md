# Backend Container Environment

## Scope

この文書は backend / worker application の container contract を扱う。
対象は次の 6 application。

- `graphql-gateway`
- `command-api`
- `query-api`
- `explanation-worker`
- `image-worker`
- `billing-worker`

Flutter client は scope 外。`docker/firebase/` は repository-wide shared dependency stack として別管理する。

## Ownership Rule

- Docker 関連ファイルの正本は `docker/applications/<application>/`
- local orchestration の正本は `docker/applications/compose.yaml`
- shared env template の正本は `docker/applications/env/.env.example`
- local override は `docker/applications/env/.env` を使い、commit しない

## Success Signals

| Runtime family | Applications | Canonical success signal |
|---|---|---|
| API | `graphql-gateway`, `command-api`, `query-api` | `HTTP readiness endpoint` |
| Worker | `explanation-worker`, `image-worker`, `billing-worker` | `long-running consumer` の stable-run |

API は process 起動だけでは成功とみなさない。worker は外向き HTTP endpoint を必須にしない。

## Shared vs Application-Specific

### Shared baseline

- Docker-compatible runtime
- root Cargo workspace build context
- `docker/applications/compose.yaml`
- `docker/applications/<application>/Dockerfile`
- `docker/applications/env/.env.example`
- `scripts/bootstrap/validate_application_containers.sh`
- `scripts/ci/run_application_container_smoke.sh`

### Application-specific

- `graphql-gateway`: unified endpoint routing, readiness on `${GRAPHQL_GATEWAY_PORT}`
- `command-api`: command acceptance surface, readiness on `${COMMAND_API_PORT}`
- `query-api`: query read surface, readiness on `${QUERY_API_PORT}`
- worker 群: service port なし、entrypoint heartbeat と stable-run window を利用

## Required / Optional Inputs

| Variable | Required | Scope | Notes |
|---|---|---|---|
| `GRAPHQL_GATEWAY_PORT` | yes | API | host/container 共通 port |
| `COMMAND_API_PORT` | yes | API | host/container 共通 port |
| `QUERY_API_PORT` | yes | API | host/container 共通 port |
| `VOCAS_READINESS_PATH` | yes | API | readiness path |
| `VOCAS_WORKER_STABLE_RUN_SECONDS` | yes | Worker | stable-run 判定までの待機秒数 |
| `VOCAS_WORKER_POLL_INTERVAL_SECONDS` | yes | Worker | heartbeat 間隔 |
| `RUST_LOG` | no | API/Worker | log verbosity |
| `VOCAS_COMMAND_UPSTREAM_BASE_URL` | no | Gateway | internal routing default |
| `VOCAS_QUERY_UPSTREAM_BASE_URL` | no | Gateway | internal routing default |
| `VOCAS_PRODUCTION_ADAPTERS` | yes | API/Worker | production 経路で必須 (`true`/`1`/`yes`)。production binary は in-memory fixture を持たないため、未設定だと起動時に panic する |
| `PUBSUB_EMULATOR_HOST` | yes | API/Worker | `command-api` と worker の PubSub dispatch 経路で必須。emulator もしくは production PubSub の host:port |
| `FIRESTORE_EMULATOR_HOST` | yes | API/Worker | すべての Firestore adapter (`FirestoreCommandStore` / `FirestoreMutationCommandStore` / `FirestoreCatalogProjectionSource` / detail reader 群 / `SubscriptionPersistence`) で必須 |
| `FIREBASE_AUTH_EMULATOR_HOST` | yes | API | `FirebaseAuthTokenVerifier` の REST 宛先 |
| `STORAGE_EMULATOR_HOST` | yes | Worker | `image-worker` の `AssetStoragePort` で必須 |
| `ANTHROPIC_API_KEY` | yes | Worker | `explanation-worker` の `AnthropicAdapter` (smoke 時は placeholder でも OK) |
| `STABILITY_API_KEY` | yes | Worker | `image-worker` の `StabilityAdapter` (smoke 時は placeholder でも OK) |
| `STRIPE_SECRET_KEY` | yes | Worker | `billing-worker` の `StripePort` (smoke 時は placeholder でも OK) |

secret は committed local default に置かない。smoke script (`scripts/ci/run_application_container_smoke.sh`) は sentinel placeholder を自動注入して stable-run を確認する — placeholder で外部 API を実行することはない (smoke で PubSub queue は empty なので pull loop は idle)。

## Default Port Policy

- API の既定 host/container port は `18180`、`18181`、`18182` を使う
- `18080` は Firebase Firestore emulator の既定 host port と競合するため、application 側の既定値に使わない
- `scripts/ci/run_application_container_smoke.sh` は configured port が使用中なら `.artifacts/ci/logs/application-container-smoke.env` を一時生成し、空きポートへ自動退避して検証する
- `scripts/ci/run_local_stack_smoke.sh --with-application-containers` は `host.docker.internal` 経由で Firebase emulator host port を各 application container に注入し、API dependency probe と worker 起動前 check で実接続を検証する

## Commands

- contract validate: `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_application_containers.sh`
- application smoke: `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`
- local stack + app containers: `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --with-application-containers`

## Local / CI Contract

- local / CI は同じ Dockerfile / target / entry contract を使う
- image artifact 自体は local / CI で別 build を許可する
- CI は `.github/workflows/ci.yml` の `application-container-smoke` job で同じ smoke script を呼ぶ
- runtime duration と failure stage は `.artifacts/ci/` に出力する
- Firebase emulator を併用する local stack smoke では、API は `/dependencies/firebase` が 200 を返し、worker は dependency host へ到達できなければ early exit する
- Linux CI runner でも `host.docker.internal` を解決できるよう、`docker/applications/compose.yaml` は `host-gateway` mapping を持つ

## Rust Quality CI

- `.github/workflows/ci.yml` の `rust-quality` job は Rust 関連 path のみ `full` 実行し、非該当時は required check 名を維持した no-op success を返す
- change detection の正本は `bash /Users/lihs/workspace/vocastock/scripts/ci/detect_rust_changes.sh --base <base> --head <head>`
- local / CI の実行本体は `bash /Users/lihs/workspace/vocastock/scripts/ci/run_rust_quality_checks.sh --mode full|noop`
- Rust quality artifact は `.artifacts/ci/logs/rust-quality.*` と `.artifacts/ci/durations/rust-quality.seconds` に出力する
- feature segment は `VOCAS_FEATURE_REUSE_RUNNING=1` を使って 1 回の Firebase emulator session を `graphql-gateway`、`query-api`、`command-api` で共有する

## Troubleshooting

- `docker info` が失敗する: Docker Desktop / Docker daemon を起動する
- `docker compose ... config` が失敗する: `docker/applications/env/.env` を見直す。無ければ example から再生成される
- readiness timeout: port 競合、API binary 起動失敗、Docker build failure を確認する。smoke 実行時は `.artifacts/ci/logs/application-container-smoke.env` の実効ポートも確認する
- worker stable-run failure: worker container が early exit しているため `docker compose ps` と container log を確認する
- firebase emulator も併用する場合は ownership を混ぜず、まず `docker/firebase/`、次に application containers の順で切り分ける
