# Tasks: Billing Worker Implementation

**Input**: Design documents from [/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/)  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/quickstart.md)

**Tests**: `cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test`、`cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test feature`、`cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test --enable-coverage`、`bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers` を前提に、Haskell unit と Haskell feature の両方を task に含める。feature テストは Haskell コードから Docker container と Firebase emulator を使い、worker-owned coverage 90% 以上を満たす。  
**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: `billing-worker` の package baseline、責務別 source/test layout、review entrypoints を整える

- [ ] T001 Create the package baseline in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/cabal.project` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/billing-worker.cabal`
- [ ] T002 [P] Create the worker source skeleton in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/app/Main.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkItemContract.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkflowStateMachine.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/PurchaseVerificationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/SubscriptionAuthorityPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/EntitlementRecalcPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/NotificationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/BillingPersistence.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/CurrentSubscriptionHandoff.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/FailureSummary.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkerRuntime.hs`
- [ ] T003 [P] Create the Haskell unit and Haskell feature test skeleton in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/Main.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/WorkItemContractSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/PurchaseVerificationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/SubscriptionAuthorityPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/EntitlementRecalcPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/NotificationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/BillingPersistenceSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/CurrentSubscriptionHandoffSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/FailureSummarySpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/WorkerRuntimeSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/feature/Main.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/feature/BillingWorker/FeatureSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/support/TestSupport.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/support/FeatureSupport.hs`
- [ ] T004 [P] Normalize the review and verification entrypoints in `/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/quickstart.md` so the planned Cabal package layout, Haskell feature suite, and validation commands stay aligned

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が共有する worker runtime shell、state/port/failure 基盤、build/runtime wiring を先に固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T005 Create the shared stable-run boot shell and worker configuration entrypoint in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkerRuntime.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/app/Main.hs`
- [ ] T006 [P] Define work item, business key, trigger classification, and intake validation entities in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkItemContract.hs`
- [ ] T007 [P] Define purchase verification, subscription authority, entitlement recalc, notification, persistence, and current handoff port contracts in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/PurchaseVerificationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/SubscriptionAuthorityPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/EntitlementRecalcPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/NotificationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/BillingPersistence.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/CurrentSubscriptionHandoff.hs`
- [ ] T008 [P] Define redacted failure summary and status-only mapping primitives in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/FailureSummary.hs`
- [ ] T009 Implement the baseline lifecycle state shell for `queued`, `running`, `retry-scheduled`, `timed-out`, `succeeded`, `failed-final`, and `dead-lettered` in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkflowStateMachine.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkerRuntime.hs`
- [ ] T010 Wire package build/test targets and container runtime boot in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/billing-worker.cabal`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/feature/Main.hs`, `/Users/lihs/workspace/vocastock/docker/applications/billing-worker/Dockerfile`, `/Users/lihs/workspace/vocastock/docker/applications/billing-worker/entrypoint.sh`, and `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 購入 artifact を authoritative subscription state へ反映できる (Priority: P1) 🎯 MVP

**Goal**: submitted 済み purchase artifact を completed `BillingRecord` と `currentEntitlementSnapshot` handoff へ到達させる

**Independent Test**: `cabal test` と Haskell feature suite の結果を読むだけで、submitted work item が `queued` から `succeeded` へ進み、完了時だけ `currentEntitlementSnapshot` が切り替わり、non-success 時は既存 current が維持されることを説明できること

### Tests for User Story 1

- [ ] T011 [P] [US1] Add Haskell unit coverage for `queued -> running -> succeeded`, completed `BillingRecord` assembly, current handoff completion, and existing `currentEntitlementSnapshot` retention across non-success outcomes in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/BillingPersistenceSpec.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/CurrentSubscriptionHandoffSpec.hs`
- [ ] T012 [P] [US1] Add Haskell feature coverage for submitted purchase-artifact success, in-flight status-only visibility, and retained `currentEntitlementSnapshot` after retryable / timeout / terminal non-success paths in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/feature/BillingWorker/FeatureSpec.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/support/FeatureSupport.hs`

### Implementation for User Story 1

