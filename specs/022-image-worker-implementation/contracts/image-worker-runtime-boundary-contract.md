# Contract: Image Worker Runtime Boundary

## Purpose

022 で実装する `image-worker` runtime surface と scope 外を固定する。

## In Scope

| Concern | Scope |
|---------|-------|
| worker runtime | Haskell long-running consumer |
| stable-run contract | `long-running consumer` を canonical success signal とする |
| workflow state machine | image generation lifecycle と retry / timeout / dead-letter / stale-success |
| generation adapter | `ImageGenerationPort` 越しの caller-owned adapter |
| asset storage adapter | `ImageAssetStoragePort` 越しの caller-owned adapter |
| persistence | `VisualImage` 保存と `currentImage` handoff port |
| testing | Haskell unit mirror + Haskell feature suite with Docker / Firebase emulator |
| runtime validation | `docker/applications/image-worker/`、compose、local stack validation |

## Out Of Scope

| Concern | Why Deferred |
|---------|--------------|
| public HTTP / GraphQL endpoint | worker boundary ではない |
| `query-api` の read projection 実装変更 | query visibility の正本は 017 / 012 に属する |
| `explanation-worker` / `billing-worker` | 別 worker responsibility |
| provider 固有最適化 | initial slice の scope 外 |
| multiple current image / gallery | follow-on image feature の責務 |

## Rules

- worker は completed result を直接 user-facing response として返してはならない
- external HTTP endpoint を必須にしてはならない
- worker container の canonical success signal は queue / subscription 待受プロセスとしての stable-run である
- runtime 追加後も 016 の container smoke 契約と矛盾してはならない
- runtime validation は `success`、`retryable-failure`、`terminal-failure` を別 record として
  `application-container-smoke.summary` に残し、local stack validation から再利用できなければならない
