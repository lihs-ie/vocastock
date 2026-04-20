# Tasks: Image Worker Implementation

**Input**: Design documents from [/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/)  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/quickstart.md)

**Tests**: `cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test`、`cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test feature`、`cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test --enable-coverage`、`bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers` を前提に、Haskell unit と Haskell feature の両方を task に含める。feature テストは Haskell コードから Docker container と Firebase emulator を使い、worker-owned coverage 90% 以上を満たす。  
**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: `image-worker` の package baseline、責務別 source/test layout、review entrypoints を整える

- [x] T001 Create the package baseline in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/cabal.project` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/image-worker.cabal`
- [x] T002 [P] Create the worker source skeleton in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/app/Main.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkItemContract.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/TargetResolution.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkflowStateMachine.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/ImageGenerationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/AssetStoragePort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/ImagePersistence.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/CurrentImageHandoff.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/FailureSummary.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkerRuntime.hs`
- [x] T003 [P] Create the Haskell unit and Haskell feature test skeleton in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/WorkItemContractSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/TargetResolutionSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/ImageGenerationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/AssetStoragePortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/ImagePersistenceSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/CurrentImageHandoffSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/FailureSummarySpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/WorkerRuntimeSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/Main.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/ImageWorker/FeatureSpec.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/support/FeatureSupport.hs`
- [x] T004 [P] Normalize the review and verification entrypoints in `/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/quickstart.md` so the planned Cabal package layout, Haskell feature suite, and validation commands stay aligned

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が共有する worker runtime shell、inner layer boundary、state/port/failure 基盤、build/runtime wiring を先に固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Create the shared stable-run boot shell and worker configuration entrypoint in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkerRuntime.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/app/Main.hs`
- [x] T006 [P] Define work item, business key, accepted-order priority, and intake validation entities in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkItemContract.hs`
- [x] T007 [P] Define target resolution and ownership/precondition validation for completed `Explanation` and optional `Sense` in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/TargetResolution.hs`
- [x] T008 [P] Define generation port, asset storage port, image persistence, and current handoff contracts in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/ImageGenerationPort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/AssetStoragePort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/ImagePersistence.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/CurrentImageHandoff.hs`
- [x] T009 [P] Define redacted failure summary, lifecycle states, and stale-success primitives in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/FailureSummary.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkflowStateMachine.hs`
- [x] T010 Wire package build/test targets and container runtime boot in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/image-worker.cabal`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/Main.hs`, `/Users/lihs/workspace/vocastock/docker/applications/image-worker/Dockerfile`, `/Users/lihs/workspace/vocastock/docker/applications/image-worker/entrypoint.sh`, and `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 完了済み解説から画像生成を完了できる (Priority: P1) 🎯 MVP

**Goal**: accepted 済み image generation 要求を completed `VisualImage` と `currentImage` handoff へ到達させる

**Independent Test**: `cabal test` と Haskell feature suite の結果を読むだけで、accepted work item が `queued` から `succeeded` へ進み、完了時だけ `currentImage` が切り替わることを説明できること

### Tests for User Story 1

- [x] T011 [P] [US1] Add Haskell unit coverage for `queued -> running -> succeeded`, completed image payload validation, asset reference confirmation, image persistence, and current handoff completion in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/WorkflowStateMachineSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/ImageGenerationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/AssetStoragePortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/ImagePersistenceSpec.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/CurrentImageHandoffSpec.hs`
- [x] T012 [P] [US1] Add Haskell feature coverage for accepted image-generation success, in-flight status-only visibility, and completed-only current image adoption in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/ImageWorker/FeatureSpec.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/support/FeatureSupport.hs`

### Implementation for User Story 1

- [x] T013 [US1] Implement accepted `requestImageGeneration` intake validation, completed `Explanation` gating, and optional `Sense` resolution in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkItemContract.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/TargetResolution.hs`
- [x] T014 [US1] Implement completed image payload validation and provider generation success flow in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/ImageGenerationPort.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkflowStateMachine.hs`
- [x] T015 [US1] Implement stable asset storage handoff and completed `VisualImage` persistence in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/AssetStoragePort.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/ImagePersistence.hs`
- [x] T016 [US1] Implement `Explanation.currentImage` handoff and end-to-end success orchestration in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/CurrentImageHandoff.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkerRuntime.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/app/Main.hs`

**Checkpoint**: User Story 1 should provide an independently testable image-generation MVP

---

