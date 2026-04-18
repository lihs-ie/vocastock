# Contract: Generation Workflow State Machines

## Purpose

explanation 生成と image 生成の runtime state、retry、timeout、fallback、dead-letter 相当を固定する。

## Explanation Generation Workflow

| Runtime State | Entry Condition | Exit Condition | Retry / Timeout / Fallback |
|---------------|-----------------|----------------|-----------------------------|
| `queued` | command accepted、dispatch 未了 | worker が開始 | timeout 前は `pending` 表示のみ |
| `running` | worker が generation を開始 | payload 成功、retryable failure、timeout、non-retryable failure | timeout で `timed-out` |
| `retry-scheduled` | retryable failure 発生 | next retry 到来で `queued` | 既存 completed explanation があれば維持する |
| `timed-out` | 規定時間内に completion しない | retry 可能なら `retry-scheduled`、不可なら `failed-final` | 新しい completed explanation を作らない |
| `succeeded` | completed explanation 保存と current handoff 完了 | terminal | `VocabularyExpression.currentExplanation` を更新できる |
| `failed-final` | retry 不可または retry exhaustion | terminal | status-only failure として返す |
| `dead-lettered` | operator review が必要な終端 | operator resolution | status-only failure として返し、review unit を作る |

## Image Generation Workflow

| Runtime State | Entry Condition | Exit Condition | Retry / Timeout / Fallback |
|---------------|-----------------|----------------|-----------------------------|
| `queued` | completed `Explanation` への request 受理 | worker が開始 | `Explanation.currentImage` は維持する |
| `running` | provider 生成と asset 保存を開始 | completed image 保存成功、retryable failure、timeout、non-retryable failure | timeout で `timed-out` |
| `retry-scheduled` | retryable generation failure または storage failure | next retry 到来で `queued` | 既存 completed image を維持する |
| `timed-out` | 規定時間内に provider or storage completion がない | retry 可能なら `retry-scheduled`、不可なら `failed-final` | partial success を current image にしない |
| `succeeded` | `VisualImageRecord` 保存と `Explanation.currentImage` handoff 完了 | terminal | 新 current image を採用できる |
| `failed-final` | retry 不可または retry exhaustion | terminal | status-only failure |
| `dead-lettered` | operator review が必要 | operator resolution | review unit を作る |

## Generation Rules

- explanation 生成は completed `ExplanationRecord` 保存前に `currentExplanation` を切り替えてはならない
- image 生成は `VisualImageRecord` 保存と asset 参照確定前に `currentImage` を切り替えてはならない
- storage failure は image workflow の partial success であり、`succeeded` として扱ってはならない
- `retry-scheduled` は user-facing projection では completed payload を返さない
