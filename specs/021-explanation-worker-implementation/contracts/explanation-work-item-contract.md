# Contract: Explanation Work Item

## Purpose

accepted 済み explanation generation 要求が、どの形で `explanation-worker` へ渡るかを固定する。

## Intake Contract

| Field | Required | Notes |
|-------|----------|-------|
| `trigger` | Yes | initial slice では `registration-accepted` に固定 |
| `businessKey` | Yes | replay / duplicate 判定に使う |
| `vocabularyExpression` | Yes | target `VocabularyExpressionIdentifier` |
| `learner` | Yes | ownership 整合確認用 |
| `normalizedVocabularyExpressionText` | Yes | generation input の canonical text |
| `requestCorrelation` | Yes | upstream request と worker log の相関 |
| `startExplanation` | Yes | initial slice では `true` のみ受理対象 |

## Acceptance Rules

- `startExplanation = false` の accepted registration は worker へ dispatch してはならない
- worker は `trigger = registration-accepted` 以外の work item を initial slice で処理してはならない
- `vocabularyExpression` 不在、ownership mismatch、前提不正は completed explanation なしの failure outcome とする

## Duplicate Rules

- 同一 `businessKey` の replay / duplicate arrival は idempotent に扱う
- `queued`、`running`、`retry-scheduled` 中の duplicate は新しい generation を開始してはならない
- `succeeded` 済み `businessKey` の duplicate は existing completed result を再利用してよい
