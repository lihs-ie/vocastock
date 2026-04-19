# Contract: Catalog Visibility

## Purpose

`VocabularyCatalogProjection` における completed summary と status-only の visible guarantee を固定する。

## Visibility Matrix

| Condition | Allowed Result | Prohibited Result |
|-----------|----------------|------------------|
| `currentExplanation` 参照可 | `completed-summary` | status-only only に倒すこと |
| workflow `queued/running/retry-scheduled` | `status-only` | provisional completed payload |
| workflow `timed-out/failed-final/dead-lettered` かつ completed 不在 | `status-only` | provisional completed payload |
| projection lag 中 | `status-only` | authoritative write を先回りした completed |

## Rules

- provisional completed payload を返してはならない
- stale read 中でも completed / failed / pending の意味を逆転させてはならない
- catalog は detail 本文ではなく summary / status だけを返す
- `pending-sync` など未確認 entitlement 情報を completed 判定に使ってはならない

## UI Alignment

- `AppShell` の catalog 一覧に整合する
- `VocabularyExpressionDetail` や `ExplanationDetail` の専用 payload を先行公開しない
