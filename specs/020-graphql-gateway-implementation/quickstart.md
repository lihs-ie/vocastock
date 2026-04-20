# Quickstart: GraphQL Gateway Implementation

## Review Sequence

1. [research.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/research.md) で、
   public transport、allowlist、downstream relay、failure envelope、auth/correlation、feature test
   の主要判断を確認する。
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/data-model.md) で、
   `UnifiedGraphqlRequest`、`GatewayRoutingDecision`、`PublicMutationResult`、
   `PublicCatalogResult`、`GatewayFailureEnvelope` の境界を確認する。
3. [public-graphql-operation-contract.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/public-graphql-operation-contract.md)
   で `/graphql` transport、2 operation allowlist、downstream mapping を確認する。
4. [gateway-auth-correlation-contract.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/gateway-auth-correlation-contract.md)
   と [gateway-failure-envelope-contract.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/gateway-failure-envelope-contract.md)
   で auth propagation、request correlation、public failure shaping を確認する。
5. [gateway-runtime-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/gateway-runtime-boundary-contract.md)
   で readiness、Docker/Firebase feature test、gateway 非所有責務を確認する。

## Local Verification Outline

1. `cargo test -p graphql-gateway --test unit`
2. `cargo test -p graphql-gateway --test feature -- --nocapture`
3. 必要に応じて `cargo llvm-cov -p graphql-gateway --tests --summary-only --ignore-filename-regex 'applications/backend/command-api|applications/backend/query-api|packages/rust/shared-|applications/backend/graphql-gateway/src/server/main.rs' -- --test-threads=1`
4. `bash /Users/lihs/workspace/vocastock/scripts/ci/run_rust_quality_checks.sh --mode full`

## What Reviewers Should Be Able To Explain

- `/graphql` が public endpoint であり、initial slice では `registerVocabularyExpression` mutation と
  `vocabularyCatalog` query だけを受け付けること
- allowlist 外 operation は `unsupported-operation`、曖昧な multi-operation document は
  `ambiguous-operation` として拒否されること
- failure は `errors[0].code` と `errors[0].message` を持つ共通 body にそろえられること
- gateway が auth header を透過伝播し、request correlation は client 値優先・欠落時補完であること
- gateway が token verification、idempotency、read projection、workflow dispatch を own しないこと
- mutation は `command-api` の accepted / reused-existing / failed family、query は `query-api` の
  completed summary / status-only familyを public response へ写像すること

## Deferred Scope

- GraphQL schema 全体の拡張
- worker 起点 operation の追加
- cache / rate limit / alert policy
- downstream service の business contract 自体の変更
