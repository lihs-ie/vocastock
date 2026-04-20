# Tasks: Command API Implementation

**Input**: Design documents from [/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/)  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/quickstart.md)

**Tests**: `cargo test -p command-api --test unit`、`cargo test -p command-api --test feature`、`cargo llvm-cov -p command-api --tests --summary-only` を前提に、unit と feature の両方を task に含める。feature テストは Rust コードから Docker container と Firebase emulator を使い、unit / feature とも coverage 90% 以上を満たす。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: `command-api` の register command slice に必要な crate baseline、責務別ディレクトリ、test harness を整える

- [X] T001 Update `/Users/lihs/workspace/vocastock/applications/backend/command-api/Cargo.toml` to replace the generic `lib.rs` / `main.rs` layout with a named crate root, explicit test targets, JSON serialization support, and any dependencies required by the register command slice
- [X] T002 [P] Create the crate/module skeleton in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/mod.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/mod.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/http/mod.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/mod.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/server/main.rs`
- [X] T003 [P] Create the Rust test harness skeleton in `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/support/unit.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/support/feature.rs`
- [X] T004 [P] Normalize the implementation and review notes in `/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/quickstart.md` so the internal route, accepted / reused-existing wording, and feature-test requirements match the planned code slice

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が共有する request/response 基盤、runtime shell、stub ports、service constants を先に固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Replace the flat command skeleton with named request/response/service exports in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/mod.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/request.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/response.rs`
- [X] T006 [P] Define stable service constants, internal route names, and visible-guarantee helpers in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/service_contract.rs`
- [X] T007 [P] Define stub runtime ports for authoritative write, idempotency, and dispatch in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/command_store.rs` and `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/dispatch_port.rs`
- [X] T008 [P] Define the HTTP request parsing, JSON response rendering, and failure status helpers in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/http/endpoint.rs`
- [X] T009 Refactor `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/server/main.rs` so `/readyz`, `/dependencies/firebase`, `/`, and `/commands/register-vocabulary-expression` coexist under one route dispatcher

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 登録 command を受理できる (Priority: P1) 🎯 MVP

**Goal**: `registerVocabularyExpression` を accepted / reused-existing で処理し、`statusHandle` と state summary を返せるようにする

**Independent Test**: `cargo test -p command-api --test unit` と `cargo test -p command-api --test feature` の結果を読むだけで、新規受理、duplicate reuse、canonical normalization、`startExplanation = false`、省略時既定値 `true` の扱いを説明できること

### Tests for User Story 1

- [X] T010 [P] [US1] Add unit coverage for canonical text normalization, request parsing, accepted response shaping, duplicate reuse, `startExplanation = false`, and omitted `startExplanation -> true` handling in `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/command/request.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/command/response.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/command/acceptance.rs`
- [X] T011 [P] [US1] Add Rust feature-level contract coverage for accepted, reused-existing, canonical normalization, `startExplanation = false`, and omitted `startExplanation -> true` responses in `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature/register_vocabulary_command.rs`

### Implementation for User Story 1

- [X] T012 [US1] Implement `RegisterVocabularyExpressionRequest` parsing and canonical normalization in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/request.rs`, fixing `trim + lowercase + internal whitespace collapse` and omitted `startExplanation -> true`
- [X] T013 [US1] Implement accepted / reused-existing response entities, `statusHandle`, and duplicate reuse shaping in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/response.rs`
- [X] T014 [US1] Implement register command acceptance, duplicate registration reuse, canonical text comparison, omitted `startExplanation -> true`, and `startExplanation = false` behavior in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/acceptance.rs`
- [X] T015 [US1] Implement the `POST /commands/register-vocabulary-expression` success path and JSON response shape in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/http/endpoint.rs` and `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/server/main.rs`
- [X] T016 [US1] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/acceptance.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/command_store.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature/register_vocabulary_command.rs` so duplicate registration returns `reused-existing` instead of creating a new target

**Checkpoint**: User Story 1 should provide an independently testable command acceptance MVP

