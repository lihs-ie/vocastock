# Tasks: GraphQL Gateway Implementation

**Input**: Design documents from [/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/)  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/quickstart.md)

**Tests**: `cargo test -p graphql-gateway --test unit`、`cargo test -p graphql-gateway --test feature -- --nocapture`、`cargo llvm-cov -p graphql-gateway --tests --summary-only --ignore-filename-regex 'applications/backend/command-api|applications/backend/query-api|packages/rust/shared-|applications/backend/graphql-gateway/src/server/main.rs' -- --test-threads=1` を前提に、unit と feature の両方を task に含める。feature テストは Rust コードから Docker container と Firebase emulator を使い、unit / feature とも coverage 90% 以上を満たす。  
**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: `graphql-gateway` の public GraphQL slice に必要な crate baseline、責務別ディレクトリ、test harness を整える

- [X] T001 Update `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/Cargo.toml` to add the HTTP relay, JSON serialization, GraphQL request parsing, and test/runtime dependencies required by the public gateway slice
- [X] T002 [P] Create the module skeleton in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/mod.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/mod.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/mod.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/server/main.rs`
- [X] T003 [P] Create the Rust test harness skeleton in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/support/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/support/feature.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs`
- [X] T004 [P] Normalize the implementation and review notes in `/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/quickstart.md` so `/graphql`, allowlist, failure envelope, auth propagation, and feature-test requirements match the planned code slice

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が共有する public request/response 基盤、relay shell、runtime dispatch、service constants を先に固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Replace the flat gateway skeleton with named exports and stable service constants in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/mod.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/service_contract.rs`
- [X] T006 [P] Define public GraphQL request, success response, and failure envelope entities in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/public_request.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/public_response.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/failure_envelope.rs`
- [X] T007 [P] Define single-operation parsing and 2-operation allowlist validation in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/operation_allowlist.rs`
- [X] T008 [P] Define the downstream relay client shell and command/query adapter contracts in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/relay_client.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/command_relay.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/query_relay.rs`
- [X] T009 [P] Refactor the runtime dispatch shell for `/graphql`, `/readyz`, `/dependencies/firebase`, and `/` in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/http_endpoint.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/server_runtime.rs`
- [X] T010 Refactor `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/server/main.rs` so the named runtime entrypoint owns the public route while preserving existing readiness and Firebase dependency probes

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - unified endpoint から allowlisted mutation/query を呼べる (Priority: P1) 🎯 MVP

**Goal**: `POST /graphql` から `registerVocabularyExpression` mutation と `vocabularyCatalog` query を allowlist 公開し、内部 route を意識せず downstream に relay できるようにする

**Independent Test**: `cargo test -p graphql-gateway --test unit` と `cargo test -p graphql-gateway --test feature -- --nocapture` の結果を読むだけで、2 operation の routing、`unsupported-operation`、`ambiguous-operation`、`accepted` / `reused-existing` / `dispatch-failed` / `idempotency-conflict`、completed-summary / status-only relay を説明できること

### Tests for User Story 1

- [X] T011 [P] [US1] Add unit coverage for single-operation parsing, `operationName` disambiguation, allowlist decisions, unsupported-operation, and ambiguous-operation handling in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/graphql/operation_allowlist.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/graphql/public_request.rs`
- [X] T012 [P] [US1] Add Rust feature-level coverage for `registerVocabularyExpression`, `vocabularyCatalog`, `dispatch-failed`, `idempotency-conflict`, unsupported operation rejection, and ambiguous document rejection in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs`

### Implementation for User Story 1

- [X] T013 [US1] Implement `UnifiedGraphqlRequest` parsing and the 1 request 1 operation rule in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/public_request.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/operation_allowlist.rs`
- [X] T014 [US1] Implement the public mutation/query response family for `accepted` / `reused-existing` / `dispatch-failed` / `idempotency-conflict` and completed-summary / status-only relay in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/public_response.rs`
- [X] T015 [US1] Implement the allowlisted command/query relay adapters that map public operations to `/commands/register-vocabulary-expression` and `/vocabulary-catalog` in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/command_relay.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/query_relay.rs`
- [X] T016 [US1] Implement the `/graphql` success path plus `unsupported-operation` / `ambiguous-operation` rejection in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/http_endpoint.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/server_runtime.rs`
- [X] T017 [US1] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/mod.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/service_contract.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs` so only the 2 allowlisted operations are publicly exposed

**Checkpoint**: User Story 1 should provide an independently testable unified GraphQL MVP

---

