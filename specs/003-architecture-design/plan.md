# Implementation Plan: アーキテクチャ設計

**Branch**: `003-architecture-design` | **Date**: 2026-04-15 | **Spec**: [/Users/lihs/workspace/vocastock/specs/003-architecture-design/spec.md](/Users/lihs/workspace/vocastock/specs/003-architecture-design/spec.md)
**Input**: Feature specification from `/specs/003-architecture-design/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Flutter クライアントから英単語登録、解説生成、画像生成、結果表示までの
end-to-end 全体について、責務境界、運用単位、主要データフロー、外部ポート、
段階移行方針を設計成果物として整理する。現在の docs-first な repository を前提に、
実装前に判断すべき target architecture を固定し、非同期生成の完了結果のみ表示する
規則と外部依存の差し替え可能性をレビュー可能な形にする。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/development/*.md`  
**Storage**: Git-managed repository files、設計上で参照する抽象的な永続化ストアとアセットストア  
**Testing**: spec / constitution / domain docs / ADR に対する手動クロスレビュー、責務割当レビュー、非同期状態と表示規則のシナリオ確認  
**Target Platform**: Flutter クライアント（iOS / Android / macOS）と、登録・生成・取得を担う application / worker runtime  
**Project Type**: documentation / system-architecture design  
**Performance Goals**: レビュー参加者が 10 分以内に主要責務を境界へ割り当てられること、解説生成と画像生成の全状態についてユーザー表示可否を説明できること、変更要求ごとに移行フェーズを 5 分以内に選べること  
**Constraints**: この feature では product code を追加しない、完了済み結果のみをユーザーへ表示する、非同期ワークフローは明示的状態と冪等再試行を持つ、外部依存はすべてポート/アダプタ越しに接続する、学習概念は分離したまま保つ、識別子命名は憲章に従う、現状から target architecture への段階移行を含める  
**Scale/Scope**: 1 end-to-end product、3 user stories、4 つの参照ドメイン文書、4 つの契約文書、6 つの主要責務境界、2 つの非同期生成ワークフロー、4 段階の移行定義

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is architectural alignment only. `docs/internal/domain/common.md`,
      `docs/internal/domain/explanation.md`, `docs/internal/domain/visual.md`,
      `docs/internal/domain/service.md` は参照元であり、この plan では集約自体を
      再定義せず、将来の実装変更時に反映すべき境界を明示する。
- [x] Async generation flows は `pending`、`running`、`succeeded`、`failed` を
      明示し、冪等再試行と「完了結果のみ表示」を契約として固定する。
- [x] 単語検証、解説生成、画像生成、アセット保存、発音参照はすべてポート越しに
      接続し、`contracts/external-port-contract.md` で責務境界を固定する。
- [x] ユーザーストーリーは、全体責務、非同期と表示、外部境界と運用境界に分かれており、
      それぞれ `contracts/` と `data-model.md` で独立にレビュー可能である。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態は target
      architecture 上でも別概念として扱い、状態所有者を混同しない。
- [x] 設計成果物内の識別子命名は憲章に従い、`id` / `xxxId` を使わず、
      `XxxIdentifier`、`identifier`、概念名フィールドで統一する。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/boundary-responsibility-contract.md`,
`contracts/async-visibility-contract.md`,
`contracts/external-port-contract.md`,
and `contracts/migration-phase-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/003-architecture-design/
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
│   └── security-version-review.md
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

references/
└── vocalibrary/

scripts/
├── bootstrap/
├── ci/
├── firebase/
└── lib/

tooling/
└── versions/

specs/003-architecture-design/
├── checklists/
│   └── requirements.md
├── contracts/
├── data-model.md
├── plan.md
├── quickstart.md
├── research.md
└── spec.md
```

**Structure Decision**: 現在の repository は docs / platform setup 先行であり、
この feature でも product code を増やさず、`specs/003-architecture-design/` に
architecture artifact を集約する。target runtime は設計上で定義するが、物理的な
ディレクトリ追加は後続 implementation feature に委ねる。

## Complexity Tracking

> No constitution violations identified at planning time.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
