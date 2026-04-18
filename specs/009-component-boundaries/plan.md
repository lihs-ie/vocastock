# Implementation Plan: 機能別コンポーネント定義

**Branch**: `010-component-boundaries` | **Date**: 2026-04-17 | **Spec**: [/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md)
**Input**: Feature specification from `/specs/009-component-boundaries/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock の既存コンポーネント一覧を、フラットな機能名の列挙ではなく、オニオン
アーキテクチャを主軸にした component boundary package へ再編する。内側の
`Domain Core` と `Application Coordination` は top-level 責務一覧と分離した基盤として
扱い、外側の top-level 責務は `Presentation`、`Actor/Auth Boundary`、
`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` に固定する。
`auth/session` は outer boundary として分離し、長時間処理である `Explanation generation`
と `Image generation` は `Async Generation` 配下の別 workflow component として定義する。
あわせて、現在の一覧に不足している `Actor Session Handoff`、`Visual Image Reader`、
`Generation Status Reader`、`Asset Access Adapter` などを追加し、request acceptance /
workflow orchestration / result reading / external adapter の責務差分を contract として
固定したうえで、最終的な canonical topology と allocation を
`/Users/lihs/workspace/vocastock/docs/external/adr.md` の「コンポーネント」節へ同期する。
`/Users/lihs/workspace/vocastock/docs/external/requirements.md` は source-of-truth 参照導線の
同期対象とし、`docs/internal/domain/*.md` は用語 cross-check のみを行い、domain semantics
自体は変更しない。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`、`specs/007-backend-command-design/`、`specs/008-auth-session-design/`  
**Storage**: Git-managed repository files、設計上で参照する抽象的な command state store、query read store、asset store、auth/session boundary outputs  
**Testing**: spec / constitution / architecture の手動クロスレビュー、component allocation review、flow tracing review、deferred scope review、dependency direction review  
**Target Platform**: Flutter client UI、GraphQL command/query entry、auth/session boundary handoff、非同期 explanation/image workflow、外部 validation / generation / storage / media adapter boundary  
**Project Type**: documentation / architecture component design  
**Performance Goals**: レビュー担当者が 5 分以内に top-level 責務 6 分類を説明できること、10 分以内に登録・解説閲覧・画像生成の 3 フローを component 単位で追跡できること、3 分以内に任意の変更要求を in-scope component または deferred scope へ割り当てられること  
**Constraints**: product code は追加しない、主軸はオニオンアーキテクチャとする、`Domain Core` と `Application Coordination` は内側基盤として別枠で扱う、`auth/session` は outer boundary として分離する、`Explanation generation` と `Image generation` は別 workflow とする、未完了生成物を user-visible result として扱わない、vendor 固有詳細は external adapter の外へ漏らさない、既存の auth/session と backend command feature が持つ責務を再定義しない、識別子命名は憲章に従う、domain docs は terminology cross-check のみとし semantics を再定義しない  
**Scale/Scope**: 6 つの top-level 責務、2 つの内側基盤レイヤ、12 から 16 の canonical component、3 つの主要 user flow、5 つの contract 文書に加え、`/Users/lihs/workspace/vocastock/docs/external/adr.md` の component 正本更新と `/Users/lihs/workspace/vocastock/docs/external/requirements.md` の source-of-truth 参照同期を含む docs-first の boundary design package を対象とする

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. 本 feature は `docs/internal/domain/*.md` を terminology source として cross-check するが、aggregate、value object、repository contract 自体は変更しない。コンポーネント境界のみを再編し、domain semantics は更新しない docs-first feature として扱う。
- [x] Async generation flows keep lifecycle and visibility rules. `Explanation generation` と `Image generation` は request acceptance、workflow execution、result reading を分離し、完了済み結果以外を UI 公開しない前提で contract 化する。
- [x] External dependencies remain behind ports/adapters. validation、generation provider、asset storage、asset access、pronunciation media は external adapter として整理し、domain や UI へ vendor detail を持ち込まない。
- [x] User stories are independently reviewable. 現行一覧の棚卸し、責務分離、deferred scope の境界固定は、それぞれ別の成果物レビューで確認できる。
- [x] 学習概念を混同しない。frequency、sophistication、proficiency、登録状態、解説生成状態、画像生成状態は component 定義によって統合せず、read-side と async workflow の責務分離でも区別を維持する。
- [x] Identifier naming follows the constitution. 本 feature は新しい domain identifier を追加しないが、参照する既存用語と contract 名では `XxxIdentifier` / `identifier` / 概念名参照の規約を崩さない。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/architecture-topology-contract.md`,
`contracts/component-allocation-contract.md`,
`contracts/actor-boundary-contract.md`,
`contracts/async-generation-boundary-contract.md`, and
`contracts/deferred-scope-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/009-component-boundaries/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── actor-boundary-contract.md
│   ├── architecture-topology-contract.md
│   ├── async-generation-boundary-contract.md
│   ├── component-allocation-contract.md
│   └── deferred-scope-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
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
        ├── learner.md
        ├── learning-state.md
        ├── service.md
        ├── visual.md
        └── vocabulary-expression.md

specs/
├── 003-architecture-design/
├── 004-tech-stack-definition/
├── 007-backend-command-design/
├── 008-auth-session-design/
└── 009-component-boundaries/
```

**Structure Decision**: 最終的なプロダクト横断の component definition 正本は
`docs/external/adr.md` の「コンポーネント」節とし、本 feature では
`specs/009-component-boundaries/` を設計パッケージ兼レビュー導線として整備したうえで、
確定した canonical topology と allocation を ADR へ同期する。併せて
`docs/external/requirements.md` では component-boundary の source-of-truth 参照導線だけを
更新する。用語の正本は `docs/internal/domain/*.md` に置き、`auth/session` の責務境界は
`specs/008-auth-session-design/`、command intake と retry / dispatch semantics は
`specs/007-backend-command-design/` を参照する。009 では、それらの既存正本を
置き換えずに、component taxonomy、dependency direction、current-list allocation、
deferred scope の整理と外部文書への同期だけを担う。domain docs は terminology
cross-check の対象に留め、意味論は変更しない。

## Complexity Tracking

> No constitution violations requiring justification were identified.
