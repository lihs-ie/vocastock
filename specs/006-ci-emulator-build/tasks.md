# Tasks: CI Emulator Build Optimization

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/`
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/plan.md), [spec.md](/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/spec.md), [research.md](/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/data-model.md), [contracts/](/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/contracts)

**Tests**: 専用の test-first task は追加しない。検証は `actrun`、GitHub Actions run、`bash scripts/firebase/*.sh`、`bash scripts/ci/*.sh` による実行可能な smoke / verification を independent test として扱う。

**Organization**: Tasks are grouped by user story so each story can be implemented and verified independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in every task

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: reusable image path を扱うための共通ファイルと source-of-truth を揃える

- [X] T001 Define reusable-image baseline constants, GHCR naming, and startup mode environment keys in `/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh`
- [X] T002 [P] Create the reusable workflow shell for emulator image preparation in `/Users/lihs/workspace/vocastock/.github/workflows/emulator-image-prepare.yml`
- [X] T003 [P] Add CI ownership, baseline source-of-truth, and reusable-image policy sections to `/Users/lihs/workspace/vocastock/docs/development/ci-policy.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する baseline 解決・compose mode・workflow 共通前提を整備する

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Create baseline hash calculation and image-ref export flow in `/Users/lihs/workspace/vocastock/scripts/ci/resolve_emulator_image_ref.sh`
- [X] T005 Create the image preparation entrypoint with Buildx/GHCR/artifact interfaces in `/Users/lihs/workspace/vocastock/scripts/ci/prepare_emulator_image.sh`
- [X] T006 [P] Update `/Users/lihs/workspace/vocastock/docker/firebase/compose.yaml` to support `ci-prepared-image` mode and `local-build` mode without duplicating the stack definition
- [X] T007 [P] Refactor `/Users/lihs/workspace/vocastock/scripts/firebase/start_emulators.sh` to accept startup mode, image reference, and build/no-build switches shared by local and CI paths
- [X] T008 Create the shared smoke consumer plumbing in `/Users/lihs/workspace/vocastock/scripts/ci/run_emulator_smoke.sh` and `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml` so any story can supply an explicit image reference and startup mode

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Reuse Prepared Emulator Image (Priority: P1) 🎯 MVP

**Goal**: `emulator-smoke` が inline build を要求せず、GHCR 上の prepared baseline image を解決して ready 判定まで進める

**Independent Test**: `actrun workflow run .github/workflows/ci.yml --local --include-dirty --trust` で `emulator-smoke` が GHCR baseline image を使って通り、`docker compose build` 相当の inline build を要求しないことを確認する

### Implementation for User Story 1

- [X] T009 [P] [US1] Update `/Users/lihs/workspace/vocastock/scripts/ci/run_emulator_smoke.sh` to resolve the GHCR baseline image before startup and record the resolved source
- [X] T010 [US1] Update `/Users/lihs/workspace/vocastock/scripts/firebase/start_emulators.sh` so CI mode fails fast on missing or stale prepared images while local mode still permits build fallback
- [X] T011 [P] [US1] Update `/Users/lihs/workspace/vocastock/scripts/firebase/smoke_local_stack.sh` to report the reusable image source and ready timing used by smoke validation
- [X] T012 [US1] Update the `emulator-smoke` job in `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml` to consume prepared images without changing the required-check name
- [X] T013 [US1] Document reusable-image smoke validation and local fallback behavior in `/Users/lihs/workspace/vocastock/docs/development/flutter-environment.md` and `/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/quickstart.md`

**Checkpoint**: User Story 1 should allow emulator smoke to run from a reusable image path without inline build

---

## Phase 4: User Story 2 - Separate Image Preparation From Smoke Execution (Priority: P2)

**Goal**: image build/publish と smoke execution を別 operational unit に分け、baseline 変更時だけ preparation path を走らせる

**Independent Test**: image preparation workflow を単独実行して artifact または GHCR image を生成し、Foundational で用意した image-ref consumer path を使って smoke path だけを別 run で起動して成立することを確認する

### Implementation for User Story 2

- [X] T014 [P] [US2] Implement Buildx cache, GHCR publish, and same-run artifact export in `/Users/lihs/workspace/vocastock/scripts/ci/prepare_emulator_image.sh`
- [X] T015 [P] [US2] Extend `/Users/lihs/workspace/vocastock/scripts/ci/resolve_emulator_image_ref.sh` with baseline invalidation logic and separated-path resolution order `workflow-artifact -> ghcr -> deterministic failure`
- [X] T016 [US2] Implement reusable/manual preparation workflow in `/Users/lihs/workspace/vocastock/.github/workflows/emulator-image-prepare.yml`
- [X] T017 [US2] Update `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml` to call the separated preparation path and pass outputs or artifacts into `emulator-smoke`
- [X] T018 [US2] Update `/Users/lihs/workspace/vocastock/docker/firebase/Dockerfile` and `/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh` with labels, digests, and runtime inputs required for baseline hashing
- [X] T019 [US2] Record image baseline ownership, invalidation triggers, registry/cache rationale, and trusted-context rules in `/Users/lihs/workspace/vocastock/docs/development/ci-policy.md` and `/Users/lihs/workspace/vocastock/docs/development/security-version-review.md`

**Checkpoint**: User Story 2 should allow build/publish and smoke execution to run as separate units while preserving the existing required check

---

## Phase 5: User Story 3 - Diagnose Emulator Startup Delays Quickly (Priority: P3)

**Goal**: maintainer が artifact とログだけで image resolution、pull/build、container start、readiness wait の停止点を即座に判断できるようにする

**Independent Test**: 成功 run と失敗 run の artifact を見て、第三者が 5 分以内に stop stage と所要時間を説明できることを確認する

### Implementation for User Story 3

- [X] T020 [P] [US3] Add stage markers and duration capture to `/Users/lihs/workspace/vocastock/scripts/ci/run_emulator_smoke.sh`
- [X] T021 [P] [US3] Add stage-specific logs, compose status snapshots, and container log tails to `/Users/lihs/workspace/vocastock/scripts/firebase/start_emulators.sh` and `/Users/lihs/workspace/vocastock/scripts/firebase/stop_emulators.sh`
- [X] T022 [US3] Update `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml` and `/Users/lihs/workspace/vocastock/.github/workflows/emulator-image-prepare.yml` to upload diagnostic bundles on success and failure
- [X] T023 [US3] Update `/Users/lihs/workspace/vocastock/scripts/firebase/measure_emulator_ready_time.sh` and `/Users/lihs/workspace/vocastock/scripts/ci/check_ci_runtime_budget.sh` to report reusable-image runtime impact against readiness and aggregate budgets
- [X] T024 [US3] Document stop-stage interpretation and troubleshooting flow in `/Users/lihs/workspace/vocastock/docs/development/ci-policy.md` and `/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/quickstart.md`

**Checkpoint**: User Story 3 should make emulator delays and failures diagnosable from artifacts alone

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーに跨る整合と最終運用導線を仕上げる

- [X] T025 [P] Reconcile local/CI mode consistency across `/Users/lihs/workspace/vocastock/docker/firebase/compose.yaml`, `/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh`, and `/Users/lihs/workspace/vocastock/docs/development/flutter-environment.md`
- [X] T026 [P] Re-run quickstart validation commands and capture the final operator flow in `/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/quickstart.md`
- [X] T027 Reconcile shipped behavior across `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml`, `/Users/lihs/workspace/vocastock/.github/workflows/emulator-image-prepare.yml`, and `/Users/lihs/workspace/vocastock/docs/development/ci-policy.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on other stories
- **User Story 2 (P2)**: Can start after Foundational - standalone preparation execution reuses the shared consumer plumbing from Phase 2 and does not depend on US1 delivery
- **User Story 3 (P3)**: Can start after Foundational and layers diagnostics onto the shared preparation / smoke path without changing required-check names

### Within Each User Story

- Shared scripts and workflow wiring from Phase 2 must land first
- Workflow changes should follow script entrypoint changes, not precede them
- Documentation tasks complete after the corresponding behavior is implemented

### Parallel Opportunities

- `T002` and `T003` can run in parallel after `T001`
- `T006` and `T007` can run in parallel after `T004` and `T005`
- In US1, `T009` and `T011` can run in parallel
- In US2, `T014` and `T015` can run in parallel
- In US3, `T020` and `T021` can run in parallel
- Final polish `T025` and `T026` can run in parallel after all stories complete

---

## Parallel Example: User Story 1

```bash
# Launch reusable-image smoke consumer tasks together:
Task: "Update /Users/lihs/workspace/vocastock/scripts/ci/run_emulator_smoke.sh to resolve same-run artifact or GHCR image before startup and record the resolved source"
Task: "Update /Users/lihs/workspace/vocastock/scripts/firebase/smoke_local_stack.sh to report the reusable image source and ready timing used by smoke validation"
```

## Parallel Example: User Story 2

```bash
# Launch preparation-path implementation tasks together:
Task: "Implement Buildx cache, GHCR publish, and same-run artifact export in /Users/lihs/workspace/vocastock/scripts/ci/prepare_emulator_image.sh"
Task: "Extend /Users/lihs/workspace/vocastock/scripts/ci/resolve_emulator_image_ref.sh with baseline invalidation logic and resolution order workflow-artifact -> ghcr -> deterministic failure"
```

## Parallel Example: User Story 3

```bash
# Launch diagnostic logging tasks together:
Task: "Add stage markers and duration capture to /Users/lihs/workspace/vocastock/scripts/ci/run_emulator_smoke.sh"
Task: "Add stage-specific logs, compose status snapshots, and container log tails to /Users/lihs/workspace/vocastock/scripts/firebase/start_emulators.sh and /Users/lihs/workspace/vocastock/scripts/firebase/stop_emulators.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate `emulator-smoke` reusable-image path independently
5. Stop and review runtime impact before moving on

### Incremental Delivery

1. Ship Setup + Foundational to establish baseline resolution and startup modes
2. Add User Story 1 to recover `emulator-smoke` reliability
3. Add User Story 2 to separate build/publish from smoke execution
4. Add User Story 3 to make stop-stage diagnosis self-serve
5. Finish with cross-cutting polish and quickstart validation

### Parallel Team Strategy

1. One developer handles Phase 1 and Phase 2 shared adapters
2. After Foundation:
   - Developer A: User Story 1 consumer path
   - Developer B: User Story 2 preparation workflow
   - Developer C: User Story 3 diagnostics and artifact handling
3. Reconcile all stories in Phase 6

---

## Notes

- [P] tasks target different files and can proceed in parallel after their dependencies
- No standalone test-file tasks were generated because the feature spec asks for executable smoke validation rather than TDD
- Keep the required check name `emulator-smoke` unchanged throughout implementation
- Do not reintroduce inline CI builds as a silent fallback
