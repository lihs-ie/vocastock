# Contract: Explanation Generation Port

## Purpose

`ExplanationGenerationPort` を `explanation-worker` がどう使うかを固定する。

## Input

| Field | Required | Notes |
|-------|----------|-------|
| `vocabularyExpression` | Yes | target `VocabularyExpressionIdentifier` |
| `normalizedVocabularyExpressionText` | Yes | canonical generation input |
| `requestCorrelation` | Yes | worker log / provider request の相関 |

## Output

| Field | Required | Notes |
|-------|----------|-------|
| `requestIdentifier` | Yes | provider / adapter 側 request 参照 |
| `status` | Yes | `succeeded`、`retryable-failure`、`non-retryable-failure`、`timed-out` |
| `explanationPayload` | No | completed 時のみ存在 |
| `failureReason` | No | non-success 時の redacted 要約 |

## Completed Payload Requirements

- `Sense` を 1 件以上含むこと
- `Frequency` と `Sophistication` を含むこと
- `Pronunciation`、`Etymology`、`SimilarExpression` を completed `Explanation` として保存できる形で含むこと
- incomplete / inconsistent payload は `succeeded` として扱ってはならない

## Mapping Rules

- `status = succeeded` でも completed payload requirement を満たさない場合は `failed-final` に写像する
- `retryable-failure` は worker state `retry-scheduled` へ写像する
- `timed-out` は worker state `timed-out` へ写像する
- `non-retryable-failure` は worker state `failed-final` へ写像する
