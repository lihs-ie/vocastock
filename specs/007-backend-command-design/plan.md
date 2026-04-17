# Implementation Plan: バックエンド Command 設計

**Branch**: `007-backend-command-design` | **Date**: 2026-04-17 | **Spec**: [/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md)
**Input**: Feature specification from `/specs/007-backend-command-design/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock の backend command 境界について、登録、解説生成開始、画像生成開始、再試行/
再生成を受け付ける command 契約を定義する。登録 command は既定では解説生成開始を含む
一体 command としつつ、明示的に生成開始を抑止できる。重複登録時は既存
`VocabularyExpression` と現在状態を返し、既存状態が `not-started` または `failed`
で、かつ開始抑止がない場合だけ生成開始を再受理する。workflow dispatch に失敗した
場合は `pending` を確定せず command 全体を失敗として扱う。`Learner` /
`VocabularyExpression` の所有意味は、`docs/internal/domain/learner.md`、
`vocabulary-expression.md`、`learning-state.md` が正本化されるまで
`specs/005-domain-modeling/` を暫定 semantic source とし、その materialization と
007 の参照切替は 005-domain-modeling 側の follow-on work へ handoff する。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/service.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`、`specs/005-domain-modeling/`  
**Storage**: Git-managed repository files、設計上で参照する抽象的な command-side persistence、workflow state store、identity reference store  
**Testing**: spec / constitution / architecture / domain docs の手動クロスレビュー、command catalog review、受理条件 review、冪等性 review、失敗整合 review  
**Target Platform**: Rust command/query runtime 上の Vocabulary Command boundary、GraphQL mutation boundary、Cloud Run command service  
**Project Type**: documentation / backend application design  
**Performance Goals**: レビュー担当者が 10 分以内に主要 command の受理対象、拒否条件、即時応答を説明できること、重複登録・重複登録時の再開条件・再送・dispatch failure の扱いを 5 分以内に判定できること、実装着手前の参照文書と暫定 semantic source の終了条件を 3 分以内に辿れること  
**Constraints**: product code は追加しない、command は長時間生成を直接実行しない、未完了成果物を即時応答で返さない、登録 command は既定で解説生成開始を含むが抑止可能、同一学習者内の重複登録は既存対象を返す、重複登録時の生成再開は既存状態が `not-started` または `failed` で、かつ開始抑止がない場合に限る、workflow dispatch failure では `pending` を確定しない、外部依存は port 越しに扱う、識別子命名は憲章に従う、暫定 semantic source は 005-domain-modeling の domain docs materialization 完了後に置き換える  
**Scale/Scope**: 4 から 6 の主要 command、3 から 4 の acceptance outcome、4 つの契約文書、既存 architecture / tech stack / domain specs を横断する command design package を対象とする

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. `docs/internal/domain/common.md`、`docs/internal/domain/service.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md` を command-side rule の参照対象として扱い、`Learner` / `VocabularyExpression` の所有意味は `specs/005-domain-modeling/` を暫定 semantic source として参照する。終了条件は `docs/internal/domain/learner.md`、`vocabulary-expression.md`、`learning-state.md` の正本化と 007 の参照切替である。
- [x] Async generation flows keep `pending`、`running`、`succeeded`、`failed` と user-visible status rule を維持し、command は未完了成果物を返さない。workflow dispatch failure では `pending` を確定しない前提で整合を取る。
- [x] 英語表現検証、永続化、workflow dispatch、認証主体解決はすべて external port として扱い、domain / command 契約からベンダー固有詳細を分離する。
- [x] User stories are independently reviewable. command boundary catalog、acceptance / idempotency rule、参照文書と除外範囲は、共有語彙を Foundational へ寄せる前提で別々に確認できる。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態を混同せず、command は状態変更責務だけを扱う。
- [x] Identifier naming follows the constitution. `VocabularyExpressionIdentifier`、`ExplanationIdentifier` などの既存命名を前提にし、command 契約でも `id` / `xxxId` を採用しない。

Post-design re-check: PASS with documented exception and handoff. Verified against
`research.md`, `data-model.md`, `contracts/command-catalog-contract.md`,
`contracts/command-acceptance-contract.md`,
`contracts/command-dispatch-consistency-contract.md`, and
`contracts/command-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/007-backend-command-design/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── command-acceptance-contract.md
│   ├── command-boundary-contract.md
│   ├── command-catalog-contract.md
│   └── command-dispatch-consistency-contract.md
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
        ├── service.md
        └── visual.md

specs/
├── 003-architecture-design/
├── 004-tech-stack-definition/
├── 005-domain-modeling/
└── 007-backend-command-design/
```

**Structure Decision**: 実装時の正本は `docs/external/requirements.md`、
`docs/external/adr.md`、`docs/internal/domain/*.md` に置き、`specs/007-backend-command-design/`
は backend command 実装前提の設計パッケージとして扱う。ここでは command 一覧、
受理結果、冪等性規則、dispatch 整合、責務分離、非対象範囲を定義し、後続の plan / tasks /
implementation が query や workflow の論点を混ぜずに進められる状態を目指す。なお
`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、
`docs/internal/domain/learning-state.md` は 005 で planned source-of-truth とされているが
未実体化のため、本 feature では `specs/005-domain-modeling/` を暫定 semantic source とし、
007 独自に所有意味や一意性規則を再定義しない。exit 条件は前記 3 文書が正本として
materialize され、007 の command 設計参照が `docs/internal/domain/*.md` へ切り替わること。
この domain-doc materialization と参照切替の follow-on owner は 005-domain-modeling 側の
source-of-truth 整備作業とし、007 はその handoff 条件だけを明記する。

## Complexity Tracking

> Temporary constitution exception is documented below.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `Learner` / `VocabularyExpression` の正本が `docs/internal/domain/*.md` ではなく一部 `specs/005-domain-modeling/` に残っている | 005 が planned source-of-truth を定義したが、domain docs 本体はまだ未実体化であり、007 は learner-owned vocabulary semantics を先に参照する必要がある。終了条件は 3 つの domain docs の正本化と 007 参照の切替であり、その follow-on owner は 005-domain-modeling 側の文書整備作業である | 005 の文書実装完了まで 007 を停止すると command 設計が進まず、現時点では暫定 semantic source と handoff を明示した方が再定義リスクを抑えられる |
