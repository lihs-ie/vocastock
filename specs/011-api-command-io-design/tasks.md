# Tasks: API / Command I/O 設計

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は request DTO review、response DTO review、error code review、idempotency review、boundary / deferred-scope review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 011 の設計成果物を置く受け皿と active feature 導線を揃える

- [X] T001 Create the feature artifact skeleton in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/research.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/`
- [X] T002 [P] Update `/Users/lihs/workspace/vocastock/.specify/feature.json` to keep `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design` as the active feature directory
- [X] T003 [P] Sync `/Users/lihs/workspace/vocastock/AGENTS.md` with the planning context for API / command I/O design

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する source-of-truth、用語、boundary framing を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Update API / command-I/O source-of-truth references in `/Users/lihs/workspace/vocastock/docs/external/requirements.md` using `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, and `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md` as alignment inputs
- [X] T005 [P] Cross-check command-I/O terminology and identifier wording in `/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learner.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/learning-state.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`, `/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`, and `/Users/lihs/workspace/vocastock/docs/internal/domain/service.md` against `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md` without changing domain semantics
- [X] T006 [P] Normalize clarified actor-handoff shape, actor-scoped idempotency, retry / regenerate mode, and mandatory `message` wording across `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md`, and `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/`
- [X] T007 [P] Capture feature-wide assumptions, external-boundary framing, and deferred-scope notes in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md` and `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/research.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 主要 command の入出力を固定する (Priority: P1) 🎯 MVP

**Goal**: 4 command の canonical request / success response shape を固定し、actor handoff の最小 shape と duplicate reuse の返却方式を独立レビュー可能にする

**Independent Test**: [command-request-envelope-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-request-envelope-contract.md)、[command-response-envelope-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-response-envelope-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md) を読むだけで、第三者が 10 分以内に 4 command の request 必須項目、任意項目、success response shape、duplicate registration の返却内容を説明できること

### Implementation for User Story 1

- [X] T008 [P] [US1] Define the shared request envelope, command-specific body matrix, actor-handoff minimum shape, and retry-mode input rules in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-request-envelope-contract.md`
- [X] T009 [P] [US1] Define the success response envelope, duplicate reuse shape, replay flag, and mandatory user-facing `message` rules in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-response-envelope-contract.md`
- [X] T010 [US1] Map `CommandRequestEnvelope`, `ActorHandoffInput`, `CommandTargetReference`, `CommandResponseEnvelope`, and `DuplicateReuseResult` into `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md`
- [X] T011 [US1] Align User Story 1 wording, acceptance scenarios, FR-001 through FR-004, FR-007, and key entities in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md`
- [X] T012 [US1] Update the API / command-I/O source-of-truth notes in `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` with the finalized request / response and actor-handoff rules

**Checkpoint**: User Story 1 should make canonical request / response DTOs independently reviewable

---

## Phase 4: User Story 2 - error / idempotency / ownership の規則を固定する (Priority: P2)

**Goal**: failure response、actor-scoped idempotency、ownership mismatch、dispatch failure、retry / regenerate distinctionを分離し、実装ごとの差を防ぐ

**Independent Test**: [command-error-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-error-contract.md)、[command-idempotency-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-idempotency-contract.md)、[data-model.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md) を読むだけで、第三者が ownership mismatch、target-not-ready、idempotency conflict、dispatch failure、retry / regenerate mode の違いを一貫して説明できること

### Implementation for User Story 2

- [X] T013 [P] [US2] Define the canonical error code catalog, mandatory error `message`, retryable flag, and client/internal detail split in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-error-contract.md`
- [X] T014 [P] [US2] Define actor-scoped idempotency, same-request replay, duplicate reuse, conflict rejection, and retry / regenerate mode handling in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-idempotency-contract.md`
- [X] T015 [US2] Extend `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md` with `CommandError`, `CommandIdempotencyRule`, `RetryMode`, actor-scoped replay rules, and mandatory message semantics
- [X] T016 [US2] Align User Story 2 wording, edge cases, and FR-005 through FR-011 in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md` with the finalized error / idempotency / ownership rules
- [X] T017 [US2] Capture the rationale for actor-scoped idempotency, mandatory error message, dispatch-failure rejection, and retry / regenerate split in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/research.md`

**Checkpoint**: User Story 2 should make error / replay / ownership rules independently reviewable

---

## Phase 5: User Story 3 - client / auth / workflow との接続境界を固定する (Priority: P3)

**Goal**: actor handoff、deferred scope、source-of-truth dependency、subscription visibility guardrail を整理し、011 が持つべき contract 境界を固定する

**Independent Test**: [actor-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/actor-handoff-contract.md)、[command-io-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-io-boundary-contract.md)、[quickstart.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/quickstart.md) を読むだけで、第三者が actor handoff、deferred scope、`pending-sync` visibility rule、007 / 008 / 009 / 010 との接続点を 5 分以内に割り当てられること

### Implementation for User Story 3

- [X] T018 [P] [US3] Define the completed actor-handoff input contract, required session / auth-account references, and ownership-check boundary in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/actor-handoff-contract.md`
- [X] T019 [P] [US3] Define the prerequisite source-of-truth matrix, deferred-scope ownership, and `pending-sync` visibility guardrails in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-io-boundary-contract.md`
- [X] T020 [P] [US3] Update `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/quickstart.md` with the review sequence for upstream prerequisites, actor handoff, mandatory message rules, retry / regenerate mode, and deferred scope
- [X] T021 [US3] Align User Story 3 wording, FR-012 through FR-015, assumptions, and source-of-truth notes in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md` and `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`

