# Tasks: Subscription Component Boundaries

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は subscription authority review、purchase-state review、entitlement gate review、adapter resilience review、purchase reconciliation review、deferred-scope review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 010 の設計成果物を置く受け皿と参照導線を揃える

- [X] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/research.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/`
- [X] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries` as the active feature directory
- [X] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for subscription component boundary design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する source-of-truth、用語、authority framing を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Update billing-boundary source-of-truth references in `/Users/lihs/workspace/vocastock/docs/external/requirements.md` using `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md` as alignment inputs
- [X] T005 [P] Cross-check subscription terminology and actor-reference wording in `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learner.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md` against `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md` without changing domain semantics
- [X] T006 [P] Normalize authoritative-state names, entitlement mirror wording, and quota terminology across `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/`
- [X] T007 [P] Capture feature-wide assumptions, external-boundary framing, and cross-feature source-of-truth notes in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md` and `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/research.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 課金責務の正本を整理する (Priority: P1) 🎯 MVP

**Goal**: subscription topology、authoritative state、app-facing mirror の責務を整理し、課金状態の正本、unlock の正本、UI 表示責務を独立レビュー可能にする

**Independent Test**: [subscription-topology-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-topology-contract.md)、[subscription-authority-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-authority-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md) を読むだけで、第三者が 5 分以内に authoritative owner、purchase state と subscription state の分離、entitlement mirror、UI responsibility を説明できること

### Implementation for User Story 1

