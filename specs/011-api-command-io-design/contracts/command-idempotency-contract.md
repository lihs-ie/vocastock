# Contract: Command Idempotency

## Purpose

actor 単位の same-request replay、duplicate reuse、conflict rejection の規則を command ごとに固定する。

## Idempotency Matrix

| Command | Same-request Identity | Replay Response | Conflict Condition |
|---------|-----------------------|-----------------|-------------------|
| `registerVocabularyExpression` | same actor + same normalized `text` + same `startExplanation` | 既知の accepted / reused-existing 結果または現在状態を返す | same key で `text` または `startExplanation` が異なる |
| `requestExplanationGeneration` | same actor + same `vocabularyExpression` + same `reason` | 既知の受付結果または既存 `pending` / `running` 状態を返す | same key で target または reason が異なる |
| `requestImageGeneration` | same actor + same `explanation` + same optional `sense` + same `reason` | 既知の受付結果または既存状態を返す | same key で `explanation` / `sense` / reason が異なる |
| `retryGeneration` | same actor + same `targetKind` + same normalized `target` + same `mode` + same optional `reason` | 既知の retry / regenerate 結果を返す | same key で `targetKind` / `target` / `mode` / reason が異なる |

## Rules

- same-request replay では新しい dispatch を行ってはならない
- `idempotencyKey` の一意性スコープは actor 単位である
- same key でも actor が異なる場合は replay とみなしてはならない
- duplicate registration の business reuse と same-request replay は別概念である
- duplicate registration は key が異なっても existing target reuse を返しうる

## Duplicate Registration And Replay

| Situation | Outcome |
|-----------|---------|
| same key + same normalized register request | replay された既知結果を返す |
| different key + same normalized text on existing registration | `reused-existing` を返す |
| same key + different normalized register request | `idempotency-conflict` を返す |
