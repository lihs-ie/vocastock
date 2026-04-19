# Tasks: Flutter 画面遷移 / UI 状態設計

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は navigation topology review、screen-to-source binding review、generation visibility review、subscription access / recovery review、deferred-scope review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 013 の設計成果物を置く受け皿と active feature 導線を揃える

- [X] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/research.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/`
- [X] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design` as the active feature directory
- [X] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for Flutter UI-state design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する source-of-truth、用語、boundary framing を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Update mobile UI-state source-of-truth references in `/Users/lihs/workspace/vocastock/docs/external/requirements.md` using `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md` as alignment inputs
- [X] T005 [P] Cross-check UI-state terminology, identifier wording, and non-domain-change assumptions in `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learner.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learning-state.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md` against `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md` without changing domain semantics
- [X] T006 [P] Normalize route-group, screen, reader / gate / command, `status-only`, completed-result, `pending-sync`, `expired`, and `revoked` wording across `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/research.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/`
- [X] T007 [P] Capture feature-wide assumptions, phone-first scope, and deferred-scope notes in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md` and `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/research.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 利用開始と利用制限の入口画面を固定する (Priority: P1) 🎯 MVP

**Goal**: `Auth` / `AppShell` / `Paywall` / `Restricted` の入口条件、ルート分離、`expired` / `revoked` の access policy を独立レビュー可能にする

**Independent Test**: [navigation-topology-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/navigation-topology-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md) を読むだけで、第三者が 10 分以内に未ログイン、session 解決中、利用可能、paywall 必要、`grace`、`expired`、`revoked` の入口画面と遷移条件を説明できること

### Implementation for User Story 1

- [X] T008 [P] [US1] Define the route-group matrix, canonical entry / exit flow, and shell separation rules in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/navigation-topology-contract.md`
- [X] T009 [P] [US1] Model `RouteGroupDefinition`, `ScreenDefinition`, `NavigationGuard`, and entry-related `UIStateVariant` rules in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md`
- [X] T010 [US1] Align User Story 1 wording, acceptance scenarios, edge cases, and `FR-001` through `FR-005` plus `FR-008` in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md`
- [X] T011 [US1] Update `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md` with the login, session resolving, paywall, restricted, and shell-entry review sequence
- [X] T012 [US1] Sync the canonical route topology, shell separation, and `expired` / `revoked` access-policy notes into `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md`

**Checkpoint**: User Story 1 should make entry routes and restriction boundaries independently reviewable

---

## Phase 4: User Story 2 - 単語登録から生成結果閲覧までの画面状態を固定する (Priority: P2)

**Goal**: registration、generation status、completed explanation / image 閲覧、stale read の扱いを独立レビュー可能にする

**Independent Test**: [screen-source-binding-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/screen-source-binding-contract.md)、[generation-result-visibility-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/generation-result-visibility-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md) を読むだけで、第三者が 10 分以内に registration から explanation / image result 閲覧までの screen / state / reader 単位の流れを追跡できること

### Implementation for User Story 2

- [X] T013 [P] [US2] Define the catalog, registration, `VocabularyExpressionDetail`, `ExplanationDetail`, and `ImageDetail` reader / gate / command bindings in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/screen-source-binding-contract.md`
- [X] T014 [P] [US2] Define the `status-only`, completed-only, stale-read, retryable-failure, and single-current-image visibility rules in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/generation-result-visibility-contract.md`
- [X] T015 [US2] Extend `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md` with `ReaderBinding`, `CommandBinding`, result-view `UIStateVariant`, and generation-related `ScreenDefinition` details
- [X] T016 [US2] Align User Story 2 wording, acceptance scenarios, edge cases, and `FR-009` through `FR-013` in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md`
- [X] T017 [US2] Update `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md` with the registration-to-result review sequence, stale-read checks, and completed-result-only confirmation steps

**Checkpoint**: User Story 2 should make registration, status aggregation, and result visibility independently reviewable

---

## Phase 5: User Story 3 - 課金回復と状態差分の画面を固定する (Priority: P3)

**Goal**: `SubscriptionStatus` の canonical 配置、paywall / restricted からの recovery、`pending-sync` / `grace` / `expired` / `revoked` の access policy を独立レビュー可能にする

