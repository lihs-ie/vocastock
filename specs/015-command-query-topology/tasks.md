# Tasks: Command/Query Deployment Topology

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は deployment topology review、command/query separation review、gateway routing review、async worker allocation review、source-of-truth update-map review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 015 の設計成果物を置く受け皿と active feature 導線を揃える

- [X] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/research.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/`
- [X] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/015-command-query-topology` as the active feature directory
- [X] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for command/query deployment-topology design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する source-of-truth、用語、topology framing を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Update deployment-topology source-of-truth references in `/Users/lihs/workspace/vocastock/docs/external/requirements.md` using `/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md` as alignment inputs
- [X] T005 [P] Cross-check deployment-topology terminology, non-domain-change assumptions, and boundary wording in `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learner.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learning-state.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md` against `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md` without changing domain semantics
- [X] T006 [P] Normalize `graphql-gateway`, `command-api`, `query-api`, durable-state handoff, accepted/status-handle, status-only, worker-allocation, and caller-owned-adapter wording across `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/research.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/`
- [X] T007 [P] Capture feature-wide assumptions, Cloud Run deployment-unit rules, unified-endpoint constraint, and deferred-topology notes in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md` and `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/research.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Command と Query の配置先を分離する (Priority: P1) 🎯 MVP

**Goal**: `Command Intake` と `Query Read` の physical topology と責務差分を独立レビュー可能にする

**Independent Test**: [deployment-topology-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/deployment-topology-contract.md)、[command-query-separation-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/command-query-separation-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md) を読むだけで、第三者が 10 分以内に `command-api` と `query-api` の別配置と責務差分を説明できること

### Implementation for User Story 1

- [X] T008 [P] [US1] Define the canonical deployment-unit catalog, component allocation matrix, and non-ownership rules in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/deployment-topology-contract.md`
- [X] T009 [P] [US1] Define the command/query responsibility matrix, visible-guarantee rules, and durable-handoff prohibition on direct calls in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/command-query-separation-contract.md`
- [X] T010 [US1] Extend `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md` with `DeploymentUnit` and `ComponentAllocation` validation rules for separate `command-api` and `query-api` ownership
- [X] T011 [US1] Align User Story 1 wording, acceptance scenarios, edge cases, and `FR-001` through `FR-003` plus `FR-006` in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md`
- [X] T012 [US1] Update `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md` with the command/query separation review sequence, responsibility-difference checks, and MVP-topology explanation steps

**Checkpoint**: User Story 1 should make command/query topology and responsibility split independently reviewable

---

## Phase 4: User Story 2 - 非同期 worker と外部境界の配置を固定する (Priority: P2)

**Goal**: `graphql-gateway`、auth/session 検証、workflow worker、adapter 配置を独立レビュー可能にする

**Independent Test**: [gateway-routing-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/gateway-routing-contract.md)、[async-worker-allocation-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/async-worker-allocation-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md) を読むだけで、第三者が 10 分以内に gateway、auth/session、worker、adapter の配置先を追跡できること

### Implementation for User Story 2

- [X] T013 [P] [US2] Define unified-endpoint routing, auth propagation, and gateway non-ownership rules in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/gateway-routing-contract.md`
- [X] T014 [P] [US2] Define worker allocation, caller-owned-adapter placement, and user-visible read restrictions in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/async-worker-allocation-contract.md`
- [X] T015 [US2] Extend `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md` with `GatewayRoute` and `DurableStateHandoff` details, including status-only lag handling and no-provisional-completed-result rules
- [X] T016 [US2] Align User Story 2 wording, acceptance scenarios, edge cases, and `FR-004` through `FR-008` plus `FR-010` and `FR-011` in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md` and `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md`
- [X] T017 [US2] Update `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md` with the gateway, token-verification, actor-handoff, async-worker, and caller-owned-adapter review sequence

**Checkpoint**: User Story 2 should make gateway, auth/session, and worker allocation independently reviewable

---

## Phase 5: User Story 3 - 正本更新箇所と deferred scope を明示する (Priority: P3)

**Goal**: canonical sync 先、artifact resync 対象、deferred scope を独立レビュー可能にする

