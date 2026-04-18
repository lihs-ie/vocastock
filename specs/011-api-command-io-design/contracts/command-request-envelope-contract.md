# Contract: Command Request Envelope

## Purpose

4 つの主要 command が共有する request envelope と、command ごとの body shape を固定する。

## Common Envelope

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | `CommandName` | Yes | canonical command 名 |
| `actor` | `ActorHandoffInput` | Yes | completed auth/session handoff |
| `idempotencyKey` | `IdempotencyKey` | Yes | 同一業務要求の再送識別子 |
| `body` | command-specific body | Yes | command 固有入力 |

## Command-specific Body Matrix

| Command | Required Body Fields | Optional Body Fields | Notes |
|---------|----------------------|----------------------|-------|
| `registerVocabularyExpression` | `text` | `startExplanation` | omitted 時は `true`。`false` 許可はこの command のみ |
| `requestExplanationGeneration` | `vocabularyExpression`, `reason` | none | target は learner-owned `VocabularyExpression` |
| `requestImageGeneration` | `explanation`, `reason` | `sense` | 主 target は `Explanation`。`sense` は補助参照 |
| `retryGeneration` | `targetKind`, `target`, `mode` | `reason` | `targetKind` に応じて target shape が変わる |

## Retry Target Rules

| `targetKind` | Required Target Fields | Must Not Include |
|--------------|------------------------|------------------|
| `explanation` | `vocabularyExpression` | `explanation`, `sense` |
| `image` | `explanation` | completed image payload |

## Rules

- request envelope は raw token、provider credential、password、refresh token を含めてはならない
- `idempotencyKey` は actor 単位で一意に扱う
- `startExplanation = false` は `registerVocabularyExpression` 以外で受け付けてはならない
- `requestImageGeneration.body.sense` を指定する場合、その `Sense` は target `Explanation` 配下でなければならない
- `retryGeneration.body.mode` は `retry` または `regenerate` のどちらかでなければならない
- request body は completed explanation payload や image asset payload を含めてはならない
