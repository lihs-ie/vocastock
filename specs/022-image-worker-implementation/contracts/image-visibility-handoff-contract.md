# Contract: Image Visibility And Handoff

## Purpose

completed image の保存、`currentImage` handoff、status-only visibility の境界を固定する。

## Visibility Rules

| Concern | Rule |
|---------|------|
| current image 表示 | `Explanation.currentImage` handoff 完了まで user-visible にしてはならない |
| `queued` / `running` / `retry-scheduled` / `timed-out` / `failed-final` / `dead-lettered` | status-only だけを許可する |
| 既存 `currentImage` | regenerate 相当の試行が non-success の間は維持する |
| stale success | より新しい accepted request が current 採用権を持つ場合、古い成功結果は non-current completed として保持する |
| failure summary | provider / adapter detail を redacted した要約だけを持つ |

## Handoff Rules

- stable asset reference を持つ completed `VisualImage` 保存後に `Explanation.currentImage` handoff を行う
- handoff が完了するまでは candidate image を `hidden-until-handoff` として扱う
- handoff retry は既存 candidate image と既存 asset reference を再利用し、再生成を必須にしない
- handoff が unrecoverable failure になった場合も partial completed payload を current image として表示してはならない
- より新しい accepted request がある場合、古い request の completed image は `retained-non-current` として保持してよいが current を更新してはならない

## Non-Success Rules

- retryable failure は `retry-scheduled` へ進み、既存 current があれば継続表示してよい
- timeout と terminal failure は completed image を新 current にしてはならない
- `dead-lettered` は operator review が必要な status-only failure とする
