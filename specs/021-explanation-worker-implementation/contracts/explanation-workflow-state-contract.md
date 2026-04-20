# Contract: Explanation Workflow State

## Purpose

`explanation-worker` が扱う runtime state、retry、timeout、terminal outcome を固定する。

## State Machine

| Runtime State | Entry Condition | Exit Condition | Visibility Rule |
|---------------|-----------------|----------------|-----------------|
| `queued` | accepted work item を受信 | worker が処理開始 | status-only のみ |
| `running` | generation または handoff を開始 | payload success、retryable failure、timeout、non-retryable failure | status-only のみ |
| `retry-scheduled` | retryable failure または handoff retry | next retry 到来で `queued` | status-only のみ |
| `timed-out` | 規定時間内に completion しない | retry 可能なら `retry-scheduled`、不可なら `failed-final` | status-only のみ |
| `succeeded` | completed explanation 保存と current handoff が両方成功 | terminal | completed payload を current として表示可能 |
| `failed-final` | non-retryable failure または retry exhaustion | terminal | status-only failure |
| `dead-lettered` | operator review が必要 | operator resolution | status-only failure |

## Transition Rules

- `succeeded` へ進む前に `Explanation` 保存と `VocabularyExpression.currentExplanation` handoff の両方が完了していなければならない
- retryable generation failure は `retry-scheduled` へ写像する
- timeout は `timed-out` を経由し、retry 可否に応じて `retry-scheduled` か `failed-final` へ進む
- malformed / incomplete completed payload は `failed-final` として扱う
- `dead-lettered` は operator review が必要な terminal failure に限定する

## Idempotency Rules

- 同一 `businessKey` で completed `Explanation` を重複保存してはならない
- 同一 `businessKey` で `currentExplanation` を二重に切り替えてはならない
- worker restart 後も existing workflow state を参照して duplicate completion を防がなければならない
