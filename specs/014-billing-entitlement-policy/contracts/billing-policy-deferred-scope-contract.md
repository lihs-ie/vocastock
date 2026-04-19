# Contract: Billing Policy Deferred Scope

## Purpose

014 が ownership を持たない商用 / 外部境界 concern を明示する。

## Deferred Items

| Concern | Source Of Truth | Reason |
|---------|-----------------|--------|
| pricing amount / currency | store catalog / business operation | 商用施策であり 014 の policy package 外 |
| tax / invoicing | finance policy / store policy | 会計ルールは別 concern |
| refund policy | support policy / store policy | access policy とは別の運用判断 |
| coupon / intro offer | future billing feature | 初期 catalog を複雑化しないため |
| family plan / annual plan | future product feature | 初期 plan catalog を 3 つに固定するため |
| vendor SDK detail | 010 external adapters / implementation | adapter boundary は既に 010 で固定済み |
| exact paywall copy | 013 UI state / future UI implementation | 014 は policy 正本であり文言正本ではない |

## In-Scope vs Deferred Boundary

- 014 が持つのは `plan catalog`、`entitlement bundle`、`quota profile`、`feature gate matrix`、`subscription state effect`
- 014 が持たないのは pricing、tax、refund、campaign、SDK 実装、workflow runtime detail

## Invariants

- deferred concern を 014 の contract へ流し込んではならない
- in-scope concern と deferred concern で同じ policy を二重定義してはならない
