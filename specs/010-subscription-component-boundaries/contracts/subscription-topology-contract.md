# Contract: Subscription Topology

## Purpose

subscription component を 009 の product-wide taxonomy に沿って配置し、どの責務を
billing package が持つかを固定する。

## Top-Level Boundary Groups

| Boundary Group | Owns | Must Not Own |
|----------------|------|--------------|
| `Presentation` | paywall、subscription status、upsell、pending / revoked / expired の状態表示 | authoritative subscription state、verification、quota 消費 |
| `Actor/Auth Boundary` | actor reference の handoff | auth lifecycle、purchase verification |
| `Command Intake` | purchase artifact 提出、restore 要求、status refresh 要求の受付 | paid unlock の最終確定、UI rendering |
| `Query Read` | subscription status、entitlement mirror、usage allowance、feature gate result の返却 | purchase artifact 受付、verification 実行 |
| `Async Subscription Reconciliation` | verification、notification ingest、authoritative state 更新 | paywall 表示、product policy UI |
| `External Adapters` | storefront、verification API、notification source との接続 | entitlement policy、quota policy、feature gate 判定 |

## Canonical Component Allocation

| Component | Boundary Group | Notes |
|-----------|----------------|-------|
| `Subscription Paywall UI` | `Presentation` | purchase 開始導線と upsell 表示 |
| `Subscription Status UI` | `Presentation` | state / entitlement / quota 表示 |
| `Actor Session Handoff` | `Actor/Auth Boundary` | 008 の auth/session 正本を再利用する依存 component |
| `Purchase Result Intake` | `Command Intake` | storefront 完了後の artifact 提出受付 |
| `Restore Purchase Intake` | `Command Intake` | restore 開始要求受付 |
| `Subscription Status Refresh Intake` | `Command Intake` | status refresh / cross-device 再同期の起点 |
| `Subscription Status Reader` | `Query Read` | authoritative state の app-facing read |
| `Entitlement Reader` | `Query Read` | synced entitlement mirror の read |
| `Usage Allowance Reader` | `Query Read` | quota 状態の read |
| `Subscription Feature Gate Reader` | `Query Read` | app core / UI 向け gate decision の read |
| `Purchase Verification Workflow` | `Async Subscription Reconciliation` | purchase artifact の照合と state 更新 |
| `Store Notification Reconciliation Workflow` | `Async Subscription Reconciliation` | server notification による state / entitlement 再計算 |
| `Mobile Storefront Adapter` | `External Adapters` | App Store / Google Play 接続 |
| `Purchase Verification Adapter` | `External Adapters` | receipt / token 検証接続 |
| `Store Notification Adapter` | `External Adapters` | store notification の受信と正規化 |

## Inner Policy Components

次の 3 つは top-level boundary group とは別に、内側基盤の policy として扱う。

| Policy | Role |
|--------|------|
| `Entitlement Policy` | authoritative subscription state と plan から解放権限を導出する |
| `Subscription Feature Gate` | entitlement と feature key から allow / limited / deny を決定する |
| `Usage Metering / Quota Gate` | 利用回数、期間上限、無料枠消費を評価する |

## Dependency Direction

1. `Presentation` は `Query Read` の結果を表示してよいが、`Async Subscription Reconciliation` を直接呼び出してはならない
2. `Command Intake` は `External Adapters` を直接 ownership せず、workflow 起動要求だけを行う
3. `Async Subscription Reconciliation` は adapter を使って authoritative state を更新してよいが、UI 向け read model を直接返してはならない
4. `Query Read` は authoritative source から導出された state / mirror / gate result だけを返し、verification を開始してはならない
5. `External Adapters` は timeout、retry、fallback を持ってよいが、未確認 entitlement の unlock を決めてはならない

## Invariants

- product-wide taxonomy の正本は引き続き 009 にあり、010 は subscription-specific package として追加される
- subscription package は auth/session、command semantics、pricing policy の正本を置き換えてはならない
- `Presentation` で利用する entitlement mirror は backend authority から同期済みでなければならない
