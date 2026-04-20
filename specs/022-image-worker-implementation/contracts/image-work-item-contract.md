# Contract: Image Work Item

## Purpose

accepted 済み image generation 要求が、どの形で `image-worker` へ渡るかを固定する。

## Intake Contract

| Field | Required | Notes |
|-------|----------|-------|
| `trigger` | Yes | initial slice では `request-image-generation-accepted` に固定 |
| `businessKey` | Yes | replay / duplicate 判定に使う |
| `explanation` | Yes | target `ExplanationIdentifier` |
| `learner` | Yes | ownership 整合確認用 |
| `sense` | No | optional `SenseIdentifier` |
| `reason` | Yes | command 正本に従う起点理由 |
| `requestCorrelation` | Yes | upstream request と worker log の相関 |
| `acceptedAt` | Yes | current adoption priority 判定に使う |

## Acceptance Rules

- worker は `trigger = request-image-generation-accepted` 以外の work item を initial slice で処理してはならない
- target `explanation` は completed 状態でなければならない
- `sense` を指定する場合、その `Sense` は target `Explanation` 配下でなければならない
- target 不在、ownership mismatch、未完了 `Explanation`、`Sense` ownership mismatch は `failed-final` とする

## Duplicate Rules

- 同一 `businessKey` の replay / duplicate arrival は idempotent に扱う
- `queued`、`running`、`retry-scheduled` 中の duplicate は新しい generation を開始してはならない
- `succeeded` 済み `businessKey` の duplicate は existing completed result を再利用してよい
- 同じ `Explanation` に対してより新しい accepted request が存在する場合、古い request は `currentImage` 採用権を持たない
