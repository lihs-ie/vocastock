# Contract: Billing Worker Runtime Boundary

## Purpose

023 で実装する `billing-worker` runtime surface と scope 外を固定する。

## In Scope

| Concern | Scope |
|---------|-------|
| worker runtime | Haskell long-running consumer |
| stable-run contract | `long-running consumer` を canonical success signal とする |
| workflow state machine | purchase verification workflow + notification reconciliation workflow |
| purchase verification adapter | `PurchaseVerificationPort` 越しの caller-owned adapter |
| subscription authority adapter | `SubscriptionAuthorityPort` 越しの authoritative state update adapter |
| entitlement recalculation | `EntitlementRecalcPort` による subscription state → entitlement bundle + quota profile 導出 |
| store notification adapter | `NotificationPort` 越しの normalized notification intake adapter |
| persistence | completed `BillingRecord` 保存と `Subscription.currentEntitlementSnapshot` handoff port |
| testing | Haskell unit mirror + Haskell feature suite with Docker / Firebase emulator |
| runtime validation | `docker/applications/billing-worker/`、compose、local stack validation |

## Out Of Scope

| Concern | Why Deferred |
|---------|--------------|
| public HTTP / GraphQL endpoint | worker boundary ではない |
| internal HTTP surface (Servant) | canonical success signal は stable-run で足り、pull-based consumer に HTTP layer は不要 |
| restore workflow | 012 に別 runtime trace あり、後続 slice に分離 |
| `query-api` の read projection 実装変更 | query visibility の正本は 017 に属する |
| `explanation-worker` / `image-worker` | 別 worker responsibility |
| store product catalog 管理 / pricing change / tax / intro offer / coupon / family plan | 014 の scope 外、商用施策は別 feature |
| Apple / Google 固有 SDK 実 adapter | port contract のみで足り、実 adapter は Production 導入フェーズ |
| provider 固有最適化 | initial slice の scope 外 |
| public schema 拡張 | gateway / API feature の責務 |

## Rules

- worker は confirmed entitlement snapshot を直接 user-facing response として返してはならない
- 外向き HTTP endpoint を必須にしてはならない
- pull-based stable-run 以外の canonical success signal (HTTP readiness、push-based RPC 等) を worker に持ち込まない
- worker container の canonical success signal は queue / subscription 待受プロセスとしての stable-run である
- runtime 追加後も 016 の container smoke 契約と矛盾してはならない
- runtime validation は `success`、`retryable-failure`、`terminal-failure`、`notification-reconciled` を別 record として
  `application-container-smoke.summary` に残し、local stack validation から再利用できなければならない
