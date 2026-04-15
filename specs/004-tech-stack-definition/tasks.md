# Tasks: 技術スタック定義

**Input**: Design documents from `/specs/004-tech-stack-definition/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`

**Tests**: この feature は docs-only の stack governance 実装なので、自動テスト追加ではなく、各 user story を独立に検証できる validation / review task を含める。

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Every task includes exact file paths

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: repository-level source-of-truth 文書の受け皿を作る

- [ ] T001 [P] Create technology stack source-of-truth skeleton in `docs/development/tech-stack.md`
- [ ] T002 [P] Create stack governance source-of-truth skeleton in `docs/development/stack-governance.md`
- [ ] T003 Add top-level references to the new stack documents in `README.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべての user story が共有する語彙、表形式、governance tier、正本の参照関係を固める

**⚠️ CRITICAL**: No user story work should start before this phase is complete

- [ ] T004 Define shared boundary and runtime vocabulary section covering Rust command/query, Haskell workflow, GraphQL, Pub/Sub, Google Drive, and observability in `docs/development/tech-stack.md`
- [ ] T005 [P] Define standard table schemas for boundary stack, GraphQL compatibility, managed-service ownership, asset adapter ownership, and observability ownership in `docs/development/tech-stack.md`
- [ ] T006 [P] Define governance tiers, version strategy glossary, and proposal status vocabulary for Flutter, Rust, Haskell, Firebase, Pub/Sub, and Google Drive in `docs/development/stack-governance.md`
- [ ] T007 [P] Clarify exact-version catalog scope and family-tier handoff notes for Rust toolchain, GHC toolchain, `graphql_flutter`, Pub/Sub, and Google Drive API in `tooling/versions/approved-components.md`
- [ ] T008 [P] Align security review procedure with GraphQL, Rust/Haskell split runtime, Pub/Sub worker, and Google Drive adapter governance in `docs/development/security-version-review.md`
- [ ] T009 Create cross-reference sections and source-of-truth ownership notes to `specs/003-architecture-design/plan.md`, `specs/003-architecture-design/contracts/boundary-responsibility-contract.md`, and `specs/004-tech-stack-definition/plan.md` in `docs/development/tech-stack.md` and `docs/development/stack-governance.md`

**Checkpoint**: 共有語彙、governance、正本の参照関係が揃い、各 user story を独立に進められる

---

## Phase 3: User Story 1 - 境界ごとの採用スタックを確定する (Priority: P1)

**Goal**: 責務境界ごとに採用 stack、採用理由、禁止事項、service ownership、observability 責務を一意に説明できるようにする

**Independent Test**: 第三者が `docs/development/tech-stack.md` と `docs/external/adr.md` を読むだけで、client、application、workflow、persistence、external connection、operations / observability の各境界について `Flutter + graphql_flutter`、`Rust command/query`、`Haskell workflow + Pub/Sub`、`Firebase baseline`、`Google Drive adapter`、observability 方針を説明できること

### Validation for User Story 1

- [ ] T010 [P] [US1] Add six-boundary coverage review checklist including GraphQL, Pub/Sub, Google Drive, and observability checks in `docs/development/tech-stack.md`
- [ ] T011 [US1] Add runtime-to-boundary mapping table including Rust command/query runtime, Haskell workflow runtime, Google Drive adapter ownership, and operations / observability ownership in `docs/development/tech-stack.md`

### Implementation for User Story 1

- [ ] T012 [US1] Document Client Experience adopted stack with Flutter 3.41.5, `graphql_flutter`, GraphQL rationale, and direct-dependency prohibitions in `docs/development/tech-stack.md`
- [ ] T013 [US1] Document Vocabulary Command and Learning Query adopted stack with Rust runtime, GraphQL boundary ownership, and direct-dependency prohibitions in `docs/development/tech-stack.md`
- [ ] T014 [US1] Document Explanation Workflow and Image Workflow adopted stack with Haskell runtime, Pub/Sub trigger, Firestore state, and direct-dependency prohibitions in `docs/development/tech-stack.md`
- [ ] T015 [US1] Document Persistence / Identity baseline ownership with Firebase Authentication, Firestore, Firebase Hosting, and Google Drive asset-storage separation in `docs/development/tech-stack.md`
- [ ] T016 [US1] Document Integration Adapter adopted stack covering AI provider HTTP/JSON adapter and Google Drive `AssetStoragePort` responsibilities in `docs/development/tech-stack.md`
- [ ] T017 [US1] Document Operations / Observability adopted stack with Cloud Logging, Cloud Monitoring, Error Reporting, and GraphQL/Pub/Sub correlation responsibilities in `docs/development/tech-stack.md`
- [ ] T018 [US1] Align component-level ADR narrative with Rust/Haskell/GraphQL/Google Drive boundary decisions and repository-level source-of-truth references in `docs/external/adr.md`

**Checkpoint**: User Story 1 が単独で成立し、責務境界ごとの採用 stack を end-to-end で説明できる

---

## Phase 4: User Story 2 - 選定基準と互換条件を共有する (Priority: P2)

**Goal**: 新しい技術提案を既存方針で評価できるように、shared standard、互換条件、support governance を定義する

**Independent Test**: 第三者が `docs/development/tech-stack.md` と `docs/development/stack-governance.md` を使って、新しい技術候補を採用済み / 非推奨 / 例外申請対象のいずれかへ分類できること

### Validation for User Story 2

- [ ] T019 [P] [US2] Add technology proposal evaluation checklist for Rust/Haskell split runtime, GraphQL client/server, Pub/Sub, and Google Drive adapter in `docs/development/stack-governance.md`
- [ ] T020 [P] [US2] Add compatibility review matrix skeleton for GraphQL schema, Pub/Sub message contract, Firestore state handoff, and asset reference contract in `docs/development/tech-stack.md`

### Implementation for User Story 2

- [ ] T021 [US2] Document shared standards and prohibited patterns across all boundaries including GraphQL-only client/backend sync, port-owned Google Drive access, and no provider SDK in core stack in `docs/development/tech-stack.md`
- [ ] T022 [US2] Document GraphQL synchronous contract rules and Pub/Sub async workflow contract rules in `docs/development/tech-stack.md`
- [ ] T023 [US2] Document external adapter rules, `graphql_flutter` compatibility conditions, and Google Drive / AI provider SDK restrictions in `docs/development/tech-stack.md`
- [ ] T024 [US2] Document governance tiers, support triggers, and escalation rules for Flutter, Rust, Haskell, Firebase, Pub/Sub, GraphQL library, and Google Drive in `docs/development/stack-governance.md`
- [ ] T025 [US2] Reconcile exact-version, service-family, and implementation-wave guidance across `docs/development/stack-governance.md`, `docs/development/security-version-review.md`, and `tooling/versions/approved-components.md`
- [ ] T026 [US2] Record the initial adopted stack baseline and rationale references for Rust/Haskell runtimes, GraphQL, Pub/Sub, and Google Drive in `docs/development/tech-stack.md` and `docs/development/stack-governance.md`

**Checkpoint**: User Story 2 が単独で成立し、技術提案の採用可否と互換条件を説明できる

---

## Phase 5: User Story 3 - 移行と例外運用を定義する (Priority: P3)

**Goal**: 現状から target stack へ寄せる波と、非標準技術の例外ルールを明文化する

**Independent Test**: 第三者が `docs/development/stack-governance.md`、`docs/development/flutter-environment.md`、`docs/development/ci-policy.md` を見れば、実装対象がどの migration wave に属するかと、例外申請が必要かを判断できること

### Validation for User Story 3

- [ ] T027 [P] [US3] Add exception request review checklist for GraphQL exceptions, single-language backend exceptions, and non-port Google Drive access in `docs/development/stack-governance.md`
- [ ] T028 [US3] Add migration-wave verification checklist covering GraphQL foundation, Rust command/query, Haskell workflow, Pub/Sub, and Google Drive adapter rollout in `docs/development/stack-governance.md`

### Implementation for User Story 3

- [ ] T029 [US3] Document exception approval conditions, expiry rules, and owner responsibilities for runtime split, GraphQL deviations, and asset-storage deviations in `docs/development/stack-governance.md`
- [ ] T030 [US3] Document `current-state`, `wave-1-foundation`, `wave-2-service-runtime`, and `wave-3-workflow-hardening` with GraphQL, Rust, Haskell, Pub/Sub, and Google Drive adoption details in `docs/development/stack-governance.md`
- [ ] T031 [US3] Align migration-wave guidance with local and CI baseline documents in `docs/development/flutter-environment.md` and `docs/development/ci-policy.md`
- [ ] T032 [US3] Publish stack source-of-truth and exception entry points for GraphQL, Rust/Haskell, Pub/Sub, and Google Drive in `README.md` and `docs/development/tech-stack.md`

**Checkpoint**: User Story 3 が単独で成立し、移行順序と例外運用を説明できる

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 横断整合と開発者向け導線を仕上げる

- [ ] T033 [P] Update developer guidance to reference `docs/development/tech-stack.md` and `docs/development/stack-governance.md` in `AGENTS.md`
- [ ] T034 [P] Reconcile implementation guidance in `specs/004-tech-stack-definition/quickstart.md`, `docs/development/tech-stack.md`, and `docs/development/stack-governance.md`
- [ ] T035 Run cross-document consistency pass across `docs/development/tech-stack.md`, `docs/development/stack-governance.md`, `docs/development/security-version-review.md`, `tooling/versions/approved-components.md`, `docs/external/adr.md`, `docs/development/flutter-environment.md`, `docs/development/ci-policy.md`, and `README.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup**: 開始条件なし
- **Phase 2: Foundational**: Phase 1 完了後に開始。すべての user story をブロックする
- **Phase 3: US1**: Phase 2 完了後に開始可能
- **Phase 4: US2**: Phase 2 完了後に開始可能
- **Phase 5: US3**: Phase 2 完了後に開始可能
- **Phase 6: Polish**: 実装対象の user story 完了後に開始

