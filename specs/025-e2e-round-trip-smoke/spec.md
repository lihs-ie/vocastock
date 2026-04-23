# Feature Specification: E2E Command → Worker → Query Round-Trip Smoke

**Feature Branch**: `025-e2e-round-trip-smoke`
**Created**: 2026-04-24
**Status**: Draft
**Input**: User description (GitHub Issue #21): "既存の application-container-smoke は service 起動と worker stable-run (10s sleep) を見るだけで、『command 投入 → Pub/Sub dispatch → worker consume → Firestore write → query-api 読み取り』を 1 本で回す end-to-end smoke が存在しない。"

## Clarifications

### Session 2026-04-24

- Q: driver の主実装言語は何か → A: **shell script + Node stub**。Rust feature test ではない。既存 `run_application_container_smoke.sh` の stage/summary/trap-diagnostics の定型を再利用するため
- Q: worker が round-trip 中に外部 API (Anthropic / Stability) を呼ぶのをどう回避するか → A: **env override + Node stub server**。worker 側は既に `ANTHROPIC_API_BASE_URL` / `STABILITY_API_BASE_URL` の override をサポート済みなので、production コードは無変更で URL だけ差し替える
- Q: projection lag (status-only) の assert は必須か → A: **best effort**。worker consume 速度のレース条件で観測漏れが起きうるため、lag 観測は warning log 化し completed 観測 (stage 10) を主主張とする
- Q: image-worker round-trip も同時に検証するか → A: **初版は explanation-worker のみ**。image は Stability stub の schema 複雑化を伴うため別 follow-up issue
- Q: Flutter mobile integration test を同梱するか → A: **scope 外**。別 issue `#22 (仮)` に分離

## User Scenarios & Testing *(mandatory)*

### User Story 1 - deployment topology が round-trip で仕事をしていることを保証する (Priority: P1)

Backend 運用者として、全 application container と Firebase emulator を起動した状態で `command accept → dispatch → worker consume → Firestore write → query-api read` の round-trip が 1 本の CI job で機械的に検証できてほしい。そうすることで、spec 015 (topology) と spec 021 (explanation-worker) が実装された後、deployment 全体の整合性を退行させずに保てる。

**Why this priority**: 各レイヤーの feature test は既にあるが、deployment topology が動作する保証が無いと、spec 015 / 021 / 022 / 023 の実装が進むにつれて境界不整合の検出が遅れる。

**Independent Test**: 第三者が成果物だけを読み、round-trip が green になる条件と失敗時の原因特定手順を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** CI 上で全 application container と Firebase emulator が起動している, **When** `scripts/ci/run_e2e_round_trip_smoke.sh` を実行する, **Then** `command accept → Pub/Sub dispatch → worker consume → Firestore write → query-api read` の全段が pass し exit 0 を返す
2. **Given** worker consume が Pub/Sub 側で止まる / Firestore write が失敗する等の regression, **When** script が失敗する, **Then** `.artifacts/ci/logs/e2e-round-trip-smoke.stage` に失敗直前の stage 名が記録され、`compose-logs.txt` / `firestore-snapshot.json` / `pubsub-state.txt` / `stub-access.log` によって原因レイヤが即時特定できる
3. **Given** local 環境で同じ script を実行する, **When** 初回ビルドを含めても 10 分以内に完結する, **Then** CI と local で同じ契約で round-trip を検証できる

---

### User Story 2 - projection lag と completed 切替を明示的に assert する (Priority: P2)

Backend 運用者として、query-api が projection 反映前に `status-only`、反映後に `completed` を返す spec 015 の契約が実地で守られているかを、同じ smoke test 内で確認できてほしい。そうすることで、spec 015 の `VisibleGuarantee::CompletedOrStatusOnly` が production path で退行したときに CI で検出できる。

**Why this priority**: Constitution 原則 III (非同期生成は完了結果のみ公開) は production 経路の最重要 invariant。レイヤー単位のテストでは projection lag の状態遷移を観測しにくい。

**Independent Test**: 第三者が smoke test の stage ログを読み、どの時点で `status-only` / `completed` それぞれが assert されているかを 5 分以内に特定できれば成立する。

**Acceptance Scenarios**:

1. **Given** mutation 受理直後、Firestore projection が未反映, **When** `vocabularyCatalog` query を送る, **Then** 対象 item の `visibility` が `status-only` を返す (best effort; 観測できない場合は warning log)
2. **Given** worker consume が完了し Firestore write が反映された後, **When** 同じ query を再送する, **Then** 対象 item の `visibility` が `completed-summary` に切替わり、`vocabularyExpressionDetail` query が `explanationStatus=SUCCEEDED` と `currentExplanation` non-null を返す

---

### User Story 3 - worker 外部依存を production コード無変更で隔離する (Priority: P3)

Backend 実装担当者として、E2E smoke 中に worker が Anthropic / Stability の本物のエンドポイントを叩かないように隔離したい。ただし production binary にモックを仕込むのは Constitution 違反なので、**env override** と **test-scope stub server** の組み合わせで達成したい。

**Why this priority**: production path にモックを混入させると constitution 原則 III/IV を違反し、"no mocks in production" CI job も fail する。

**Independent Test**: 第三者が stub server (`scripts/ci/e2e_stub_providers.mjs`) の実装と worker adapter (`AnthropicAdapter.hs`) の `resolveBaseUrl` を読み、production 経路が無変更であることを 10 分以内に確認できれば成立する。

**Acceptance Scenarios**:

1. **Given** `ANTHROPIC_API_BASE_URL` が未設定 (production default), **When** worker が起動する, **Then** `https://api.anthropic.com` に向ける default URL が使われる
2. **Given** E2E smoke run 時のみ `ANTHROPIC_API_BASE_URL=http://host.docker.internal:{stub_port}` が worker container に注入される, **When** worker が PubSub メッセージを consume する, **Then** `/v1/messages` 呼び出しが Node stub に向かい、success fixture JSON を受領する
3. **Given** `scripts/ci/verify_no_mock_in_production.sh` が production path を検査する, **When** 本 feature の実装 (spec 025) 後に検査を実行する, **Then** stub / mock references が production binary 経路に存在せず、検査が pass する

### Edge Cases

- Pub/Sub emulator が稀にメッセージ取りこぼしをする場合 (stage 9 の retry で吸収)
- seed 済み `stub-actor-demo` に過去実行の smoke vocabulary が残留している場合 (epoch suffix 付き unique id で衝突回避)
- 初回 image build で `compose-up` stage が 2 分以上かかる場合 (stage-level timeout と全体 550s budget で吸収)
- stub server が途中で異常終了した場合 (trap cleanup で cleanup 漏れを防止、failure stage に `stubs-crashed` を記録)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: driver script は 11 stage を順に実行し、各 stage 名を `.artifacts/ci/logs/e2e-round-trip-smoke.stage` に記録する
- **FR-002**: stage 10 で `vocabularyExpressionDetail` query が `explanationStatus=SUCCEEDED` + `currentExplanation` non-null を返し、かつ `vocabularyCatalog` query が `visibility=completed-summary` を返すことを assert する
- **FR-003**: stage 8 で `vocabularyCatalog` query が `visibility=status-only` を返すことを best effort で assert する。未観測の場合は warning log のみで stage を通過する
- **FR-004**: 失敗時の trap は `.artifacts/ci/logs/e2e-round-trip-smoke.compose-logs.txt`、`firestore-snapshot.json`、`pubsub-state.txt`、`stub-access.log` を dump する
- **FR-005**: Script internal timeout は 550 秒。CI job `timeout-minutes: 12`。経過秒数は `.artifacts/ci/durations/e2e-round-trip-smoke.seconds` に書き出す
- **FR-006**: Node stub (`scripts/ci/e2e_stub_providers.mjs`) は Anthropic `/v1/messages` success body を返却し、受領 request を access log に append する
- **FR-007**: worker production binary は変更しない。`ANTHROPIC_API_BASE_URL` / `STABILITY_API_BASE_URL` env は docker compose の `x-worker-environment` 経由でのみ注入する
- **FR-008**: Smoke script は `application-container-smoke` と並列実行できるよう独立 `COMPOSE_PROJECT_NAME` (`vocastock-e2e-round-trip-{pid}`) を使用する
- **FR-009**: CI job `e2e-round-trip-smoke` は `ci-runtime-budget.needs` に追加され、Linux CI aggregate 30 分予算の対象になる

### Non-functional Requirements

- **NFR-001**: Local 実行も CI と同契約 (同 script / 同 env / 同 compose file) で再現可能であること
- **NFR-002**: stage 名は仕様と実装で一致し、`contracts/e2e-round-trip-smoke-contract.md` の表に登録されている名前のみを使う
- **NFR-003**: diagnostics artifact は失敗直後 (trap 内) に dump 完了していること。CI の `upload-artifact` step 到達時点で全 file が存在すること

## Key Dependencies

- spec 006 (CI emulator build) — emulator 起動契約
- spec 015 (command-query-topology) — `VisibleGuarantee::CompletedOrStatusOnly` 契約
- spec 016 (application-docker-env) — container readiness / stable-run 契約
- spec 021 (explanation-worker) — workflow state machine (queued / running / succeeded) 契約
- Constitution 原則 III (非同期生成は完了結果のみ公開) / 原則 IV (外部依存はポート越し)

## Success Criteria

- [ ] `scripts/ci/run_e2e_round_trip_smoke.sh` が local で pass (≤10 分)
- [ ] CI job `e2e-round-trip-smoke` が green、`application-container-smoke` と並列で実行される
- [ ] 失敗時 diagnostics 4 種 (compose-logs / firestore-snapshot / pubsub-state / stub-access) が自動 dump される
- [ ] `no-mocks-in-production` job が本 feature 追加後も pass する
- [ ] `ci-runtime-budget` job が通過 (Linux CI aggregate 30 分以内)

## Out of Scope

- image-worker round-trip (Stability stub schema 対応は別 issue)
- billing-worker round-trip (別 issue)
- Flutter mobile integration test (別 issue #22)
- load test / chaos test (Issue #21 本文で明示的に out of scope)
