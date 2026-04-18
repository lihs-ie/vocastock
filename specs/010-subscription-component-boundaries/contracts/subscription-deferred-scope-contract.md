# Contract: Subscription Deferred Scope

## Purpose

今回の feature が ownership を持つ領域と、別 feature または外部境界へ委譲する領域を固定する。

## In Scope

- subscription-specific component taxonomy
- authoritative subscription state と entitlement mirror の責務分離
- `Entitlement Policy`、`Subscription Feature Gate`、`Usage Metering / Quota Gate` の役割分離
- purchase / restore / refresh / notification reconciliation の boundary 定義
- UI が参照する subscription status、entitlement、quota decision の app-facing read 責務

## Deferred To Existing Source Of Truth

| Concern | Source Of Truth | Reason |
|---------|-----------------|--------|
| auth / account / session lifecycle | `/Users/lihs/workspace/vocastock/specs/008-auth-session-design/` | 010 では actor handoff 接点だけを使う |
| protected feature の command semantics | `/Users/lihs/workspace/vocastock/specs/007-backend-command-design/` | billing gate は前段判定のみを扱う |
| product-wide component taxonomy | `/Users/lihs/workspace/vocastock/specs/009-component-boundaries/` | 010 は subscription-specific package である |

## Deferred To External Boundary Or Future Implementation

| Concern | Source Of Truth | Reason |
|---------|-----------------|--------|
| pricing catalog | mobile storefront / product business policy | component boundary feature で固定しない |
| tax / refund policy | mobile storefront / legal-operational policy | store policy と運用判断の領域 |
| vendor SDK detail | future implementation | adapter の存在だけを定義し、SDK 選定は実装時に決める |
| store-specific dashboard setup | App Store Connect / Play Console | product architecture 文書ではなく運用設定 |

## Guardrails

- in-scope component が pricing / tax / refund rule を再定義してはならない
- 010 は 008、007、009 の正本を上書きしてはならない
- deferred concern を理由なく `UI` や `Feature Gate` に取り込んではならない
