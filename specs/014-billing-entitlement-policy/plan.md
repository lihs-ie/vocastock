# Implementation Plan: 課金 Product / Entitlement Policy 設計

**Branch**: `014-billing-entitlement-policy` | **Date**: 2026-04-19 | **Spec**: [/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/spec.md)
**Input**: Feature specification from `/specs/014-billing-entitlement-policy/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock の subscription 実装前提として、`010-subscription-component-boundaries` が
定義した責務境界の内側に、商品設計と entitlement / quota / gate policy の正本を
docs-first で追加する。canonical plan catalog は `free`、`standard-monthly`、
`pro-monthly` の 3 つとし、paid plan の store product ID はそれぞれ
`vocastock.standard.monthly`、`vocastock.pro.monthly` とする。`free` でも
explanation / image を少量使える一方、`standard-monthly` と `pro-monthly` は
同じ premium entitlement bundle を共有し、差分は explanation / image の月次 quota
だけに限定する。月次 quota は `free` が explanation 10 / image 3、
`standard-monthly` が explanation 100 / image 30、`pro-monthly` が
explanation 300 / image 100 とする。`grace` は paid bundle と paid quota profile を
維持し、`pending-sync` と `expired` は premium unlock を与えず free profile へ倒し、
`revoked` は hard-stop とする。pricing amount、tax、refund、coupon などの商用施策は
この feature の正本から外し、catalog / entitlement / quota / gate matrix /
state-effect matrix のみを設計 package として固定する。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/010-subscription-component-boundaries/`、`specs/011-api-command-io-design/`、`specs/012-persistence-workflow-design/`、`specs/013-flutter-ui-state-design/`、mobile storefront catalog 運用前提、backend entitlement / quota policy 前提  
**Storage**: Git-managed repository files、設計上で参照する抽象的な product catalog store、entitlement policy table、quota policy table、feature gate rule set、subscription state effect table  
**Testing**: spec / constitution / architecture の手動クロスレビュー、product catalog review、quota review、feature gate review、state-effect review、deferred-scope review、source-of-truth review  
**Target Platform**: Flutter paywall / subscription status UI、backend entitlement authority、App Store / Google Play billing catalog の logical policy layer  
**Project Type**: documentation / billing product and policy design  
**Performance Goals**: レビュー担当者が 5 分以内に canonical plan catalog と product ID 対応を説明できること、10 分以内に free / standard / pro の quota 差分と gate matrix を追跡できること、10 分以内に `grace` / `pending-sync` / `expired` / `revoked` の access policy を UI と backend の両面で説明できること  
**Constraints**: product code は追加しない、010 の subscription boundary を再定義しない、`free` でも explanation / image の両方を少量利用可能にする、paid plan は `standard-monthly` と `pro-monthly` の 2 種類に固定する、paid plan 間の差分は explanation / image の quota のみとする、quota は `free` / paid とも月次リセットにする、初期月次 quota は `free` explanation 10 / image 3、`standard-monthly` explanation 100 / image 30、`pro-monthly` explanation 300 / image 100 とする、`pending-sync` は premium unlock の根拠にしない、`grace` は paid quota profile を維持する、`expired` は free profile fallback、`revoked` は hard-stop とする、pricing amount / tax / refund / coupon / intro offer / family plan / vendor SDK detail は再定義しない  
**Scale/Scope**: 3 つの canonical plan、2 つの entitlement bundle、3 つの quota profile、7 つの feature gate key、5 つの subscription state effect、6 つの contract 文書を含む docs-first の billing policy design package を対象とする

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. 本 feature は `docs/internal/domain/*.md` の aggregate / value object / repository contract を変更せず、billing catalog と entitlement / quota / gate policy の正本だけを追加する docs-first design として扱う。
- [x] Async generation flows keep lifecycle and visibility rules. explanation / image generation の lifecycle は 012 を正本参照し、本 feature はその実行可否を quota / gate で制御するだけで、未完了生成物の非表示ルールを壊さない。
- [x] External dependencies remain behind ports/adapters. mobile storefront、purchase verification、store notification は 010 の external adapter を前提にし、本 feature は product catalog と policy table を定義するだけで vendor detail を持ち込まない。
- [x] User stories remain independently reviewable. 商品 catalog、entitlement / quota 差分、state-effect policy は別 contract と quickstart 手順で独立にレビューできる。
- [x] 学習概念を混同しない。subscription state、purchase state、entitlement、quota、feature gate decision は `Frequency`、`Sophistication`、`Proficiency`、登録状態、生成状態と統合しない。
- [x] Identifier naming follows the constitution. 新しい domain identifier は追加しないが、plan code、feature key、bundle 名、contract 名で `id` / `xxxId` を導入しない。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/product-catalog-contract.md`,
`contracts/entitlement-policy-contract.md`,
`contracts/quota-policy-contract.md`,
`contracts/feature-gate-matrix-contract.md`,
`contracts/subscription-state-effect-contract.md`, and
`contracts/billing-policy-deferred-scope-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/014-billing-entitlement-policy/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── billing-policy-deferred-scope-contract.md
│   ├── entitlement-policy-contract.md
│   ├── feature-gate-matrix-contract.md
│   ├── product-catalog-contract.md
│   ├── quota-policy-contract.md
│   └── subscription-state-effect-contract.md
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
├── 010-subscription-component-boundaries/
├── 011-api-command-io-design/
├── 012-persistence-workflow-design/
├── 013-flutter-ui-state-design/
└── 014-billing-entitlement-policy/
```

**Structure Decision**: 014 は 010 の責務境界 package を置き換えず、その内側で
運用される product catalog、entitlement bundle、quota profile、feature gate matrix、
subscription state effect を別紙で固定する設計 package として扱う。010 は
「誰が authoritative state と gate を持つか」の正本、011 は command intake と message、
012 は workflow / persistence ordering、013 は UI access policy の正本として再利用し、
014 は「どの plan が存在し」「どの quota と bundle が紐づき」「各 state で何が allow /
limited / deny になるか」だけを設計する。外部同期先は最終的に `docs/external/adr.md` と
`docs/external/requirements.md` だが、planning artifact では 014 配下に billing policy review
導線を集約する。

## Complexity Tracking

> No constitution violations requiring justification were identified.