- [ ] T013 [US1] Implement purchase-artifact intake validation and `trigger = purchase-artifact-submitted` gating in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkItemContract.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkerRuntime.hs`
- [ ] T014 [US1] Implement verified payload validation, authority update, entitlement snapshot derivation, and persistence success flow in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/PurchaseVerificationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/SubscriptionAuthorityPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/EntitlementRecalcPort.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/BillingPersistence.hs`
- [ ] T015 [US1] Implement current entitlement snapshot handoff and existing-current preservation while processing is incomplete in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/CurrentSubscriptionHandoff.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkflowStateMachine.hs`
- [ ] T016 [US1] Implement the end-to-end success orchestration and Docker-driven happy-path fixture wiring in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkerRuntime.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/app/Main.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/support/FeatureSupport.hs`

**Checkpoint**: User Story 1 should provide an independently testable purchase-verification MVP

---

## Phase 4: User Story 2 - 失敗、再試行、重複要求を一貫して扱える (Priority: P2)

**Goal**: retryable failure、timeout、terminal failure、duplicate/replay を state machine と visibility ルールに従って一貫処理する

**Independent Test**: `cabal test` と Haskell feature suite の結果を読むだけで、retryable / terminal / duplicate / invalid-target / ownership-mismatch の各ケースで worker がどの状態へ遷移し、何を user-visible にしてはいけないかを説明できること

### Tests for User Story 2

- [ ] T017 [P] [US2] Add Haskell unit coverage for retryable failure, timeout, malformed payload terminal failure, invalid target, ownership mismatch, duplicate/replay idempotency, and redacted failure summary in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/PurchaseVerificationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/WorkItemContractSpec.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/FailureSummarySpec.hs`
- [ ] T018 [P] [US2] Add Haskell feature coverage for `retry-scheduled`, `failed-final` / `dead-lettered`, invalid target / ownership mismatch failure mapping, retained current on failure, and duplicate work no-op behavior in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/feature/BillingWorker/FeatureSpec.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/support/FeatureSupport.hs`

### Implementation for User Story 2

- [ ] T019 [US2] Implement retryable / timeout / non-retryable classification, retry-budget transitions, and retained-current failure summaries in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkflowStateMachine.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/FailureSummary.hs`
- [ ] T020 [US2] Implement malformed verified-payload rejection plus invalid target / ownership mismatch terminal mapping in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/PurchaseVerificationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/BillingPersistence.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkItemContract.hs`
- [ ] T021 [US2] Implement duplicate/replay detection and idempotent save/switch guards that preserve existing `currentEntitlementSnapshot` across non-success paths in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkItemContract.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/BillingPersistence.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/CurrentSubscriptionHandoff.hs`
- [ ] T022 [US2] Integrate failure handling, restart-safe replay lookup, invalid-target / ownership mismatch dispatch outcomes, and operator-review dead-letter routing in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkerRuntime.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/app/Main.hs`

**Checkpoint**: User Story 2 should make failure classification, retry handling, and idempotency independently reviewable

---

## Phase 5: User Story 3 - store notification を取り込み subscription state を補正できる (Priority: P3)

**Goal**: normalized store notification を取り込み、subscription state と entitlement snapshot を補正する経路を確立し、retry / timeout / failure 中に新規 paid entitlement を付与しないことを保証する

**Independent Test**: `cabal test` と Haskell feature suite の結果を読むだけで、normalized notification が `queued` から `succeeded` へ進んで subscription state / entitlement snapshot が補正され、notification 経路の retry / timeout / failure 中は新規 premium unlock を付与しないことを説明できること

### Tests for User Story 3

