# Tasks: Application Container Environments

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts), [quickstart.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/quickstart.md)

**Tests**: 専用の test-first task は追加しない。検証は `cargo test`、`docker compose -f docker/applications/compose.yaml config`、API readiness smoke、worker stable-run review、local/CI contract review、cross-document review を independent test として扱う。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: application container 実装の置き場と repository-level 導線を整える

- [X] T001 Create the application container directory skeleton in `/Users/lihs/workspace/vocastock/docker/applications/graphql-gateway/`, `/Users/lihs/workspace/vocastock/docker/applications/command-api/`, `/Users/lihs/workspace/vocastock/docker/applications/query-api/`, `/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/`, `/Users/lihs/workspace/vocastock/docker/applications/image-worker/`, `/Users/lihs/workspace/vocastock/docker/applications/billing-worker/`, and `/Users/lihs/workspace/vocastock/docker/applications/env/`
- [X] T002 [P] Update `/Users/lihs/workspace/vocastock/.gitignore` and `/Users/lihs/workspace/vocastock/.dockerignore` for application container env overrides, compose-local artifacts, and per-application build outputs
- [X] T003 [P] Update `/Users/lihs/workspace/vocastock/README.md` and `/Users/lihs/workspace/vocastock/applications/backend/README.md` with the application container feature entrypoints, ownership rule, and worker directory catalog

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての application profile が依存する shared compose / env / helper contract を先に固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Create the shared local orchestration baseline in `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`
- [X] T005 [P] Create the committed shared env template in `/Users/lihs/workspace/vocastock/docker/applications/env/.env.example`
- [X] T006 [P] Extend `/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh` with application-container compose paths, env-template discovery, and shared-dependency-stack boundary helpers
- [X] T007 Create `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh` with shared Dockerfile/target/entry-contract validation plus API HTTP readiness and worker stable-run smoke hooks
- [X] T008 Create `/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_application_containers.sh` to validate local Docker prerequisites, env-template usage, and compose-contract availability

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 各アプリの実行環境を独立して再現する (Priority: P1) 🎯 MVP

**Goal**: 各 deployable application が独立した Docker assets と runtime success contract を持つ状態を作る

**Independent Test**: 任意の 1 API application と 1 worker application について、Dockerfile、API readiness endpoint 実装、worker entrypoint、backend container catalog だけを見て起動単位、entry contract、API readiness と worker stable-run の違いを説明できること

### Implementation for User Story 1

- [X] T009 [P] [US1] Create `/Users/lihs/workspace/vocastock/docker/applications/graphql-gateway/Dockerfile` with the canonical build target and API readiness-oriented entry contract
- [X] T010 [P] [US1] Create `/Users/lihs/workspace/vocastock/docker/applications/command-api/Dockerfile` with the canonical build target and API readiness-oriented entry contract
- [X] T011 [P] [US1] Create `/Users/lihs/workspace/vocastock/docker/applications/query-api/Dockerfile` with the canonical build target and API readiness-oriented entry contract
- [X] T012 [P] [US1] Update `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/Cargo.toml` and `/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/main.rs` with a long-running HTTP listener and readiness endpoint for the canonical API success contract
- [X] T013 [P] [US1] Update `/Users/lihs/workspace/vocastock/applications/backend/command-api/Cargo.toml` and `/Users/lihs/workspace/vocastock/applications/backend/command-api/src/main.rs` with a long-running HTTP listener and readiness endpoint for the canonical API success contract
- [X] T014 [P] [US1] Update `/Users/lihs/workspace/vocastock/applications/backend/query-api/Cargo.toml` and `/Users/lihs/workspace/vocastock/applications/backend/query-api/src/main.rs` with a long-running HTTP listener and readiness endpoint for the canonical API success contract
- [X] T015 [P] [US1] Create `/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/Dockerfile` and `/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/entrypoint.sh` for the long-running consumer contract
- [X] T016 [P] [US1] Create `/Users/lihs/workspace/vocastock/docker/applications/image-worker/Dockerfile` and `/Users/lihs/workspace/vocastock/docker/applications/image-worker/entrypoint.sh` for the long-running consumer contract
- [X] T017 [P] [US1] Create `/Users/lihs/workspace/vocastock/docker/applications/billing-worker/Dockerfile` and `/Users/lihs/workspace/vocastock/docker/applications/billing-worker/entrypoint.sh` for the long-running consumer contract
- [X] T018 [US1] Update `/Users/lihs/workspace/vocastock/applications/backend/README.md` with the finalized runtime-profile catalog, per-application Docker asset ownership, and API-versus-worker success-signal mapping

