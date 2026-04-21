# Contract: Purchase Verification Workflow

## Purpose

`billing-worker` が扱う purchase verification workflow の runtime state、retry、timeout、
terminal outcome、authoritative state 更新順序を固定する。

## State Machine

| Runtime State | Entry Condition | Exit Condition | Visibility Rule |
|---------------|-----------------|----------------|-----------------|
| `queued` | submitted purchase artifact を受信 | worker が処理開始 | status-only のみ |
| `running` | verification adapter 実行中 | verified、retryable failure、timeout、non-retryable failure | status-only のみ |
| `retry-scheduled` | retryable verification failure または handoff retry | next retry 到来で `queued` | status-only のみ、authoritative state を paid へ進めない |
| `timed-out` | verification が所定時間内に完了しない | retry 可能なら `retry-scheduled`、不可なら `failed-final` | status-only のみ、purchase state は `verifying` に留める |
| `succeeded` | completed `BillingRecord` 保存と current handoff が両方成功 | terminal | confirmed entitlement snapshot を unlock 根拠にしてよい |
| `failed-final` | non-retryable failure または retry exhaustion | terminal | status-only failure、purchase state は `rejected` または `verifying` 維持 |
| `dead-lettered` | operator review が必要 | operator resolution | status-only failure、既存 mirror 維持 |

## Transition Rules

- `succeeded` へ進む前に completed `BillingRecord` 保存と `Subscription.currentEntitlementSnapshot` handoff の両方が完了していなければならない
- retryable verification failure は `retry-scheduled` へ写像する
- timeout は `timed-out` を経由し、retry 可否に応じて `retry-scheduled` か `failed-final` へ進む
- malformed / incomplete verified payload は `failed-final` として扱う
- `dead-lettered` は operator review が必要な terminal failure に限定する (例: ownership mismatch、critical partial commit 失敗)

## Verification Adapter Output

| Field | Required | Notes |
|-------|----------|-------|
| `requestIdentifier` | Yes | verification adapter 側 request 参照 |
| `status` | Yes | `verified`、`retryable-failure`、`non-retryable-failure`、`timed-out` |
| `verifiedPayload` | No | `verified` 時のみ存在。subscription term、plan code、grace window を含む |
| `failureReason` | No | non-success 時の redacted 要約 |

## Completed Payload Requirements

- `subscriptionStateName` が `active` / `grace` / `expired` / `pending-sync` / `revoked` のいずれかであること
- `entitlementBundleName` が `free-basic` / `premium-generation` のいずれかであること
- `quotaProfileName` が `free-monthly` / `standard-monthly` / `pro-monthly` のいずれかであること
- `effectivePeriod` (term start / end、必要に応じて grace window) が含まれていること
- incomplete / inconsistent payload は `succeeded` として扱ってはならない

## Mapping Rules

- `status = verified` でも completed payload requirement を満たさない場合は `failed-final` に写像する
- `retryable-failure` は worker state `retry-scheduled` へ写像する
- `timed-out` は worker state `timed-out` へ写像する
- `non-retryable-failure` は worker state `failed-final` へ写像する

## Idempotency Rules

- 同一 `businessKey` で completed `BillingRecord` を重複保存してはならない
- 同一 `businessKey` で `currentEntitlementSnapshot` を二重に切り替えてはならない
- worker restart 後も existing workflow state を参照して duplicate completion を防がなければならない
