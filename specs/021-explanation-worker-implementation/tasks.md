# Tasks: Explanation Worker Implementation

**Input**: Design documents from [/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/)  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/quickstart.md)

**Tests**: `cd /Users/lihs/workspace/vocastock/applications/backend/explanation-worker && cabal test`、`cd /Users/lihs/workspace/vocastock/applications/backend/explanation-worker && cabal test --enable-coverage`、`cargo test --manifest-path /Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/Cargo.toml --test feature -- --nocapture`、`bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers` を前提に、Haskell unit と Rust feature の両方を task に含める。feature テストは Rust コードから Docker container と Firebase emulator を使い、worker-owned coverage 90% 以上を満たす。  
**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: `explanation-worker` の package baseline、責務別 source/test layout、review entrypoints を整える

- [X] T001 Create the package baseline in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/cabal.project` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/explanation-worker.cabal`
- [X] T002 [P] Create the worker source skeleton in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/app/Main.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkItemContract.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkflowStateMachine.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/GenerationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/ExplanationPersistence.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/CurrentExplanationHandoff.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/FailureSummary.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkerRuntime.hs`
- [X] T003 [P] Create the Haskell unit and Rust feature test skeleton in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/WorkItemContractSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/GenerationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/ExplanationPersistenceSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/CurrentExplanationHandoffSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/FailureSummarySpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/WorkerRuntimeSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/Cargo.toml`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/feature.rs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/support/feature.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/feature/explanation_worker.rs`
- [X] T004 [P] Normalize the review and verification entrypoints in `/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/quickstart.md` so the planned Cabal package layout, Rust feature harness, and validation commands stay aligned

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が共有する worker runtime shell、state/port/failure 基盤、build/runtime wiring を先に固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Create the shared stable-run boot shell and worker configuration entrypoint in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkerRuntime.hs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/app/Main.hs`
- [X] T006 [P] Define work item, business key, and intake validation entities in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkItemContract.hs`
- [X] T007 [P] Define generation, explanation persistence, and current handoff port contracts in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/GenerationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/ExplanationPersistence.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/CurrentExplanationHandoff.hs`
- [X] T008 [P] Define redacted failure summary and status-only mapping primitives in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/FailureSummary.hs`
- [X] T009 Implement the baseline lifecycle state shell for `queued`, `running`, `retry-scheduled`, `timed-out`, `succeeded`, `failed-final`, and `dead-lettered` in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkflowStateMachine.hs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkerRuntime.hs`
- [X] T010 Wire package build/test targets and container runtime boot in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/explanation-worker.cabal`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/Cargo.toml`, `/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/Dockerfile`, `/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/entrypoint.sh`, and `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 登録済み語彙の解説生成を完了できる (Priority: P1) 🎯 MVP

**Goal**: accepted 済み registration 起点 explanation generation 要求を completed `Explanation` と `currentExplanation` handoff へ到達させる

**Independent Test**: `cabal test` と Rust feature harness の結果を読むだけで、accepted work item が `queued` から `succeeded` へ進み、完了時だけ `currentExplanation` が切り替わり、non-success 時は既存 current が維持されることを説明できること

### Tests for User Story 1

- [X] T011 [P] [US1] Add Haskell unit coverage for `queued -> running -> succeeded`, completed explanation assembly, current handoff completion, and existing `currentExplanation` retention across non-success outcomes in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/ExplanationPersistenceSpec.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/CurrentExplanationHandoffSpec.hs`
- [X] T012 [P] [US1] Add Rust feature coverage for accepted registration-origin success, in-flight status-only visibility, and retained `currentExplanation` after retryable / timeout / terminal non-success paths in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/feature/explanation_worker.rs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/support/feature.rs`

### Implementation for User Story 1

- [X] T013 [US1] Implement registration-origin work item intake validation and `startExplanation = true` gating in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkItemContract.hs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkerRuntime.hs`
- [X] T014 [US1] Implement completed explanation payload validation and persistence success flow in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/GenerationPort.hs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/ExplanationPersistence.hs`
- [X] T015 [US1] Implement current explanation handoff and existing-current preservation while processing is incomplete in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/CurrentExplanationHandoff.hs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkflowStateMachine.hs`
- [X] T016 [US1] Implement the end-to-end success orchestration and Docker-driven happy-path fixture wiring in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkerRuntime.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/app/Main.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/support/feature.rs`

**Checkpoint**: User Story 1 should provide an independently testable explanation-generation MVP

---

## Phase 4: User Story 2 - 失敗、再試行、重複要求を一貫して扱える (Priority: P2)

**Goal**: retryable failure、timeout、terminal failure、duplicate/replay を state machine と visibility ルールに従って一貫処理する

**Independent Test**: `cabal test` と Rust feature harness の結果を読むだけで、retryable / terminal / duplicate / invalid-target の各ケースで worker がどの状態へ遷移し、何を user-visible にしてはいけないかを説明できること

### Tests for User Story 2

- [X] T017 [P] [US2] Add Haskell unit coverage for retryable failure, timeout, malformed payload terminal failure, invalid target, ownership mismatch, precondition-invalid work items, duplicate/replay idempotency, and redacted failure summary in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/GenerationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/WorkItemContractSpec.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/FailureSummarySpec.hs`
- [X] T018 [P] [US2] Add Rust feature coverage for `retry-scheduled`, `failed-final` / `dead-lettered`, invalid target / ownership mismatch / precondition-invalid failure mapping, retained current on failure, and duplicate work no-op behavior in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/feature/explanation_worker.rs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/support/feature.rs`

### Implementation for User Story 2

- [X] T019 [US2] Implement retryable / timeout / non-retryable classification, retry-budget transitions, and retained-current failure summaries in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkflowStateMachine.hs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/FailureSummary.hs`
- [X] T020 [US2] Implement malformed completed-payload rejection plus invalid target / ownership mismatch / precondition-invalid terminal mapping in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/GenerationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/ExplanationPersistence.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkItemContract.hs`
- [X] T021 [US2] Implement duplicate/replay detection and idempotent save/switch guards that preserve existing `currentExplanation` across non-success paths in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkItemContract.hs`, `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/ExplanationPersistence.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/CurrentExplanationHandoff.hs`
- [X] T022 [US2] Integrate failure handling, restart-safe replay lookup, invalid-target / ownership mismatch dispatch outcomes, and operator-review dead-letter routing in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/WorkerRuntime.hs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/app/Main.hs`

**Checkpoint**: User Story 2 should make failure classification, retry handling, and idempotency independently reviewable

---

## Phase 5: User Story 3 - worker 境界と runtime 検証を維持できる (Priority: P3)

**Goal**: query/public endpoint を持たない long-running consumer boundary を維持しつつ、Docker/Firebase 環境で success / non-success 経路を再現できるようにする

**Independent Test**: Rust feature harness、container smoke、local stack validation の結果を読むだけで、`explanation-worker` の owned responsibility、stable-run 条件、validation で再現すべき success / retryable failure / terminal failure 経路を説明できること

### Tests for User Story 3

- [X] T023 [P] [US3] Add Haskell unit coverage for stable-run boot rules, non-owned responsibility boundaries, and no-public-endpoint assumptions in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/WorkerRuntimeSpec.hs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/FailureSummarySpec.hs`
- [X] T024 [P] [US3] Add Rust feature coverage for long-running consumer startup, success, retryable failure validation flow, terminal failure validation flow, and the absence of user-facing HTTP assumptions in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/feature/explanation_worker.rs` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/support/feature.rs`

