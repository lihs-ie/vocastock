# Tasks: Rust Quality CI

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/`  
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/plan.md) (required), [spec.md](/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/spec.md) (required), [research.md](/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/contracts)

**Tests**: この feature は required check と Rust test 実行そのものを対象にするため、workflow / script / Rust feature harness の検証タスクを含める。  
**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Rust quality CI feature の共通土台を用意する

- [X] T001 Create rust-quality script placeholders in `scripts/ci/detect_rust_changes.sh` and `scripts/ci/run_rust_quality_checks.sh`
- [X] T002 [P] Add rust-quality artifact and duration helper stubs in `scripts/lib/vocastock_env.sh`
- [X] T003 [P] Reserve a `rust-quality` job section and artifact upload placeholder in `.github/workflows/ci.yml`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story を支える path gating と artifact contract を固定する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Implement the Rust-related path catalog and `execution_mode=full|noop` output contract in `scripts/ci/detect_rust_changes.sh`
- [X] T005 Implement shared rust-quality summary, stage, and duration writers in `scripts/ci/run_rust_quality_checks.sh`
- [X] T006 Wire `.github/workflows/ci.yml` to execute `scripts/ci/detect_rust_changes.sh`, keep the `rust-quality` check name stable, and always upload `.artifacts/ci`
- [X] T007 [P] Document local reproduction and artifact locations for rust-quality in `docs/development/backend-container-environment.md`
- [X] T008 [P] Extend `scripts/lib/vocastock_env.sh` and `.github/workflows/ci.yml` with rust-quality runtime-budget and artifact naming conventions

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Rust の静的品質ゲートを CI に追加する (Priority: P1) 🎯 MVP

**Goal**: Rust path 変更時だけ formatting / clippy を required gate として実行し、非該当時は no-op success を返す

**Independent Test**: `scripts/ci/detect_rust_changes.sh` で Rust path 非該当の `noop` と該当時の `full` を切り分け、`scripts/ci/run_rust_quality_checks.sh --mode full` で formatting または clippy failure が segment 単位で判別できれば成立する

### Implementation for User Story 1

- [X] T009 [US1] Implement the no-op success branch and matched-path summary handling in `scripts/ci/run_rust_quality_checks.sh`
- [X] T010 [US1] Implement the `cargo fmt --all -- --check` segment with dedicated log output in `scripts/ci/run_rust_quality_checks.sh`
- [X] T011 [US1] Implement the `cargo clippy --workspace --all-targets -- -D warnings` segment with dedicated log output in `scripts/ci/run_rust_quality_checks.sh`
- [X] T012 [US1] Update `.github/workflows/ci.yml` so `rust-quality` runs static gate only when `execution_mode=full` and returns no-op success otherwise
- [X] T013 [US1] Sync static-gate reproduction and no-op behavior in `specs/019-rust-quality-ci/quickstart.md` and `specs/019-rust-quality-ci/contracts/rust-quality-job-contract.md`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - command/query の unit test を required check にする (Priority: P2)

**Goal**: `query-api` と `command-api` の unit test を rust-quality full mode に組み込み、failure stage を明示できるようにする

**Independent Test**: `scripts/ci/run_rust_quality_checks.sh --mode full` で `query-api` と `command-api` の unit segment が両方実行され、どちらかの失敗時に stage / log から停止点を説明できれば成立する

### Implementation for User Story 2

- [X] T014 [US2] Implement `cargo test -p query-api --test unit` and `cargo test -p command-api --test unit` segments in `scripts/ci/run_rust_quality_checks.sh`
- [X] T015 [US2] Update `.github/workflows/ci.yml` to surface unit-test segment results and keep artifact upload on unit failure
- [X] T016 [P] [US2] Ensure the `query-api` unit target remains CI-callable in `applications/backend/query-api/Cargo.toml` and `applications/backend/query-api/tests/unit.rs`
- [X] T017 [P] [US2] Ensure the `command-api` unit target remains CI-callable in `applications/backend/command-api/Cargo.toml` and `applications/backend/command-api/tests/unit.rs`
- [X] T018 [US2] Sync the unit-test catalog and local reproduction steps in `specs/019-rust-quality-ci/quickstart.md` and `specs/019-rust-quality-ci/contracts/rust-test-catalog-contract.md`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Docker/Firebase を使う Rust feature test を CI で再現する (Priority: P3)

**Goal**: 全 Rust アプリケーションの Docker/Firebase feature test を shared emulator session 上で required gate として実行する

**Independent Test**: `scripts/ci/run_rust_quality_checks.sh --mode full` が `graphql-gateway`、`query-api`、`command-api` の feature test を shared emulator session 付きで順に実行し、失敗時にどのアプリで止まったかを artifact から説明できれば成立する

### Implementation for User Story 3

- [X] T019 [US3] Refactor `graphql-gateway` source layout to `applications/backend/graphql-gateway/src/gateway_routing/mod.rs` and `applications/backend/graphql-gateway/src/server/main.rs`, updating `applications/backend/graphql-gateway/Cargo.toml`
- [X] T020 [P] [US3] Move `graphql-gateway` route tests into AGENTS-compliant unit layout in `applications/backend/graphql-gateway/tests/unit.rs` and `applications/backend/graphql-gateway/tests/unit/gateway_routing/mod.rs`
- [X] T021 [P] [US3] Add a Docker/Firebase feature harness for `graphql-gateway` in `applications/backend/graphql-gateway/tests/feature.rs` and `applications/backend/graphql-gateway/tests/support/feature.rs`
- [X] T022 [US3] Add the `graphql-gateway` feature scenario in `applications/backend/graphql-gateway/tests/feature/gateway_routing.rs`
- [X] T023 [P] [US3] Update `applications/backend/query-api/tests/support/feature.rs` and `applications/backend/command-api/tests/support/feature.rs` to reuse a shared emulator session consistently in CI
- [X] T024 [US3] Implement emulator lifecycle management and `feature-all` sequencing in `scripts/ci/run_rust_quality_checks.sh`
- [X] T025 [US3] Update `.github/workflows/ci.yml` to run all Rust application feature tests and capture per-application feature logs
- [X] T026 [US3] Sync feature runtime and artifact reporting details in `specs/019-rust-quality-ci/quickstart.md`, `specs/019-rust-quality-ci/contracts/rust-feature-runtime-contract.md`, and `specs/019-rust-quality-ci/contracts/rust-artifact-reporting-contract.md`

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: source-of-truth 同期、最終検証、横断的な調整

- [X] T027 [P] Sync Rust quality CI decisions into `docs/external/adr.md` and `docs/external/requirements.md`
- [X] T028 [P] Update `README.md` and `docs/development/backend-container-environment.md` with rust-quality local/CI usage guidance
- [X] T029 Validate no-op/full path gating, static gate, unit gate, and feature gate using `scripts/ci/detect_rust_changes.sh`, `scripts/ci/run_rust_quality_checks.sh`, and `.github/workflows/ci.yml`
- [X] T030 Reconcile shipped behavior with `specs/019-rust-quality-ci/quickstart.md` and all files in `specs/019-rust-quality-ci/contracts/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Depends on shared runner / artifact contract from US1 but remains independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Depends on shared runner / path gating contract and extends it with feature-all behavior

