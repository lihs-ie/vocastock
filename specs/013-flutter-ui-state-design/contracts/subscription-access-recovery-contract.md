# Contract: Subscription Access And Recovery

## Purpose

subscription state ごとの screen access policy と recovery flow を固定する。

## Access Policy Matrix

| Subscription State | App Shell Access | Completed Result Access | Premium Action Access | Recovery Entry |
|--------------------|------------------|-------------------------|-----------------------|----------------|
| `active` | allow | allow | allow | `SubscriptionStatus` |
| `grace` | allow | allow | allow | `SubscriptionStatus` |
| `pending-sync` | allow | allow | limited | `SubscriptionStatus` |
| `expired` | allow | allow | deny -> `Paywall` | `SubscriptionStatus` |
| `revoked` | deny -> `RestrictedAccess` | deny outside recovery flow | deny | `RestrictedAccess` |

## Recovery Flow Matrix

| Flow | Start Screen | Progress Surface | Success Target | Failure Target |
|------|--------------|------------------|----------------|----------------|
| `restore` | `SubscriptionStatus` | `status-only` | previous shell screen | `SubscriptionStatus` |
| `re-subscribe` | `Paywall` | `status-only` | previous shell screen or `VocabularyCatalog` | `Paywall` |
| `re-login` | `RestrictedAccess` | `loading` | `SessionResolving` | `Login` |
| `retry purchase sync` | `SubscriptionStatus` | `status-only` | `SubscriptionStatus` refreshed state | `SubscriptionStatus` retryable failure |

## Recovery Rules

- paywall と restricted access は recovery action 自体を持てるが、canonical な状態説明と restore 導線は `SubscriptionStatus` に集約する
- `pending-sync` は status 表示できるが、premium unlock を completed として見せてはならない
- `grace` は paid entitlement を維持するため、paywall へ強制送出してはならない
- `expired` は completed result 閲覧を維持する一方、新規 premium 操作では paywall を開く
- `revoked` は hard stop 扱いであり、通常 shell を継続させてはならない
