# Contract: Command Response Envelope

## Purpose

accepted / reused-existing の success response が返してよい形を固定する。

## Common Success Envelope

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `acceptance` | `AcceptanceOutcome` | Yes | `accepted` または `reused-existing` |
| `target` | `CommandTargetReference` | Yes | command が返す対象参照 |
| `state` | `StateSummary` | Yes | client に返してよい状態要約 |
| `message` | `UserFacingMessage` | Yes | user-facing な要約メッセージ |
| `replayedByIdempotency` | `boolean` | Yes | same-request replay か |
| `duplicateReuse` | `DuplicateReuseResult` | No | duplicate registration の補足 |

## Success Response by Command

| Command | `target` | `state` | Special Notes |
|---------|----------|---------|---------------|
| `registerVocabularyExpression` | `vocabularyExpression` | registration と explanation の要約 | duplicate 時は `duplicateReuse` を返しうる |
| `requestExplanationGeneration` | `vocabularyExpression` | explanation の要約 | explanation payload は返さない |
| `requestImageGeneration` | `explanation` と必要時 `sense` | image の要約 | image asset は返さない |
| `retryGeneration` | retry 対象参照 | explanation または image の要約 | retry / regenerate の内部理由は詳細露出しない |

## Duplicate Registration Shape

| Field | Required | Meaning |
|-------|----------|---------|
| `acceptance = reused-existing` | Yes | 既存対象を再利用した |
| `target.vocabularyExpression` | Yes | 既存登録対象参照 |
| `duplicateReuse.state` | Yes | 現在状態 |
| `duplicateReuse.restartDecision` | Yes | 生成再開有無 |
| `duplicateReuse.restartCondition` | Yes | 判定理由の要約 |

## Visibility Rules

- success response は未完了解説本文、未完了画像 payload、provider detail、dispatch detail を返してはならない
- `pending-sync` は `state.subscriptionDisplay` として表示できても、`premiumAccessConfirmed = true` と同時に返してはならない
- `replayedByIdempotency = true` の場合も、新規 dispatch 成功を意味してはならない
