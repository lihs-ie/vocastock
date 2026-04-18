# Tasks: 永続化 / Read Model と非同期 Workflow 設計

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は persistence allocation review、read projection review、workflow state-machine review、retry / timeout / fallback review、dead-letter review、boundary / deferred-scope review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 012 の設計成果物を置く受け皿と active feature 導線を揃える

- [X] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/research.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/`
- [X] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design` as the active feature directory
- [X] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for persistence / workflow design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する source-of-truth、用語、boundary framing を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Update persistence / workflow source-of-truth references in `/Users/lihs/workspace/vocastock/docs/external/requirements.md` using `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, and `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md` as alignment inputs
- [X] T005 [P] Cross-check persistence / workflow terminology and identifier wording in `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learner.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learning-state.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md` against `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md` without changing domain semantics
- [X] T006 [P] Normalize authoritative store, read projection, runtime state, timeout / fallback, and dead-letter wording across `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/research.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/`
- [X] T007 [P] Capture feature-wide assumptions, prerequisite source-of-truth framing, and deferred-scope notes in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md` and `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/research.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 集約と read model の保存責務を固定する (Priority: P1) 🎯 MVP

**Goal**: authoritative persistence allocation、ownership、一意制約、主要 index、app-facing read projection の組み立て方を独立レビュー可能にする

**Independent Test**: [persistence-allocation-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/persistence-allocation-contract.md)、[read-model-assembly-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/read-model-assembly-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md) を読むだけで、第三者が 10 分以内に主要 aggregate / state の保存先、一意制約、主要 index、read projection の組み立て方を説明できること

### Implementation for User Story 1

- [X] T008 [P] [US1] Define the authoritative persistence allocation matrix, ownership rules, uniqueness rules, and primary index rules in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/persistence-allocation-contract.md`
- [X] T009 [P] [US1] Define the read projection sources, completed payload conditions, status-only conditions, and refresh expectations in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/read-model-assembly-contract.md`
- [X] T010 [US1] Map `LearnerRecord`, `VocabularyExpressionRecord`, `LearningStateRecord`, `ExplanationRecord`, `VisualImageRecord`, `SubscriptionAuthorityRecord`, `PurchaseStateRecord`, `EntitlementSnapshotRecord`, `UsageAllowanceRecord`, and projection entities into `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md`
- [X] T011 [US1] Align User Story 1 wording, FR-001 through FR-005, and key entities in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md`
- [X] T012 [US1] Update the persistence / read-model source-of-truth notes in `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` with the finalized allocation and projection rules

**Checkpoint**: User Story 1 should make persistence allocation and read projection assembly independently reviewable

---

## Phase 4: User Story 2 - 非同期 workflow と状態遷移を固定する (Priority: P2)

**Goal**: explanation / image / purchase / restore / notification の runtime state、retry、timeout、fallback、dead-letter 相当、partial success 非許容を分離し、実装ごとの差を防ぐ

**Independent Test**: [generation-workflow-state-machine-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/generation-workflow-state-machine-contract.md)、[subscription-workflow-state-machine-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/subscription-workflow-state-machine-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md) を読むだけで、第三者が 10 分以内に各 workflow の state 遷移、retry / timeout / fallback、dead-letter 相当、partial success 非許容を説明できること

### Implementation for User Story 2

- [X] T013 [P] [US2] Define explanation generation and image generation runtime states, transition rules, retry behavior, timeout handling, fallback rules, and partial-success rejection in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/generation-workflow-state-machine-contract.md`
- [X] T014 [P] [US2] Define purchase verification, restore, and notification reconciliation runtime states, subscription / purchase ordering rules, retry behavior, timeout handling, fallback rules, and dead-letter handling in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/subscription-workflow-state-machine-contract.md`
- [X] T015 [US2] Extend `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md` with `WorkflowAttemptRecord`, `WorkflowRuntimeState`, `DeadLetterReviewUnit`, runtime-to-projection mapping, and authoritative update ordering rules
- [X] T016 [US2] Align User Story 2 wording, edge cases, and FR-006 through FR-011 in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md`
- [X] T017 [US2] Capture the rationale for rich runtime states, partial-success rejection, timeout fallback, and dead-letter review handling in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/research.md`

**Checkpoint**: User Story 2 should make workflow runtime and recovery rules independently reviewable

