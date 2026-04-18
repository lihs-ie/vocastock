# Implementation Plan: Subscription Component Boundaries

**Branch**: `010-component-boundaries` | **Date**: 2026-04-19 | **Spec**: [/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md)
**Input**: Feature specification from `/specs/010-subscription-component-boundaries/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock のサブスク責務を、既存の 009 component boundary discipline と整合する
subscription boundary package として定義する。課金そのものは mobile storefront の外部境界に
置き、課金状態の最終正本は backend authoritative subscription state が持つ。app core と UI は
同期済み entitlement mirror を参照して制御し、機能解放は `Entitlement Policy` と
`Subscription Feature Gate`、利用回数や無料枠の消費判定は `Usage Metering / Quota Gate`
へ分離する。`Purchase State Model` は `initiated`、`submitted`、`verifying`、`verified`、
`rejected` を持つ canonical 受付・照合モデルとして定義し、authoritative subscription
state と分離する。`grace` は有料 entitlement を維持する一時継続状態として扱い、
restore purchase、status refresh、cross-device reconciliation は purchase verification と
store notification を介した別 workflow で定義する。外部 adapter には timeout、retry、
fallback を明示し、一時障害中も未確認 entitlement を unlock 根拠にしない。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/service.md`、`specs/007-backend-command-design/`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`  
**Storage**: Git-managed repository files、設計上で参照する抽象的な subscription state store、purchase state store、entitlement store、usage metering store、store purchase artifact / notification ingest store  
**Testing**: spec / constitution / architecture の手動クロスレビュー、subscription authority review、purchase-state review、entitlement gate review、adapter resilience review、purchase reconciliation review、deferred scope review  
**Target Platform**: Flutter paywall / subscription status UI、mobile storefront boundary、backend subscription authority、app-facing entitlement mirror、store verification / notification boundary  
**Project Type**: documentation / architecture component design  
**Performance Goals**: レビュー担当者が 5 分以内に「課金状態の正本」「機能 unlock の正本」「UI 制御責務」を説明できること、10 分以内に purchase / restore / protected feature evaluation の 3 フローを component 単位で追跡できること、5 分以内に任意の billing 変更要求を in-scope component または deferred scope へ割り当てられること  
**Constraints**: product code は追加しない、009 のオニオン分離方針と矛盾しない、課金状態の最終正本は backend 側に置く、アプリ側は同期済み entitlement mirror だけで UI 制御する、purchase state は `initiated` / `submitted` / `verifying` / `verified` / `rejected` を区別する、authoritative subscription state は `active` / `grace` / `expired` / `pending-sync` / `revoked` を区別する、`grace` 中は有料 entitlement を維持する、entitlement と usage limit の消費判定を統合しない、mobile storefront / purchase verification / store notification adapter ごとに timeout / retry / fallback を定義する、store SDK detail や pricing / tax / refund policy は再定義しない、auth/session と command semantics の既存正本を上書きしない、識別子命名は憲章に従う  
**Scale/Scope**: 6 つの boundary group、3 つの inner policy component、15 の canonical subscription component、2 つの canonical state model、3 つの主要フロー、5 つの contract 文書を含む docs-first の billing boundary design package を対象とする

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. 本 feature は `docs/internal/domain/*.md` を terminology source として参照するが、aggregate、value object、repository contract 自体は変更しない。subscription / billing component の責務境界のみを整理する docs-first feature として扱う。
- [x] Async generation flows keep lifecycle and visibility rules. 本 feature は解説生成や画像生成の workflow 自体を再定義せず、billing gate が既存の完了結果のみ公開ルールを壊さない前提で設計する。subscription reconciliation は別 workflow として扱うが、生成物の visibility rule は変更しない。
- [x] External dependencies remain behind ports/adapters. mobile storefront、purchase verification、store notification は external adapter として整理し、domain や UI へ vendor detail を持ち込まない。憲章の要件に従い、timeout、retry、障害時 fallback を plan と contract に明示する。
- [x] User stories are independently reviewable. 課金責務の正本整理、unlock / quota 分離、deferred scope 固定はそれぞれ別の成果物レビューで確認できる。
- [x] 学習概念を混同しない。purchase state、subscription state、entitlement、feature gate decision、usage limit は `Frequency`、`Sophistication`、`Proficiency`、登録状態、生成状態と統合しない。
- [x] Identifier naming follows the constitution. 本 feature は新しい domain identifier を追加しないが、参照する用語と contract 名では `XxxIdentifier` / `identifier` / 概念名参照の規約を崩さない。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/subscription-topology-contract.md`,
`contracts/subscription-authority-contract.md`,
`contracts/entitlement-gate-contract.md`,
`contracts/purchase-reconciliation-contract.md`, and
`contracts/subscription-deferred-scope-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/010-subscription-component-boundaries/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── entitlement-gate-contract.md
│   ├── purchase-reconciliation-contract.md
│   ├── subscription-authority-contract.md
│   ├── subscription-deferred-scope-contract.md
│   └── subscription-topology-contract.md
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
        └── service.md

specs/
├── 007-backend-command-design/
├── 008-auth-session-design/
├── 009-component-boundaries/
└── 010-subscription-component-boundaries/
```

**Structure Decision**: 010 は 009 の product-wide component boundary 正本を置き換えず、
その内側 / 外側分離を再利用した subscription-specific boundary package として扱う。
component taxonomy の最終的な外部同期先は `docs/external/adr.md` と
`docs/external/requirements.md` だが、本 feature の planning artifact では
`specs/010-subscription-component-boundaries/` に設計判断と review 導線をまとめる。
auth/session の behavioral contract は `specs/008-auth-session-design/`、
command semantics と retry / regenerate rule は `specs/007-backend-command-design/`、
既存の product-wide component taxonomy は `specs/009-component-boundaries/` を正本参照とし、
010 では billing-specific component、purchase state model、authority rule、adapter resilience、
gate rule、deferred scope だけを定義する。

## Complexity Tracking

> No constitution violations requiring justification were identified.