- [ ] T023 [P] [US3] Add Haskell unit coverage for notification parse / normalization, retryable / timeout / terminal / stale notification outcomes, no-new-unlock enforcement, and dead-letter routing in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/NotificationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/FailureSummarySpec.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/EntitlementRecalcPortSpec.hs`
- [ ] T024 [P] [US3] Add Haskell feature coverage for long-running consumer startup, notification-reconciled success, notification retryable / terminal paths, and stable-run behavior in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/feature/BillingWorker/FeatureSpec.hs` and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/support/FeatureSupport.hs`

### Implementation for User Story 3

- [ ] T025 [US3] Implement normalized notification intake, stale notification detection, subscription state reconciliation, and no-new-unlock enforcement in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/NotificationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/SubscriptionAuthorityPort.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/WorkflowStateMachine.hs`
- [ ] T026 [US3] Replace the shell-only consumer stub with packaged worker execution while preserving dependency probes and stable-run logging in `/Users/lihs/workspace/vocastock/docker/applications/billing-worker/entrypoint.sh`, `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/app/Main.hs`, and `/Users/lihs/workspace/vocastock/docker/applications/billing-worker/Dockerfile`
- [ ] T027 [US3] Extend `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`, `/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh`, and `/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh` so billing-worker success, retryable failure, terminal failure, and notification-reconciled validation paths are executable and recorded separately via Docker/Firebase
- [ ] T028 [US3] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/README.md`, `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`, and `/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/billing-worker-runtime-boundary-contract.md` so billing-worker ownership excludes query response, public API, explanation workflow, and image workflow

**Checkpoint**: User Story 3 should make notification reconciliation and runtime boundary independently testable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: mirror layout、artifact 同期、coverage、runtime 文書整合を最終化する

- [ ] T029 [P] Mirror the final Haskell source layout into `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/tests/unit/BillingWorker/` so every module under `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/src/BillingWorker/` has a corresponding unit spec file
- [ ] T030 [P] Update `/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/quickstart.md` and `/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/*.md` if shipped state names, port fields, visibility wording, or runtime entrypoints drift during implementation
- [ ] T031 Run `cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test`, `cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test feature`, `cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test --enable-coverage`, `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`, and `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`, then reconcile shipped behavior in `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/`, `/Users/lihs/workspace/vocastock/docker/applications/billing-worker/`, and `/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/` while enforcing coverage 90% 以上 and confirming success, retryable failure, terminal failure, and notification-reconciled are recorded as separate validation outcomes
- [ ] T032 [P] Cross-check `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, and `/Users/lihs/workspace/vocastock/applications/backend/README.md` so billing-worker runtime/ownership wording stays aligned with shipped behavior

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - builds on the shared lifecycle shell but remains independently testable
- **User Story 3 (P3)**: Can start after Foundational - builds on the shared runtime shell but remains independently testable

### Within Each User Story

- Haskell unit tests and Haskell feature tests should be written before the corresponding implementation tasks are considered complete
- Work item intake and verified payload validation should stabilize before the end-to-end runtime orchestration is finalized
- Failure classification should be implemented before duplicate/replay integration is finalized
- Runtime validation scripts and container boot flow should complete before final coverage and artifact reconciliation

### Parallel Opportunities

- `T002`, `T003`, and `T004` can run in parallel after `T001`
- `T006`, `T007`, and `T008` can run in parallel within Foundational
- `T011` and `T012` can run in parallel within US1
- `T017` and `T018` can run in parallel within US2
- `T023` and `T024` can run in parallel within US3
- `T029`, `T030`, and `T032` can run in parallel in Phase 6

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Confirm the worker can drive a submitted purchase artifact from `queued` to `succeeded` and switch `currentEntitlementSnapshot` only on completion

### Incremental Delivery

1. Complete Setup + Foundational to stabilize the Haskell package, lifecycle shell, port boundaries, and Docker runtime
2. Add User Story 1 and validate the completed billing record + current handoff happy path
3. Add User Story 2 and validate retryable / terminal / duplicate handling plus status-only failure semantics
4. Add User Story 3 and validate notification reconciliation and stable-run runtime behavior
5. Finish with coverage, artifact sync, and runtime wording reconciliation

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- Tests are included because 023 explicitly requires success / retryable / terminal / notification-reconciled validation, feature tests must use Docker/Firebase, and worker-owned coverage must stay at or above 90%
- Keep 023 terminology aligned with `BillingWorkItem`, `BillingWorkflowState`, `SubscriptionAuthoritySnapshotCandidate`, `CurrentSubscriptionHandoff`, `BillingFailureSummary`, `queued`, `retry-scheduled`, `failed-final`, `dead-lettered`
- Do not expand scope into `explanation-worker`, `image-worker`, restore workflow, store product catalog management, pricing changes, provider-specific optimization, or public GraphQL schema extensions