## Phase 4: User Story 2 - 失敗、再試行、重複要求、前提不正を一貫して扱える (Priority: P2)

**Goal**: retryable failure、timeout、terminal failure、saved-but-non-current、duplicate/replay、invalid target を state machine と visibility ルールに従って一貫処理する

**Independent Test**: `cabal test` と Haskell feature suite の結果を読むだけで、retryable / terminal / stale-success / duplicate / invalid-target の各ケースで worker がどの状態へ遷移し、何を current image として採用してはいけないかを説明できること

### Tests for User Story 2

- [x] T017 [P] [US2] Add Haskell unit coverage for retryable generation failure, retryable asset-storage failure, timeout, malformed payload terminal failure, invalid target, ownership mismatch, invalid `Sense`, and redacted failure summary in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/ImageGenerationPortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/AssetStoragePortSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/TargetResolutionSpec.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/WorkflowStateMachineSpec.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/FailureSummarySpec.hs`
- [x] T018 [P] [US2] Add Haskell feature coverage for `retry-scheduled`, `failed-final`, `dead-lettered`, saved-but-non-current retention, retained current on failure, and duplicate work no-op behavior in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/ImageWorker/FeatureSpec.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/support/FeatureSupport.hs`

### Implementation for User Story 2

- [x] T019 [US2] Implement retryable / timeout / terminal classification, deterministic invalid-target mapping, and redacted failure summary generation in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkflowStateMachine.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/FailureSummary.hs`
- [x] T020 [US2] Implement retryable asset-storage handling, handoff-only retry, and saved-but-non-current candidate retention in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/AssetStoragePort.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/ImagePersistence.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/CurrentImageHandoff.hs`
- [x] T021 [US2] Implement newest-accepted adoption priority, stale-success handling, and duplicate/replay guards in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkItemContract.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkflowStateMachine.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/ImagePersistence.hs`
- [x] T022 [US2] Integrate invalid target / ownership mismatch / invalid `Sense` outcomes, restart-safe replay lookup, and operator-review dead-letter routing in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/TargetResolution.hs`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkerRuntime.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/app/Main.hs`

**Checkpoint**: User Story 2 should make failure classification, stale-success retention, and idempotency independently reviewable

---

## Phase 5: User Story 3 - worker 境界と validation 経路を維持できる (Priority: P3)

**Goal**: query/public endpoint を持たない long-running consumer boundary を維持しつつ、Docker/Firebase 環境で success / retryable / terminal 経路を再現できるようにする

**Independent Test**: Haskell feature suite、container smoke、local stack validation の結果を読むだけで、`image-worker` の owned responsibility、stable-run 条件、validation で再現すべき success / retryable failure / terminal failure 経路を説明できること

### Tests for User Story 3

- [x] T023 [P] [US3] Add Haskell unit coverage for stable-run boot rules, no-public-endpoint assumptions, and runtime boundary exclusions in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/WorkerRuntimeSpec.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/FailureSummarySpec.hs`
- [x] T024 [P] [US3] Add Haskell feature coverage for long-running consumer startup, success validation flow, retryable failure validation flow, and terminal failure validation flow in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/ImageWorker/FeatureSpec.hs` and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/support/FeatureSupport.hs`

### Implementation for User Story 3

