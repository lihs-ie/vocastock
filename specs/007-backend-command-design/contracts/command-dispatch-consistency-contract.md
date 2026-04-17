# Contract: Command Dispatch Consistency

## Purpose

command の受付確定と workflow dispatch の成否が不整合にならないよう、状態確定順序と failure handling を固定する。

## Consistency Rules

| Case | Command Outcome | Persisted State | User-visible Result | Internal Handling |
|------|------------------|-----------------|---------------------|------------------|
| dispatch 成功 | `accepted` | 受付済み初期状態を確定してよい | 状態要約を返す | correlation 情報を保持する |
| dispatch 失敗 | `failed` | 受付済み `pending` を確定しない | 受付失敗の要約のみ返す | failure detail を内部に保持する |
| duplicate in `not-started/failed` without suppression | `reused-existing` | 既存対象を再利用し、dispatch 成功時のみ新しい生成要求を確定してよい | 既存参照と再開後の状態要約を返す | 同一登録対象を再利用し、再開条件を記録する |
| duplicate in `pending/running` | `reused-existing` | 新規状態は作らない | 既存状態を返す | 同一業務キーを再利用する |
| invalid precondition | `rejected` | 状態変更なし | 拒否理由の要約のみ返す | validation detail を内部に保持してよい |

## Ordering Rule

1. 入力と所有者整合を確認する
2. 重複、既存進行中要求、または重複再開条件の有無を確認する
3. dispatch 成功を伴う受理だけを受付済みとして確定する
4. dispatch 失敗時は command 全体を不成立として扱う

## Prohibited States

- dispatch 不成立なのに `pending` が見える状態
- 利用者向け即時応答と内部保持状態が食い違う状態
- duplicate 要求ごとに別の業務キーを増やしてしまう状態
