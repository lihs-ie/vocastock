# Contract: Billing Work Item

## Purpose

submitted 済み purchase artifact と normalized store notification が、どの形で `billing-worker` へ渡るかを固定する。

## Intake Contract

| Field | Required | Notes |
|-------|----------|-------|
| `trigger` | Yes | initial slice では `purchase-artifact-submitted` または `notification-received` |
| `businessKey` | Yes | replay / duplicate 判定に使う |
| `subscription` | Yes | target `SubscriptionIdentifier` |
| `actor` | Yes | ownership 整合確認用 |
| `purchaseArtifact` | Conditional | `trigger = purchase-artifact-submitted` 時に必須。canonical receipt/token 参照 |
| `notificationPayload` | Conditional | `trigger = notification-received` 時に必須。normalized notification 内容 |
| `requestCorrelation` | Yes | upstream request と worker log の相関 |

## Acceptance Rules

- `purchase-artifact-submitted` では `purchaseArtifact` が必須、`notificationPayload` は持たない
- `notification-received` では `notificationPayload` が必須、`purchaseArtifact` は持たない
- worker は上記以外の `trigger` 値を initial slice で処理してはならない
- `subscription` 不在、ownership mismatch、前提不正は completed `BillingRecord` なしの failure outcome とする

## Duplicate Rules

- 同一 `businessKey` の replay / duplicate arrival は idempotent に扱う
- `queued`、`running`、`retry-scheduled` 中の duplicate は新しい verification / notification ingest を開始してはならない
- `succeeded` 済み `businessKey` の duplicate は existing completed snapshot を再利用してよい

## Ownership Rules

- `actor` と `subscription` の ownership が一致しない場合、worker は `dead-lettered` へ進める
- notification 経路では `subscription` に紐づく actor が一意に resolve できない場合、`failed-final` へ進める
