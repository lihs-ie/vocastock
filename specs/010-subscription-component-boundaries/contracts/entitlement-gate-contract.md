# Contract: Entitlement And Gate Separation

## Purpose

subscription state、entitlement、feature gate、usage quota を別責務として固定する。

## Role Separation

| Component | Primary Responsibility | Must Not Decide |
|-----------|------------------------|-----------------|
| `Entitlement Policy` | plan と authoritative subscription state から権限集合を導出する | usage 消費、purchase verification |
| `Subscription Feature Gate` | entitlement と feature key から allow / limited / deny を決定する | store verification、quota 集計 |
| `Usage Metering / Quota Gate` | 利用量、無料枠、期間上限を評価する | plan 由来の paid entitlement 付与 |
| `Subscription Feature Gate Reader` | app core / UI 向けに gate result を返す | entitlement 自体の再計算 |

## Decision Pipeline

1. authoritative subscription state を更新する
2. `Entitlement Policy` が entitlement set を導出する
3. `Subscription Feature Gate` が feature ごとの unlock 方針を決定する
4. `Usage Metering / Quota Gate` が利用量制限を適用する
5. `Subscription Feature Gate Reader` が app-facing decision を返す

## Gate Rules

- feature unlock は confirmed entitlement に対してのみ行う
- `pending-sync` は feature unlock の根拠に使ってはならない
- `grace` は paid entitlement を維持するため、通常の premium gate を継続してよい
- quota 枯渇時は entitlement が有効でも `limited` または `deny` を返しうる

## Example Outcomes

| Subscription State | Entitlement | Quota | Feature Gate Outcome |
|--------------------|-------------|-------|----------------------|
| `active` | premium | remaining | `allow` |
| `grace` | premium | remaining | `allow` |
| `active` | premium | exhausted | `limited` or `deny` |
| `pending-sync` | none confirmed | any | `deny` |
| `expired` | free only | remaining free quota | `limited` or `deny` |

## Invariants

- `Entitlement` と `Usage Metering / Quota Gate` の責務を 1 つの `isPremium` フラグへ潰してはならない
- UI local state だけで premium unlock を決めてはならない
- quota の消費履歴は paid / free の判定根拠ではなく、usage execution 可否の判定根拠として扱う
