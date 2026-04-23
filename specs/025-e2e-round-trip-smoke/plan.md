# Implementation Plan: E2E Round-Trip Smoke

**Spec**: `specs/025-e2e-round-trip-smoke/spec.md`
**Contract**: `specs/025-e2e-round-trip-smoke/contracts/e2e-round-trip-smoke-contract.md`
**Branch**: `024-flutter-client-ui-implementation` (本 issue 対応を同一 branch 内で完結)

## 実装レイヤー

本 feature は application inner layer を新設せず、**CI / shell 層と test helper 層** にのみ artifact を追加する。Rust / Haskell の production code は変更しない (CLAUDE.md「production にモック/インメモリなし」遵守)。

| Layer | Owner | 追加 / 修正 artifact |
|---|---|---|
| CI driver | `scripts/ci/` | `run_e2e_round_trip_smoke.sh` (新規) |
| CI helper | `scripts/lib/` | `vocastock_env.sh` (定数 + helper 追加) |
| CI stub | `scripts/ci/` | `e2e_stub_providers.mjs` (新規 Node HTTP server) |
| CI workflow | `.github/workflows/` | `ci.yml` (新 job `e2e-round-trip-smoke` + budget needs) |
| Container contract | `docker/applications/` | `compose.yaml` (`x-worker-environment` に `ANTHROPIC_API_BASE_URL` / `STABILITY_API_BASE_URL` mapping 追加) |
| Spec | `specs/025-e2e-round-trip-smoke/` | `spec.md` / `plan.md` / `contracts/*.md` / `quickstart.md` (本 PR 同梱) |

Worker adapter (`AnthropicAdapter.hs` / `StabilityAdapter.hs`) は `ANTHROPIC_API_BASE_URL` / `STABILITY_API_BASE_URL` env override を既にサポート済み。追加実装は不要。

## Phase 分解と依存

```
A1 spec.md ──┐
A2 plan.md ──┼── 並列実装可 (docs-first)
A3 contract ─┘
              │
              ▼
             B1 e2e_stub_providers.mjs ─┐
             C1 vocastock_env.sh helpers ─┐
                                          ▼
                                         C2 run_e2e_round_trip_smoke.sh
                                          │
                                          ▼
                                         D1 ci.yml (new job + budget needs)
                                          │
                                          ▼
                                         F1 docker/applications/compose.yaml
                                          │
                                          ▼
                                         E1 quickstart.md (検証コマンド明記)
                                          │
                                          ▼
                                         Local verification
                                          │
                                          ▼
                                         Commit & push
```

## Phase A — Spec / Contract (docs-first)

- **A1** `spec.md`: User Stories (3) / Functional Requirements / Success Criteria / Out of Scope を明記
- **A2** `plan.md`: 本ファイル
- **A3** `contracts/e2e-round-trip-smoke-contract.md`: stage 列 / timeout / diagnostics / mutation-query 契約を固定

## Phase B — Upstream stub

- **B1** `scripts/ci/e2e_stub_providers.mjs`:
  - Node 24 の `node:http` で HTTP server を実装 (追加 npm 依存なし)
  - `GET /readyz` → 200 `OK`
  - `POST /v1/messages` → Anthropic success fixture (`AnthropicDevProvider.hs` の `payloadText` schema を複製)
  - 受領 request を `.artifacts/ci/logs/e2e-round-trip-smoke.stub-access.log` に `ISO8601 method path\n` 形式で append
  - `SIGTERM` / `SIGINT` で graceful shutdown
  - CLI 引数: `--port <port>` (未指定なら空きポートを listen、stdout に `listening on {port}` を出力して driver が port を拾える)

## Phase C — Shell driver

