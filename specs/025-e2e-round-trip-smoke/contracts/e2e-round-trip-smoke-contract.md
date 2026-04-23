# Contract: E2E Round-Trip Smoke

**Namespace**: `e2e-round-trip-smoke`
**Owner**: CI platform (backend)
**Related specs**: 006 (emulator), 012 (workflow state machine), 015 (topology), 016 (container env), 021 (explanation-worker)

## 目的

`command accept → Pub/Sub dispatch → worker consume → Firestore write → query-api read` の一連の round-trip が、CI 上で全 application container と Firebase emulator を起動した状態で機械的に動作することを保証する契約。

本契約は実装 artifact として以下 2 つを定義する:

- Driver script: `scripts/ci/run_e2e_round_trip_smoke.sh`
- Upstream stub: `scripts/ci/e2e_stub_providers.mjs`

## Non-goals

- Production 実行経路への mock / in-memory fallback 追加 (Constitution 原則 III / IV 違反)
- Load / chaos / fuzz 系テスト
- image-worker round-trip (初版は explanation のみ。image-worker は stub startup 検証のみ)
- Flutter mobile integration (別 issue)

## Stage 契約

Driver script は以下の stage を順に実行し、各 stage 名を `.artifacts/ci/logs/e2e-round-trip-smoke.stage` に記録する。失敗時は最後に記録された stage 名が原因特定の起点となる。

| # | Stage name | Success condition |
|---|---|---|
| 1 | `init` | port 割当、`.artifacts/ci/logs/e2e-round-trip-smoke.*` 初期化完了 |
| 2 | `stubs-up` | Node stub server が `/readyz` 200 を返す |
| 3 | `firebase-emulators` | `scripts/firebase/start_emulators.sh` + `smoke_local_stack.sh` 成功 |
| 4 | `seed` | `scripts/firebase/seed_emulators.sh` 成功 (PubSub topic/subscription 作成含む) |
| 5 | `compose-up` | `docker compose up -d --build` が exit 0、全 6 services が `running` |
| 6 | `readiness` | graphql-gateway / command-api / query-api の `/readyz` が 200、worker 3 種が `running` 状態を維持 |
| 7 | `mutation-accepted` | gateway への `registerVocabularyExpression` mutation が `"acceptance":"accepted"` と `vocabularyExpression` identifier を返す |
| 8 | `status-only-observed` | **best effort** — `vocabularyCatalog` query の対象 item が `"visibility":"status-only"` を返す。取得できなくても `warning` log のみで次段へ進む |
| 9 | `firestore-polling` | Firestore emulator REST を 2s 間隔で poll、`actors/{actor}/vocabularyExpressions/{vocab}` の `explanationStatus=succeeded` かつ `currentExplanation != null` を検出 (最大 120s) |
| 10 | `completed-observed` | `vocabularyExpressionDetail` query が `"explanationStatus":"SUCCEEDED"` + `"currentExplanation":"exp-*"` を返し、かつ `vocabularyCatalog` query の対象 item が `"visibility":"completed-summary"` を返す |
| 11 | `cleanup` | compose down、emulator stop、stub kill (trap により常に実行) |

## Success signal

全 stage 完了かつ stage 10 の assert が pass した時点で round-trip smoke は success とみなす。`.artifacts/ci/logs/e2e-round-trip-smoke.summary` の末尾に `status=completed` 行を追記する。

## Timeout budget

- Script internal: **550s** (`VOCAS_E2E_ROUND_TRIP_BUDGET_SECONDS`)
- CI job (`timeout-minutes`): **12分** (2分 buffer)
- Firestore polling: 120s (60 retry @ 2s interval)
- Best-effort lag observation: 5s (検出 window、取れなければ skip)

## Diagnostics 契約

失敗時 (trap 起動時) に driver script は以下を `.artifacts/ci/` 配下に出力する。

| File | 内容 |
|---|---|
| `logs/e2e-round-trip-smoke.stage` | 最後に記録された stage 名 |
| `logs/e2e-round-trip-smoke.summary` | 各 stage の結果サマリ、port 情報、elapsed time |
| `logs/e2e-round-trip-smoke.compose-logs.txt` | `docker compose logs` 全 6 services 分 |
| `logs/e2e-round-trip-smoke.firestore-snapshot.json` | `actors/stub-actor-demo/vocabularyExpressions` の最終状態 (Firestore REST) |
| `logs/e2e-round-trip-smoke.pubsub-state.txt` | `workflow.explanation-jobs.sub` 等の pull エラー / backlog 情報 |
| `logs/e2e-round-trip-smoke.stub-access.log` | Node stub server が受領した HTTP request 列 (append-only) |
| `durations/e2e-round-trip-smoke.seconds` | 経過秒数 (成功時のみ) |