- [X] T008 [P] [US1] Define boundary groups, canonical subscription components, inner policy components, and dependency-direction rules in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-topology-contract.md`
- [X] T009 [P] [US1] Define the authoritative-source matrix, five-state subscription model, canonical purchase-state model, entitlement mirror rules, and adapter resilience rules in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-authority-contract.md`
- [X] T010 [US1] Map `SubscriptionBoundaryGroup`, `SubscriptionComponentDefinition`, `AuthoritativeSubscriptionStateModel`, `PurchaseStateModel`, `AdapterResiliencePolicy`, and `EntitlementMirror` semantics into `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md`
- [X] T011 [US1] Align User Story 1 wording, FR-001 through FR-004a, assumptions, and authority-related edge cases in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md`
- [X] T012 [US1] Update the subscription / billing component section in `/Users/lihs/workspace/vocastock/docs/external/adr.md` and the billing source-of-truth guidance in `/Users/lihs/workspace/vocastock/docs/external/requirements.md` with the finalized topology and authority rules

**Checkpoint**: User Story 1 should make subscription authority and UI responsibility independently reviewable

---

## Phase 4: User Story 2 - 課金状態と機能解放の流れを分離する (Priority: P2)

**Goal**: entitlement、feature gate、usage quota、purchase / restore / refresh / reconciliation の流れを分離し、premium unlock と usage 制限を混同しない構成を固める

**Independent Test**: [entitlement-gate-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/entitlement-gate-contract.md)、[purchase-reconciliation-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/purchase-reconciliation-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md) を読むだけで、第三者が purchase state の進行、adapter timeout / retry / fallback、entitlement 反映、quota 判定、feature gate までを component 単位で追跡できること

### Implementation for User Story 2

- [X] T013 [P] [US2] Define entitlement, feature gate, and usage-quota responsibility separation in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/entitlement-gate-contract.md`
- [X] T014 [P] [US2] Define complete-purchase, restore-purchase, and refresh / notification reconciliation flows, purchase-state progression, and adapter resilience matrix in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/purchase-reconciliation-contract.md`
- [X] T015 [US2] Extend `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md` with `UsageQuotaPolicy`, `SubscriptionFlowAssignment`, purchase-state effect tables, adapter resilience matrix, and gate decision flow assignments
- [X] T016 [US2] Align User Story 2 wording, Domain & Async Impact, and FR-004b through FR-009 in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md` with the finalized purchase-state / gate / reconciliation split
- [X] T017 [US2] Capture the rationale for backend authority, purchase-state separation, adapter resilience, `grace` handling, `pending-sync` denial, and quota separation in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/research.md`

**Checkpoint**: User Story 2 should make unlock / quota / reconciliation flow separation independently reviewable

---

## Phase 5: User Story 3 - 課金境界と deferred scope を固定する (Priority: P3)

**Goal**: auth/session、backend command、product-wide taxonomy、pricing / tax / refund / SDK detail の ownership を切り分け、サブスク変更要求の行き先を一貫して判断できるようにする

**Independent Test**: [subscription-deferred-scope-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-deferred-scope-contract.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/quickstart.md)、[plan.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md) を読むだけで、第三者が任意の billing 変更要求を in-scope component または deferred source-of-truth へ 5 分以内に割り当てられること

### Implementation for User Story 3

- [X] T018 [P] [US3] Define the deferred ownership matrix, guardrails, and external-boundary split in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-deferred-scope-contract.md`
- [X] T019 [P] [US3] Update `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/quickstart.md` with the review sequence for topology, authority, entitlement / quota separation, reconciliation, and deferred scope
- [X] T020 [US3] Align User Story 3 wording, FR-010 through FR-012, assumptions, and deferred edge cases in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md` with the finalized ownership matrix
- [X] T021 [US3] Update `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md` Structure Decision and source-of-truth notes to match the finalized deferred-scope ownership and external sync targets

**Checkpoint**: User Story 3 should make deferred ownership and cross-feature boundaries independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終レビュー導線を整える

- [X] T022 [P] Reconcile all 010 artifacts across `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/research.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md`, `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/`
- [X] T023 [P] Cross-check 010 subscription terminology against `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`
- [X] T024 Re-run the review flow in `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/quickstart.md` and reconcile reviewer guidance with the finalized subscription topology, purchase-state model, adapter resilience rules, entitlement / quota split, and deferred-scope boundaries

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - uses the topology and authority vocabulary from Phase 2, but remains independently reviewable
- **User Story 3 (P3)**: Can start after Foundational - uses the same source-of-truth framing, but remains independently reviewable

### Within Each User Story

- Topology and authority contracts should be fixed before final spec wording adjustments
- Entitlement / quota separation and reconciliation flows should land before final flow-alignment updates
- Deferred ownership should be fixed before quickstart and structure-decision guidance are finalized

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T005`, `T006`, and `T007` can run in parallel after `T004`
- In US1, `T008` and `T009` can run in parallel
- In US2, `T013` and `T014` can run in parallel
- In US3, `T018` and `T019` can run in parallel
- Final polish `T022` and `T023` can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch topology and authority tasks together:
Task: "Define boundary groups, canonical subscription components, inner policy components, and dependency-direction rules in /Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-topology-contract.md"
Task: "Define the authoritative-source matrix, five-state subscription model, entitlement mirror rules, and drift handling in /Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-authority-contract.md"
```

## Parallel Example: User Story 2

```bash
# Launch gate-separation and reconciliation tasks together:
Task: "Define entitlement, feature gate, and usage-quota responsibility separation in /Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/entitlement-gate-contract.md"
Task: "Define complete-purchase, restore-purchase, and refresh / notification reconciliation flows in /Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/purchase-reconciliation-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch deferred-scope tasks together:
Task: "Define the deferred ownership matrix, guardrails, and external-boundary split in /Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-deferred-scope-contract.md"
Task: "Update /Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/quickstart.md with the review sequence for topology, authority, entitlement / quota separation, reconciliation, and deferred scope"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that subscription authority, entitlement mirror, and UI responsibility can be reviewed independently
5. Stop and review before adding gate / quota and deferred-scope refinements

### Incremental Delivery

1. Complete Setup + Foundational to fix vocabulary, source-of-truth references, and authority framing
2. Add User Story 1 to define subscription topology and authoritative ownership
3. Add User Story 2 to separate entitlement, quota, and reconciliation flows
4. Add User Story 3 to define deferred ownership and review guidance
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 topology and authority
   - Contributor B: User Story 2 gate / quota / reconciliation separation
   - Contributor C: User Story 3 deferred ownership and review guidance
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep 010 terminology aligned with `Presentation`, `Actor/Auth Boundary`, `Command Intake`, `Query Read`, `Async Subscription Reconciliation`, `External Adapters`, `Entitlement Policy`, `Subscription Feature Gate`, and `Usage Metering / Quota Gate`
- Do not pull pricing / tax / refund policy, vendor SDK detail, auth/session lifecycle, or protected-feature command semantics into this feature