### Implementation for User Story 3

- [X] T025 [US3] Replace the shell-only consumer stub with packaged worker execution while preserving dependency probes and stable-run logging in `/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/entrypoint.sh` and `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/app/Main.hs`
- [X] T026 [US3] Extend `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh` and `/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh` so explanation-worker success, retryable failure, and terminal failure validation paths are executable and recorded separately via Docker/Firebase
- [X] T027 [US3] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/README.md`, `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`, and `/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-worker-runtime-boundary-contract.md` so explanation-worker ownership excludes query response, public API, image workflow, and billing workflow

**Checkpoint**: User Story 3 should make runtime boundary and validation behavior independently testable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: mirror layout、artifact 同期、coverage、runtime 文書整合を最終化する

- [X] T028 [P] Mirror the final Haskell source layout into `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/` so every module under `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/src/ExplanationWorker/` has a corresponding unit spec file
- [X] T029 [P] Update `/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/quickstart.md` and `/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/*.md` if shipped state names, port fields, visibility wording, or runtime entrypoints drift during implementation
- [X] T030 Run `cd /Users/lihs/workspace/vocastock/applications/backend/explanation-worker && cabal test`, `cd /Users/lihs/workspace/vocastock/applications/backend/explanation-worker && cabal test --enable-coverage`, `cargo test --manifest-path /Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/Cargo.toml --test feature -- --nocapture`, `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`, and `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`, then reconcile shipped behavior in `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/`, `/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/`, and `/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/` while enforcing coverage 90% 以上 and confirming success, retryable failure, and terminal failure are recorded as separate validation outcomes
- [X] T031 [P] Cross-check `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, and `/Users/lihs/workspace/vocastock/applications/backend/README.md` so explanation-worker runtime/ownership wording stays aligned with shipped behavior

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

- Haskell unit tests and Rust feature tests should be written before the corresponding implementation tasks are considered complete
- Work item intake and completed payload validation should stabilize before the end-to-end runtime orchestration is finalized
- Failure classification should be implemented before duplicate/replay integration is finalized
- Runtime validation scripts and container boot flow should complete before final coverage and artifact reconciliation

### Parallel Opportunities

- `T002`, `T003`, and `T004` can run in parallel after `T001`
- `T006`, `T007`, and `T008` can run in parallel within Foundational
- `T011` and `T012` can run in parallel within US1
- `T017` and `T018` can run in parallel within US2
- `T023` and `T024` can run in parallel within US3
- `T028`, `T029`, and `T031` can run in parallel in Phase 6

---

## Parallel Example: User Story 1

```bash
# Launch the story-specific test tasks together:
Task: "Add Haskell unit coverage for queued -> running -> succeeded, completed explanation assembly, and current handoff completion in /Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/"
Task: "Add Rust feature coverage for accepted registration-origin success and in-flight status-only visibility in /Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/feature/explanation_worker.rs"
```

## Parallel Example: User Story 2

```bash
# Launch failure and duplicate verification together:
Task: "Add Haskell unit coverage for retryable failure, timeout, malformed payload terminal failure, duplicate/replay idempotency, and redacted failure summary in /Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/"
Task: "Add Rust feature coverage for retry-scheduled, failed-final / dead-lettered, and duplicate work no-op behavior in /Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/feature/explanation_worker.rs"
```

## Parallel Example: User Story 3

```bash
# Launch runtime-boundary verification together:
Task: "Add Haskell unit coverage for stable-run boot rules, non-owned responsibility boundaries, and no-public-endpoint assumptions in /Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/unit/ExplanationWorker/WorkerRuntimeSpec.hs"
Task: "Add Rust feature coverage for long-running consumer startup, success/non-success validation flows, and the absence of user-facing HTTP assumptions in /Users/lihs/workspace/vocastock/applications/backend/explanation-worker/tests/feature/explanation_worker.rs"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Confirm the worker can drive an accepted registration-origin request from `queued` to `succeeded` and switch `currentExplanation` only on completion

### Incremental Delivery

1. Complete Setup + Foundational to stabilize the Haskell package, lifecycle shell, port boundaries, and Docker runtime
2. Add User Story 1 and validate the completed explanation + current handoff happy path
3. Add User Story 2 and validate retryable / terminal / duplicate handling plus status-only failure semantics
4. Add User Story 3 and validate stable-run runtime behavior and Docker/Firebase validation flows
5. Finish with coverage, artifact sync, and runtime wording reconciliation

### Parallel Team Strategy

1. One contributor stabilizes Setup + Foundational
2. After Foundation:
   - Contributor A: User Story 1 success orchestration and happy-path fixtures
   - Contributor B: User Story 2 failure classification and idempotency handling
   - Contributor C: User Story 3 runtime validation and container/script reconciliation
3. Reconcile coverage and docs in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- Tests are included because 021 explicitly requires success / retryable / terminal validation, AGENTS mandates Rust-based Docker/Firebase feature tests, and worker-owned coverage must stay at or above 90%
- Keep 021 terminology aligned with `ExplanationGenerationWorkItem`, `ExplanationWorkflowState`, `CompletedExplanationCandidate`, `CurrentExplanationHandoff`, `ExplanationFailureSummary`, `queued`, `retry-scheduled`, `failed-final`, and `dead-lettered`
- Do not expand scope into `image-worker`, `billing-worker`, public HTTP / GraphQL endpoints, `query-api` projection ownership, or provider-specific optimization
