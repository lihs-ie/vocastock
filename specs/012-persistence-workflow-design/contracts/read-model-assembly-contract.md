# Contract: Read Model Assembly

## Purpose

app-facing projection がどの authoritative state から構成され、どこで completed result と
status-only 情報を分離するかを固定する。

## Projection Matrix

| Projection | Sources | Completed Payload Condition | Status-only Condition |
|------------|---------|-----------------------------|----------------------|
| `VocabularyCatalogProjection` | `VocabularyExpressionRecord`, `LearningStateRecord`, latest explanation workflow attempt | `currentExplanation` が参照可能 | `currentExplanation` 不在、または workflow が未完了 / 失敗 |
| `ExplanationDetailProjection` | `VocabularyExpressionRecord.currentExplanation`, `ExplanationRecord`, latest explanation workflow attempt | `currentExplanation` が完了済み explanation を指す | workflow が `queued` / `running` / `retry-scheduled` / `timed-out` / `failed-final` / `dead-lettered` |
| `ImageDetailProjection` | `ExplanationRecord.currentImage`, `VisualImageRecord`, latest image workflow attempt | `currentImage` が完了済み image を指す | 画像生成が未完了、timeout、保存失敗、dead-letter |
| `SubscriptionStatusProjection` | `SubscriptionAuthorityRecord`, `PurchaseStateRecord`, `EntitlementSnapshotRecord` | authoritative subscription state と entitlement snapshot が同期済み | `pending-sync`、verification 未完了、notification 補正待ち |
| `UsageAllowanceProjection` | `UsageAllowanceRecord`, `EntitlementSnapshotRecord` | allowance 集計が current window に同期済み | current window 集計前、refresh 遅延中 |

## Projection Rules

- completed payload は authoritative current pointer が切り替わった後にだけ公開する
- `pending-sync` は状態表示してよいが、paid entitlement 確定情報として返してはならない
- purchase verification timeout 中は purchase state を表示できても premium unlock を確定してはならない
- partial success により新しい aggregate が一部だけ保存された場合、projection は既存 completed result を維持するか status-only に倒す
- dead-lettered workflow は projection 上 `failed` として見せ、operator review detail は返さない

## Refresh Expectations

- command side write 完了後、projection refresh は eventual に反映されてよい
- projection refresh 遅延中でも authoritative write を先に completed と見せてはならない
- stale read が許容される場合でも、completed / failed / pending の意味を逆転させてはならない
