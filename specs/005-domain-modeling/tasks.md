# Tasks: ドメインモデリング

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/005-domain-modeling/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/plan.md), [spec.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md), [research.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/data-model.md), [quickstart.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/quickstart.md), [contracts/](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/contracts)

**Tests**: 自動テストは追加しない。各 user story は spec.md の独立テスト条件と quickstart の cross-review 手順で検証する。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g. [US1], [US2], [US3])
- 各 task は exact file path を含む

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: `Sense` 導入で触る正本文書の受け皿を整える

- [X] T001 Create `Sense` review anchors and migration-note placeholders in /Users/lihs/workspace/vocastock/docs/internal/domain/common.md
- [X] T002 [P] Create `Sense` section placeholders for aggregate/entity updates in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md and /Users/lihs/workspace/vocastock/docs/internal/domain/visual.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story で共有する用語、識別子、mapping 前提を固める

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 Define canonical `Sense` terminology, `Meaning` migration note, and project-wide mapping rules in /Users/lihs/workspace/vocastock/docs/internal/domain/common.md
- [X] T004 [P] Align `SenseIdentifier` naming, ownership language, and related-field naming across /Users/lihs/workspace/vocastock/docs/internal/domain/common.md, /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md, and /Users/lihs/workspace/vocastock/docs/internal/domain/visual.md
- [X] T005 [P] Document the single-current-image rule and meaning-to-image mapping baseline in /Users/lihs/workspace/vocastock/docs/internal/domain/common.md
- [X] T006 Add `Sense`-aware image generation and storage port vocabulary in /Users/lihs/workspace/vocastock/docs/internal/domain/service.md

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - 主要概念の境界を定める (Priority: P1) 🎯 MVP

**Goal**: `Sense` を `Explanation` 所有の意味単位として定義し、`Explanation` / `VisualImage` との責務差分を明確化する

**Independent Test**: 第三者が /Users/lihs/workspace/vocastock/docs/internal/domain/common.md、/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md、/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md だけを読み、`Sense`、`Explanation`、`VisualImage` の責務と不変条件を 5 分以内に説明できること

### Implementation for User Story 1

- [X] T007 [US1] Define `Sense` as an `Explanation`-owned internal entity with fields, order, and invariants in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md
- [X] T008 [P] [US1] Replace coarse `Meaning` ownership with `Explanation.senses` language in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md
- [X] T009 [P] [US1] Move example and collocation ownership from explanation-wide wording to sense-specific wording in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md
- [X] T010 [US1] Add cross-links from /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md to /Users/lihs/workspace/vocastock/docs/internal/domain/common.md and /Users/lihs/workspace/vocastock/docs/internal/domain/visual.md for `Sense` semantics
- [X] T011 [US1] Reconcile `Explanation` aggregate summary and invariants with the `Sense` model in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md

**Checkpoint**: User Story 1 should be independently understandable and reviewable

---

## Phase 4: User Story 2 - 非同期生成の業務意味を定める (Priority: P2)

**Goal**: `Sense` 導入後も画像生成の current 参照、retry、regenerate、表示可否を壊さないようにする

**Independent Test**: レビュー担当者が /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md、/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md、/Users/lihs/workspace/vocastock/docs/internal/domain/service.md だけを読み、sense-aware image generation と単一 `currentImage` の業務意味を説明できること

### Implementation for User Story 2

- [X] T012 [P] [US2] Document `currentImage` as a single completed image even when multiple `Sense` values exist in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md
- [X] T013 [P] [US2] Define `VisualImage.sense`, same-explanation ownership, and same-sense regeneration constraints in /Users/lihs/workspace/vocastock/docs/internal/domain/visual.md
- [X] T014 [P] [US2] Update image generation port wording to accept `sense?` and preserve completion-only visibility in /Users/lihs/workspace/vocastock/docs/internal/domain/service.md
- [X] T015 [US2] Reconcile retry/regenerate and visibility language across /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md, /Users/lihs/workspace/vocastock/docs/internal/domain/visual.md, and /Users/lihs/workspace/vocastock/docs/internal/domain/service.md

**Checkpoint**: User Story 2 should be independently reviewable without exposing intermediate results

---

## Phase 5: User Story 3 - 文書横断で用語と deferred scope を統一する (Priority: P3)

**Goal**: 要件、ADR、共通 glossary を `Sense` 前提へ揃え、複数 current image を後続 scope として明示する