**Checkpoint**: User Story 3 should make boundary ownership and deferred scope independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終レビュー導線を整える

- [X] T022 Reconcile all 011 artifacts across `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/research.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/quickstart.md`, and `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/`
- [X] T023 [P] Cross-check 011 terminology and source-of-truth guidance against `/Users/lihs/workspace/vocastock/docs/external/adr.md`, `/Users/lihs/workspace/vocastock/docs/external/requirements.md`, `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md`, and `/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md`
- [X] T024 Re-run the review flow in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/quickstart.md` and reconcile reviewer guidance with the finalized actor-handoff shape, actor-scoped idempotency, retry / regenerate mode, mandatory message rules, and deferred-scope boundaries

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - uses the same vocabulary and command names, but remains independently reviewable
- **User Story 3 (P3)**: Can start after Foundational - uses the same source-of-truth framing, but remains independently reviewable

### Within Each User Story

- Contract files should be fixed before the corresponding spec and data-model wording is finalized
- Shared-file edits in `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md`, `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, and `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md` should be coordinated even when stories are independently reviewable
- Source-of-truth sync in `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` should happen after the story-specific contracts are stable

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T005`, `T006`, and `T007` can run in parallel after `T004`
- In US1, `T008` and `T009` can run in parallel
- In US2, `T013` and `T014` can run in parallel
- In US3, `T018`, `T019`, and `T020` can run in parallel
- Final polish `T023` can run in parallel with `T022` once story work is complete

---

## Parallel Example: User Story 1

```bash
# Launch request/response contract tasks together:
Task: "Define the shared request envelope, command-specific body matrix, actor-handoff minimum shape, and retry-mode input rules in /Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-request-envelope-contract.md"
Task: "Define the success response envelope, duplicate reuse shape, replay flag, and mandatory user-facing `message` rules in /Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-response-envelope-contract.md"
```

## Parallel Example: User Story 2

```bash
# Launch error and idempotency tasks together:
Task: "Define the canonical error code catalog, mandatory error `message`, retryable flag, and client/internal detail split in /Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-error-contract.md"
Task: "Define actor-scoped idempotency, same-request replay, duplicate reuse, conflict rejection, and retry / regenerate mode handling in /Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-idempotency-contract.md"
```

## Parallel Example: User Story 3

```bash
# Launch boundary and review-flow tasks together:
Task: "Define the completed actor-handoff input contract, required session / auth-account references, and ownership-check boundary in /Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/actor-handoff-contract.md"
Task: "Define the prerequisite source-of-truth matrix, deferred-scope ownership, and `pending-sync` visibility guardrails in /Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-io-boundary-contract.md"
Task: "Update /Users/lihs/workspace/vocastock/specs/011-api-command-io-design/quickstart.md with the review sequence for upstream prerequisites, actor handoff, mandatory message rules, retry / regenerate mode, and deferred scope"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that canonical request / response DTOs, duplicate reuse, and completed actor-handoff shape can be reviewed independently
5. Stop and review before adding error / idempotency refinements

### Incremental Delivery

1. Complete Setup + Foundational to fix vocabulary, source-of-truth references, and boundary framing
2. Add User Story 1 to define canonical request / response DTOs
3. Add User Story 2 to define failure, replay, and ownership rules
4. Add User Story 3 to define source-of-truth boundaries and deferred scope
5. Finish with cross-cutting reconciliation

### Parallel Team Strategy

1. One contributor handles Setup and Foundational alignment
2. After Foundation:
   - Contributor A: User Story 1 request / response contracts
   - Contributor B: User Story 2 error / idempotency rules
   - Contributor C: User Story 3 actor handoff and deferred scope
3. Reconcile all artifacts together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is a design package and independent review is the intended validation mode
- Keep 011 terminology aligned with `CommandRequestEnvelope`, `CommandResponseEnvelope`, `ActorHandoffInput`, `CommandError`, `IdempotencyKey Rule`, `StateSummary`, and `DuplicateReuseResult`
- Do not pull HTTP / GraphQL / RPC binding、workflow payload schema、provider-specific payload、query response schema、persistence schema into this feature
