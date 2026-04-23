# Quickstart: E2E Round-Trip Smoke

## 前提

- Docker Desktop が起動していること
- `node` 24.14.1 以上 (stub server 用)
- `python3` 3.9 以上 (JSON parsing 用)
- `curl` が利用可能であること
- `docker/firebase/env/.env` が存在する (無い場合は `.env.example` を自動使用)

## ローカル実行

### 初回 (image build 含む)

```bash
bash scripts/ci/run_e2e_round_trip_smoke.sh
```

初回は Rust と Haskell の application container image build (計 6 services) で時間がかかる。build cache が効けば 2 回目以降は大幅に短縮される。

### 再実行 (build をスキップ)

```bash
bash scripts/ci/run_e2e_round_trip_smoke.sh --skip-build
```

### 既存の compose stack を再利用 (cleanup しない)

```bash
bash scripts/ci/run_e2e_round_trip_smoke.sh --reuse-running
```

## 成功時の expected output

Exit 0 で終わり、以下の artifact が生成される:

```
.artifacts/ci/
├── durations/
│   └── e2e-round-trip-smoke.seconds
└── logs/
    ├── e2e-round-trip-smoke.stage                  # 末尾 "cleanup"
    ├── e2e-round-trip-smoke.summary                # 末尾 "status=completed"
    ├── e2e-round-trip-smoke.env                    # 実行時 env snapshot
    ├── e2e-round-trip-smoke.compose-logs.txt       # 全 6 サービス分
    ├── e2e-round-trip-smoke.firestore-snapshot.json
    ├── e2e-round-trip-smoke.pubsub-state.txt
    ├── e2e-round-trip-smoke.stub-access.log        # Anthropic stub 受信ログ
    └── e2e-round-trip-smoke.stub-server.log        # Node stub stdout/stderr
```

`e2e-round-trip-smoke.summary` 例:

```
epoch=1714000000
vocabulary_identifier=vocabulary:smoke-round-trip-1714000000
idempotency_key=e2e-smoke-1714000000-12345
actor_uid=stub-actor-demo
compose_project_name=vocastock-e2e-1714000000-12345
stub_port=51234
ANTHROPIC_API_BASE_URL=http://host.docker.internal:51234
STABILITY_API_BASE_URL=http://host.docker.internal:51234
register_response={"data":{"registerVocabularyExpression":{"acceptance":"accepted", ...}}}
firestore_current_explanation=exp-...
detail_response={"data":{"vocabularyExpressionDetail":{"explanationStatus":"SUCCEEDED","currentExplanation":"exp-..."}}}
catalog_done_response={"data":{"vocabularyCatalog":{"items":[{"vocabularyExpression":"vocabulary:smoke-round-trip-...","visibility":"completed-summary"}, ...]}}}
elapsed_seconds=NNN
status_only_observed=yes|no
status=completed
```

## 失敗時の diagnostics

失敗すると trap により以下が強制 dump される:

| File | 見るべきポイント |
|---|---|
| `.artifacts/ci/logs/e2e-round-trip-smoke.stage` | 最後の stage 名で原因レイヤ特定 |
| `.artifacts/ci/logs/e2e-round-trip-smoke.summary` | 各 response の内容、elapsed_seconds |
| `.artifacts/ci/logs/e2e-round-trip-smoke.compose-logs.txt` | 各 service の startup / runtime error |
| `.artifacts/ci/logs/e2e-round-trip-smoke.firestore-snapshot.json` | Firestore 側の最終状態 |
| `.artifacts/ci/logs/e2e-round-trip-smoke.pubsub-state.txt` | Pub/Sub subscription の pending / backlog |
| `.artifacts/ci/logs/e2e-round-trip-smoke.stub-access.log` | worker → stub へのリクエスト列 |

### よくある stage 名と対処

| `stage` 値 | 原因候補 | 対処 |
|---|---|---|
| `stubs-up` | node/port/permissions | `node --version`、Port 競合、`stub-server.log` |
| `firebase-emulators` | emulator image 未 pull / port 衝突 | `scripts/firebase/start_emulators.sh` 単独実行 |
| `seed` | firebase admin 依存欠落 | `pnpm --dir firebase/seed install` |
| `compose-up` | Dockerfile エラー | `compose-logs.txt` の該当 service を確認 |
| `readiness` | 起動時 env 不足 | `compose-logs.txt` で `missing required env var` を検索 |
| `mutation-accepted` | gateway / command-api 連携失敗 | `summary.register_response` を確認 |
| `status-only-observed` | (warning のみ) | projection lag 観測漏れ、通常は無視可 |
| `firestore-polling` | worker consume 停止 | `stub-access.log` が空なら PubSub dispatch が問題、非空なら worker が write に失敗 |
| `completed-observed` | query-api 読取失敗 | `detail_response` / `catalog_done_response` を確認 |

## Regression 確認

本 feature 追加後、既存 smoke / guard が壊れていないことを確認:

```bash
# 既存 application smoke
bash scripts/ci/run_application_container_smoke.sh

# production にモック混入なし
bash scripts/ci/verify_no_mock_in_production.sh

# compose config validation
bash scripts/bootstrap/validate_application_containers.sh
```

## CI

push 後、GitHub Actions の `e2e-round-trip-smoke` job が ≤12 分で green を期待。`application-container-smoke` とは並列に実行される。

`ci-runtime-budget` job が pass すれば Linux aggregate 30 分予算に収まっている。

## トラブルシュート

### `docker info` が失敗する

Docker Desktop を起動してから再実行。

### Port 競合

`run_application_container_smoke.sh` や別 smoke が同時に走っていないか確認。local では並列実行は想定していない。`--reuse-running` flag で既存 stack を再利用するか、他 smoke を停止する。

### Node stub が listen できない

`.artifacts/ci/logs/e2e-round-trip-smoke.stub-server.log` を確認。多くは `EADDRINUSE` か node バージョン不一致。

### Worker が consume しない

`.artifacts/ci/logs/e2e-round-trip-smoke.stub-access.log` に `POST /v1/messages` が記録されているか確認。記録が無い場合は:
1. `compose-logs.txt` で `explanation-worker` の起動エラーを確認
2. `pubsub-state.txt` で `workflow.explanation-jobs.sub` にメッセージが pending していないか確認
3. `command-api` の log で dispatch が成功したか確認
