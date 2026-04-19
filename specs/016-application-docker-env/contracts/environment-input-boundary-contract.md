# Contract: Environment Input Boundary

## Purpose

application runtime に渡す required / optional input と secret boundary を固定する。

## Input Categories

| Category | Allowed | Rule |
|----------|---------|------|
| `secret` | yes | committed local default にしてはならない |
| `local-default` | yes | example file にのみ置く |
| `runtime-parameter` | yes | application profile に応じて required / optional を明示する |

## Rules

- required input は欠落時の failure behavior を持たなければならない
- shared input の committed template は `docker/applications/env/.env.example` を正本とする
- local override は repository に commit してはならない
- `docker/firebase/` 側の env と application-specific env を混同してはならない

## Output

application ごとに required / optional input、secret boundary、shared/local split を説明できること。
