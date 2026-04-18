# Contract: Subscription Workflow State Machines

## Purpose

purchase verification、restore、notification reconciliation の runtime state と、
purchase state / subscription state / entitlement への反映順序を固定する。

## Purchase Verification Workflow

| Runtime State | Entry Condition | Exit Condition | Retry / Timeout / Fallback |
|---------------|-----------------|----------------|-----------------------------|
| `queued` | purchase artifact 提出済み | verification 開始 | purchase state は `submitted` または `verifying` |
| `running` | verification adapter 実行中 | verified、retryable failure、timeout、rejected | timeout で `timed-out` |
| `retry-scheduled` | retryable verification failure | next retry 到来で `queued` | authoritative subscription state を paid へ進めない |
| `timed-out` | verification が所定時間内に完了しない | retry 可能なら `retry-scheduled`、不可なら `failed-final` | purchase state は `verifying` に留める |
| `succeeded` | purchase state を `verified` に更新し、subscription authority 再計算完了 | terminal | entitlement snapshot を再生成できる |
| `failed-final` | non-retryable failure または retry exhaustion | terminal | purchase state は `rejected` または `verifying` 維持 |
| `dead-lettered` | operator review が必要 | operator resolution | review unit を作り mirror を維持する |

## Restore Workflow

| Runtime State | Entry Condition | Exit Condition | Retry / Timeout / Fallback |
|---------------|-----------------|----------------|-----------------------------|
| `queued` | restore request 受理 | restore reconciliation 開始 | existing mirror を維持する |
| `running` | store / verification 参照中 | reconciled、retryable failure、timeout | timeout で `timed-out` |
| `retry-scheduled` | retryable failure | next retry 到来で `queued` | unverified paid unlock を付与しない |
| `timed-out` | restore 完了前に時間超過 | retry 可能なら `retry-scheduled`、不可なら `failed-final` | status-only 表示 |
| `succeeded` | purchase state / subscription state / entitlement snapshot の再整合完了 | terminal | projection を更新できる |
| `failed-final` | retry 不可または exhaustion | terminal | 既存 mirror 維持 |
| `dead-lettered` | operator review が必要 | operator resolution | review unit を作る |

## Notification Reconciliation Workflow

| Runtime State | Entry Condition | Exit Condition | Retry / Timeout / Fallback |
|---------------|-----------------|----------------|-----------------------------|
| `queued` | normalized notification 受信済み | reconciliation 開始 | 既存 mirror を維持する |
| `running` | source-of-truth 補正中 | reconciled、retryable failure、timeout | timeout で `timed-out` |
| `retry-scheduled` | retryable ingest / verification failure | next retry 到来で `queued` | 新規 paid entitlement を付与しない |
| `timed-out` | reconciliation 未完了 | retry 可能なら `retry-scheduled`、不可なら `failed-final` | `pending-sync` のまま表示可 |
| `succeeded` | subscription authority / entitlement snapshot 補正完了 | terminal | projection 更新可 |
| `failed-final` | retry 不可または exhaustion | terminal | 既存 mirror 維持 |
| `dead-lettered` | operator review が必要 | operator resolution | review unit を作る |

## Subscription Rules

- purchase state と authoritative subscription state を同じ runtime state で表現してはならない
- `verified` になる前の purchase state は premium unlock の根拠にしてはならない
- notification reconciliation は補正・追随路であり、timeout / failure 中に新規 paid entitlement を付与してはならない
- restore は purchase verification と同じ最終保存対象を更新しうるが、runtime trace は別 workflow として記録する
