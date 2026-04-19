# Implementation Plan: 永続化 / Read Model と非同期 Workflow 設計

**Branch**: `012-persistence-workflow-design` | **Date**: 2026-04-19 | **Spec**: [/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/spec.md)
**Input**: Feature specification from `/specs/012-persistence-workflow-design/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock の実装前提として、aggregate ごとの authoritative persistence allocation、
app-facing read projection、非同期 workflow runtime state machine を docs-first で固定する。
対象は `Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、
`VisualImage`、authoritative subscription state、purchase state、entitlement、
usage allowance、command idempotency record、workflow attempt record であり、
保存境界、一意制約、主 lookup 軸、主要 index、ownership を整理する。あわせて
explanation 生成、image 生成、purchase verification、restore、notification
reconciliation について、runtime state、retry 条件、timeout、fallback、
dead-letter 相当、partial success 非許容を state machine と projection ルールに分離して定義する。
007 の command semantics、008 の actor handoff、009 の component boundary、
010 の subscription authority、011 の command I/O contract を正本参照とし、物理 DB / queue /
cache 製品や vendor SDK detail は deferred scope に置く。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md`、`specs/007-backend-command-design/`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/`、`specs/011-api-command-io-design/`  
**Storage**: Git-managed repository files、設計上で参照する抽象的な learner store、vocabulary expression store、learning state store、explanation store、visual image store、subscription authority store、purchase state store、entitlement snapshot store、usage allowance store、workflow runtime state store、dead-letter review store、read projection store  
**Testing**: spec / constitution / architecture の手動クロスレビュー、persistence allocation review、read projection review、workflow state-machine review、retry / timeout / fallback review、dead-letter review、deferred-scope review  
**Target Platform**: Flutter app-facing read surface、Rust command/query runtime、非同期 explanation/image workflow runner、backend subscription reconciliation boundary、GraphQL / HTTP query surface 前段の read model  
**Project Type**: documentation / persistence and workflow runtime design  
**Performance Goals**: レビュー担当者が 10 分以内に主要 aggregate / state の保存先、一意制約、主要 index を説明できること、10 分以内に 5 つの workflow の state 遷移と retry / timeout / fallback / dead-letter 方針を説明できること、5 分以内に stale read・partial success・`pending-sync`・`grace` の扱いを判定できること  
**Constraints**: product code は追加しない、物理 DB / queue / cache 製品は選定しない、authoritative write と read projection を分離する、runtime state は domain-facing status と混同しない、completed result だけを user-facing read model に公開する、partial success を completed として扱わない、各 external adapter の timeout / retry / fallback を state machine に反映する、retry exhaustion 後の dead-letter 相当を operator review 用終端として持つ、007 / 008 / 009 / 010 / 011 の既存正本を上書きしない、識別子命名は憲章に従う  
**Scale/Scope**: 10 から 12 の authoritative persistence allocation、5 つの workflow state machine、5 つの read projection 群、5 つの contract 文書を含む docs-first の persistence / runtime design package を対象とする

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. 本 feature は `docs/internal/domain/*.md` を terminology source として参照し、aggregate semantics 自体は変更しない。永続化 allocation、read projection、workflow runtime を docs-first で定義し、domain docs 更新は不要と明記する。
- [x] Async generation flows define lifecycle and visible result rules. explanation / image 生成、および課金同期 workflow は retry、timeout、fallback、dead-letter 相当を含む runtime state を持つが、user-visible read model には completed result と status-only 情報だけを返す。
- [x] External dependencies remain behind ports/adapters. validation、generation provider、asset storage、mobile storefront、purchase verification、store notification は既存 port / adapter 境界の外で扱い、012 では persistence と runtime expectation だけを定義する。
- [x] User stories remain independently reviewable. persistence allocation、workflow state machine、deferred boundary は別 artifact として確認できる。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態、purchase state、subscription state、entitlement を混同しない。runtime state は domain-facing status と別概念で管理する。
- [x] Identifier naming follows the constitution. 識別子型は `XxxIdentifier` を前提にし、store record と read projection の関連参照も `learner`、`vocabularyExpression`、`explanation`、`sense`、`actor` のように概念名で扱う。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/persistence-allocation-contract.md`,
`contracts/read-model-assembly-contract.md`,
`contracts/generation-workflow-state-machine-contract.md`,
`contracts/subscription-workflow-state-machine-contract.md`, and
`contracts/persistence-runtime-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/012-persistence-workflow-design/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── generation-workflow-state-machine-contract.md
│   ├── persistence-allocation-contract.md
│   ├── persistence-runtime-boundary-contract.md
│   ├── read-model-assembly-contract.md
│   └── subscription-workflow-state-machine-contract.md
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
        ├── learner.md
        ├── vocabulary-expression.md
        ├── learning-state.md
        ├── explanation.md
        ├── visual.md
        └── service.md

specs/
├── 007-backend-command-design/
├── 008-auth-session-design/
├── 009-component-boundaries/
├── 010-subscription-component-boundaries/
├── 011-api-command-io-design/
└── 012-persistence-workflow-design/
```

**Structure Decision**: 012 は product code の永続化実装や workflow 実装を直接追加する feature ではなく、
その前提となる authoritative persistence allocation、read projection assembly、workflow runtime
state machine を定義する設計パッケージとして扱う。command semantics は 007、actor handoff は 008、
component placement は 009、subscription authority は 010、command I/O shape は 011 を正本参照し、
012 はどこへ保存するか、どの projection を公開するか、どの runtime state と recovery rule を持つかだけを
固定する。最終的な product-wide architecture メモは `docs/external/adr.md` と
`docs/external/requirements.md` へ同期する前提だが、planning artifact では 012 配下に review 導線を集約する。

## Complexity Tracking

> No constitution violations requiring justification were identified.
