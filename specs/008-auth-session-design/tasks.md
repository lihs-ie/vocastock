# Tasks: 会員登録・ログイン・ログアウト設計

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は auth flow review、Firebase ID token handoff review、boundary review、session handoff review、provider policy review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 008 の設計成果物を置く受け皿と参照導線を揃える

- [ ] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/research.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/`
- [ ] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/008-auth-session-design` as the active feature directory
- [ ] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for Flutter / Firebase / backend auth design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する認証境界の前提文書と用語を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Reconcile auth-boundary references across `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/specs/003-architecture-design/contracts/boundary-responsibility-contract.md`, and `/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/spec.md`
- [ ] T005 [P] Reconcile auth-outside-domain and Firebase-subject terminology across `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md` and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md`
- [ ] T006 [P] Normalize Flutter Auth UI, Firebase Authentication, verified Firebase identity, session, actor reference, and provider-tier terminology across `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/`
- [ ] T007 [P] Capture feature-wide assumptions, Firebase handoff review method, and provider baseline / exclusion notes in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md` and `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/research.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 主要な会員導線を定義する (Priority: P1) 🎯 MVP

**Goal**: `Basic` と `Google` の会員登録、ログイン、ログアウト導線を、Flutter auth UI、Firebase Authentication、backend handoff を含む形で一貫した設計成果物として定義する

**Independent Test**: [auth-flow-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/auth-flow-contract.md) と [data-model.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md) を読むだけで、`Basic` / `Google` の会員登録、ログイン、ログアウトの流れと user-visible な完了条件を第三者が説明できること

### Implementation for User Story 1

- [ ] T008 [P] [US1] Define `Basic` and `Google` registration, login, and logout acceptance / completion rules, including Flutter Firebase sign-in and backend token verification, in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/auth-flow-contract.md`
- [ ] T009 [P] [US1] Update baseline membership-flow review order and completion checkpoints, including Flutter-to-backend handoff, in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/quickstart.md`
- [ ] T010 [US1] Map `AuthAccount`, `VerifiedFirebaseIdentity`, `SessionState`, `RegisterFlowResult`, `LoginFlowResult`, and `LogoutFlowResult` semantics into `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md`
- [ ] T011 [US1] Align User Story 1 wording, acceptance scenarios, duplicate edge cases, and logout completion wording in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/spec.md` with the finalized baseline flows

**Checkpoint**: User Story 1 should define the baseline membership flows independently

---

## Phase 4: User Story 2 - 認証をアプリのコアドメイン外として切り分ける (Priority: P2)

**Goal**: Flutter Auth UI、Firebase Authentication、backend token verification、session 管理、actor / learner resolution、アプリ本体への handoff を分離し、認証詳細をコアドメインへ持ち込まない設計を固定する

**Independent Test**: [auth-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/auth-boundary-contract.md)、[session-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/session-handoff-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md) を読むだけで、Flutter / Firebase / backend の責務分離と actor handoff 条件を第三者が説明できること

### Implementation for User Story 2