## Phase 4: User Story 2 - auth propagation と gateway 非所有責務を守る (Priority: P2)

**Goal**: auth header と request correlation を downstream に伝播しつつ、token verification / idempotency / projection ownership を gateway が持たないことを固定する

**Independent Test**: `cargo test -p graphql-gateway --test unit` と `cargo test -p graphql-gateway --test feature -- --nocapture` の auth/correlation と failure ケースを読むだけで、auth pass-through、client-first correlation、generated fallback、`downstream-unavailable`、`downstream-invalid-response`、failure redaction、gateway 非所有責務を説明できること

### Tests for User Story 2

- [X] T018 [P] [US2] Add unit coverage for auth header pass-through, client-first request correlation, generated fallback correlation, `downstream-unavailable`, `downstream-invalid-response`, and failure redaction in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/downstream/relay_client.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/graphql/failure_envelope.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/runtime/http_endpoint.rs`
- [X] T019 [P] [US2] Add Rust feature-level coverage for downstream auth failure, `downstream-unavailable`, `downstream-invalid-response`, gateway-generated request correlation, and redacted public failures in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs`

### Implementation for User Story 2

- [X] T020 [US2] Implement request correlation extraction/generation helpers and header propagation rules in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/service_contract.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/relay_client.rs`
- [X] T021 [US2] Implement the common public failure envelope and downstream auth/unavailable/invalid-response mapping in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/graphql/failure_envelope.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/http_endpoint.rs`
- [X] T022 [US2] Implement command/query relay response translation for `dispatch-failed` / `idempotency-conflict` and downstream auth/unavailable/invalid-response without re-owning token verification, idempotency, read projection, or workflow dispatch in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/command_relay.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/query_relay.rs`
- [X] T023 [US2] Reconcile `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/downstream/relay_client.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/service_contract.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/support/feature.rs` so auth header pass-through and generated request correlation remain observable in downstream fixtures

**Checkpoint**: User Story 2 should make propagation and non-ownership rules independently testable

---

## Phase 5: User Story 3 - public binding と runtime 契約を継続検証できる (Priority: P3)

**Goal**: readiness を維持しつつ、Docker/Firebase/downstream services を使う public GraphQL end-to-end 検証を local / CI で再現できるようにする

**Independent Test**: `cargo test -p graphql-gateway --test feature -- --nocapture` と `cargo llvm-cov -p graphql-gateway --tests --summary-only --ignore-filename-regex 'applications/backend/command-api|applications/backend/query-api|packages/rust/shared-|applications/backend/graphql-gateway/src/server/main.rs' -- --test-threads=1` の結果を読むだけで、`/graphql` public binding、`/readyz` 維持、Firebase dependency probe、Docker/Firebase feature runtime を説明できること

### Tests for User Story 3

- [X] T024 [P] [US3] Add unit coverage for `/graphql` route coexistence, readiness preservation, root-message stability, and failure envelope serialization in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/runtime/http_endpoint.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/runtime/server_runtime.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/graphql/public_response.rs`
- [X] T025 [P] [US3] Extend the Rust Docker/Firebase feature harness to boot or reuse `graphql-gateway`, `command-api`, and `query-api` together and validate public `/graphql` end-to-end in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/support/feature.rs` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs`

### Implementation for User Story 3

- [X] T026 [US3] Update the Docker-aware feature runtime and downstream service startup assumptions in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/support/feature.rs` and `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml` so public GraphQL tests target gateway plus both downstream services together
- [X] T027 [US3] Preserve `/readyz` and `/dependencies/firebase` alongside the public `/graphql` route in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/http_endpoint.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/runtime/server_runtime.rs`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/server/main.rs`
- [X] T028 [US3] Reconcile `/Users/lihs/workspace/vocastock/docker/applications/graphql-gateway/Dockerfile`, `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`, and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs` so the gateway runtime contract remains CI-callable after the public endpoint is added

**Checkpoint**: User Story 3 should make runtime and public binding verification independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: coverage、mirror layout、quickstart/contracts、runtime/CI integration の最終同期を行う