---

## Phase 4: User Story 2 - auth/session と idempotency を既存契約どおりに扱える (Priority: P2)

**Goal**: `shared-auth` の token verification / actor handoff 契約と actor-scoped idempotency を再利用し、安全な replay / conflict 処理を実装する

**Independent Test**: `cargo test -p command-api --test unit` と `cargo test -p command-api --test feature` の auth/idempotency ケースを読むだけで、active handoff、missing/invalid token、same-request replay、same-key conflict を説明できること

### Tests for User Story 2

- [X] T017 [P] [US2] Add unit coverage for active, missing-token, invalid-token, reauth-required, same-request replay, and `idempotency-conflict` outcomes in `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/runtime/stub_token_verifier.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/runtime/command_store.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/command/acceptance.rs`
- [X] T018 [P] [US2] Add Rust feature-level coverage for auth failures, same-request replay, and same-key conflict responses in `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature/register_vocabulary_command.rs`

### Implementation for User Story 2

- [X] T019 [US2] Implement the command-side token verifier adapter and `VerifiedActorContext` entrypoint reuse in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/stub_token_verifier.rs`
- [X] T020 [US2] Implement actor-scoped idempotency replay/conflict storage and lookup in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/command_store.rs`
- [X] T021 [US2] Implement bearer token extraction, auth failure mapping, and replay/conflict response routing in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/http/endpoint.rs`
- [X] T022 [US2] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/acceptance.rs` and `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/command_store.rs` so same-request replay does not trigger a new dispatch while same-key conflict returns `idempotency-conflict`

**Checkpoint**: User Story 2 should make auth/session and idempotency reuse independently testable

---

## Phase 5: User Story 3 - dispatch と visible guarantee を守ったまま運用できる (Priority: P3)

**Goal**: `dispatch-failed`、completed payload 非返却、readiness 維持を実装し、015/016 の runtime 契約と visible guarantee を保つ

**Independent Test**: `cargo test -p command-api --test unit` と `cargo test -p command-api --test feature` の dispatch / visibility ケースを読むだけで、accepted 条件、dispatch-failed 条件、rollback、completed payload 非返却、readiness 維持を説明できること

### Tests for User Story 3

- [X] T023 [P] [US3] Add unit coverage for dispatch-required, dispatch-skipped, dispatch-failed, rollback on dispatch failure, and completed-payload filtering in `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/runtime/dispatch_port.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/http/endpoint.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/runtime/service_contract.rs`
- [X] T024 [P] [US3] Add Rust feature-level coverage that `dispatch-failed` never returns accepted, leaves no committed registration write, and that command responses never include completed payloads in `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature/register_vocabulary_command.rs`

### Implementation for User Story 3