**Independent Test**: /Users/lihs/workspace/vocastock/docs/external/requirements.md、/Users/lihs/workspace/vocastock/docs/external/adr.md、/Users/lihs/workspace/vocastock/docs/internal/domain/common.md を横断して、`Sense` 導入、meaning-to-image mapping、follow-on scope が矛盾なく説明できること

### Implementation for User Story 3

- [X] T016 [P] [US3] Add `Sense` terminology and meaning-unit language to /Users/lihs/workspace/vocastock/docs/external/requirements.md
- [X] T017 [P] [US3] Add `Sense` boundary, single-current-image decision, and follow-on scope notes to /Users/lihs/workspace/vocastock/docs/external/adr.md
- [X] T018 [US3] Update deferred-scope guidance for multi-image-per-explanation follow-on work in /Users/lihs/workspace/vocastock/docs/internal/domain/common.md
- [X] T019 [US3] Cross-check `Sense`, `Meaning`, and image mapping terminology across /Users/lihs/workspace/vocastock/docs/external/requirements.md, /Users/lihs/workspace/vocastock/docs/external/adr.md, and /Users/lihs/workspace/vocastock/docs/internal/domain/common.md

**Checkpoint**: User Story 3 should make external docs and glossary align on `Sense` and follow-on boundaries

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 最終整合確認と旧表現の残差分除去

- [X] T020 Validate /Users/lihs/workspace/vocastock/specs/005-domain-modeling/quickstart.md and /Users/lihs/workspace/vocastock/specs/005-domain-modeling/contracts/sense-image-mapping-contract.md against /Users/lihs/workspace/vocastock/docs/internal/domain/common.md, /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md, /Users/lihs/workspace/vocastock/docs/internal/domain/visual.md, /Users/lihs/workspace/vocastock/docs/internal/domain/service.md, /Users/lihs/workspace/vocastock/docs/external/requirements.md, and /Users/lihs/workspace/vocastock/docs/external/adr.md
- [X] T021 Remove leftover explanation-wide `Meaning.values` wording and ambiguous multi-image wording beyond intentional migration notes across /Users/lihs/workspace/vocastock/docs/internal/domain/*.md and /Users/lihs/workspace/vocastock/docs/external/*.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: All depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational - no dependencies on other stories
- **User Story 3 (P3)**: Can start after Foundational - no dependencies on other stories

### Within Each User Story

- Shared terminology, identifier rules, and mapping baselines from Foundational must exist first
- `Explanation` aggregate updates before cross-links that depend on `Sense`
- `VisualImage.sense` rules before async reconciliation that references them
- External-doc alignment before final terminology cleanup

### Parallel Opportunities

- T002 can run in parallel with T001
- T004 and T005 can run in parallel
- T008 and T009 can run in parallel
- T012, T013, and T014 can run in parallel
- T016 and T017 can run in parallel

---

## Parallel Example: User Story 1

```bash
Task: "Replace coarse `Meaning` ownership with `Explanation.senses` language in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md"
Task: "Move example and collocation ownership to sense-specific wording in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md"
```

## Parallel Example: User Story 2

```bash
Task: "Document single `currentImage` behavior in /Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md"
Task: "Define `VisualImage.sense` constraints in /Users/lihs/workspace/vocastock/docs/internal/domain/visual.md"
Task: "Update sense-aware image generation port wording in /Users/lihs/workspace/vocastock/docs/internal/domain/service.md"
```

## Parallel Example: User Story 3

```bash
Task: "Add `Sense` terminology to /Users/lihs/workspace/vocastock/docs/external/requirements.md"
Task: "Add `Sense` boundary and follow-on scope notes to /Users/lihs/workspace/vocastock/docs/external/adr.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Review the `Sense` / `Explanation` / `VisualImage` boundaries independently before proceeding

### Incremental Delivery

1. Complete Setup + Foundational
2. Deliver User Story 1 and verify `Sense` boundary
3. Deliver User Story 2 and verify sense-aware async visibility rules
4. Deliver User Story 3 and verify cross-document terminology alignment
5. Run Polish validation against quickstart and contracts, then remove leftover old wording

### Parallel Team Strategy

1. One writer prepares glossary anchors and placeholders in Phase 1
2. A second writer stabilizes identifier and mapping rules in Phase 2
3. After Foundational:
   - Writer A: User Story 1
   - Writer B: User Story 2
   - Writer C: User Story 3

---

## Notes

- [P] tasks = different files, no dependencies
- [US1], [US2], [US3] labels map tasks to user stories for traceability
- Each user story is independently reviewable with its own document set
- Keep `currentImage` singular in this feature; multi-current-image support is follow-on scope
- Commit after each logical group of document changes