- [X] T029 [P] Mirror the final source layout into `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/` so every source file under `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/` has a corresponding unit test file
- [X] T030 [P] Update `/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/quickstart.md` and `/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/*.md` if shipped route naming, allowlist wording, failure categories, or propagation rules drift during implementation
- [X] T031 Run `cargo test -p graphql-gateway --test unit`, `cargo test -p graphql-gateway --test feature -- --nocapture`, and `cargo llvm-cov -p graphql-gateway --tests --summary-only --ignore-filename-regex 'applications/backend/command-api|applications/backend/query-api|packages/rust/shared-|applications/backend/graphql-gateway/src/server/main.rs' -- --test-threads=1`, then reconcile shipped behavior in `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/gateway_routing/`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/server/main.rs`, `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/`, and `/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/quickstart.md` while enforcing coverage 90% 以上
- [X] T032 [P] Cross-check `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml` and `/Users/lihs/workspace/vocastock/scripts/ci/run_rust_quality_checks.sh` so the renamed gateway feature harness and Docker/Firebase runtime assumptions remain rust-quality compatible

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - depends on the shared request/relay shell but remains independently testable
- **User Story 3 (P3)**: Can start after Foundational - depends on the public route surface and runtime shell but remains independently testable

### Within Each User Story

- Public request parsing and allowlist validation should stabilize before endpoint serialization is finalized
- Downstream relay adapters should be in place before feature tests are considered complete
- Auth/correlation propagation should be implemented before redacted failure mapping is finalized
- Runtime preservation and Docker/Firebase orchestration should complete before final coverage and CI reconciliation

### Parallel Opportunities

- `T002`, `T003`, and `T004` can run in parallel after `T001`
- `T006`, `T007`, `T008`, and `T009` can run in parallel within Foundational
- `T011` and `T012` can run in parallel within US1
- `T018` and `T019` can run in parallel within US2
- `T024` and `T025` can run in parallel within US3
- `T029`, `T030`, and `T032` can run in parallel in Phase 6

---

## Parallel Example: User Story 1

```bash
# Launch the story-specific test tasks together:
Task: "Add unit coverage for single-operation parsing, operationName disambiguation, allowlist decisions, unsupported-operation, and ambiguous-operation handling in /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/graphql/"
Task: "Add Rust feature-level coverage for registerVocabularyExpression, vocabularyCatalog, dispatch-failed, idempotency-conflict, unsupported operation rejection, and ambiguous document rejection in /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs"
```

## Parallel Example: User Story 2

```bash
# Launch propagation and failure verification together:
Task: "Add unit coverage for auth header pass-through, client-first request correlation, generated fallback correlation, downstream-unavailable, downstream-invalid-response, and failure redaction in /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/downstream/relay_client.rs and sibling runtime tests"
Task: "Add Rust feature-level coverage for downstream auth failure, downstream-unavailable, downstream-invalid-response, gateway-generated request correlation, and redacted public failures in /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs"
```

## Parallel Example: User Story 3

```bash
# Launch runtime and end-to-end verification together:
Task: "Add unit coverage for /graphql route coexistence, readiness preservation, root-message stability, and failure envelope serialization in /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/runtime/ and /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/unit/gateway_routing/graphql/public_response.rs"
Task: "Extend the Rust Docker/Firebase feature harness to boot or reuse graphql-gateway, command-api, and query-api together and validate public /graphql end-to-end in /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/support/feature.rs and /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/tests/feature/public_graphql_gateway.rs"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Confirm `/graphql` routes the 2 allowlisted operations and rejects unsupported / ambiguous documents correctly

### Incremental Delivery

1. Complete Setup + Foundational to stabilize the crate baseline, public request shell, relay adapters, runtime dispatch, and runtime/CI touchpoints
2. Add User Story 1 and validate the unified GraphQL MVP plus command mutation failure family relay
3. Add User Story 2 and validate auth/correlation propagation plus downstream failure shaping and gateway non-ownership
4. Add User Story 3 and validate Docker/Firebase end-to-end runtime behavior
5. Finish with coverage / contract / rust-quality reconciliation

### Parallel Team Strategy

1. One contributor stabilizes Setup + Foundational
2. After Foundation:
   - Contributor A: User Story 1 public request parsing, allowlist, and success relay
   - Contributor B: User Story 2 auth/correlation propagation and failure shaping
   - Contributor C: User Story 3 feature runtime and Docker/Firebase validation
3. Reconcile coverage and CI integration in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- Tests are included because 020 explicitly requires unit / feature verification and AGENTS mandates Rust-based Docker/Firebase feature tests plus 90% coverage
- Keep 020 terminology aligned with `UnifiedGraphqlRequest`, `GatewayRoutingDecision`, `PublicMutationResult`, `PublicCatalogResult`, `GatewayFailureEnvelope`, `unsupported-operation`, and `ambiguous-operation`
- Do not expand scope into GraphQL schema-wide changes, worker operations, downstream token verification ownership, cache / rate limit policy, or command/query business-rule rewrites