- [X] T025 [US3] Implement dispatch success / failure planning and rollback coordination in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/dispatch_port.rs`
- [X] T026 [US3] Implement `dispatch-failed` failure shaping, rollback-aware failure handling, and completed-payload filtering in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/http/endpoint.rs` and `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/command/response.rs`
- [X] T027 [US3] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/server/main.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/runtime/service_contract.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature/register_vocabulary_command.rs` so readiness and `/dependencies/firebase` remain valid after the new command route is added

**Checkpoint**: User Story 3 should make dispatch and visibility guarantees independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: coverage / container runtime / quickstart の最終同期を行う

- [X] T028 [P] Mirror the final source layout into `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/` so every source file under `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/` has a corresponding unit test file
- [X] T029 [P] Update `/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/quickstart.md` and `/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/*.md` if shipped route naming, response wording, or runtime behavior drifted during implementation
- [X] T030 Run `cargo test -p command-api --test unit`, `cargo test -p command-api --test feature`, and `cargo llvm-cov -p command-api --tests --summary-only`, then reconcile shipped behavior in `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/register_command_api/`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/server/main.rs`, `/Users/lihs/workspace/vocastock/applications/backend/command-api/tests/`, and `/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/quickstart.md` while enforcing coverage 90% 以上
- [X] T031 [P] Cross-check `/Users/lihs/workspace/vocastock/docker/applications/command-api/Dockerfile`, `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`, and `/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh` so command-api runtime assumptions still hold after the crate/layout refactor

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - depends on the shared request/response/runtime shell but remains independently testable
- **User Story 3 (P3)**: Can start after Foundational - depends on the same endpoint surface but remains independently testable

### Within Each User Story

- Request / response entities should stabilize before endpoint serialization and feature tests are considered complete
- Auth/session failure mapping should be implemented before replay/conflict feature assertions are finalized
- Dispatch planning and failure mapping should complete before final coverage and container smoke reconciliation

### Parallel Opportunities

- `T002`, `T003`, and `T004` can run in parallel after `T001`
- `T006`, `T007`, and `T008` can run in parallel within Foundational
- `T010` and `T011` can run in parallel within US1
- `T017` and `T018` can run in parallel within US2
- `T023` and `T024` can run in parallel within US3
- `T028`, `T029`, and `T031` can run in parallel in Phase 6

---

## Parallel Example: User Story 1

```bash
# Launch the story-specific test tasks together:
Task: "Add unit coverage for canonical text normalization, accepted response shaping, duplicate reuse, startExplanation = false, and omitted startExplanation -> true handling in /Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/command/"
Task: "Add Rust feature-level contract coverage for accepted, reused-existing, canonical normalization, startExplanation = false, and omitted startExplanation -> true responses in /Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature/register_vocabulary_command.rs"
```

## Parallel Example: User Story 2

```bash
# Launch auth and idempotency verification coverage together:
Task: "Add unit coverage for active, missing-token, invalid-token, reauth-required, same-request replay, and idempotency-conflict outcomes in /Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/runtime/ and /Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/command/acceptance.rs"
Task: "Add Rust feature-level coverage for auth failures, same-request replay, and same-key conflict responses in /Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature/register_vocabulary_command.rs"
```

## Parallel Example: User Story 3

```bash
# Launch dispatch and visibility verification coverage together:
Task: "Add unit coverage for dispatch-required, dispatch-skipped, dispatch-failed, rollback on dispatch failure, and completed-payload filtering in /Users/lihs/workspace/vocastock/applications/backend/command-api/tests/unit/register_command_api/runtime/dispatch_port.rs and sibling endpoint tests"
Task: "Add Rust feature-level coverage that dispatch-failed never returns accepted, leaves no committed registration write, and that command responses never include completed payloads in /Users/lihs/workspace/vocastock/applications/backend/command-api/tests/feature/register_vocabulary_command.rs"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Confirm `registerVocabularyExpression` returns `accepted`, `reused-existing`, canonical normalization, omitted `startExplanation -> true`, and `startExplanation = false` correctly

### Incremental Delivery

1. Complete Setup + Foundational to stabilize the crate baseline, route shell, and stub ports
2. Add User Story 1 and validate the register command MVP
3. Add User Story 2 and validate auth/session reuse plus idempotency replay/conflict
4. Add User Story 3 and validate dispatch-failed, rollback, visible guarantee, and readiness preservation
5. Finish with coverage / quickstart / container-runtime reconciliation

### Parallel Team Strategy

1. One contributor stabilizes Setup + Foundational
2. After Foundation:
   - Contributor A: User Story 1 request/response/acceptance and endpoint success path
   - Contributor B: User Story 2 auth/session reuse and idempotency behavior
   - Contributor C: User Story 3 dispatch / visibility / runtime guarantees
3. Reconcile coverage and runtime in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- Tests are included because 018 explicitly requires unit / feature verification and AGENTS mandates TDD-style test ownership plus 90% coverage
- Keep 018 terminology aligned with `registerVocabularyExpression`, `accepted`, `reused-existing`, `statusHandle`, `dispatch-failed`, `VerifiedActorContext`, and actor-scoped `idempotencyKey`
- Do not expand scope into GraphQL schema-wide changes, worker implementations, `query-api`, or Firestore / Pub/Sub production adapters