- **C1** `scripts/lib/vocastock_env.sh` 拡張:
  - 定数: `VOCAS_E2E_ROUND_TRIP_BUDGET_SECONDS=550`, `VOCAS_E2E_ROUND_TRIP_NAMESPACE=e2e-round-trip-smoke`, `VOCAS_E2E_POLL_INTERVAL_SECONDS=2`, `VOCAS_E2E_POLL_MAX_RETRIES=60`
  - Helpers: `vocas_e2e_round_trip_summary_file`, `vocas_e2e_round_trip_stage_file`, `vocas_e2e_round_trip_compose_logs_file`, `vocas_e2e_round_trip_firestore_snapshot_file`, `vocas_e2e_round_trip_pubsub_state_file`, `vocas_e2e_round_trip_stub_access_log_file`, `vocas_e2e_round_trip_duration_file`

- **C2** `scripts/ci/run_e2e_round_trip_smoke.sh`:
  - `run_application_container_smoke.sh` の epoch-timeout / trap-cleanup / summary-file パターンを複製
  - 独立 `COMPOSE_PROJECT_NAME=vocastock-e2e-round-trip-$$` で port 分離
  - stage 1-11 を実行 (詳細は contract.md)
  - `--skip-build` / `--reuse-running` flag をサポート
  - trap で diagnostics dump → compose down → emulator stop → stub kill

## Phase D — CI workflow

- **D1** `.github/workflows/ci.yml`:
  - 新 job `e2e-round-trip-smoke` (runner: ubuntu-24.04, timeout-minutes: 12, needs: toolchain-validate)
  - steps:
    1. `actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd`
    2. `bash scripts/ci/run_e2e_round_trip_smoke.sh`
    3. `actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` → `ci-metrics-e2e-round-trip-smoke`
  - `ci-runtime-budget.needs` に `e2e-round-trip-smoke` を追加

## Phase F — Container compose

- **F1** `docker/applications/compose.yaml`:
  - `x-worker-environment` anchor に以下 2 mapping を追加:
    ```yaml
    ANTHROPIC_API_BASE_URL: ${ANTHROPIC_API_BASE_URL:-}
    STABILITY_API_BASE_URL: ${STABILITY_API_BASE_URL:-}
    ```
  - default 空値で production 影響なし。smoke 実行時のみ driver が env を設定

## Phase E — Quickstart

- **E1** `specs/025-e2e-round-trip-smoke/quickstart.md`:
  - Local 実行コマンド (初回 / `--skip-build` 再実行 / `--reuse-running`)
  - Expected output サマリ
  - Diagnostics file location 一覧
  - トラブルシュート (Docker non-running / port conflict / stub crash)

## Verification

### Local
```bash
bash scripts/ci/run_e2e_round_trip_smoke.sh
```
**成功条件**: exit 0、`.artifacts/ci/durations/e2e-round-trip-smoke.seconds` が記録される、`summary` の末尾が `status=completed`

### Regression check
```bash
# 既存 application smoke が壊れていないこと
bash scripts/ci/run_application_container_smoke.sh

# production に mock が漏れていないこと
bash scripts/ci/verify_no_mock_in_production.sh
```

### CI
- push 後、GitHub Actions の `e2e-round-trip-smoke` job が green
- `application-container-smoke` と `e2e-round-trip-smoke` が並列に走る
- `ci-runtime-budget` job が pass (Linux aggregate 30 分以内)
- artifact `ci-metrics-e2e-round-trip-smoke` が期待 file 全てを含む

## Risk mitigation (spec 25 で追跡)

| 項目 | 緩和策 |
|---|---|
| Stage 8 (lag 観測) の flakiness | best-effort 化、warning log のみ |
| 10 分 buffer 不足 (初回 CI) | `timeout-minutes: 12` + internal 550s、初回 cache miss 時のみ長い |
| Pub/Sub 取りこぼし | 60 retry @ 2s interval (合計 120s) |
| stub 異常終了 | trap cleanup、failure stage に `stubs-crashed` 記録 |
| ID 衝突 | vocabulary id に epoch suffix を付与 |
| compose project name 衝突 | `$$` (PID) で分離 |
