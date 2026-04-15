# Implementation Plan: ドメインモデリング

**Branch**: `005-domain-modeling` | **Date**: 2026-04-16 | **Spec**: [/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md)
**Input**: Feature specification from `/specs/005-domain-modeling/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock プロジェクト全体のドメインを、`Learner` を所有境界、`VocabularyExpression` を
学習者が所有する登録対象として再整理する。単語と連語は同一の `VocabularyExpression`
概念で扱い、`Explanation` は現在表示中の解説参照、`VisualImage` は履歴を保持する独立集約、
`LearningState` は習熟度専用集約として設計する。あわせて、`VocabularyExpression*` /
`LearningState*` 命名、完了済み結果のみ表示する非同期規則、外部 identity を含む port 境界を
project-wide の source of truth に落とし込める設計成果物を生成する。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`  
**Storage**: Git-managed repository files、設計上で参照する抽象的な learner store、explanation store、image asset store  
**Testing**: spec / constitution / ADR / domain docs の手動クロスレビュー、所有境界レビュー、一意性レビュー、状態遷移レビュー、識別子命名レビュー  
**Target Platform**: Flutter client、Rust command/query runtime、Haskell workflow runtime をまたぐ project-wide domain language  
**Project Type**: documentation / domain design  
**Performance Goals**: レビュー担当者が 5 分以内に主要概念、所有境界、不変条件を説明できること、非同期状態とユーザー表示ルールを 5 分以内に判定できること、source-of-truth 文書の参照先を 3 分以内に辿れること  
**Constraints**: product code は追加しない、完了済み結果のみをユーザーへ表示する、頻出度・知的度・習熟度・登録状態・解説生成状態・画像生成状態を統合しない、`Learner` は独立集約、`VocabularyExpression` は学習者所有、重複判定は同一学習者内で行う、`VisualImage` は独立集約として履歴を保持する、認証そのものは外部責務として扱う、外部依存はポート越しに接続する、派生命名は `VocabularyExpression*` / `LearningState*` に統一する、識別子命名は憲章に従う  
**Scale/Scope**: 5 つの中心集約、6 つの状態/指標概念、4 つの契約文書、`docs/internal/domain/` の新規追加 3 件と更新 4 件を想定する

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. `docs/internal/domain/common.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/service.md`、`docs/internal/domain/visual.md` を更新対象とし、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md` を新規 source-of-truth 候補として扱う。
- [x] Async generation flows define `pending`、`running`、`succeeded`、`failed`、再試行、再生成、表示可否を分けて扱い、不完全な生成物をユーザーへ見せない。再生成中も直前の完了済み `currentExplanation` / `currentImage` は保持し、新しい成功時だけ参照を切り替える。
- [x] 単語検証、重複登録判定、学習者 identity 解決、解説生成、画像生成、アセット保存、発音参照はすべて external port として扱い、ドメインモデルへベンダー固有実装を持ち込まない。
- [x] User stories are independently reviewable. project-wide scope、非同期表示、文書横断整合は research / data-model / contracts で別々に検証できる。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態は別概念として維持し、どれも代替概念として扱わない。
- [x] Identifier naming follows the constitution: `LearnerIdentifier`、`VocabularyExpressionIdentifier`、`ExplanationIdentifier`、`VisualImageIdentifier`、`LearningStateIdentifier` を使い、self identifier は `identifier`、関連参照は `learner`、`vocabularyExpression`、`currentImage` のような概念名で持つ。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/vocabulary-expression-identity-contract.md`,
`contracts/concept-separation-contract.md`,
`contracts/async-visibility-contract.md`,
and `contracts/domain-port-catalog.md`.

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
        ├── learner.md                 # planned source-of-truth
        ├── learning-state.md          # planned source-of-truth
        ├── service.md
        ├── visual.md
        └── vocabulary-expression.md   # planned source-of-truth

specs/
├── 001-complete-domain-model/
├── 003-architecture-design/
├── 004-tech-stack-definition/
└── 005-domain-modeling/
```

**Structure Decision**: 実装時の正本は `docs/internal/domain/*.md` と
`docs/external/requirements.md` / `docs/external/adr.md` に置く。`specs/005-domain-modeling/`
は、project-wide なドメイン再整理の根拠、所有境界、状態契約、ポート契約、review 導線を
保持する設計パッケージとして扱う。`Learner`、`VocabularyExpression`、`LearningState`
を独立した source-of-truth に切り出し、現行の `Explanation` / `VisualImage` 中心の記述を
学習者所有の登録対象中心へ移行する。

## Complexity Tracking

> No constitution violations identified at planning time.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