## Upstream stub 契約

Node stub (`scripts/ci/e2e_stub_providers.mjs`) は以下を満たす:

- Host 127.0.0.1 の空き port で HTTP listen
- `GET /readyz` → 200 `OK`
- `POST /v1/messages` (Anthropic) → 200 with body `{ "id": "msg_e2e", "content": [{ "type": "text", "text": "<explanation JSON>" }] }`。`<explanation JSON>` は `AnthropicDevProvider.hs` の `payloadText` と同一 schema: `summary / senses / frequency / sophistication / pronunciation / etymology / similar_expressions`
- API key 検証は素通し (`x-api-key` header の値を問わない)
- 受領 request は `.artifacts/ci/logs/e2e-round-trip-smoke.stub-access.log` に `ISO8601 method path\n` 形式で append
- `SIGTERM` / `SIGINT` でクリーンに終了

## Worker env override 契約

docker compose の worker-environment section に以下 2 変数を伝搬させる (空値 default で production 影響なし):

```yaml
ANTHROPIC_API_BASE_URL: ${ANTHROPIC_API_BASE_URL:-}
STABILITY_API_BASE_URL: ${STABILITY_API_BASE_URL:-}
```

Driver script はこの env を `host.docker.internal:{stub_port}` に設定した smoke 専用 env file を生成する。Production deploy では本 env は未設定となり、worker adapter は `resolveBaseUrl` の default URL (`https://api.anthropic.com` 等) を用いる。

## Mutation / Query 契約

### Stage 7: `registerVocabularyExpression`

- Path: `POST {gateway}/graphql`
- Headers: `Authorization: Bearer {demo-user id token}`, `x-request-correlation: e2e-{epoch}-register`, `content-type: application/json`
- Body (variables):
  - `actor`: `"stub-actor-demo"` (seed 済み)
  - `idempotencyKey`: `"e2e-smoke-{epoch}"` (unique per run)
  - `text`: `"smoke round trip {epoch}"` (normalized → `vocabulary:smoke-round-trip-{epoch}`)
  - `startExplanation`: `true`
- Expected response: HTTP 200、body に `"acceptance":"accepted"` と `"vocabularyExpression":"vocabulary:smoke-round-trip-{epoch}"`

### Stage 8: `vocabularyCatalog` (best effort)

- Path: `POST {gateway}/graphql`
- Query: `query VocabularyCatalog { vocabularyCatalog { items { vocabularyExpression visibility } } }`
- Expected: `items[].vocabularyExpression == "vocabulary:smoke-round-trip-{epoch}"` の entry が `visibility == "status-only"` を返す。取得できない場合は warning log のみ

### Stage 9: Firestore polling

- Path: `GET http://127.0.0.1:{firestore_port}/v1/projects/demo-vocastock/databases/(default)/documents/actors/stub-actor-demo/vocabularyExpressions/vocabulary:smoke-round-trip-{epoch}`
- Success: JSON response の `fields.explanationStatus.stringValue == "succeeded"` かつ `fields.currentExplanation.stringValue` が `exp-` prefix で始まる値を持つ

### Stage 10: `vocabularyExpressionDetail` + `vocabularyCatalog`

- Query 1: `query VocabularyExpressionDetail($identifier: String!) { vocabularyExpressionDetail(identifier: $identifier) { identifier explanationStatus currentExplanation } }`
- Expected: `explanationStatus == "SUCCEEDED"` かつ `currentExplanation` が non-null
- Query 2: stage 8 と同じ catalog query を再送、同 item が `visibility == "completed-summary"` を返す

## CI 統合契約

- Job name: `e2e-round-trip-smoke`
- Runner: `ubuntu-24.04`
- `timeout-minutes: 12`
- `needs: toolchain-validate`
- `ci-runtime-budget.needs` に本 job を追加
- artifact upload: `ci-metrics-e2e-round-trip-smoke` → `.artifacts/ci/`
- `application-container-smoke` とは **並列実行** (独立 `COMPOSE_PROJECT_NAME` で port/container 分離)

## 変更 / 拡張手順

stage 追加 / diagnostics file 追加 / stub endpoint 拡張を行う際は:

1. 本 contract を同じ変更セットで更新する
2. `scripts/ci/run_e2e_round_trip_smoke.sh` と `scripts/ci/e2e_stub_providers.mjs` の差分を契約に一致させる
3. `specs/025-e2e-round-trip-smoke/quickstart.md` の expected output を更新する

Constitution 原則 III (非同期生成は完了結果のみ公開) との整合性は、stage 8 (status-only) と stage 10 (completed) の両 invariant assert によって維持される。
