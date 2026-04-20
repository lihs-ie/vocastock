# Contract: Register Vocabulary Command

## Purpose

`registerVocabularyExpression` の internal route、request body、success / failure response を固定する。

## Internal Route

| Field | Value |
|-------|-------|
| Method | `POST` |
| Path | `/commands/register-vocabulary-expression` |
| Visibility | `command-api` internal service route |

## Request Envelope

| Field | Required | Notes |
|-------|----------|-------|
| `command` | Yes | `registerVocabularyExpression` に固定 |
| `actor` | Yes | completed actor handoff |
| `idempotencyKey` | Yes | actor 単位で一意 |
| `body.text` | Yes | 登録対象 text |
| `body.startExplanation` | No | omitted 時は `true` |

## Success Response

| Field | Required | Notes |
|-------|----------|-------|
| `acceptance` | Yes | `accepted` または `reused-existing` |
| `target.vocabularyExpression` | Yes | 登録対象参照 |
| `state.registration` | Yes | registration state summary |
| `state.explanation` | Yes | explanation state summary |
| `statusHandle` | Yes | query-side status 参照ハンドル |
| `message` | Yes | user-facing message |
| `replayedByIdempotency` | Yes | same-request replay か |
| `duplicateReuse` | No | duplicate registration 時のみ |

## Failure Response

| Code | Use When |
|------|----------|
| `missing-token` | bearer token が無い |
| `invalid-token` | bearer token が不正 |
| `reauth-required` | session が再認証を要求する |
| `validation-failed` | `text` 不正、許可されない field 組み合わせ |
| `ownership-mismatch` | actor と target ownership が一致しない |
| `idempotency-conflict` | same key + different normalized request |
| `dispatch-failed` | dispatch が成立せず registration write も確定しない |
| `internal-failure` | 上記以外の内部失敗 |

## Rules

- `startExplanation = false` を許可するのはこの command のみ
- success response は completed payload を返してはならない
- duplicate registration は rejection ではなく `reused-existing` を返しうる
