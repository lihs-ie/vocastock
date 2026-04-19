# Tasks: Query Catalog Read

**Input**: Design documents from [/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/)  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/quickstart.md)

**Tests**: `cargo test -p query-api --test unit` と `cargo test -p query-api --test feature` を前提に、unit と feature の両方を task に含める。TDD-first を強制しないが、catalog contract、auth/session failure、visibility / projection lag は独立に検証できるようにする。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: `query-api` の catalog read slice に必要な crate baseline と test entrypoint を整える

- [X] T001 Update `/Users/lihs/workspace/vocastock/applications/backend/query-api/Cargo.toml` with the JSON serialization helper and any test/runtime dependencies needed for the catalog read slice
- [X] T002 [P] Create the endpoint test harness skeleton in `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature.rs`, `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs`, `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/support/feature.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/support/unit.rs`
- [X] T003 [P] Normalize the feature-specific implementation notes in `/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/quickstart.md` so endpoint path, auth reuse, and completed/status-only wording match the planned code slice

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が共有する catalog model、stub source、HTTP route shell、auth reuse points を先に固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Replace the generic projection skeleton with catalog-specific response entities and visibility variants in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/mod.rs` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/model.rs`
- [X] T005 Define the in-memory / stub projection source record, workflow-state normalization, and collection builder in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/source.rs` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs`
- [X] T006 Define the read entrypoint that consumes `shared_auth::VerifiedActorContext` and keeps the service read-only in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs`
- [X] T007 Refactor `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/server/main.rs` so `/readyz`, `/dependencies/firebase`, `/`, and `/vocabulary-catalog` can coexist under one route dispatcher
- [X] T008 Define stable JSON response rendering and auth-failure HTTP status helpers in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/http/endpoint.rs`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 語彙カタログを read できる (Priority: P1) 🎯 MVP

**Goal**: `query-api` から `VocabularyCatalogProjection` の completed summary / status-only を返せるようにする

**Independent Test**: `cargo test -p query-api --test unit` と `cargo test -p query-api --test feature` の確認結果を読むだけで、completed summary を返す条件、status-only に倒す条件、空 collection の扱いを説明できること

### Tests for User Story 1

- [X] T009 [P] [US1] Add unit coverage for empty collection, completed item, and status-only item assembly in `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/unit.rs` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/unit/query_catalog_read/catalog/read.rs`
- [X] T010 [P] [US1] Add feature-level contract coverage for completed / status-only / empty collection responses in `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs`

### Implementation for User Story 1

- [X] T011 [US1] Implement `VocabularyCatalogProjection` assembly, `completed-summary`, and `status-only` item mapping in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/model.rs`
- [X] T012 [US1] Implement the `GET /vocabulary-catalog` success path and JSON response shape in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/server/main.rs` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/http/endpoint.rs`
- [X] T013 [US1] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs`, `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/source.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs` so empty catalog reads return a successful empty collection rather than a failure

**Checkpoint**: User Story 1 should provide an independently testable catalog read MVP

---

## Phase 4: User Story 2 - auth/session 境界を再利用して安全に読む (Priority: P2)

**Goal**: `shared-auth` の token verification / actor handoff 契約を再利用し、auth failure でも raw credential を漏らさずに読む

**Independent Test**: `cargo test -p query-api --test unit` と `cargo test -p query-api --test feature` の auth/session ケースを読むだけで、active session 成功、missing token、invalid token、reauth-required の扱いを説明できること

### Tests for User Story 2

- [X] T014 [P] [US2] Add unit coverage for active, missing-token, invalid-token, and reauth-required verification outcomes in `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/unit.rs` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/unit/query_catalog_read/catalog/read.rs`
- [X] T015 [P] [US2] Add feature-level coverage for auth failure HTTP responses and actor-scoped reads in `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs`

### Implementation for User Story 2

- [X] T016 [US2] Implement bearer token extraction, `shared_auth::TokenVerificationPort` invocation, and `VerifiedActorContext`-scoped read entry in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/http/endpoint.rs`
- [X] T017 [US2] Implement failure mapping in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/http/endpoint.rs` so user-facing auth errors stay stable while internal auth detail remains non-public
- [X] T018 [US2] Update `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs` so non-active sessions are rejected and `query-api` keeps an explicit read-only boundary

**Checkpoint**: User Story 2 should make auth/session reuse independently testable without touching command or worker code

---

## Phase 5: User Story 3 - UI 可視性ルールと projection lag を守る (Priority: P3)

**Goal**: projection lag、workflow failure、detail payload 非露出の visible guarantee を `query-api` 実装に固定する

**Independent Test**: `cargo test -p query-api --test unit` と `cargo test -p query-api --test feature` の visibility ケースを読むだけで、projection lag 中に provisional completed payload を返さないことと、catalog が detail payload を返さないことを説明できること

