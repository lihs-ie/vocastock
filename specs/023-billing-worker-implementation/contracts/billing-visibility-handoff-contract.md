# Contract: Billing Visibility And Handoff

## Purpose

completed `BillingRecord` の保存、`Subscription.currentEntitlementSnapshot` handoff、
status-only visibility の境界を固定する。

## Visibility Rules

| Concern | Rule |
|---------|------|
| completed `BillingRecord` の entitlement snapshot 本体 | `succeeded` になるまで confirmed entitlement snapshot として扱ってはならない |
| `queued` / `running` / `retry-scheduled` / `timed-out` / `failed-final` / `dead-lettered` | status-only だけを許可する |
| 既存 `currentEntitlementSnapshot` | 新しい verification / reconciliation 試行が non-success の間は維持する |
| failure summary | provider / adapter detail (raw receipt、credential、stack trace) を redacted した要約だけを持つ |

## Handoff Rules

- completed `BillingRecord` 保存後に `Subscription.currentEntitlementSnapshot` handoff を行う
- handoff が完了するまでは candidate snapshot を `hidden-until-handoff` として扱う
- handoff retry は既存 candidate snapshot を再利用し、再検証や再 reconciliation を必須にしない
- handoff が unrecoverable failure になった場合も partial snapshot を confirmed として表示してはならない

## Non-Success Rules

- retryable failure は `retry-scheduled` へ進み、既存 current があれば継続表示してよい
- timeout と terminal failure は candidate snapshot を新 current にしてはならない
- `dead-lettered` は operator review が必要な status-only failure とする
- notification reconciliation の retry / timeout / failure 中は、認証経路を通らない新規 `premium-generation` unlock を付与してはならない

## Current Snapshot Actions

- `switched`: handoff 成功、新 snapshot を current に採用
- `retained`: non-success 経路、既存 current を維持
- `superseded`: 新 snapshot の保存は成立したが current が別 workflow で既に先行更新されており、今回の candidate は current にしない (status-only に留める)
