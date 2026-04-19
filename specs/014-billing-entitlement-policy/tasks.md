# Tasks: 課金 Product / Entitlement Policy 設計

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は product catalog review、entitlement / quota review、feature gate review、subscription state-effect review、deferred-scope review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 014 の設計成果物を置く受け皿と active feature 導線を揃える

- [X] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/research.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/`
- [X] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy` as the active feature directory
- [X] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for billing product / entitlement policy design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する source-of-truth、用語、policy framing を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Update billing policy source-of-truth references in `/Users/lihs/workspace/vocastock/docs/external/requirements.md` using `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md` as alignment inputs
- [X] T005 [P] Cross-check billing terminology, plan-code wording, and non-domain-change assumptions in `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learner.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learning-state.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md` against `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md` without changing domain semantics
- [X] T006 [P] Normalize plan code, entitlement bundle, quota profile, feature key, `grace`, `pending-sync`, `expired`, and `revoked` wording across `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/research.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/`
- [X] T007 [P] Capture feature-wide assumptions, monthly-reset constraint, and deferred commercial-scope notes in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md` and `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/research.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 商品カタログの正本を固定する (Priority: P1) 🎯 MVP

**Goal**: `free`、`standard-monthly`、`pro-monthly` の catalog と product ID 対応を独立レビュー可能にする

**Independent Test**: [product-catalog-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/product-catalog-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md) を読むだけで、第三者が 5 分以内に plan catalog、store product mapping、bundle / quota 参照関係を説明できること

### Implementation for User Story 1

- [X] T008 [P] [US1] Define the canonical plan catalog, store product mapping, and plan-to-bundle / quota references in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/product-catalog-contract.md`
- [X] T009 [P] [US1] Model `SubscriptionPlanDefinition` and catalog-level validation rules in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md`
- [X] T010 [US1] Align User Story 1 wording, acceptance scenarios, edge cases, and `FR-001` through `FR-003` in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md`
- [X] T011 [US1] Update `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md` with the product-catalog review sequence and store-product mapping checks
- [X] T012 [US1] Sync the canonical catalog and product-ID source-of-truth notes into `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md`

**Checkpoint**: User Story 1 should make product catalog and SKU mapping independently reviewable

---

## Phase 4: User Story 2 - entitlement と quota の差分を固定する (Priority: P2)

**Goal**: free / paid の bundle、quota、feature gate 差分を独立レビュー可能にする

**Independent Test**: [entitlement-policy-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/entitlement-policy-contract.md)、[quota-policy-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/quota-policy-contract.md)、[feature-gate-matrix-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/feature-gate-matrix-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md) を読むだけで、第三者が 10 分以内に bundle / quota / gate の差分を追跡できること

### Implementation for User Story 2

- [X] T013 [P] [US2] Define the canonical bundle mapping and shared premium-bundle rule in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/entitlement-policy-contract.md`
- [X] T014 [P] [US2] Define the monthly quota table, plan-to-quota mapping, and exhaustion behavior in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/quota-policy-contract.md`
- [X] T015 [P] [US2] Define the feature-key catalog and allow / limited / deny matrix in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/feature-gate-matrix-contract.md`
- [X] T016 [US2] Extend `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md` with `EntitlementBundleDefinition`, `QuotaPolicyDefinition`, `FeatureGateRule`, and cross-policy validation rules
- [X] T017 [US2] Align User Story 2 wording, acceptance scenarios, edge cases, `FR-004` through `FR-006`, `FR-010`, `FR-015`, and `FR-016` in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md` and update `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md` with the entitlement / quota / gate review sequence

**Checkpoint**: User Story 2 should make entitlement, quota, and gate policy independently reviewable

---

## Phase 5: User Story 3 - subscription state ごとの access policy を固定する (Priority: P3)

**Goal**: `grace`、`pending-sync`、`expired`、`revoked` の state effect と deferred scope を独立レビュー可能にする

**Independent Test**: [subscription-state-effect-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/subscription-state-effect-contract.md)、[billing-policy-deferred-scope-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/billing-policy-deferred-scope-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md) を読むだけで、第三者が 10 分以内に state effect と deferred concern を割り当てられること

### Implementation for User Story 3

- [X] T018 [P] [US3] Define the state-effect matrix for `active`, `grace`, `pending-sync`, `expired`, and `revoked` in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/subscription-state-effect-contract.md`
- [X] T019 [P] [US3] Define the in-scope vs deferred commercial concerns in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/billing-policy-deferred-scope-contract.md`
- [X] T020 [US3] Extend `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md` with `SubscriptionStateEffect`, `DeferredScopeItem`, and 010 / 011 / 012 / 013 source-of-truth alignment notes
- [X] T021 [US3] Align User Story 3 wording, acceptance scenarios, edge cases, and `FR-007` through `FR-014` in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md`, and `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md`

