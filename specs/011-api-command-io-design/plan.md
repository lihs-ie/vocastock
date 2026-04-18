# Implementation Plan: API / Command I/O 設計

**Branch**: `011-api-command-io-design` | **Date**: 2026-04-19 | **Spec**: [/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/spec.md)
**Input**: Feature specification from `/specs/011-api-command-io-design/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock の backend command 実装へ進む前提として、`007-backend-command-design` が定義した
command semantics を transport 非依存の canonical I/O contract へ落とし込む。対象は
`registerVocabularyExpression`、`requestExplanationGeneration`、
`requestImageGeneration`、`retryGeneration` の 4 command であり、共通 request envelope、
success response envelope、error code catalog、actor handoff input、idempotency rule、
duplicate reuse shape、visible state summary を固定する。completed actor handoff は
`actor reference`、`session reference`、`auth account reference` を最小 shape とし、
`idempotencyKey` は actor 単位で一意に扱う。`retryGeneration` は retry / regenerate を
明示 mode で区別し、success / error の両方で必須の user-facing `message` を返す。
auth/session の completed handoff は `008-auth-session-design`、component boundary は
`009-component-boundaries`、subscription / entitlement visibility は
`010-subscription-component-boundaries` を正本参照とし、workflow payload、query schema、
provider detail、transport binding は deferred scope に置く。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md`、`specs/007-backend-command-design/`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/`  
**Storage**: Git-managed repository files、設計上で参照する抽象的な actor handoff output、command request log、actor-scoped idempotency store、workflow state store  
**Testing**: spec / constitution / architecture の手動クロスレビュー、request DTO review、response DTO review、error code review、idempotency review、boundary / deferred scope review  
**Target Platform**: Flutter client からの protected operation intake、GraphQL / HTTP mutation binding の前段となる backend command boundary、Rust command service  
**Project Type**: documentation / backend API design  
**Performance Goals**: レビュー担当者が 10 分以内に 4 command の request / success response shape を対応付けられること、5 分以内に ownership mismatch / not-ready / dispatch failure / idempotency conflict の返却規則を判定できること、3 分以内に visible summary、必須 `message`、internal-only detail の境界を説明できること  
**Constraints**: product code は追加しない、transport 非依存 contract とする、completed actor handoff は `actor reference` / `session reference` / `auth account reference` を最小 shape とする、`idempotencyKey` は actor 単位で一意に扱う、`retryGeneration` は retry / regenerate mode を明示する、success / error ともに `message` を必須にする、raw token / provider credential / session secret を request に含めない、未完了 payload を response に含めない、dispatch failure 時は `pending` success を返さない、`startExplanation = false` は登録 command にのみ許可する、`pending-sync` は状態表示してよいが premium unlock 確定情報として返さない、workflow payload / provider detail / query schema / persistence schema は再定義しない、識別子命名は憲章に従う  
**Scale/Scope**: 4 つの canonical command、8 つの設計エンティティ、6 つの contract 文書、4 つの prerequisite feature、5 つの deferred concern を含む docs-first の command I/O design package を対象とする

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. 本 feature は `docs/internal/domain/*.md` を terminology source として参照するが、aggregate、value object、repository contract 自体は変更しない。command 実装が参照する I/O 契約だけを docs-first で固定する。
- [x] Async generation visibility rule is preserved. command response は受理結果、target 参照、状態要約、必須 `message` だけを返し、未完了解説や未完了画像 payload を返さない。dispatch failure 時は success 扱いにせず、`pending` の見せかけ確定を禁止する。
- [x] External dependencies remain behind ports/adapters. actor handoff は 008、workflow dispatch と command semantics は 007、component allocation は 009、subscription / entitlement visibility は 010 の外部境界として参照し、vendor detail や transport detail を 011 に持ち込まない。
- [x] User stories are independently reviewable. request / response shape、error / idempotency rule、boundary / deferred scope は別 artifact として独立レビューできる。
- [x] Registration、Explanation、Image、subscription / entitlement の各状態概念は分離したまま扱い、command I/O では state summary と internal detail を混同しない。
- [x] Identifier naming follows the constitution. 識別子型は `XxxIdentifier` を前提にし、field 名では `vocabularyExpression`、`explanation`、`sense`、`actor` のように概念名で参照する。`id` / `xxxId` / `xxxIdentifier` は採用しない。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/command-request-envelope-contract.md`,
`contracts/command-response-envelope-contract.md`,
`contracts/command-error-contract.md`,
`contracts/actor-handoff-contract.md`,
`contracts/command-idempotency-contract.md`, and
`contracts/command-io-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/011-api-command-io-design/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── actor-handoff-contract.md
│   ├── command-error-contract.md
│   ├── command-idempotency-contract.md
│   ├── command-io-boundary-contract.md
│   ├── command-request-envelope-contract.md
│   └── command-response-envelope-contract.md
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
└── 011-api-command-io-design/
```

**Structure Decision**: 011 は 007 の command semantics を置き換える feature ではなく、
その実装着手前提となる canonical I/O contract package として扱う。command 名、受理条件、
duplicate reuse、dispatch failure rule は 007 を正本参照し、actor handoff の completed
output は 008、command intake の配置は 009、subscription / entitlement visibility は 010 を
引き継ぐ。011 が新たに固定するのは request envelope、success response、error code、
actor-scoped idempotency、mandatory `message`、retry / regenerate mode、visible summary、
deferred scope のみであり、HTTP / GraphQL / RPC binding、workflow payload、
provider adapter detail、query response は別 feature へ委ねる。

## Complexity Tracking

> No constitution violations requiring justification were identified.