- [ ] T012 [P] [US2] Define Flutter Auth UI, Firebase Auth Client Adapter, Backend Token Verifier, Session Manager, Actor Resolver, and App Core Entry responsibilities in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/auth-boundary-contract.md`
- [ ] T013 [P] [US2] Define Firebase ID token handoff checkpoints, visibility rules, backend actor resolution conditions, and reauthentication expectations in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/session-handoff-contract.md`
- [ ] T014 [US2] Extend `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md` with `VerifiedFirebaseIdentity`, `ResolvedActorReference` constraints, and session-to-app handoff validation rules
- [ ] T015 [US2] Align `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/spec.md` Domain & Async Impact, FR-004, FR-005, FR-008, FR-009, and FR-010 wording with the finalized Flutter / Firebase / backend split
- [ ] T016 [US2] Capture the rationale for auth-outside-domain, Firebase token verification, credential hiding, and actor-only handoff in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/research.md`

**Checkpoint**: User Story 2 should make auth-boundary separation and actor handoff independently reviewable

---

## Phase 5: User Story 3 - 条件付き provider 採用方針を定義する (Priority: P3)

**Goal**: `Basic` / `Google` の初期対象と、`Apple ID` / `LINE` の条件付き採用ルール、Firebase 経由の有効化条件、fallback guidance、対象外範囲を運用可能な形で整理する

**Independent Test**: [provider-availability-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/provider-availability-contract.md)、[research.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/research.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/quickstart.md) を読むだけで、provider ごとの初期対象 / 条件付き対象 / fallback を第三者が説明できること

### Implementation for User Story 3

- [ ] T017 [P] [US3] Define baseline, conditional, disable, Firebase-based enablement, and fallback rules for each provider in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/provider-availability-contract.md`
- [ ] T018 [P] [US3] Extend `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md` with `ProviderAvailabilityPolicy` tier, Firebase-based condition, and fallback guidance details
- [ ] T019 [US3] Align provider availability, out-of-scope, and cost-trigger edge cases in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/spec.md` with the finalized provider adoption policy
- [ ] T020 [US3] Update `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/research.md` and `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/quickstart.md` with provider evaluation order, Firebase dependency notes, deferred-provider guidance, and fallback review steps

**Checkpoint**: User Story 3 should make provider adoption policy independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終導線を整える

- [ ] T021 [P] Reconcile all 008 artifacts across `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/research.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/`
- [ ] T022 [P] Cross-check 008 auth terminology against `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/specs/003-architecture-design/`, and `/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/`
- [ ] T023 Re-run the review flow in `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/quickstart.md` and reconcile reviewer guidance with the finalized auth design
- [ ] T024 Update `/Users/lihs/workspace/vocastock/AGENTS.md` and final repository guidance if Flutter / Firebase / backend auth terminology introduces new canonical wording worth surfacing

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - uses shared Flutter / Firebase / actor vocabulary fixed in Phase 2, so no dependency on US1 remains
- **User Story 3 (P3)**: Can start after Foundational - uses the same provider vocabulary and Firebase baseline, but remains independently reviewable

### Within Each User Story

- Flow, boundary, handoff, and provider contracts should be fixed before final spec wording adjustments
- Data-model alignment should follow the corresponding contract decisions
- Quickstart and reviewer guidance should be finalized after the relevant contracts and policy wording are stable

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T005`, `T006`, and `T007` can run in parallel after `T004`
- In US1, `T008` and `T009` can run in parallel
- In US2, `T012` and `T013` can run in parallel
- In US3, `T017` and `T018` can run in parallel
- Final polish `T021` and `T022` can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch baseline flow-definition tasks together:
Task: "Define Basic and Google registration, login, and logout rules including Flutter sign-in and backend token verification in /Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/auth-flow-contract.md"
Task: "Update baseline membership-flow review order including Flutter-to-backend handoff in /Users/lihs/workspace/vocastock/specs/008-auth-session-design/quickstart.md"
```

## Parallel Example: User Story 2

```bash
# Launch boundary-separation tasks together:
Task: "Define Flutter Auth UI, Firebase Auth Client Adapter, Backend Token Verifier, Session Manager, Actor Resolver, and App Core Entry responsibilities in /Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/auth-boundary-contract.md"
Task: "Define Firebase ID token handoff checkpoints in /Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/session-handoff-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch provider-policy tasks together:
Task: "Define provider availability and Firebase-based enablement rules in /Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/provider-availability-contract.md"
Task: "Extend ProviderAvailabilityPolicy details in /Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that `Basic` / `Google` membership flows can be reviewed independently
5. Stop and review before adding boundary-separation and provider-policy refinements

### Incremental Delivery

1. Complete Setup + Foundational to fix source-of-truth references and shared terminology
2. Add User Story 1 to define the baseline membership flows
3. Add User Story 2 to fix Flutter / Firebase / backend boundary separation and actor handoff rules
4. Add User Story 3 to define provider adoption policy and conditional enablement guidance
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 baseline flows
   - Contributor B: User Story 2 boundary separation and handoff
   - Contributor C: User Story 3 provider policy and deferred-provider guidance
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep auth terminology aligned across `Flutter Auth UI`, `Firebase Authentication`, `verified Firebase identity`, `session`, `actor reference`, and provider-tier vocabulary
- Do not pull password reset, profile management, billing integration, or advanced identity merge into this feature