**Checkpoint**: User Story 1 should make each application runtime independently reviewable

---

## Phase 4: User Story 2 - 共通要件とアプリ固有要件を分離する (Priority: P2)

**Goal**: shared runtime baseline と app-specific requirement、secret/local boundary を独立レビュー可能にする

**Independent Test**: `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`、`/Users/lihs/workspace/vocastock/docker/applications/env/.env.example`、`/Users/lihs/workspace/vocastock/docs/development/backend-container-environment.md` を読むだけで、shared requirement と app-specific requirement、required/optional input、repository-wide shared dependency stack の境界を説明できること

### Implementation for User Story 2

- [X] T019 [P] [US2] Extend `/Users/lihs/workspace/vocastock/docker/applications/compose.yaml` with per-application services, build targets, shared-network rules, and explicit separation from `/Users/lihs/workspace/vocastock/docker/firebase/compose.yaml`
- [X] T020 [P] [US2] Populate `/Users/lihs/workspace/vocastock/docker/applications/env/.env.example` with required/optional runtime inputs, secret boundaries, and local-default notes for all in-scope applications
- [X] T021 [US2] Update `/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh` and `/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_application_containers.sh` with application-specific input validation and shared-versus-application boundary checks
- [X] T022 [US2] Create `/Users/lihs/workspace/vocastock/docs/development/backend-container-environment.md` with the shared runtime baseline, app-specific requirements, and secret/local env split

**Checkpoint**: User Story 2 should make shared versus app-specific runtime requirements independently reviewable

---

## Phase 5: User Story 3 - ローカルと CI の検証契約を揃える (Priority: P3)

**Goal**: local / CI が同じ Dockerfile / target / entry contract を使うことと、failure troubleshooting 導線を独立レビュー可能にする

**Independent Test**: `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh` の契約、`/Users/lihs/workspace/vocastock/.github/workflows/ci.yml` の job、`/Users/lihs/workspace/vocastock/docs/development/backend-container-environment.md` の手順を読むだけで、local / CI が同じ build/run contract を共有し、API readiness と worker stable-run を別々に判定することを説明できること

### Implementation for User Story 3

- [X] T023 [P] [US3] Update `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml` to add an application-container smoke job that uses `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`
- [X] T024 [P] [US3] Update `/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh` and `/Users/lihs/workspace/vocastock/scripts/ci/check_ci_runtime_budget.sh` with readiness/stable-run metrics, artifact output, and failure-stage reporting
- [X] T025 [US3] Update `/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh` and `/Users/lihs/workspace/vocastock/scripts/ci/run_local_stack_smoke.sh` to reuse the application-container contract without folding `/Users/lihs/workspace/vocastock/docker/firebase/` into application ownership
- [X] T026 [US3] Update `/Users/lihs/workspace/vocastock/docs/development/backend-container-environment.md` and `/Users/lihs/workspace/vocastock/README.md` with the local/CI shared contract, troubleshooting flow, and same-Dockerfile/non-shared-image rule

**Checkpoint**: User Story 3 should make local/CI contract reuse and troubleshooting independently reviewable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: external source-of-truth と quickstart 導線を最終同期する

- [X] T027 Update `/Users/lihs/workspace/vocastock/docs/external/adr.md` and `/Users/lihs/workspace/vocastock/docs/external/requirements.md` with the finalized application-container policy, Docker asset ownership rule, API readiness rule, and worker stable-run rule
- [X] T028 [P] Cross-check 016 terminology and shared-dependency boundaries against `/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/plan.md`, `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/plan.md`, `/Users/lihs/workspace/vocastock/docker/firebase/compose.yaml`, and `/Users/lihs/workspace/vocastock/docs/development/flutter-environment.md` without redefining their semantics
- [X] T029 Run `cargo test`, validate `docker compose -f /Users/lihs/workspace/vocastock/docker/applications/compose.yaml config`, run `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_application_containers.sh`, and reconcile shipped behavior with `/Users/lihs/workspace/vocastock/specs/016-application-docker-env/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - depends on the shared compose/env/helper baseline but remains independently testable
- **User Story 3 (P3)**: Can start after Foundational - depends on the shared smoke/validation baseline but remains independently testable

### Within Each User Story

- Application-scoped Dockerfiles should be created before compose and CI wiring depends on them
- API readiness endpoint implementation should complete before smoke and CI tasks depend on HTTP readiness checks
- Shared env defaults should be stabilized before local/CI scripts enforce required inputs
- CI workflow integration should happen after the smoke script contract is stable
- External source-of-truth sync should happen after local implementation files and development docs are finalized

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T005` and `T006` can run in parallel after `T004`
- In US1, `T009` through `T017` can run in parallel
- In US2, `T019` and `T020` can run in parallel
- In US3, `T023` and `T024` can run in parallel after `T007`
- In Polish, `T028` can run in parallel with `T027` after story work is complete

