# Contract: Image Asset Storage

## Purpose

generated image payload を stable asset reference に変換する asset storage handoff を固定する。

## Input

| Field | Required | Notes |
|-------|----------|-------|
| `imagePayload` | Yes | provider から受け取った renderable payload |
| `explanation` | Yes | target `ExplanationIdentifier` |
| `sense` | No | optional `SenseIdentifier` |
| `requestCorrelation` | Yes | storage log / worker log の相関 |

## Output

| Field | Required | Notes |
|-------|----------|-------|
| `status` | Yes | `stored`、`retryable-failure`、`non-retryable-failure`、`timed-out` |
| `assetReference` | No | `stored` の時だけ存在する stable asset 参照 |
| `failureReason` | No | non-success 時の redacted 要約 |

## Rules

- `assetReference` は worker 再試行後も再取得できる stable reference でなければならない
- `assetReference` が確定する前に `VisualImage` 保存や `currentImage` handoff を行ってはならない
- handoff retry だけが残っている場合、既存 `assetReference` を再利用しなければならない

## Mapping Rules

- `stored` だけが completed `VisualImage` 保存へ進める
- `retryable-failure` は `retry-scheduled` へ写像する
- `timed-out` は `timed-out` へ写像する
- `non-retryable-failure` は `failed-final` へ写像する