### Tests for User Story 3

- [X] T019 [P] [US3] Add unit coverage for `queued`, `running`, `retry-scheduled`, `timed-out`, `failed-final`, and `dead-lettered` visibility mapping in `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/unit.rs` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/unit/query_catalog_read/catalog/read.rs`
- [X] T020 [P] [US3] Add feature-level coverage that catalog responses never include detail payloads or provisional completed payloads in `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs`

### Implementation for User Story 3

- [X] T021 [US3] Implement projection lag and failure normalization rules for catalog items in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs`
- [X] T022 [US3] Implement response filtering in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/http/endpoint.rs` so catalog payloads remain summary/status only and never leak detail payloads or pending-sync premium confirmations
- [X] T023 [US3] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs` so stale read and failure cases stay `status-only`

**Checkpoint**: User Story 3 should make visibility guarantees independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: runtime 整合と quickstart / contract の最終同期を行う

- [X] T024 [P] Cross-check `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/server/main.rs`, `/Users/lihs/workspace/vocastock/docker/applications/query-api/Dockerfile`, and `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh` so runtime readiness assumptions still hold after the new route is added
- [X] T025 [P] Update `/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/quickstart.md` and `/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/vocabulary-catalog-read-contract.md` if shipped endpoint naming or response wording drifted during implementation
- [X] T026 Run `cargo test -p query-api --test unit` and `cargo test -p query-api --test feature`, then reconcile shipped behavior in `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/mod.rs`, `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/server/main.rs`, `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/unit/query_catalog_read/catalog/read.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs` with `/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - depends on the shared read-entry and route shell but remains independently testable
- **User Story 3 (P3)**: Can start after Foundational - depends on the same endpoint surface but remains independently testable

### Within Each User Story

- Catalog model / mapper behavior in `src/query_catalog_read/` should stabilize before endpoint serialization in `src/server/main.rs`
- Endpoint contract tests should be finalized after the route path and response shape are wired
- Auth/session failure mapping should be implemented before auth endpoint tests are considered complete
- Visibility / projection lag normalization should complete before final smoke / quickstart reconciliation

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T009` and `T010` can run in parallel within US1
- `T014` and `T015` can run in parallel within US2
- `T019` and `T020` can run in parallel within US3
- `T024` and `T025` can run in parallel in Phase 6

---

## Parallel Example: User Story 1

```bash
# Launch the story-specific test tasks together:
Task: "Add unit coverage for empty collection, completed item, and status-only item assembly in /Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/ and sibling catalog modules"
Task: "Add feature-level contract coverage for completed / status-only / empty collection responses in /Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs"
```

## Parallel Example: User Story 2

```bash
# Launch auth/session verification coverage together:
Task: "Add unit coverage for active, missing-token, invalid-token, and reauth-required verification outcomes in /Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs and /Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/runtime/stub_token_verifier.rs"
Task: "Add feature-level coverage for auth failure HTTP responses and actor-scoped reads in /Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs"
```

## Parallel Example: User Story 3

```bash
# Launch visibility guarantee coverage together:
Task: "Add unit coverage for queued, running, retry-scheduled, timed-out, failed-final, and dead-lettered visibility mapping in /Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/model.rs and /Users/lihs/workspace/vocastock/applications/backend/query-api/src/query_catalog_read/catalog/read.rs"
Task: "Add feature-level coverage that catalog responses never include detail payloads or provisional completed payloads in /Users/lihs/workspace/vocastock/applications/backend/query-api/tests/feature/vocabulary_catalog.rs"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Confirm `/vocabulary-catalog` returns completed summary, status-only, and empty collection correctly

### Incremental Delivery

1. Complete Setup + Foundational to stabilize the crate baseline, route shell, and auth/read entrypoint
2. Add User Story 1 and validate the catalog read MVP
3. Add User Story 2 and validate auth/session reuse without command or worker changes
4. Add User Story 3 and validate projection lag / visibility guarantees
5. Finish with runtime alignment and run `cargo test -p query-api --test unit` plus `cargo test -p query-api --test feature`

### Parallel Team Strategy

1. One contributor stabilizes Setup + Foundational
2. After Foundation:
   - Contributor A: User Story 1 catalog assembly and endpoint success path
   - Contributor B: User Story 2 auth/session reuse and failure handling
   - Contributor C: User Story 3 visibility / projection lag guarantees
3. Reconcile runtime and quickstart in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- Tests are included because the feature completion criteria explicitly require `cargo test` updates
- Keep 017 terminology aligned with `VocabularyCatalogProjection`, `completed-summary`, `status-only`, `projection lag`, `VerifiedActorContext`, and `read-only`
- Do not expand scope into `command-api`, worker runtime behavior, GraphQL schema-wide changes, or Firestore persistence