**Independent Test**: [source-of-truth-update-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/source-of-truth-update-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md) を読むだけで、第三者が 10 分以内に canonical sync target、artifact resync target、deferred reference を割り当てられること

### Implementation for User Story 3

- [X] T018 [P] [US3] Define the canonical sync targets, artifact-resync targets, deferred references, and update-map rules in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/source-of-truth-update-contract.md`
- [X] T019 [P] [US3] Extend `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md` with `SourceOfTruthUpdate` details, required-vs-deferred validation rules, and resync classification notes
- [X] T020 [US3] Align User Story 3 wording, acceptance scenarios, edge cases, and `FR-009` plus `FR-012` in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md`, and `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md`
- [X] T021 [US3] Sync the finalized deployment-topology, unified-gateway, worker-allocation, and source-of-truth update guidance into `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md`

**Checkpoint**: User Story 3 should make source-of-truth updates and deferred scope independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終レビュー導線を整える

- [X] T022 Reconcile all 015 artifacts across `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/research.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/`
- [X] T023 [P] Cross-check 015 topology terminology and source-of-truth guidance against `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md` without redefining their semantics
- [X] T024 Re-run the review flow in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md` and reconcile deployment allocations, visible guarantees, gateway routing, worker boundaries, and source-of-truth update completeness with the finalized artifacts

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - shares the same topology vocabulary, but remains independently reviewable
- **User Story 3 (P3)**: Can start after Foundational - shares the same source-of-truth vocabulary, but remains independently reviewable

### Within Each User Story

- Contract files should be stabilized before the corresponding spec and data-model wording is finalized
- Shared-file edits in `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/quickstart.md` should be coordinated even when stories are independently reviewable
- External source-of-truth sync in `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` should happen after the source-of-truth update map is stabilized

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T005`, `T006`, and `T007` can run in parallel after `T004`
- In US1, `T008` and `T009` can run in parallel
- In US2, `T013` and `T014` can run in parallel
- In US3, `T018` and `T019` can run in parallel
- Final polish `T023` can run in parallel with `T022` once story work is complete

---

## Parallel Example: User Story 1

```bash
# Launch deployment and responsibility tasks together:
Task: "Define the canonical deployment-unit catalog, component allocation matrix, and non-ownership rules in /Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/deployment-topology-contract.md"
Task: "Define the command/query responsibility matrix, visible-guarantee rules, and durable-handoff prohibition on direct calls in /Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/command-query-separation-contract.md"
```

## Parallel Example: User Story 2

```bash
# Launch gateway and worker allocation tasks together:
Task: "Define unified-endpoint routing, auth propagation, and gateway non-ownership rules in /Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/gateway-routing-contract.md"
Task: "Define worker allocation, caller-owned-adapter placement, and user-visible read restrictions in /Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/async-worker-allocation-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch update-map and data-model extension tasks together:
Task: "Define the canonical sync targets, artifact-resync targets, deferred references, and update-map rules in /Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/source-of-truth-update-contract.md"
Task: "Extend /Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md with SourceOfTruthUpdate details, required-vs-deferred validation rules, and resync classification notes"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that `command-api` / `query-api` separation and responsibility split can be reviewed independently
5. Stop and review before adding gateway / worker allocation and source-of-truth update detail

### Incremental Delivery

1. Complete Setup + Foundational to fix vocabulary, source-of-truth references, and topology framing
2. Add User Story 1 to define command/query separation
3. Add User Story 2 to define gateway, auth/session, and worker allocation
4. Add User Story 3 to define source-of-truth sync targets and deferred scope
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 deployment catalog and command/query split
   - Contributor B: User Story 2 gateway and worker allocation
   - Contributor C: User Story 3 update map and deferred scope
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep 015 terminology aligned with `mobile-client`, `graphql-gateway`, `command-api`, `query-api`, `explanation-worker`, `image-worker`, `billing-worker`, `durable state handoff`, `accepted`, `status handle`, `status-only`, `caller-owned adapter`, `canonical sync`, `artifact-resync`, and `deferred reference`
- Do not pull GraphQL schema detail, gateway implementation product choice, service-internal module layout, or scaling / budget / alert policy into this feature
