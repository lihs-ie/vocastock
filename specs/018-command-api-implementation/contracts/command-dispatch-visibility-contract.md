# Contract: Command Dispatch & Visibility

## Purpose

accepted / `dispatch-failed` と visible guarantee の関係を固定する。

## Dispatch Matrix

| Condition | Result |
|-----------|--------|
| write 成功 + dispatch 不要 (`startExplanation = false`) | `accepted` を返してよい |
| write 成功 + dispatch 成功 | `accepted` を返してよい |
| dispatch 必要だが dispatch 失敗 | `dispatch-failed` を返し、accepted を返してはならず、registration write も確定させてはならない |
| replay-existing | 既知結果を返し、新しい dispatch を起こしてはならない |
| reused-existing | duplicate reuse 情報を返し、条件を満たす場合だけ再開判定を行う |

## Visibility Rules

- `command-api` は completed explanation payload、image payload、query projection payload を返してはならない
- `command-api` は accepted / reused-existing / failed と `statusHandle` だけを返す
- `statusHandle` は query-side status 参照用であり、completed result を意味してはならない
- `dispatch-failed` は internal dispatch detail を返してはならない
