# Tasks: 機能別コンポーネント定義

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は component allocation review、architecture topology review、actor-boundary review、async-generation review、deferred-scope review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 009 の設計成果物を置く受け皿と参照導線を揃える

- [X] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/research.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/`
- [X] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/009-component-boundaries` as the active feature directory
- [X] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for component boundary design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する component taxonomy、用語、参照元を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Update component-boundary source-of-truth references in `/Users/lihs/workspace/vocastock/docs/external/requirements.md` using `/Users/lihs/workspace/vocastock/specs/003-architecture-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md` as alignment inputs
- [X] T005 [P] Cross-check domain terminology and external-port references in `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learner.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learning-state.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md` against `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md` without changing domain semantics
- [X] T006 [P] Normalize onion-architecture vocabulary, top-level responsibility names, and completed-result visibility wording across `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/`
- [X] T007 [P] Capture feature-wide assumptions, dependency-direction review method, deferred-scope framing, and cross-feature source-of-truth notes in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md` and `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/research.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 現行コンポーネント境界を棚卸しする (Priority: P1) 🎯 MVP

**Goal**: 現行のフラットな component 一覧を canonical topology と current-to-canonical mapping へ整理し、不足項目と責務混在を第三者がレビュー可能な形で示す

**Independent Test**: [architecture-topology-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/architecture-topology-contract.md)、[component-allocation-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/component-allocation-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md) を読むだけで、現行 component の keep / split / add と top-level 責務の差分を第三者が説明できること

### Implementation for User Story 1

- [X] T008 [P] [US1] Define onion topology, inner foundation layers, top-level responsibilities, and dependency-direction rules in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/architecture-topology-contract.md`
- [X] T009 [P] [US1] Define the current-to-canonical component allocation, keep / split / add decisions, and new component list in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/component-allocation-contract.md`
- [X] T010 [US1] Map `InternalFoundationLayer`, `TopLevelResponsibility`, and `ComponentDefinition` semantics, including the canonical component catalog, into `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md`
- [X] T011 [US1] Align User Story 1 wording, acceptance scenarios, edge cases, and FR-001 through FR-003 in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md`, and update the component section in `/Users/lihs/workspace/vocastock/docs/external/adr.md` with the finalized topology and allocation decisions

**Checkpoint**: User Story 1 should make the topology and current-list audit independently reviewable

---

## Phase 4: User Story 2 - コンテキストごとの責務を分離する (Priority: P2)

**Goal**: actor/auth boundary、command intake、query read、async workflow、external adapter の責務差分を整理し、登録・解説閲覧・画像生成フローの component 分離を一貫化する

**Independent Test**: [actor-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/actor-boundary-contract.md)、[async-generation-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/async-generation-boundary-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md) を読むだけで、actor handoff、write/read split、workflow split、adapter split を第三者が説明できること

### Implementation for User Story 2

- [X] T012 [P] [US2] Define `Learner Identity Resolution`, `Actor Session Handoff`, boundary rules, and auth/session deferred areas in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/actor-boundary-contract.md`
- [X] T013 [P] [US2] Define explanation/image request acceptance, workflow execution, result reading, status reading, and adapter split in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/async-generation-boundary-contract.md`
- [X] T014 [US2] Extend `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md` with `FlowAssignment`, canonical flow tables, and non-ownership rules for `Command Intake`, `Query Read`, `Async Generation`, and `External Adapters`
- [X] T015 [US2] Align `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md` Domain & Async Impact, User Story 2 acceptance scenarios, and FR-004 through FR-010 with the finalized responsibility split
- [X] T016 [US2] Capture the rationale for auth/session boundary separation, write/read split, workflow split, and adapter split in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/research.md`

**Checkpoint**: User Story 2 should make responsibility separation and flow decomposition independently reviewable

---

## Phase 5: User Story 3 - 後続 feature との境界を固定する (Priority: P3)

**Goal**: auth/session、backend command、query model、vendor adapter 実装、follow-on image scope を deferred ownership として整理し、どの変更要求が 009 の対象かを判断できるようにする

**Independent Test**: [deferred-scope-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/deferred-scope-contract.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/quickstart.md)、[plan.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md) を読むだけで、任意の変更要求を in-scope component または deferred source-of-truth へ第三者が割り当てられること