**Checkpoint**: User Story 3 should make state effect and deferred scope independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終レビュー導線を整える

- [X] T022 Reconcile all 014 artifacts across `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/research.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/`
- [X] T023 [P] Cross-check 014 terminology and source-of-truth guidance against `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/plan.md` without redefining their semantics
- [X] T024 Sync the finalized billing catalog, entitlement / quota / gate policy, state-effect guidance, and deferred-scope source-of-truth sections into `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md`
- [X] T025 Re-run the review flow in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md` and reconcile product mapping, quota / gate matrix, state-effect guidance, and deferred commercial scope with the finalized artifacts

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - shares the same catalog vocabulary, but remains independently reviewable
- **User Story 3 (P3)**: Can start after Foundational - shares the same state and source-of-truth vocabulary, but remains independently reviewable

### Within Each User Story

- Contract files should be stabilized before the corresponding spec and data-model wording is finalized
- Shared-file edits in `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/plan.md`, `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/quickstart.md` should be coordinated even when stories are independently reviewable
- Source-of-truth sync in `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` should happen after story-specific contracts are stable

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T005`, `T006`, and `T007` can run in parallel after `T004`
- In US1, `T008` and `T009` can run in parallel
- In US2, `T013`, `T014`, and `T015` can run in parallel
- In US3, `T018` and `T019` can run in parallel
- Final polish `T023` can run in parallel with `T022` once story work is complete
- `T024` should follow the finalized 014 artifact reconciliation and external cross-check
- `T025` should run after `T024` updates the external source-of-truth

---

## Parallel Example: User Story 1

```bash
# Launch product catalog and data-model tasks together:
Task: "Define the canonical plan catalog, store product mapping, and plan-to-bundle / quota references in /Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/product-catalog-contract.md"
Task: "Model SubscriptionPlanDefinition and catalog-level validation rules in /Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md"
```

## Parallel Example: User Story 2

```bash
# Launch bundle, quota, and gate tasks together:
Task: "Define the canonical bundle mapping and shared premium-bundle rule in /Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/entitlement-policy-contract.md"
Task: "Define the monthly quota table, plan-to-quota mapping, and exhaustion behavior in /Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/quota-policy-contract.md"
Task: "Define the feature-key catalog and allow / limited / deny matrix in /Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/feature-gate-matrix-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch state-effect and deferred-scope tasks together:
Task: "Define the state-effect matrix for active, grace, pending-sync, expired, and revoked in /Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/subscription-state-effect-contract.md"
Task: "Define the in-scope vs deferred commercial concerns in /Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/billing-policy-deferred-scope-contract.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that canonical plan catalog and product mapping can be reviewed independently
5. Stop and review before adding entitlement / quota / state-effect detail

### Incremental Delivery

1. Complete Setup + Foundational to fix vocabulary, source-of-truth references, and policy framing
2. Add User Story 1 to define product catalog and product-ID mapping
3. Add User Story 2 to define bundle / quota / gate policy
4. Add User Story 3 to define state effect and deferred scope
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 product catalog and mapping
   - Contributor B: User Story 2 entitlement / quota / gate policy
   - Contributor C: User Story 3 state effect and deferred scope
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep 014 terminology aligned with `free`, `standard-monthly`, `pro-monthly`, `free-basic`, `premium-generation`, `free-monthly`, `standard-monthly`, `pro-monthly`, `catalog-viewing`, `vocabulary-registration`, `explanation-generation`, `image-generation`, `completed-result-viewing`, `subscription-status-access`, `restore-access`, `grace`, `pending-sync`, `expired`, and `revoked`
- Do not pull pricing amount, tax, refund, coupon, intro offer, family plan, vendor SDK detail, or runtime workflow ordering into this feature
