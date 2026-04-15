# Tasks: Flutter開発環境基盤整備

**Input**: Design documents from `/specs/002-flutter-dev-env/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`

**Tests**: この feature では、spec がローカル再現性、CI 自動検証、脆弱性ブロックを明示的に要求しているため、smoke/validation/CI gate の task を含める。

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Every task includes exact file paths

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 実装対象ディレクトリと基礎ドキュメントの受け皿を作る

- [X] T001 Create implementation directory skeleton for `docker/firebase/`, `.github/workflows/`, `scripts/bootstrap/`, `scripts/ci/`, `scripts/firebase/`, `docs/development/`, and `tooling/versions/`
- [X] T002 [P] Create approved component catalog skeleton in `tooling/versions/approved-components.md`
- [X] T003 [P] Create local environment guide skeleton in `docs/development/flutter-environment.md`
- [X] T004 [P] Create CI and security guidance skeletons in `docs/development/ci-policy.md` and `docs/development/security-version-review.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべてのユーザーストーリーが前提とする共通設定と実行基盤を固める

**⚠️ CRITICAL**: No user story work should start before this phase is complete

- [X] T005 Create shared Firebase project configuration in `firebase.json` and `.firebaserc`
- [X] T006 [P] Create Docker image definition for Firebase emulators in `docker/firebase/Dockerfile`
- [X] T007 [P] Create emulator compose stack and local defaults template in `docker/firebase/compose.yaml` and `docker/firebase/env/.env.example`
- [X] T008 [P] Create macOS bootstrap script for host prerequisites in `scripts/bootstrap/setup_macos.sh`
- [X] T009 [P] Create emulator lifecycle scripts in `scripts/firebase/start_emulators.sh`, `scripts/firebase/stop_emulators.sh`, and `scripts/firebase/reset_emulators.sh`
- [X] T010 [P] Create shared CI toolchain installer in `scripts/ci/install_toolchains.sh`
- [X] T011 [P] Create shared CI quality runner in `scripts/ci/run_quality_checks.sh`
- [X] T012 [P] Create vulnerability scan configuration in `.github/trivy.yaml` and `.trivyignore`
- [X] T013 Create version catalog schema and review fields in `tooling/versions/approved-components.md`

**Checkpoint**: 共通基盤が揃い、各ユーザーストーリーへ独立に着手できる

---

## Phase 3: User Story 1 - ローカル環境を再現する (Priority: P1) 🎯 MVP

**Goal**: macOS 上で Flutter 開発環境と Docker 化 Firebase エミュレーターを再現し、共有クラウドに依存せずに開発を開始できるようにする

**Independent Test**: 新規参加者が `docs/development/flutter-environment.md` の手順だけで host toolchain を揃え、emulator stack を起動し、smoke コマンドを完了できること

### Validation for User Story 1

- [X] T014 [P] [US1] Implement host toolchain verification command in `scripts/bootstrap/verify_macos_toolchain.sh`
- [X] T015 [P] [US1] Implement local setup smoke validation command in `scripts/bootstrap/validate_local_setup.sh`
- [X] T016 [P] [US1] Implement emulator readiness smoke command in `scripts/firebase/smoke_local_stack.sh`
- [X] T017 [P] [US1] Implement local setup and emulator budget measurement commands in `scripts/bootstrap/measure_local_setup_budget.sh` and `scripts/firebase/measure_emulator_ready_time.sh`

### Implementation for User Story 1

- [X] T018 [US1] Document macOS host prerequisites, install order, and supported versions in `docs/development/flutter-environment.md`
- [X] T019 [US1] Define the source-of-truth Firebase service inventory in `firebase.json` and mirror it in `docs/development/flutter-environment.md`
- [X] T020 [US1] Document Firebase service matrix, endpoint catalog, troubleshooting flow, and budget overrun response in `docs/development/flutter-environment.md`
- [X] T021 [US1] Complete emulator service definitions, ports, and healthchecks in `docker/firebase/compose.yaml` and `firebase.json`
- [X] T022 [US1] Wire bootstrap, start, stop, reset, smoke, and budget measurement commands into onboarding docs in `docs/development/flutter-environment.md`, `specs/002-flutter-dev-env/quickstart.md`, and `README.md`

**Checkpoint**: User Story 1 が単独で動作し、ローカル環境の再現手順を第三者が追従できる

---

## Phase 4: User Story 2 - CI で品質を確認する (Priority: P2)

**Goal**: 変更ブランチと保護対象ブランチに対して、静的検査、テスト、build smoke、脆弱性検査を自動実行し、必須チェック未通過では統合できないようにする

**Independent Test**: 任意の PR に対して required checks が起動し、1 つでも失敗すると `main`、`develop`、`release/*` へ統合できないこと

### Validation for User Story 2

- [X] T023 [P] [US2] Implement approved-version catalog gate in `scripts/ci/check_version_catalog.sh`
- [X] T024 [P] [US2] Implement emulator smoke gate for CI in `scripts/ci/run_emulator_smoke.sh`
- [X] T025 [P] [US2] Implement Apple build smoke gate in `scripts/ci/run_apple_build_smoke.sh`
- [X] T026 [P] [US2] Implement Android build smoke gate in `scripts/ci/run_android_build_smoke.sh`
- [X] T027 [P] [US2] Implement CI runtime budget measurement and threshold check in `scripts/ci/check_ci_runtime_budget.sh`

### Implementation for User Story 2

- [X] T028 [US2] Wire Linux required checks workflow in `.github/workflows/ci.yml`
- [X] T029 [US2] Wire Apple build smoke workflow in `.github/workflows/apple-build.yml`
- [X] T030 [US2] Enforce Trivy severity thresholds and CI artifact handling in `scripts/ci/run_quality_checks.sh` and `.github/workflows/ci.yml`
- [X] T031 [US2] Define protected-branch required-check enforcement artifacts in `scripts/ci/github_ruleset_payload.json` and `scripts/ci/apply_github_ruleset.sh`
- [X] T032 [US2] Document required checks, protected branch mapping, ruleset rollout, rerun policy, and runtime budget handling in `docs/development/ci-policy.md`

**Checkpoint**: User Story 2 が単独で機能し、保護対象ブランチへ必須 CI を強制できる

---

## Phase 5: User Story 3 - 採用バージョンの安全性を説明する (Priority: P3)

**Goal**: 各コンポーネントの exact version、サポート状況、脆弱性調査、採用理由、見直し条件を第三者が追跡できるようにする

**Independent Test**: `tooling/versions/approved-components.md` と `docs/development/security-version-review.md` を見れば、採用対象ごとの support status、security source、review cadence、stable/LTS 判断理由を説明できること

### Validation for User Story 3

- [X] T033 [P] [US3] Define version review checklist and evidence sections in `docs/development/security-version-review.md`
- [X] T034 [P] [US3] Define support-status, severity, vulnerability-source, finding, disposition, `reviewedAt`, and review-cadence columns in `tooling/versions/approved-components.md`

### Implementation for User Story 3

- [X] T035 [US3] Populate exact approved versions, support sources, and review cadence in `tooling/versions/approved-components.md`
- [X] T036 [US3] Record per-component vulnerability source, finding summary, disposition, and `reviewedAt` evidence in `tooling/versions/approved-components.md`
- [X] T037 [US3] Record stable-vs-LTS decision rules and re-evaluation triggers in `docs/development/security-version-review.md`
- [X] T038 [US3] Document CI authentication, local defaults, and prohibited secret mechanisms in `docs/development/security-version-review.md` and `docs/development/flutter-environment.md`
- [X] T039 [US3] Align repository-level requirements guidance with version governance in `docs/external/requirements.md` and `README.md`

**Checkpoint**: User Story 3 が単独で機能し、採用バージョンの保守・監査根拠を説明できる

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 各ストーリー横断の整合確認と最終仕上げ

- [X] T040 [P] Reconcile quickstart and implementation docs in `specs/002-flutter-dev-env/quickstart.md`, `docs/development/flutter-environment.md`, and `docs/development/ci-policy.md`
- [X] T041 [P] Update developer agent guidance for new scripts and workflows in `AGENTS.md`
- [X] T042 Run cross-document consistency pass across `README.md`, `docs/development/flutter-environment.md`, `docs/development/ci-policy.md`, `docs/development/security-version-review.md`, `tooling/versions/approved-components.md`, and `scripts/ci/github_ruleset_payload.json`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup**: 開始条件なし
- **Phase 2: Foundational**: Phase 1 完了後に開始。すべてのユーザーストーリーをブロックする
- **Phase 3: US1**: Phase 2 完了後に開始可能
- **Phase 4: US2**: Phase 2 完了後に開始可能
- **Phase 5: US3**: Phase 2 完了後に開始可能
- **Phase 6: Polish**: 実装対象のユーザーストーリー完了後に開始

### User Story Dependencies

- **US1 (P1)**: Foundation 完了後に独立して実装可能
- **US2 (P2)**: Foundation 完了後に独立して実装可能。US1 の完成を待たずに進められる
- **US3 (P3)**: Foundation 完了後に独立して実装可能。US1 / US2 と並行で進められる

### Within Each User Story

- Validation tasks を先に実装し、実装後に独立テスト条件で確認する
- Script / configuration を先に整え、その後 documentation / workflow wiring を行う
- Story 単位で完了条件を満たしてから次の優先度へ進む

### Recommended Execution Order

1. Phase 1: Setup
2. Phase 2: Foundational
3. Phase 3: US1 (MVP)
4. Validate US1 independently
5. Phase 4: US2
6. Phase 5: US3
7. Phase 6: Polish

---

## Parallel Opportunities

### Parallel Example: Setup

```text
T002 tool catalog skeleton in tooling/versions/approved-components.md
T003 local environment guide skeleton in docs/development/flutter-environment.md
T004 CI/security guidance skeletons in docs/development/ci-policy.md and docs/development/security-version-review.md
```

### Parallel Example: User Story 1

```text
T014 host toolchain verification in scripts/bootstrap/verify_macos_toolchain.sh
T015 local setup smoke validation in scripts/bootstrap/validate_local_setup.sh
T016 emulator readiness smoke in scripts/firebase/smoke_local_stack.sh
T017 local setup and emulator budget measurement in scripts/bootstrap/measure_local_setup_budget.sh and scripts/firebase/measure_emulator_ready_time.sh
```

### Parallel Example: User Story 2

```text
T023 version catalog gate in scripts/ci/check_version_catalog.sh
T024 emulator smoke gate in scripts/ci/run_emulator_smoke.sh
T025 Apple build smoke gate in scripts/ci/run_apple_build_smoke.sh
T026 Android build smoke gate in scripts/ci/run_android_build_smoke.sh
T027 CI runtime budget check in scripts/ci/check_ci_runtime_budget.sh
```

### Parallel Example: User Story 3

```text
T033 review checklist in docs/development/security-version-review.md
T034 catalog evidence columns in tooling/versions/approved-components.md
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate the US1 independent test
5. Stop and review before enabling CI automation

### Incremental Delivery

1. Ship local environment reproducibility first
2. Add CI required checks and protected branch policy next
3. Add version governance and security evidence last
4. Finish with cross-document reconciliation and quickstart verification

### Parallel Team Strategy

1. One person completes Phase 1 and Phase 2
2. After foundation:
   US1 owner works on local setup and emulator reproducibility
   US2 owner works on CI workflows and branch protection guidance
   US3 owner works on approved version evidence and security governance
3. Merge all stories after independent validation and final polish

---

## Notes

- `[P]` tasks touch separate files and can be worked on in parallel
- User story labels map every story task back to `spec.md`
- This task list assumes implementation will create the directories defined in `plan.md`
- Keep exact versions and source URLs synchronized between `tooling/versions/approved-components.md` and `docs/development/security-version-review.md`