### Implementation for User Story 3

- [X] T017 [P] [US3] Define the ownership matrix, scope rules, and follow-on items in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/deferred-scope-contract.md`
- [X] T018 [P] [US3] Update `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/quickstart.md` with the review sequence for topology, allocation, actor/auth boundary, async generation, and deferred-scope decisions
- [X] T019 [P] [US3] Capture the rationale for deferring auth/session implementation, command semantics, query model implementation, vendor-specific adapters, and multiple current image scope in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/research.md`
- [X] T020 [US3] Align `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md` User Story 3 wording, FR-011 through FR-016, assumptions, and deferred edge cases with the finalized ownership matrix and follow-on scope
- [X] T021 [US3] Update `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md` Structure Decision and source-of-truth notes to match the finalized deferred-scope ownership and no-redefinition constraints

**Checkpoint**: User Story 3 should make deferred ownership and follow-on scope independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終導線を整える

- [X] T022 [P] Reconcile all 009 artifacts across `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/research.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/`
- [X] T023 [P] Cross-check 009 component terminology against `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/specs/003-architecture-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`
- [X] T024 Re-run the review flow in `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/quickstart.md` and reconcile reviewer guidance with the finalized component taxonomy and deferred-scope boundaries

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - shared onion vocabulary and top-level taxonomy are fixed in Phase 2, so no dependency on US1 remains
- **User Story 3 (P3)**: Can start after Foundational - uses the same taxonomy and source-of-truth references, but remains independently reviewable

### Within Each User Story

- Topology and allocation contracts should be fixed before final spec wording adjustments
- Actor/auth boundary and async-generation contracts should land before flow-assignment and rationale alignment
- Deferred-scope ownership should be fixed before quickstart and structure-decision guidance are finalized

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T005`, `T006`, and `T007` can run in parallel after `T004`
- In US1, `T008` and `T009` can run in parallel
- In US2, `T012` and `T013` can run in parallel
- In US3, `T017`, `T018`, and `T019` can run in parallel
- Final polish `T022` and `T023` can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch topology and allocation tasks together:
Task: "Define onion topology, inner foundation layers, top-level responsibilities, and dependency-direction rules in /Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/architecture-topology-contract.md"
Task: "Define the current-to-canonical component allocation, keep / split / add decisions, and new component list in /Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/component-allocation-contract.md"
```

## Parallel Example: User Story 2

```bash
# Launch responsibility-split tasks together:
Task: "Define Learner Identity Resolution, Actor Session Handoff, boundary rules, and auth/session deferred areas in /Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/actor-boundary-contract.md"
Task: "Define explanation/image request acceptance, workflow execution, result reading, status reading, and adapter split in /Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/async-generation-boundary-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch deferred-scope tasks together:
Task: "Define the ownership matrix, scope rules, and follow-on items in /Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/deferred-scope-contract.md"
Task: "Update /Users/lihs/workspace/vocastock/specs/009-component-boundaries/quickstart.md with the review sequence for topology, allocation, actor/auth boundary, async generation, and deferred-scope decisions"
Task: "Capture the rationale for deferred auth/session, command semantics, query model implementation, vendor-specific adapters, and multiple current image scope in /Users/lihs/workspace/vocastock/specs/009-component-boundaries/research.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that the topology and current-list audit can be reviewed independently
5. Stop and review before adding responsibility-split and deferred-scope refinements

### Incremental Delivery

1. Complete Setup + Foundational to fix taxonomy, terminology, and source-of-truth references
2. Add User Story 1 to define the onion topology and current-to-canonical mapping
3. Add User Story 2 to fix actor/auth boundary, async workflow, and adapter separation
4. Add User Story 3 to define deferred ownership and follow-on scope
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 topology and allocation
   - Contributor B: User Story 2 responsibility separation
   - Contributor C: User Story 3 deferred-scope ownership and review guidance
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep 009 terminology aligned with `Domain Core`, `Application Coordination`, `Actor/Auth Boundary`, `Command Intake`, `Query Read`, `Async Generation`, and `External Adapters`
- Do not pull auth/session implementation detail, backend command semantics, query model implementation, or vendor SDK design into this feature