### User Story Dependencies

- **US1 (P1)**: Foundation 完了後に独立して実装可能
- **US2 (P2)**: Foundation 完了後に独立して実装可能。US1 の boundary mapping を参照するが、独立にレビューできる
- **US3 (P3)**: Foundation 完了後に独立して実装可能。US1 / US2 の結果を参照しても独立に検証できる

### Within Each User Story

- Validation task を先に整え、その後に source-of-truth 文書へ本体内容を反映する
- `docs/development/tech-stack.md` の編集を行う task は同一ストーリー内で順番に進める
- cross-file reconciliation は story 本体の完了後に行う

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
T001 technology stack skeleton in docs/development/tech-stack.md
T002 stack governance skeleton in docs/development/stack-governance.md
```

### Parallel Example: Foundational

```text
T005 standard table schemas in docs/development/tech-stack.md
T006 governance tiers and glossary in docs/development/stack-governance.md
T007 exact-version catalog scope in tooling/versions/approved-components.md
T008 security review alignment in docs/development/security-version-review.md
```

### Parallel Example: User Story 1

```text
T010 boundary coverage checklist in docs/development/tech-stack.md
```

### Parallel Example: User Story 2

```text
T019 technology proposal evaluation checklist in docs/development/stack-governance.md
T020 compatibility review matrix skeleton in docs/development/tech-stack.md
```

### Parallel Example: User Story 3

```text
T027 exception request review checklist in docs/development/stack-governance.md
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate the US1 independent test
5. Stop and review before extending governance rules

### Incremental Delivery

1. Ship boundary-to-stack mapping first
2. Add selection criteria and compatibility governance next
3. Add migration and exception governance after that
4. Finish with cross-document reconciliation and developer guidance updates

### Parallel Team Strategy

1. One person completes Phase 1 and Phase 2
2. After foundation:
   - US1 owner works on adopted stack mapping
   - US2 owner works on compatibility and governance rules
   - US3 owner works on migration and exception rules
3. Merge all stories after independent review and final polish

---

## Notes

- `[P]` tasks touch separate files and can be worked on in parallel
- User story labels map every story task back to `spec.md`
- This task list assumes the repository-level source of truth is `docs/development/tech-stack.md` and `docs/development/stack-governance.md`
- Keep `tooling/versions/approved-components.md` focused on exact-version tier, and document family-tier / implementation-wave rules in governance docs
