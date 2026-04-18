# Contract: Command Error

## Purpose

失敗・拒否時の canonical error code、client 可視情報、internal-only detail の区分を固定する。

## Error Code Catalog

| Code | Use When | Client-visible Fields | Internal Detail Class | Retryable |
|------|----------|-----------------------|-----------------------|-----------|
| `validation-failed` | 必須項目不足、形式不正、許可されない field 組み合わせ | `code`, `message`, optional `target` | `validation-detail` | No |
| `ownership-mismatch` | actor と target 所有者が一致しない | `code`, `message`, optional `target` | `ownership-detail` | No |
| `target-missing` | 参照先 resource が存在しない | `code`, `message`, optional `target` | `lookup-detail` | No |
| `target-not-ready` | explanation 未完了など前提状態不足 | `code`, `message`, optional `target`, optional `state` | `readiness-detail` | Usually No |
| `idempotency-conflict` | 同じ actor に対して同じ `idempotencyKey` で本文が異なる | `code`, `message` | `idempotency-detail` | No |
| `dispatch-failed` | workflow dispatch が成立せず受付不成立 | `code`, `message`, optional `target`, optional `state` | `dispatch-detail` | Yes |
| `internal-failure` | 上記以外の内部失敗 | `code`, `message` | `unexpected-detail` | Maybe |

## Error Rules

- client に返してよいのは `code`、必須 `message`、`retryable`、返して安全な `target` / `state` だけである
- internal detail class は観測・調査用であり、response body 本体へ露出してはならない
- `dispatch-failed` は success envelope と同時に返してはならない
- `idempotency-conflict` は same-request replay ではなく rejection を意味する

## Ownership And Authorization Boundary

- `ownership-mismatch` は target 所有者不整合を示すが、provider credential や auth backend detail は返してはならない
- auth/session 起因の未完了 handoff は command I/O ではなく upstream boundary failure として扱い、011 では completed handoff input だけを受ける
