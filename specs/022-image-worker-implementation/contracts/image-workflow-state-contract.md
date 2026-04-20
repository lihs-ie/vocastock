# Contract: Image Workflow State

## Purpose

`image-worker` が扱う runtime state、retry、timeout、terminal outcome、stale-success を固定する。

## State Machine

| Runtime State | Entry Condition | Exit Condition | Visibility Rule |
|---------------|-----------------|----------------|-----------------|
| `queued` | accepted work item を受信 | worker が処理開始 | status-only のみ |
| `running` | target validation、generation、asset storage、handoff を開始 | payload success、retryable failure、timeout、non-retryable failure | status-only のみ |
| `retry-scheduled` | retryable failure、asset storage retry、handoff retry | next retry 到来で `queued` | status-only のみ |
| `timed-out` | 規定時間内に completion しない | retry 可能なら `retry-scheduled`、不可なら `failed-final` | status-only のみ |
| `succeeded` | completed `VisualImage` 保存と current handoff が両方成功、または stale-success を completed non-current として確定 | terminal | current か non-current completed として保存済み |
| `failed-final` | non-retryable failure、retry exhaustion、deterministic invalid target | terminal | status-only failure |
| `dead-lettered` | operator review が必要 | operator resolution | status-only failure |

## Transition Rules

- `succeeded` へ進む前に stable asset reference を持つ `VisualImage` 保存が完了していなければならない
- retryable generation failure、retryable asset storage failure、retryable handoff failure は `retry-scheduled` へ写像する
- timeout は `timed-out` を経由し、retry 可否に応じて `retry-scheduled` か `failed-final` へ進む
- malformed / incomplete payload は `failed-final` として扱う
- target 不在、ownership mismatch、未完了 `Explanation`、`Sense` ownership mismatch は `failed-final` とする
- `dead-lettered` は不明系または operator review 必須の terminal failure に限定する
- より新しい accepted request が current 採用権を持つ場合、古い request の成功は stale-success として保持し current を更新しない

## Idempotency Rules

- 同一 `businessKey` で completed `VisualImage` を重複保存してはならない
- 同一 `businessKey` で `currentImage` を二重に切り替えてはならない
- worker restart 後も existing workflow state を参照して duplicate completion を防がなければならない
