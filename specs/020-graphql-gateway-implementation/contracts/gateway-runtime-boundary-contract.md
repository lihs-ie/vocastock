# Contract: Gateway Runtime Boundary

## Purpose

`graphql-gateway` の runtime 契約、public binding 検証方法、boundary rules を固定する。

## Runtime Rules

- `graphql-gateway` は既存 API application と同じ readiness contract を維持する
- public GraphQL route を追加しても `/readyz` と `/dependencies/firebase` を壊してはならない
- Docker runtime の正本は `docker/applications/graphql-gateway/Dockerfile` と
  `docker/applications/compose.yaml` とする

## Feature Test Rules

- feature テストは Rust integration test から Docker containers と Firebase emulator を使って実行する
- `graphql-gateway`、`command-api`、`query-api` をまとめて起動し、public `/graphql` endpoint を検証する
- local / CI の両方で同じ Dockerfile / entry contract を再利用する

## Boundary Rules

- gateway は routing、failure shaping、auth propagation、request correlation propagation だけを担う
- gateway は completed payload を合成してはならない
- gateway は downstream service の business rule を再実装してはならない
