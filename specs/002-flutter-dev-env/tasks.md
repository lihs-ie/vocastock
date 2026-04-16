# Tasks: Flutter開発環境基盤整備

**Input**: Design documents from `/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/`
**Prerequisites**: [plan.md](/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/plan.md), [spec.md](/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/spec.md), [research.md](/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/research.md), [data-model.md](/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/data-model.md), `contracts/`, [quickstart.md](/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/quickstart.md)

**Tests**: この feature では、spec がローカル再現性、CI 自動検証、脆弱性 block、version governance を明示的に要求しているため、smoke / validation / CI gate / budget measurement を task に含める。

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Every task includes exact file paths

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 最新実機 baseline を full-scope 実装へ流し込むための共通受け皿を揃える

- [X] T001 Refresh approved host baseline constants and labels in `scripts/lib/vocastock_env.sh`
- [X] T002 [P] Refresh approved host toolchain evidence headers in `tooling/versions/approved-components.md`
- [X] T003 [P] Refresh local environment guide and troubleshooting sections for the latest host baseline in `docs/development/flutter-environment.md`
- [X] T004 [P] Refresh CI and security guidance headers for latest-machine baseline governance in `docs/development/ci-policy.md` and `docs/development/security-version-review.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が依存する Firebase emulator、bootstrap、CI gate の前提を揃える

**⚠️ CRITICAL**: No user story work should start before this phase is complete

- [X] T005 Update Firebase emulator source-of-truth inventory in `firebase.json` and `.firebaserc`
- [X] T006 [P] Update Dockerized Firebase runtime versions and image notes in `docker/firebase/Dockerfile`
- [X] T007 [P] Update emulator compose stack, host ports, and local defaults template in `docker/firebase/compose.yaml` and `docker/firebase/env/.env.example`
- [X] T008 [P] Update macOS bootstrap output and install guidance for Xcode 26.4, Android Studio 2025.3, and Docker Desktop 4.69.0 in `scripts/bootstrap/setup_macos.sh`
- [X] T009 [P] Update Firebase emulator lifecycle helpers for the refreshed baseline in `scripts/firebase/start_emulators.sh`, `scripts/firebase/stop_emulators.sh`, and `scripts/firebase/reset_emulators.sh`
- [X] T010 [P] Update shared CI toolchain installation and baseline export logic in `scripts/ci/install_toolchains.sh` and `scripts/lib/vocastock_env.sh`
- [X] T011 [P] Update shared CI quality and vulnerability policy wiring in `scripts/ci/run_quality_checks.sh` and `scripts/ci/run_vulnerability_scan.sh`
- [X] T012 [P] Update Trivy policy files for the current block criteria in `.github/trivy.yaml` and `.trivyignore`
- [X] T013 Update version catalog schema, observed baseline columns, and validation rules in `tooling/versions/approved-components.md` and `scripts/ci/check_version_catalog.sh`

**Checkpoint**: 共通基盤、Firebase emulator inventory、host baseline constants、catalog validation が最新実機前提へ揃っている

---

## Phase 3: User Story 1 - ローカル環境を再現する (Priority: P1) 🎯 MVP

**Goal**: 最新実機 baseline と Dockerized Firebase emulator を使って、macOS から日常開発を再現できるようにする

**Independent Test**: 新規参加者が [flutter-environment.md](/Users/lihs/workspace/vocastock/docs/development/flutter-environment.md) の手順だけで host toolchain を揃え、`bash scripts/bootstrap/verify_macos_toolchain.sh`、`bash scripts/bootstrap/validate_local_setup.sh`、`bash scripts/firebase/start_emulators.sh`、`bash scripts/firebase/smoke_local_stack.sh`、`bash scripts/firebase/measure_emulator_ready_time.sh` を完了できること

### Validation for User Story 1

- [X] T014 [P] [US1] Update host toolchain verification for the latest machine baseline in `scripts/bootstrap/verify_macos_toolchain.sh`
- [X] T015 [P] [US1] Update local setup validation flow in `scripts/bootstrap/validate_local_setup.sh` and `scripts/bootstrap/validate_local_stack.sh`
- [X] T016 [P] [US1] Update emulator smoke flow in `scripts/firebase/smoke_local_stack.sh` and `scripts/ci/run_local_stack_smoke.sh`
- [X] T017 [P] [US1] Update local setup and emulator budget measurement commands in `scripts/bootstrap/measure_local_setup_budget.sh` and `scripts/firebase/measure_emulator_ready_time.sh`

### Implementation for User Story 1

- [X] T018 [US1] Update macOS host prerequisites, install order, and approved version table in `docs/development/flutter-environment.md`
- [X] T019 [US1] Update Firebase service inventory source-of-truth and mirror it in `firebase.json` and `docs/development/flutter-environment.md`
- [X] T020 [US1] Update local defaults, secret boundaries, and endpoint catalog in `docker/firebase/env/.env.example` and `docs/development/flutter-environment.md`
- [X] T021 [US1] Update emulator lifecycle, troubleshooting, and budget overrun guidance in `docs/development/flutter-environment.md`
- [X] T022 [US1] Wire refreshed bootstrap, verify, emulator lifecycle, smoke, and budget commands into `docs/development/flutter-environment.md`, `specs/002-flutter-dev-env/quickstart.md`, and `README.md`

**Checkpoint**: User Story 1 can be executed end-to-end on a macOS host without relying on shared cloud state

---

## Phase 4: User Story 2 - CI で品質を確認する (Priority: P2)

**Goal**: 最新実機 baseline との差分を明示しつつ、required checks と protected-branch enforcement を継続運用できるようにする

**Independent Test**: 任意の PR に対して `.github/workflows/ci.yml` と `.github/workflows/apple-build.yml` の required checks が起動し、1 つでも失敗すると `main`、`develop`、`release/*` へ統合できないことを第三者が確認できること

### Validation for User Story 2

- [X] T023 [P] [US2] Update approved-version catalog gate for observed baseline evidence in `scripts/ci/check_version_catalog.sh`
- [X] T024 [P] [US2] Update emulator smoke gate and local stack handoff in `scripts/ci/run_emulator_smoke.sh` and `scripts/ci/run_local_stack_smoke.sh`
- [X] T025 [P] [US2] Update Apple build smoke gate for the refreshed host baseline assumptions in `scripts/ci/run_apple_build_smoke.sh`
- [X] T026 [P] [US2] Update Android build smoke gate for the refreshed Android Studio baseline in `scripts/ci/run_android_build_smoke.sh`
- [X] T027 [P] [US2] Update CI runtime budget measurement and threshold enforcement in `scripts/ci/check_ci_runtime_budget.sh`

### Implementation for User Story 2

- [X] T028 [US2] Update Linux required-check workflow for latest-machine governance in `.github/workflows/ci.yml`
- [X] T029 [US2] Update Apple build workflow for latest-machine governance in `.github/workflows/apple-build.yml`
- [X] T030 [US2] Enforce Trivy severity thresholds and artifact handling in `scripts/ci/run_quality_checks.sh`, `scripts/ci/run_vulnerability_scan.sh`, and `.github/workflows/ci.yml`
- [X] T031 [US2] Update protected-branch enforcement artifacts in `scripts/ci/github_ruleset_payload.json` and `scripts/ci/apply_github_ruleset.sh`
- [X] T032 [US2] Document required checks, runner boundaries, ruleset rollout, rerun policy, and runtime budget handling in `docs/development/ci-policy.md`

**Checkpoint**: User Story 2 independently enforces required checks and protected-branch policy against the refreshed baseline

---

## Phase 5: User Story 3 - 採用バージョンの安全性を説明する (Priority: P3)

**Goal**: 各コンポーネントの approved version、observed baseline、脆弱性調査、見直し条件を第三者が追跡できるようにする

**Independent Test**: [approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md) と [security-version-review.md](/Users/lihs/workspace/vocastock/docs/development/security-version-review.md) を見れば、support status、security source、review cadence、stable/LTS 判断、baseline delta、secret/local default policy を説明できること

### Validation for User Story 3

- [X] T033 [P] [US3] Update version review checklist and observed-baseline evidence sections in `docs/development/security-version-review.md`
- [X] T034 [P] [US3] Update approved-component table columns for approvedVersion, observedBaselineVersion, supersededVersion, and baselineChangeReason in `tooling/versions/approved-components.md`

### Implementation for User Story 3

- [X] T035 [US3] Populate exact approved versions, support sources, and review cadence for the refreshed host baseline in `tooling/versions/approved-components.md`
- [X] T036 [US3] Record per-component vulnerability source, finding summary, disposition, and reviewedAt evidence in `tooling/versions/approved-components.md`
- [X] T037 [US3] Record baseline-delta policy, stable-vs-LTS rationale, and re-evaluation triggers in `docs/development/security-version-review.md`
- [X] T038 [US3] Document local default versus CI secret handling and prohibited mechanisms in `docs/development/security-version-review.md`, `docs/development/flutter-environment.md`, and `docs/development/ci-policy.md`
- [X] T039 [US3] Align repository-level requirements and onboarding guidance with refreshed version governance in `docs/external/requirements.md` and `README.md`

**Checkpoint**: User Story 3 independently explains why the refreshed baseline is approved and how it is re-evaluated

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 各 user story を跨ぐ整合確認と最終仕上げ

- [X] T040 [P] Reconcile quickstart and implementation docs in `specs/002-flutter-dev-env/quickstart.md`, `docs/development/flutter-environment.md`, and `docs/development/ci-policy.md`
- [X] T041 [P] Update developer agent guidance for refreshed baseline scripts and workflows in `AGENTS.md`
- [X] T042 Run cross-document consistency pass across `README.md`, `docs/development/flutter-environment.md`, `docs/development/ci-policy.md`, `docs/development/security-version-review.md`, `tooling/versions/approved-components.md`, `firebase.json`, `docker/firebase/compose.yaml`, and `scripts/ci/github_ruleset_payload.json`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup**: No dependencies - can start immediately
- **Phase 2: Foundational**: Depends on Setup completion - blocks all user stories
- **Phase 3: US1**: Can start after Foundational completion
- **Phase 4: US2**: Can start after Foundational completion
- **Phase 5: US3**: Can start after Foundational completion
- **Phase 6: Polish**: Depends on the desired user stories being complete

### User Story Dependencies

- **US1 (P1)**: Can start after Foundational - no dependency on other stories
- **US2 (P2)**: Can start after Foundational - should remain independently testable from US1
- **US3 (P3)**: Can start after Foundational - should remain independently testable from US1/US2

### Within Each User Story

- Validation tasks should be implemented before or alongside the corresponding implementation tasks
- Source-of-truth files should be updated before dependent documentation and rollout guidance
- Workflow and ruleset updates should follow CI gate script updates
- Story completion should be checked against the independent test before moving to the next priority

### Recommended Execution Order

1. Phase 1: Setup
2. Phase 2: Foundational
3. Phase 3: US1 (MVP)
4. Validate US1 independently
5. Phase 4: US2
6. Phase 5: US3
7. Phase 6: Polish

## Parallel Opportunities

### Parallel Example: Setup

```text
T002 approved component evidence headers in tooling/versions/approved-components.md
T003 local environment guide refresh in docs/development/flutter-environment.md
T004 CI/security guidance refresh in docs/development/ci-policy.md and docs/development/security-version-review.md
```

### Parallel Example: User Story 1

```text
T014 host toolchain verification in scripts/bootstrap/verify_macos_toolchain.sh
T015 local setup validation in scripts/bootstrap/validate_local_setup.sh and scripts/bootstrap/validate_local_stack.sh
T016 emulator smoke flow in scripts/firebase/smoke_local_stack.sh and scripts/ci/run_local_stack_smoke.sh
T017 budget measurement in scripts/bootstrap/measure_local_setup_budget.sh and scripts/firebase/measure_emulator_ready_time.sh
```

### Parallel Example: User Story 2

```text
T023 approved-version catalog gate in scripts/ci/check_version_catalog.sh
T024 emulator smoke gate in scripts/ci/run_emulator_smoke.sh and scripts/ci/run_local_stack_smoke.sh
T025 Apple build smoke gate in scripts/ci/run_apple_build_smoke.sh
T026 Android build smoke gate in scripts/ci/run_android_build_smoke.sh
T027 CI runtime budget check in scripts/ci/check_ci_runtime_budget.sh
```

### Parallel Example: User Story 3

```text
T033 review checklist and observed baseline evidence in docs/development/security-version-review.md
T034 approved component evidence columns in tooling/versions/approved-components.md
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate the US1 independent test
5. Stop and review before enabling CI/ruleset rollout updates

### Incremental Delivery

1. Ship local environment reproducibility and latest-machine baseline sync first
2. Add CI required checks and protected branch enforcement next
3. Add version governance and security evidence last
4. Finish with quickstart / README / AGENTS consistency verification

### Parallel Team Strategy

1. One maintainer completes Setup and Foundational
2. After foundation:
   - US1 owner works on local setup and emulator reproducibility
   - US2 owner works on CI workflows and branch protection guidance
   - US3 owner works on approved version evidence and security governance
3. Merge all stories after independent validation and final polish

## Notes

- `[P]` tasks touch separate files and can be worked on in parallel
- User story labels map every story task back to `spec.md`
- `firebase.json`, `docker/firebase/compose.yaml`, `scripts/firebase/*`, `.github/workflows/*`, `tooling/versions/approved-components.md`, and `docs/development/*.md` remain repository-level source of truth for this feature
- When the latest machine baseline supersedes the previous approved version, the delta, rationale, and validation logic should be updated in the same change set