- [x] T025 [US3] Replace the shell-only consumer stub with packaged worker execution while preserving dependency probes and stable-run logging in `/Users/lihs/workspace/vocastock/docker/applications/image-worker/entrypoint.sh`, `/Users/lihs/workspace/vocastock/applications/backend/image-worker/app/Main.hs`, and `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/WorkerRuntime.hs`
- [x] T026 [US3] Extend `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh` and `/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh` so image-worker success, retryable failure, and terminal failure validation paths are executable and recorded separately via Docker/Firebase
- [x] T027 [US3] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/README.md`, `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`, and `/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-worker-runtime-boundary-contract.md` so image-worker ownership excludes query response, public API, explanation workflow, and billing workflow

**Checkpoint**: User Story 3 should make runtime boundary and validation behavior independently testable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: mirror layout、artifact 同期、coverage、runtime 文書整合を最終化する

- [x] T028 [P] Mirror the final Haskell source layout into `/Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/` so every module under `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/` has a corresponding unit spec file
- [x] T029 [P] Update `/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/quickstart.md` and `/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/*.md` if shipped state names, handoff wording, stale-success wording, port fields, or runtime entrypoints drift during implementation
- [x] T030 [P] Reconcile `/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/data-model.md` with the shipped source layout and inner layer module boundary in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/src/ImageWorker/`
- [x] T031 Run `cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test`, `cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test feature`, `cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test --enable-coverage`, `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`, and `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`, then reconcile shipped behavior in `/Users/lihs/workspace/vocastock/applications/backend/image-worker/`, `/Users/lihs/workspace/vocastock/docker/applications/image-worker/`, and `/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/` while enforcing coverage 90% 以上 and confirming success, retryable failure, and terminal failure are recorded as separate validation outcomes
- [x] T032 [P] Cross-check `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, and `/Users/lihs/workspace/vocastock/applications/backend/README.md` so image-worker runtime/ownership wording stays aligned with shipped behavior

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
- Target resolution and completed payload validation should stabilize before end-to-end success orchestration is finalized
- Failure classification should be implemented before duplicate/replay and stale-success integration is finalized
- Runtime validation scripts and container boot flow should complete before final coverage and artifact reconciliation

### Parallel Opportunities

- `T002`, `T003`, and `T004` can run in parallel after `T001`
- `T006`, `T007`, `T008`, and `T009` can run in parallel within Foundational
- `T011` and `T012` can run in parallel within US1
- `T017` and `T018` can run in parallel within US2
- `T023` and `T024` can run in parallel within US3
- `T028`, `T029`, `T030`, and `T032` can run in parallel in Phase 6

---

## Parallel Example: User Story 1

```bash
# Launch the story-specific test tasks together:
Task: "Add Haskell unit coverage for queued -> running -> succeeded, completed image payload validation, asset reference confirmation, and current handoff completion in /Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/"
Task: "Add Haskell feature coverage for accepted image-generation success and completed-only current image adoption in /Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/ImageWorker/FeatureSpec.hs"
```

## Parallel Example: User Story 2

```bash
# Launch failure and stale-success verification together:
Task: "Add Haskell unit coverage for retryable failure, timeout, malformed payload terminal failure, invalid target, invalid Sense, and redacted failure summary in /Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/"
Task: "Add Haskell feature coverage for retry-scheduled, failed-final, dead-lettered, saved-but-non-current retention, and duplicate work no-op behavior in /Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/ImageWorker/FeatureSpec.hs"
```

## Parallel Example: User Story 3

```bash
# Launch runtime-boundary verification together:
Task: "Add Haskell unit coverage for stable-run boot rules, no-public-endpoint assumptions, and runtime boundary exclusions in /Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/unit/ImageWorker/WorkerRuntimeSpec.hs"
Task: "Add Haskell feature coverage for long-running consumer startup, success/retryable/terminal validation flows in /Users/lihs/workspace/vocastock/applications/backend/image-worker/tests/feature/ImageWorker/FeatureSpec.hs"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Confirm the worker can drive an accepted image-generation request from `queued` to `succeeded` and switch `currentImage` only on completion

### Incremental Delivery

1. Complete Setup + Foundational to stabilize the Haskell package, inner layer boundary, lifecycle shell, port boundaries, and Docker runtime
2. Add User Story 1 and validate the completed image + current handoff happy path
3. Add User Story 2 and validate retryable / terminal / stale-success / duplicate handling plus status-only failure semantics
4. Add User Story 3 and validate stable-run runtime behavior and Docker/Firebase validation flows
5. Finish with coverage, artifact sync, and runtime wording reconciliation

### Parallel Team Strategy

1. One contributor stabilizes Setup + Foundational
2. After Foundation:
   - Contributor A: User Story 1 success orchestration and happy-path fixtures
   - Contributor B: User Story 2 failure classification, stale-success retention, and idempotency handling
   - Contributor C: User Story 3 runtime validation and container/script reconciliation
3. Reconcile coverage and docs in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- Tests are included because 022 explicitly requires success / retryable / terminal validation, feature tests must use Docker/Firebase, image workflow touches async generation and external adapters, and worker-owned coverage must stay at or above 90%
- Keep 022 terminology aligned with `ImageGenerationWorkItem`, `ImageWorkflowState`, `CompletedVisualImageCandidate`, `CurrentImageHandoff`, `ImageFailureSummary`, `queued`, `retry-scheduled`, `failed-final`, `dead-lettered`, and `retained-non-current`
- Do not expand scope into public `requestImageGeneration` intake ownership, multiple current image / gallery, `query-api` projection ownership, `graphql-gateway`, or billing workflow
