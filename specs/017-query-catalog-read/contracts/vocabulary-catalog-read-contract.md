# Contract: Vocabulary Catalog Read

## Purpose

`query-api` が返す `VocabularyCatalogProjection` read endpoint の surface を固定する。

## Endpoint

- method: `GET`
- path: `/vocabulary-catalog`
- owner: `query-api`
- visibility: `query-api` 内部 route。gateway での public mapping は deferred

## Success Response Shape

| Field | Type | Description |
|-------|------|-------------|
| `items` | array | catalog 項目一覧 |
| `collectionState` | string | `empty` または `populated` |
| `projectionFreshness` | string | `eventual` |

## Item Shape

| Field | Required | Description |
|-------|----------|-------------|
| `vocabularyExpression` | yes | 対象語彙参照 |
| `registrationState` | yes | 登録状態 summary |
| `explanationState` | yes | explanation 側 status summary |
| `visibility` | yes | `completed-summary` または `status-only` |
| `completedSummary` | no | completed 時のみ返す summary |
| `statusReason` | no | status-only 時のみ返す reason summary |

## Rules

- `currentExplanation` が参照可能なときだけ `completed-summary` を返す
- `currentExplanation` が無い、または latest workflow が未完了 / failure のときは `status-only` を返す
- `items = []` でも失敗ではなく空 collection を返す
- explanation detail 本文、image detail payload、intermediate payload を返してはならない

## Out of Scope

- GraphQL schema 全体の拡張
- detail 画面用 payload
- command acceptance、workflow dispatch、write-side mutation