---

## Phase 5: User Story 3 - read/write 境界と deferred scope を固定する (Priority: P3)

**Goal**: prerequisite source-of-truth、deferred scope、boundary ownership、review flow を整理し、012 が持つべき persistence / runtime 境界を固定する

**Independent Test**: [persistence-runtime-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/persistence-runtime-boundary-contract.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/quickstart.md)、[plan.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md) を読むだけで、第三者が authoritative write、read projection、runtime state、deferred scope、007 / 008 / 009 / 010 / 011 との接続点を 5 分以内に割り当てられること

### Implementation for User Story 3

- [X] T018 [P] [US3] Define the prerequisite source-of-truth matrix, deferred-scope ownership, and boundary rules in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/persistence-runtime-boundary-contract.md`
- [X] T019 [P] [US3] Update `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/quickstart.md` with the review sequence for persistence allocation, read projection assembly, workflow state machines, stale-read expectations, and deferred scope
- [X] T020 [US3] Align User Story 3 wording, FR-012 through FR-016, assumptions, and source-of-truth notes in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md` and `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`
- [X] T021 [US3] Cross-check boundary wording against `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, and `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md` without redefining their semantics

**Checkpoint**: User Story 3 should make persistence / runtime boundary ownership and deferred scope independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終レビュー導線を整える

- [X] T022 Reconcile all 012 artifacts across `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/research.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/`
- [X] T023 [P] Cross-check 012 terminology and source-of-truth guidance against `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learner.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learning-state.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md`
- [X] T024 Re-run the review flow in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/quickstart.md` and reconcile reviewer guidance with the finalized persistence allocation, projection visibility, workflow runtime states, timeout / fallback rules, dead-letter handling, and deferred-scope boundaries

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - uses the same persistence vocabulary, but remains independently reviewable
- **User Story 3 (P3)**: Can start after Foundational - uses the same source-of-truth framing, but remains independently reviewable

### Within Each User Story

- Contract files should be fixed before the corresponding spec and data-model wording is finalized
- Shared-file edits in `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md` should be coordinated even when stories are independently reviewable
- Source-of-truth sync in `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` should happen after the story-specific contracts are stable

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
# Launch persistence allocation and projection tasks together:
Task: "Define the authoritative persistence allocation matrix, ownership rules, uniqueness rules, and primary index rules in /Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/persistence-allocation-contract.md"
Task: "Define the read projection sources, completed payload conditions, status-only conditions, and refresh expectations in /Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/read-model-assembly-contract.md"
```

## Parallel Example: User Story 2

```bash
# Launch generation and subscription workflow tasks together:
Task: "Define explanation generation and image generation runtime states, transition rules, retry behavior, timeout handling, fallback rules, and partial-success rejection in /Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/generation-workflow-state-machine-contract.md"
Task: "Define purchase verification, restore, and notification reconciliation runtime states, subscription / purchase ordering rules, retry behavior, timeout handling, fallback rules, and dead-letter handling in /Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/subscription-workflow-state-machine-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch boundary and review-flow tasks together:
Task: "Define the prerequisite source-of-truth matrix, deferred-scope ownership, and boundary rules in /Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/persistence-runtime-boundary-contract.md"
Task: "Update /Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/quickstart.md with the review sequence for persistence allocation, read projection assembly, workflow state machines, stale-read expectations, and deferred scope"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that authoritative persistence allocation and read projection rules can be reviewed independently
5. Stop and review before adding workflow runtime refinements

### Incremental Delivery

1. Complete Setup + Foundational to fix vocabulary, source-of-truth references, and boundary framing
2. Add User Story 1 to define persistence allocation and projection assembly
3. Add User Story 2 to define workflow runtime state machines and recovery rules
4. Add User Story 3 to define prerequisite boundaries and deferred scope
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 persistence allocation and read projection
   - Contributor B: User Story 2 workflow runtime and recovery rules
   - Contributor C: User Story 3 boundary ownership and review flow
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep 012 terminology aligned with `Persistence Allocation`, `Read Projection`, `Workflow Attempt Record`, `Workflow Runtime State`, `Dead-Letter Review Unit`, `SubscriptionAuthorityRecord`, and `PurchaseStateRecord`
- Do not pull physical DB / queue products、transport query schema、provider payload detail、vendor SDK detail、deployment topology into this feature