---

## Parallel Example: User Story 1

```bash
# Launch independent application runtime tasks together:
Task: "Create /Users/lihs/workspace/vocastock/docker/applications/graphql-gateway/Dockerfile with the canonical build target and API readiness-oriented entry contract"
Task: "Create /Users/lihs/workspace/vocastock/docker/applications/command-api/Dockerfile with the canonical build target and API readiness-oriented entry contract"
Task: "Create /Users/lihs/workspace/vocastock/docker/applications/query-api/Dockerfile with the canonical build target and API readiness-oriented entry contract"
Task: "Update /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/Cargo.toml and /Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/src/main.rs with a long-running HTTP listener and readiness endpoint for the canonical API success contract"
Task: "Update /Users/lihs/workspace/vocastock/applications/backend/command-api/Cargo.toml and /Users/lihs/workspace/vocastock/applications/backend/command-api/src/main.rs with a long-running HTTP listener and readiness endpoint for the canonical API success contract"
Task: "Update /Users/lihs/workspace/vocastock/applications/backend/query-api/Cargo.toml and /Users/lihs/workspace/vocastock/applications/backend/query-api/src/main.rs with a long-running HTTP listener and readiness endpoint for the canonical API success contract"
Task: "Create /Users/lihs/workspace/vocastock/docker/applications/explanation-worker/Dockerfile and /Users/lihs/workspace/vocastock/docker/applications/explanation-worker/entrypoint.sh for the long-running consumer contract"
Task: "Create /Users/lihs/workspace/vocastock/docker/applications/image-worker/Dockerfile and /Users/lihs/workspace/vocastock/docker/applications/image-worker/entrypoint.sh for the long-running consumer contract"
Task: "Create /Users/lihs/workspace/vocastock/docker/applications/billing-worker/Dockerfile and /Users/lihs/workspace/vocastock/docker/applications/billing-worker/entrypoint.sh for the long-running consumer contract"
```

## Parallel Example: User Story 2

```bash
# Launch shared baseline tasks together:
Task: "Extend /Users/lihs/workspace/vocastock/docker/applications/compose.yaml with per-application services, build targets, shared-network rules, and explicit separation from /Users/lihs/workspace/vocastock/docker/firebase/compose.yaml"
Task: "Populate /Users/lihs/workspace/vocastock/docker/applications/env/.env.example with required/optional runtime inputs, secret boundaries, and local-default notes for all in-scope applications"
```

## Parallel Example: User Story 3

```bash
# Launch CI integration tasks together:
Task: "Update /Users/lihs/workspace/vocastock/.github/workflows/ci.yml to add an application-container smoke job that uses /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh"
Task: "Update /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh and /Users/lihs/workspace/vocastock/scripts/ci/check_ci_runtime_budget.sh with readiness/stable-run metrics, artifact output, and failure-stage reporting"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate that every application has an independent Docker asset set, API readiness endpoint, and correct API/worker success contract
5. Stop and review before wiring compose/env/CI

### Incremental Delivery

1. Complete Setup + Foundational to fix directory ownership, compose/env baseline, and smoke helpers
2. Add User Story 1 to define per-application container profiles and minimal API readiness listeners
3. Add User Story 2 to separate shared baseline from app-specific requirements
4. Add User Story 3 to unify local/CI contract and troubleshooting
5. Finish with external source-of-truth sync and quickstart validation

### Parallel Team Strategy

1. One contributor prepares Setup and Foundational compose/env/helper baseline
2. After Foundation:
   - Contributor A: API Dockerfiles and readiness endpoints
   - Contributor B: Worker Dockerfiles and entrypoints
   - Contributor C: Shared compose/env and CI contract
3. Reconcile docs and external source-of-truth together in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after dependencies
- No standalone test-file tasks were generated because this feature is validated by container contract review and smoke commands rather than TDD-first domain tests
- Keep 016 terminology aligned with `application-scoped Docker assets`, `shared dependency stack`, `HTTP readiness endpoint`, `long-running consumer`, `stable-run`, `required input`, `optional input`, and `shared Dockerfile / target / entry contract`
- Do not fold Flutter client, `docker/firebase/`, or deployment pipeline publication detail into the application-specific container profile implementation
