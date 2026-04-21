# Contract: Store Notification Reconciliation Workflow

## Purpose

`billing-worker` が扱う store notification reconciliation workflow の runtime state、
retry、timeout、terminal outcome、authoritative state 補正順序を固定する。
notification は後追いの補正経路であり、新規 paid entitlement を付与しないことを明示する。

## State Machine

| Runtime State | Entry Condition | Exit Condition | Visibility Rule |
|---------------|-----------------|----------------|-----------------|
| `queued` | normalized notification を受信 | worker が処理開始 | status-only のみ、既存 mirror 維持 |
| `running` | source-of-truth 補正中 | reconciled、retryable failure、timeout、non-retryable failure | status-only のみ |
| `retry-scheduled` | retryable ingest / verification failure | next retry 到来で `queued` | status-only のみ、新規 paid entitlement を付与しない |
| `timed-out` | reconciliation が所定時間内に完了しない | retry 可能なら `retry-scheduled`、不可なら `failed-final` | status-only のみ、`pending-sync` のまま表示可 |
| `succeeded` | subscription authority / entitlement snapshot 補正完了 + current handoff 完了 | terminal | 補正済み entitlement snapshot を unlock 根拠にしてよい |
| `failed-final` | non-retryable failure または retry exhaustion | terminal | status-only failure、既存 mirror 維持 |
| `dead-lettered` | operator review が必要 | operator resolution | status-only failure、既存 mirror 維持 |

## Transition Rules

- `succeeded` へ進む前に completed `BillingRecord` (notification 経由の state 補正 + 再計算 snapshot) 保存と `Subscription.currentEntitlementSnapshot` handoff の両方が完了していなければならない
- retryable notification ingest failure は `retry-scheduled` へ写像する
- timeout は `timed-out` を経由し、retry 可否に応じて `retry-scheduled` か `failed-final` へ進む
- malformed / signature-invalid notification は `failed-final` として扱う
- 注文順序逆転 (例: 既に `revoked` なのに古い `active` notification が届く) は stale 判定で `failed-final` または no-op succeeded として扱い、authority state を退行させない

## Notification Adapter Output

| Field | Required | Notes |
|-------|----------|-------|
| `requestIdentifier` | Yes | notification adapter 側 request 参照 |
| `status` | Yes | `reconciled`、`retryable-failure`、`non-retryable-failure`、`timed-out` |
| `reconciledPayload` | No | `reconciled` 時のみ存在。normalized subscription state / term / grace window |
| `failureReason` | No | non-success 時の redacted 要約 |

## Reconciled Payload Requirements

- `subscriptionStateName` が `active` / `grace` / `expired` / `pending-sync` / `revoked` のいずれかであること
- `effectivePeriod` (term start / end、grace window) が normalized されていること
- notification 独自の field (provider notification ID、environment、received timestamp) は `VerificationAttemptRecord.providerRequestIdentifier` 等に redacted な形で記録してよい
- incomplete / inconsistent payload は `reconciled` として扱ってはならない

## No-New-Unlock Rule

- notification reconciliation の経路では、認証経路 (purchase verification) を通過していない actor に対し新たに `premium-generation` entitlement bundle を付与してはならない
- notification 経由での昇格は既存 `verified` purchase state が存在する場合に限り許可される
- notification 経由で `free-basic` / `free-monthly` へのフォールバック、`grace` → `expired` / `revoked` への遷移は許可される

## Idempotency Rules

- 同一 `businessKey` (actor + subscription + notification identifier) で authority state を二重補正してはならない
- worker restart 後も existing workflow state を参照して duplicate reconciliation を防がなければならない
- stale notification は authority state を退行させず、`failed-final` または no-op succeeded で処理する
