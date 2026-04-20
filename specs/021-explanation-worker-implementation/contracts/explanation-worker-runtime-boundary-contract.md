# Contract: Explanation Worker Runtime Boundary

## Purpose

021 で実装する `explanation-worker` runtime surface と scope 外を固定する。

## In Scope

| Concern | Scope |
|---------|-------|
| worker runtime | Haskell long-running consumer |
| stable-run contract | `long-running consumer` を canonical success signal とする |
| internal HTTP runtime adapter | Servant `0.20.3.0` / `servant-server` `0.20.3.0` を使う non-public surface のみ |
| workflow state machine | explanation generation lifecycle と retry / timeout / dead-letter |
| generation adapter | `ExplanationGenerationPort` 越しの caller-owned adapter |
| persistence | explanation 保存と `currentExplanation` handoff port |
| testing | Haskell unit mirror + Haskell feature suite with Docker / Firebase emulator |
| runtime validation | `docker/applications/explanation-worker/`、compose、local stack validation |

## Out Of Scope

| Concern | Why Deferred |
|---------|--------------|
| public HTTP / GraphQL endpoint | worker boundary ではない |
| `query-api` の read projection 実装変更 | query visibility の正本は 017 に属する |
| `image-worker` / `billing-worker` | 別 worker responsibility |
| provider 固有最適化 | initial slice の scope 外 |
| public schema 拡張 | gateway / API feature の責務 |

## Rules

- worker は completed result を直接 user-facing response として返してはならない
- Servant を使う場合でも runtime surface は internal / operator / infrastructure 向けに限定し、public API に昇格させてはならない
- worker container の canonical success signal は queue / subscription 待受プロセスとしての stable-run である
- 外向き HTTP endpoint を必須にしてはならない
- runtime 追加後も 016 の container smoke 契約と矛盾してはならない
- runtime validation は `success`、`retryable-failure`、`terminal-failure` を別 record として
  `application-container-smoke.summary` に残し、local stack validation から再利用できなければならない
