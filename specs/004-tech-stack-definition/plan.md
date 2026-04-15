# Implementation Plan: 技術スタック定義

**Branch**: `004-tech-stack-definition` | **Date**: 2026-04-15 | **Spec**: [/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/spec.md](/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/spec.md)
**Input**: Feature specification from `/specs/004-tech-stack-definition/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Flutter クライアント、Rust の command/query runtime、Haskell の workflow runtime、
Firebase Authentication / Firestore / Firebase Hosting を中心とする managed baseline、
Google Drive を使う asset storage adapter、GraphQL 同期契約、Pub/Sub + Cloud Run +
Firestore による非同期実行基盤を採用 stack として定義する。repository-level の正本は
`docs/development/tech-stack.md` と `docs/development/stack-governance.md` に置き、
`specs/004-tech-stack-definition/` は選定理由、契約、migration 根拠を保持する。

## Technical Context

**Language/Version**: Flutter 3.41.5 / Dart SDK bundled with Flutter 3.41.5、Rust stable toolchain for command/query runtime、Haskell toolchain via GHC/LTS resolver for workflow runtime、Markdown/YAML/JSON documentation  
**Primary Dependencies**: Flutter SDK 3.41.5、`graphql_flutter`、Firebase Authentication client integration、Rust GraphQL application runtime on Cloud Run、Haskell Pub/Sub worker runtime on Cloud Run、Cloud Firestore、Firebase Hosting、Google Drive API via `AssetStoragePort`、Google Cloud Pub/Sub、Dockerized Firebase Emulator Suite、GitHub Actions、Trivy CLI、Cloud Logging / Cloud Monitoring  
**Storage**: Cloud Firestore for operational state and workflow state、Google Drive for generated image assets through `AssetStoragePort`、Git-managed repository files for design and governance artifacts  
**Testing**: spec / constitution / architecture / environment artifact のクロスレビュー、boundary-to-stack traceability review、GraphQL contract review、Pub/Sub workflow review、support policy review、feature 002 の CI baseline との整合確認  
**Target Platform**: iOS / Android / macOS client、Rust GraphQL application runtime、Haskell Pub/Sub workflow runtime、Firebase managed services、Google Drive asset storage、containerized local development path  
**Project Type**: mobile-app + polyglot backend stack definition / documentation  
**Performance Goals**: レビュー参加者が 10 分以内に責務境界ごとの採用 stack を説明できること、新しい技術提案を 5 分以内に採用済み/非推奨/例外申請対象へ分類できること、既存 architecture artifact と stack artifact の矛盾を 0 件に保つこと  
**Constraints**: 完了済み結果のみをユーザーへ表示する憲章要件を満たすこと、非同期生成は `Pub/Sub + Cloud Run worker + Firestore state` で明示的状態と冪等再試行を表現すること、外部依存はポート/アダプタ越しに接続すること、client/backend 同期契約は GraphQL を標準とすること、画像アセットは Google Drive を `AssetStoragePort` 越しにのみ扱うこと、toolchain の exact version は `tooling/versions/approved-components.md` に従うこと、未承認技術は期限付き例外なしでは導入しないこと  
**Scale/Scope**: 1 end-to-end product、8 boundary profiles across 6 responsibility categories、5 runtime/service classes、4 contract documents、2 repository-level source-of-truth docs、1 migration wave plan

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is stack governance only. `docs/internal/domain/common.md`,
      `docs/internal/domain/explanation.md`, `docs/internal/domain/visual.md`,
      `docs/internal/domain/service.md` は技術選定時の制約参照であり、この feature 自体で
      集約や値オブジェクトを変更しない。
- [x] Async generation には `pending`、`running`、`succeeded`、`failed` を扱える
      stack を要求し、完了済み結果のみ表示する rule を前提条件として維持する。
- [x] AI、validation、media、asset storage などの外部依存は caller-owned
      port/adapter として扱い、`contracts/interoperability-contract.md` と
      `contracts/boundary-stack-contract.md` で接続責務を固定する。
- [x] ユーザーストーリーは、boundary mapping、selection/support criteria、
      migration/exception governance に分かれており、それぞれ独立にレビューできる。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態は stack decision に
      よって統合せず、必要な表現力を持つ技術のみを採用対象とする。
- [x] 設計成果物内の識別子命名は憲章に従い、`id` / `xxxId` を使わず、
      `XxxIdentifier`、`identifier`、概念名フィールドで統一する。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/boundary-stack-contract.md`,
`contracts/interoperability-contract.md`,
`contracts/support-governance-contract.md`,
and `contracts/exception-migration-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/004-tech-stack-definition/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
.github/
└── workflows/

docker/
└── firebase/

docs/
├── development/
│   ├── ci-policy.md
│   ├── flutter-environment.md
│   ├── security-version-review.md
│   ├── stack-governance.md
│   └── tech-stack.md
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/
        ├── common.md
        ├── explanation.md
        ├── service.md
        └── visual.md

firebase/
└── hosting/

scripts/
├── bootstrap/
├── ci/
├── firebase/
└── lib/

tooling/
└── versions/
    └── approved-components.md

specs/
├── 002-flutter-dev-env/
├── 003-architecture-design/
└── 004-tech-stack-definition/
    ├── checklists/
    ├── contracts/
    ├── data-model.md
    ├── plan.md
    ├── quickstart.md
    ├── research.md
    └── spec.md
```

**Structure Decision**: この feature は docs-only の stack governance feature として扱う。
実装時の repository-level source of truth は `docs/development/tech-stack.md` と
`docs/development/stack-governance.md` とし、`specs/004-tech-stack-definition/` は
選定理由、契約、migration 根拠を保持する設計パッケージとして参照する。toolchain の
exact version 証跡は `tooling/versions/approved-components.md` を継続利用し、boundary
と runtime の整合は `specs/003-architecture-design/` を参照元として扱う。

## Complexity Tracking

> No constitution violations identified at planning time.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