**Independent Test**: [subscription-access-recovery-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/subscription-access-recovery-contract.md)、[ui-state-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/ui-state-boundary-contract.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md) を読むだけで、第三者が 5 分以内に paywall、restore、`pending-sync`、`grace`、`expired`、`revoked` の表示差分と回復導線を割り当てられること

### Implementation for User Story 3

- [X] T018 [P] [US3] Define the subscription access-policy matrix and recovery-flow matrix in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/subscription-access-recovery-contract.md`
- [X] T019 [P] [US3] Extend `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md` with `SubscriptionAccessPolicy`, `RecoveryFlowDefinition`, and `SubscriptionStatus` placement rules for `active`, `grace`, `pending-sync`, `expired`, and `revoked`
- [X] T020 [US3] Align User Story 3 wording, acceptance scenarios, edge cases, and `FR-006`, `FR-007`, `FR-008`, `FR-012`, `FR-014`, `FR-015`, and `FR-016` in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md` and `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md`
- [X] T021 [US3] Update `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/ui-state-boundary-contract.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md`, `/Users/lihs/workspace/vocastock/docs/external/adr.md`, and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` with canonical `SubscriptionStatus` recovery placement, backend-authority boundaries, and deferred-scope notes

**Checkpoint**: User Story 3 should make subscription access and recovery boundaries independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終レビュー導線を整える

- [X] T022 Reconcile all 013 artifacts across `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/research.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/`
- [X] T023 [P] Cross-check 013 terminology and source-of-truth guidance against `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md` without redefining their semantics
- [X] T024 Re-run the review flow in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md` and reconcile reader / gate / command mapping, completed-result visibility, and subscription recovery guidance with the finalized artifacts

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - shares the same route and source-of-truth vocabulary, but remains independently reviewable
- **User Story 3 (P3)**: Can start after Foundational - shares the same shell and boundary vocabulary, but remains independently reviewable

### Within Each User Story

- Contract files should be stabilized before the corresponding spec and data-model wording is finalized
- Shared-file edits in `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/quickstart.md` should be coordinated even when stories are independently reviewable
- Source-of-truth sync in `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` should happen after story-specific contracts are stable

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
# Launch route topology and data-model entry tasks together:
Task: "Define the route-group matrix, canonical entry / exit flow, and shell separation rules in /Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/navigation-topology-contract.md"
Task: "Model RouteGroupDefinition, ScreenDefinition, NavigationGuard, and entry-related UIStateVariant rules in /Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md"
```

## Parallel Example: User Story 2

```bash
# Launch source-binding and visibility-rule tasks together:
Task: "Define the catalog, registration, VocabularyExpressionDetail, ExplanationDetail, and ImageDetail reader / gate / command bindings in /Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/screen-source-binding-contract.md"
Task: "Define the status-only, completed-only, stale-read, retryable-failure, and single-current-image visibility rules in /Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/generation-result-visibility-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch subscription access and state-model tasks together:
Task: "Define the subscription access-policy matrix and recovery-flow matrix in /Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/subscription-access-recovery-contract.md"
Task: "Extend /Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/data-model.md with SubscriptionAccessPolicy, RecoveryFlowDefinition, and SubscriptionStatus placement rules"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that route groups, shell separation, and restriction entry conditions can be reviewed independently
5. Stop and review before adding generation/result detail and subscription recovery refinements

### Incremental Delivery

1. Complete Setup + Foundational to fix vocabulary, source-of-truth references, and boundary framing
2. Add User Story 1 to define route topology and entry restrictions
3. Add User Story 2 to define registration, status aggregation, and completed-result visibility
4. Add User Story 3 to define subscription recovery and state-specific access policy
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 route topology and entry policy
   - Contributor B: User Story 2 screen binding and generation visibility
   - Contributor C: User Story 3 subscription access and recovery
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep 013 terminology aligned with `Auth`, `AppShell`, `Paywall`, `Restricted`, `VocabularyExpressionDetail`, `SubscriptionStatus`, `status-only`, `completed`, `retryable-failure`, `hard-stop`, `pending-sync`, `grace`, `expired`, and `revoked`
- Do not pull widget implementation detail, router package choice, animation curve detail, visual token finalization, or tablet / foldable layout optimization into this feature