### Within Each User Story

- Shared scripts before workflow wiring that consumes them
- `graphql-gateway` source refactor before gateway feature harness
- Shared emulator lifecycle before per-application feature execution in CI
- Story complete before moving to next priority

### Parallel Opportunities

- `T002`, `T003` can run in parallel
- `T007`, `T008` can run in parallel after foundational wiring starts
- `T016`, `T017` can run in parallel
- `T020`, `T021`, `T023` can run in parallel once `T019` is complete
- `T027`, `T028` can run in parallel during polish

---

## Parallel Example: User Story 3

```bash
# After graphql-gateway source refactor is complete:
Task: "Move graphql-gateway route tests into AGENTS-compliant unit layout in applications/backend/graphql-gateway/tests/unit.rs and applications/backend/graphql-gateway/tests/unit/gateway_routing/mod.rs"
Task: "Add a Docker/Firebase feature harness for graphql-gateway in applications/backend/graphql-gateway/tests/feature.rs and applications/backend/graphql-gateway/tests/support/feature.rs"
Task: "Update applications/backend/query-api/tests/support/feature.rs and applications/backend/command-api/tests/support/feature.rs to reuse a shared emulator session consistently in CI"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: confirm no-op/full path gating and static gate behavior
5. Merge if only static Rust quality gate is needed first

### Incremental Delivery

1. Complete Setup + Foundational
2. Add User Story 1 → validate static gate
3. Add User Story 2 → validate unit gate
4. Add User Story 3 → validate full Docker/Firebase feature gate across all Rust apps
5. Finish Polish → sync docs and final verification

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3 gateway/test harness work
3. Integrate on the shared `scripts/ci/run_rust_quality_checks.sh` boundary in sequence

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- User Story 1 is the recommended MVP scope
- `graphql-gateway` is part of feature test scope and cannot be left out
- Rust path 非該当時も required check 名は維持し、no-op success を返す
