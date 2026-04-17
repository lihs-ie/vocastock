# Tasks: ドメインモデリング

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/005-domain-modeling/`
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/plan.md), [spec.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md), [research.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/data-model.md), [quickstart.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/quickstart.md), [contracts/](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/contracts)

**Tests**: 自動テストは明示要求されていないため生成しない。各 user story は spec.md の独立テスト条件と quickstart の cross-review 手順で検証する。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g. [US1], [US2], [US3])
- 各 task は exact file path を含む

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 新しい source-of-truth 文書の受け皿を作る

- [X] T001 [P] Create learner source-of-truth skeleton in docs/internal/domain/learner.md
- [X] T002 [P] Create vocabulary expression source-of-truth skeleton in docs/internal/domain/vocabulary-expression.md
- [X] T003 [P] Create learning state source-of-truth skeleton in docs/internal/domain/learning-state.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story で共有する命名規約と導線を固める

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Define canonical glossary, deprecated-name crosswalk, and naming rules in docs/internal/domain/common.md
- [X] T005 Add source-of-truth index and aggregate relationship overview in docs/internal/domain/common.md
- [X] T006 Add backlinks from docs/internal/domain/explanation.md, docs/internal/domain/visual.md, and docs/internal/domain/service.md to the new source-of-truth files

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - 主要概念の境界を定める (Priority: P1) 🎯 MVP

**Goal**: `Learner`、`VocabularyExpression`、`LearningState`、`Explanation` の責務境界を一貫した用語で定義する

**Independent Test**: 第三者が docs/internal/domain/learner.md、docs/internal/domain/vocabulary-expression.md、docs/internal/domain/learning-state.md、docs/internal/domain/explanation.md、docs/internal/domain/common.md だけを読み、主要概念、所有境界、不変条件を 5 分以内に説明できること

### Implementation for User Story 1

- [X] T007 [US1] Define `Learner` aggregate, external identity boundary, and ownership semantics in docs/internal/domain/learner.md
- [X] T008 [P] [US1] Define `VocabularyExpression` aggregate, uniqueness scope, `VocabularyExpressionText`, `NormalizedVocabularyExpressionText`, and `currentExplanation` in docs/internal/domain/vocabulary-expression.md
- [X] T009 [P] [US1] Define `LearningState` aggregate, `Proficiency` ownership, and relations to `Learner` / `VocabularyExpression` in docs/internal/domain/learning-state.md
- [X] T010 [US1] Reframe `Explanation` domain narrative around `VocabularyExpression` references in docs/internal/domain/explanation.md
- [X] T011 [US1] Add relationship cross-links across docs/internal/domain/learner.md, docs/internal/domain/vocabulary-expression.md, docs/internal/domain/learning-state.md, and docs/internal/domain/explanation.md

**Checkpoint**: User Story 1 should be independently understandable and reviewable

---

## Phase 4: User Story 2 - 非同期生成の業務意味を定める (Priority: P2)

**Goal**: 解説生成と画像生成の状態、再試行、再生成、表示可否を domain language で明文化する

**Independent Test**: レビュー担当者が docs/internal/domain/vocabulary-expression.md、docs/internal/domain/explanation.md、docs/internal/domain/visual.md、docs/internal/domain/service.md だけを読み、生成依頼から完了・失敗・再生成までの状態遷移と表示ルールを説明できること

### Implementation for User Story 2

- [X] T012 [P] [US2] Document `VocabularyExpression` explanation-generation lifecycle, retry/regenerate rules, and `currentExplanation` visibility in docs/internal/domain/vocabulary-expression.md
- [X] T013 [P] [US2] Document `Explanation` image-generation lifecycle and `currentImage` visibility in docs/internal/domain/explanation.md
- [X] T014 [P] [US2] Document `VisualImage` history, `previousImage` chain, and current-image handoff in docs/internal/domain/visual.md
- [X] T015 [US2] Align generation, storage, and failure responsibilities with external ports in docs/internal/domain/service.md
- [X] T016 [US2] Reconcile async visibility language across docs/internal/domain/vocabulary-expression.md, docs/internal/domain/explanation.md, docs/internal/domain/visual.md, and docs/internal/domain/service.md

**Checkpoint**: User Story 2 should be independently reviewable without relying on intermediate generated results

---

## Phase 5: User Story 3 - 文書横断で用語と deferred scope を統一する (Priority: P3)

**Goal**: 要件、ADR、既存 domain docs の用語と out-of-scope / deferred 範囲を `VocabularyExpression` / `LearningState` 前提で整合させる

**Independent Test**: docs/external/requirements.md、docs/external/adr.md、docs/internal/domain/common.md を横断して、主要概念、責務境界、今回扱わない論点が矛盾なく整理されていると第三者が判定できること

### Implementation for User Story 3

- [X] T017 [P] [US3] Replace `Entry` terminology with `VocabularyExpression` terms in docs/external/requirements.md
- [X] T018 [P] [US3] Replace `Entry` / `EntryLearningState` terminology and port names in docs/external/adr.md
- [X] T019 [US3] Add canonical terminology and deprecated synonym guidance in docs/internal/domain/common.md
- [X] T020 [US3] Normalize `VocabularyExpressionText` and `NormalizedVocabularyExpressionText` naming in docs/external/requirements.md and docs/external/adr.md
- [X] T021 [US3] Add out-of-scope / deferred scope guidance and follow-on feature boundaries in docs/internal/domain/common.md and docs/external/adr.md
- [X] T022 [US3] Cross-check terminology consistency and deferred scope alignment across docs/external/requirements.md, docs/external/adr.md, and docs/internal/domain/common.md

**Checkpoint**: User Story 3 should make the external docs and glossary align on the same canonical terms and deferred boundaries

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 最終整合確認と残差分の除去

- [X] T023 Validate specs/005-domain-modeling/quickstart.md against docs/internal/domain/learner.md, docs/internal/domain/vocabulary-expression.md, docs/internal/domain/learning-state.md, docs/internal/domain/explanation.md, docs/internal/domain/visual.md, docs/internal/domain/service.md, docs/external/requirements.md, and docs/external/adr.md
- [X] T024 Remove leftover deprecated-name references beyond the allowed migration note across docs/internal/domain/*.md and docs/external/*.md

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

- Shared terminology and backlinks from Foundational must exist first
- Source-of-truth files before cross-links that reference them
- Aggregate definitions before cross-document reconciliation
- Story completion before Polish validation

### Parallel Opportunities

- T001, T002, T003 can run in parallel
- T008 and T009 can run in parallel
- T012, T013, and T014 can run in parallel
- T017, T018, and T021 can run in parallel

---

## Parallel Example: User Story 1

```bash
Task: "Define `VocabularyExpression` aggregate in docs/internal/domain/vocabulary-expression.md"
Task: "Define `LearningState` aggregate in docs/internal/domain/learning-state.md"
```

## Parallel Example: User Story 2

```bash
Task: "Document `VocabularyExpression` explanation-generation lifecycle in docs/internal/domain/vocabulary-expression.md"
Task: "Document `Explanation` image-generation lifecycle in docs/internal/domain/explanation.md"
Task: "Document `VisualImage` history in docs/internal/domain/visual.md"
```

## Parallel Example: User Story 3

```bash
Task: "Replace terminology in docs/external/requirements.md"
Task: "Replace terminology in docs/external/adr.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Review the concept boundaries independently before proceeding

### Incremental Delivery

1. Complete Setup + Foundational
2. Deliver User Story 1 and verify concept boundaries
3. Deliver User Story 2 and verify async lifecycle / visibility rules
4. Deliver User Story 3 and verify cross-document terminology alignment
5. Run Polish validation against quickstart and remove leftover old names

### Parallel Team Strategy

1. One writer prepares the three new source-of-truth files in Phase 1
2. A second writer stabilizes glossary and backlinks in Phase 2
3. After Foundational:
   - Writer A: User Story 1
   - Writer B: User Story 2
   - Writer C: User Story 3

---

## Notes

- [P] tasks = different files, no dependencies
- [US1], [US2], [US3] labels map tasks to user stories for traceability
- Each user story is independently reviewable with its own document set
- Keep deprecated names only where the migration note explicitly calls them out once
- Commit after each logical group of document changes
