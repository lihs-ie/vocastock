# Tasks: バックエンド Command 設計

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/`
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は command catalog review、acceptance review、dispatch consistency review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 007 の設計成果物を置く受け皿と参照導線を揃える

- [ ] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/research.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/data-model.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/`
- [ ] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/007-backend-command-design` as the active feature directory
- [ ] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for backend command design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する command 境界の前提文書と参照元を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Reconcile backend command scope references across `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/docs/external/adr.md`, and `/Users/lihs/workspace/vocastock/specs/003-architecture-design/contracts/boundary-responsibility-contract.md`
- [ ] T005 [P] Reconcile command-related terminology across `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`
- [ ] T006 [P] Capture command-side assumptions, exclusions, temporary semantic source references, exit conditions, and justified constitution exception details in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md` and `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/research.md`
- [ ] T007 Normalize command naming, identifier references, acceptance-result terminology, and duplicate-restart vocabulary across `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Command の責務境界を定義する (Priority: P1) 🎯 MVP

**Goal**: backend command が受け付ける状態変更要求と、query / workflow / client に委譲する責務を明確化する

**Independent Test**: [command-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-boundary-contract.md) と [command-catalog-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-catalog-contract.md) を読むだけで、各 command が何を受け付け、何を直接実行しないかを第三者が説明できること

### Implementation for User Story 1

- [ ] T008 [P] [US1] Define the primary backend command catalog, including duplicate-registration default/restart behavior summary, in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-catalog-contract.md`
- [ ] T009 [P] [US1] Define command-side responsibility boundaries in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-boundary-contract.md`
- [ ] T010 [US1] Map command definitions and ownership rules into `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/data-model.md`
- [ ] T011 [US1] Align User Story 1 scope and acceptance wording in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md` with the finalized command catalog

**Checkpoint**: User Story 1 should define the backend command boundary independently

---

## Phase 4: User Story 2 - Command 契約と状態変更規則を整理する (Priority: P2)

**Goal**: 各 command の受理条件、重複時挙動、重複登録時の再開条件、即時応答、dispatch failure 規則を一貫した contract として定義する

**Independent Test**: [command-acceptance-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-acceptance-contract.md)、[command-dispatch-consistency-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-dispatch-consistency-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/data-model.md) を読めば、重複登録、重複登録時の生成再開条件、生成再送、dispatch failure の扱いを第三者が一貫して説明できること

### Implementation for User Story 2

- [ ] T012 [P] [US2] Define command acceptance rules, including duplicate-registration restart conditions, in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-acceptance-contract.md`
- [ ] T013 [P] [US2] Define dispatch consistency and ordering rules in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-dispatch-consistency-contract.md`
- [ ] T014 [US2] Extend `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/data-model.md` with acceptance results, duplicate registration results, duplicate restart decision conditions, and dispatch consistency entities
- [ ] T015 [US2] Reconcile User Story 2 requirements, FR-003b, and edge cases in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md` with the finalized acceptance rules
- [ ] T016 [US2] Summarize the rationale for registration default behavior, duplicate reuse, duplicate restart conditions, and dispatch failure handling in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/research.md`

**Checkpoint**: User Story 2 should make command acceptance, duplicate restart conditions, and state-change rules independently reviewable

---

## Phase 5: User Story 3 - 実装前提と除外範囲を合意する (Priority: P3)

**Goal**: command 実装前に参照すべき文書、前提条件、暫定 semantic source の終了条件、後続 feature owner、今回の対象外範囲を運用可能な形で整理する

**Independent Test**: [quickstart.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/quickstart.md)、[plan.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md)、[research.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/research.md) を読めば、後続実装者が参照順序、暫定 semantic source の終了条件、`005-domain-modeling` への引き継ぎ責任、非対象範囲を説明できること

### Implementation for User Story 3

- [ ] T017 [P] [US3] Document implementation entry guidance, including the temporary `specs/005-domain-modeling/` semantic source, exit conditions, and operator-facing handoff notes, in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/quickstart.md`
- [ ] T018 [P] [US3] Document source-of-truth, assumptions, exclusions, the justified temporary semantic-source exception, and the follow-on owner for materializing `docs/internal/domain/learner.md`, `vocabulary-expression.md`, and `learning-state.md` in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`
- [ ] T019 [US3] Reconcile research decisions with out-of-scope boundaries, temporary semantic-source rationale, and migration handoff toward `005-domain-modeling` domain-doc materialization in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/research.md`
- [ ] T020 [US3] Align User Story 3 scope, assumptions, success criteria, temporary semantic-source exit wording, and follow-on ownership notes in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md`

**Checkpoint**: User Story 3 should make implementation prerequisites, temporary semantic-source exit conditions, and exclusions independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終導線を整える

- [ ] T021 [P] Reconcile all 007 artifacts across `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/research.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/`
- [ ] T022 [P] Cross-check 007 command terminology against `/Users/lihs/workspace/vocastock/specs/003-architecture-design/`, `/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/`, and `/Users/lihs/workspace/vocastock/specs/005-domain-modeling/`
- [ ] T023 Re-run the quickstart review flow in `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/quickstart.md` and reconcile operator guidance with the shipped design
- [ ] T024 Update `/Users/lihs/workspace/vocastock/AGENTS.md` and final repository guidance if the command design introduces new canonical terminology worth surfacing

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - shared command terms and duplicate-restart vocabulary are fixed in Phase 2, so no dependency on US1 remains
- **User Story 3 (P3)**: Can start after Foundational - consumes finalized command rules and documents how to use them without changing their semantics

### Within Each User Story

- Command catalog and boundary definitions should land before cross-document wording adjustments
- Acceptance and dispatch rules should be defined before final edge-case alignment
- Quickstart and operational guidance should be finalized after the corresponding design artifacts are stable

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T005` and `T006` can run in parallel after `T004`
- In US1, `T008` and `T009` can run in parallel
- In US2, `T012` and `T013` can run in parallel
- In US3, `T017` and `T018` can run in parallel
- Final polish `T021` and `T022` can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch boundary-definition tasks together:
Task: "Define the primary backend command catalog in /Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-catalog-contract.md"
Task: "Define command-side responsibility boundaries in /Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-boundary-contract.md"
```

## Parallel Example: User Story 2

```bash
# Launch acceptance-rule tasks together:
Task: "Define command acceptance rules in /Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-acceptance-contract.md"
Task: "Define dispatch consistency and ordering rules in /Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-dispatch-consistency-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch implementation-guidance tasks together:
Task: "Document implementation entry guidance, temporary semantic-source exit conditions, and handoff notes in /Users/lihs/workspace/vocastock/specs/007-backend-command-design/quickstart.md"
Task: "Document source-of-truth, assumptions, exclusions, and follow-on ownership in /Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that backend command boundary ownership can be reviewed independently
5. Stop and review before adding acceptance / dispatch details

### Incremental Delivery

1. Ship Setup + Foundational to fix source-of-truth references, temporary semantic-source exception, and terminology
2. Add User Story 1 to define the backend command boundary
3. Add User Story 2 to fix acceptance, duplicate, duplicate restart, and dispatch consistency rules
4. Add User Story 3 to document implementation entry guidance, temporary semantic-source exit conditions, and exclusions
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 command catalog and boundary split
   - Contributor B: User Story 2 acceptance and dispatch consistency
   - Contributor C: User Story 3 quickstart, source-of-truth guidance, and migration handoff
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep backend command terminology aligned with `Vocabulary Command`, `VocabularyExpression`, and the existing async visibility rules
- Do not pull query, workflow execution, or provider-specific adapter design into this feature
