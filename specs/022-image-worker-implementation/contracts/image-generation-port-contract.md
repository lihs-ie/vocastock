# Contract: Image Generation Port

## Purpose

`ImageGenerationPort` を `image-worker` がどう使うかを固定する。

## Input

| Field | Required | Notes |
|-------|----------|-------|
| `explanation` | Yes | target `ExplanationIdentifier` |
| `sense` | No | optional `SenseIdentifier` |
| `requestCorrelation` | Yes | worker log / provider request の相関 |

## Output

| Field | Required | Notes |
|-------|----------|-------|
| `requestIdentifier` | Yes | provider / adapter 側 request 参照 |
| `status` | Yes | `succeeded`、`retryable-failure`、`non-retryable-failure`、`timed-out` |
| `imagePayload` | No | completed 時のみ存在 |
| `failureReason` | No | non-success 時の redacted 要約 |

## Completed Payload Requirements

- renderable image asset を生成できる payload を含むこと
- target `Explanation` と optional `Sense` の対応を保存できること
- asset storage handoff に必要な metadata を持つこと
- incomplete / inconsistent payload は `succeeded` として扱ってはならない

## Mapping Rules

- `status = succeeded` でも completed payload requirement を満たさない場合は `failed-final` に写像する
- `retryable-failure` は worker state `retry-scheduled` へ写像する
- `timed-out` は worker state `timed-out` へ写像する
- `non-retryable-failure` は worker state `failed-final` へ写像する
