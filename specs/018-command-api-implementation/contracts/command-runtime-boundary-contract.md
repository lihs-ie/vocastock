# Contract: Command Runtime Boundary

## Purpose

018 で実装する runtime surface と scope 外を固定する。

## In Scope

| Concern | Scope |
|---------|-------|
| internal route | `POST /commands/register-vocabulary-expression` |
| readiness | 既存 `HTTP readiness endpoint` を維持する |
| Firebase dependency probe | 既存 `/dependencies/firebase` を維持する |
| authoritative write | in-memory / stub port で代替可 |
| idempotency store | in-memory / stub port で代替可 |
| dispatch port | in-memory / stub port で代替可 |
| testing | unit mirror + Rust feature test with Docker / Firebase emulator |

## Out Of Scope

| Concern | Why Deferred |
|---------|--------------|
| GraphQL gateway public binding | 015 の gateway scope に属する |
| Firestore / Pub/Sub 本実装 | 012 / infra 実装の follow-on |
| `requestExplanationGeneration` 以降の command | 018 の initial slice 外 |
| worker 本体 | 015 / 012 の別責務 |
| query-side read model | 017 の責務 |

## Rules

- `command-api` は `query-api` への direct call を導入してはならない
- runtime 追加後も 016 の container smoke 契約と矛盾してはならない
- `src/lib.rs` のような抽象名は使わず、責務名付き crate root に分割しなければならない
