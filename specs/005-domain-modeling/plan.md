# Implementation Plan: ドメインモデリング

**Branch**: `009-sense-modeling` | **Date**: 2026-04-17 | **Spec**: [/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md)
**Input**: Feature specification from `/specs/005-domain-modeling/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock project-wide domain language を維持したまま、`Explanation` に `Sense` を導入する。
`Sense` は多義語の意味単位を表す `Explanation` 所有の内部エンティティとし、意味、状況、
ニュアンス、例文、コロケーションを意味単位で保持できるようにする。`VisualImage` は
独立集約のまま維持しつつ、必要に応じてどの `Sense` を描写する画像かを示せるようにする。
一方で、`LearningState` の ownership boundary は変えずに `LearningStateIdentifier` を
`learner + vocabularyExpression` を表す複合識別子として明文化する。非同期表示ルールと
`currentImage` の単一 current 参照は維持し、意味と画像の対応を明確にしながら中間生成物を
見せない設計成果物を生成する。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`  
**Storage**: Git-managed repository files、設計上で参照する抽象的な learner store、explanation store、image asset store  
**Testing**: spec / constitution / ADR / domain docs の手動クロスレビュー、sense ownership review、image mapping review、非同期表示レビュー、識別子命名レビュー  
**Target Platform**: Flutter client、Rust command/query runtime、Haskell workflow runtime をまたぐ project-wide domain language  
**Project Type**: documentation / domain design  
**Performance Goals**: レビュー担当者が 5 分以内に `Sense` と `Explanation` / `VisualImage` の責務差分を説明できること、画像と意味の対応ルールを 5 分以内に判定できること、source-of-truth 文書の参照先を 3 分以内に辿れること  
**Constraints**: product code は追加しない、完了済み結果のみをユーザーへ表示する、頻出度・知的度・習熟度・登録状態・解説生成状態・画像生成状態を統合しない、`Sense` は `Explanation` 所有の内部エンティティとして扱う、`VisualImage` は独立集約として履歴を保持する、`Explanation.currentImage` はこの feature では単一 current 参照のまま維持する、画像を複数枚扱う場合も意味との対応なしに `Explanation` 直下へ裸の配列を足さない、外部依存はポート越しに接続する、派生命名は `VocabularyExpression*` / `LearningState*` に統一する、識別子命名は憲章に従う、`LearningStateIdentifier` は複合識別子として `learner` と `vocabularyExpression` を内包し、`LearningState` 本体へ同じ参照を重複保持しない  
**Scale/Scope**: 5 つの中心集約、1 つの内部エンティティ、1 つの複合識別子、6 つの状態/指標概念、5 つの契約文書、`docs/internal/domain/` の更新 4 件以上と `docs/external/*.md` の整合更新を想定する

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. `docs/internal/domain/common.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md` を主要更新対象とし、必要に応じて `docs/external/requirements.md` と `docs/external/adr.md` の用語整合も更新対象とする。
- [x] Async generation flows define `pending`、`running`、`succeeded`、`failed`、再試行、再生成、表示可否を分けて扱い、不完全な生成物をユーザーへ見せない。`Sense` を導入しても `currentImage` は新しい成功時だけ切り替え、再生成中は直前の完了済み画像を維持する。
- [x] 画像生成、解説生成、アセット保存、発音参照、単語検証はすべて external port として扱い、`Sense` 導入によってもベンダー固有実装をドメインモデルへ持ち込まない。
- [x] User stories are independently reviewable. concept boundary、sense-image mapping、文書横断整合は research / data-model / contracts で別々に検証できる。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態は別概念として維持し、`Sense` は意味単位として追加されるが評価指標へ吸収しない。
- [x] Identifier naming follows the constitution: `SenseIdentifier` と `LearningStateIdentifier` を含むすべての識別子型は `XxxIdentifier` を使い、self identifier は `identifier`、関連参照は `vocabularyExpression`、`currentImage`、`sense` のような概念名で持つ。複合識別子が必要な場合も、それを `XxxIdentifier` に閉じ込めて集約本体へ同じ参照を重複保持しない。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/vocabulary-expression-identity-contract.md`,
`contracts/concept-separation-contract.md`,
`contracts/async-visibility-contract.md`,
`contracts/domain-port-catalog.md`,
and `contracts/sense-image-mapping-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/005-domain-modeling/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── async-visibility-contract.md
│   ├── concept-separation-contract.md
│   ├── domain-port-catalog.md
│   ├── sense-image-mapping-contract.md
│   └── vocabulary-expression-identity-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/
        ├── common.md
        ├── explanation.md
        ├── learner.md
        ├── learning-state.md
        ├── service.md
        ├── visual.md
        └── vocabulary-expression.md

specs/
├── 001-complete-domain-model/
├── 003-architecture-design/
├── 004-tech-stack-definition/
└── 005-domain-modeling/
```

**Structure Decision**: 実装時の正本は `docs/internal/domain/*.md` と
`docs/external/requirements.md` / `docs/external/adr.md` に置く。`Sense` は
`Explanation` 配下の内部エンティティとして扱い、意味単位の説明責務を `Explanation`
本体から切り出す。一方で `VisualImage` は独立集約のまま維持し、必要に応じて
どの `Sense` を描写する画像かを示す。あわせて `LearningStateIdentifier` は
`learner + vocabularyExpression` を表す複合識別子として `LearningState` 集約から分離して
表現し、ownership boundary 自体は変更しない。`Explanation.currentImage` は単一 current
参照のまま維持し、複数 current image の導入は follow-on scope とする。

## Complexity Tracking

> No constitution violations identified at planning time.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
