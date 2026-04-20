# Contract: Explanation Visibility And Handoff

## Purpose

completed explanation の保存、`currentExplanation` handoff、status-only visibility の境界を固定する。

## Visibility Rules

| Concern | Rule |
|---------|------|
| completed explanation 本文 | `succeeded` になるまで user-visible にしてはならない |
| `queued` / `running` / `retry-scheduled` / `timed-out` / `failed-final` / `dead-lettered` | status-only だけを許可する |
| 既存 `currentExplanation` | regenerate 相当の試行が non-success の間は維持する |
| failure summary | provider / adapter detail を redacted した要約だけを持つ |

## Handoff Rules

- completed `Explanation` 保存後に `VocabularyExpression.currentExplanation` handoff を行う
- handoff が完了するまでは candidate explanation を `hidden-until-handoff` として扱う
- handoff retry は既存 candidate explanation を再利用し、再生成を必須にしない
- handoff が unrecoverable failure になった場合も partial completed payload を表示してはならない

## Non-Success Rules

- retryable failure は `retry-scheduled` へ進み、既存 current があれば継続表示してよい
- timeout と terminal failure は completed explanation を新 current にしてはならない
- `dead-lettered` は operator review が必要な status-only failure とする
