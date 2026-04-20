# Implementation Plan: GraphQL Gateway Implementation

**Branch**: `020-graphql-gateway-implementation` | **Date**: 2026-04-20 | **Spec**: [/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/spec.md](/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`graphql-gateway` に unified public GraphQL endpoint の最小実装スライスを追加する。中核実装は
`applications/backend/graphql-gateway/` に置きつつ、runtime / CI 整合のため
`docker/applications/graphql-gateway/Dockerfile`、`docker/applications/compose.yaml`、
`scripts/ci/run_application_container_smoke.sh`、`scripts/ci/run_rust_quality_checks.sh`、
`.github/workflows/ci.yml` までを必要最小限の更新対象に含める。既存の readiness / Firebase
dependency probe を維持したまま、`registerVocabularyExpression` mutation と
`vocabularyCatalog` query の 2 operation だけを allowlist 公開する。gateway は public GraphQL
request envelope、1 request 1 operation の validation、`unsupported-operation` /
`ambiguous-operation` / downstream failure を共通 envelope に写像する failure shaping、
auth header / request correlation の propagation、`command-api` / `query-api` の既存 internal
route への relay、`dispatch-failed` / `idempotency-conflict` を含む command visible guarantee
の public binding、Rust の unit / feature テスト、coverage 90% 以上を追加する。GraphQL schema
全体の拡張、worker 起点 operation、cache / rate limit policy、downstream service の token
verification 実装変更は今回の scope 外とする。

## Technical Context

**Language/Version**: Rust 2021 workspace、Markdown 1.x、Bash  
**Primary Dependencies**: Cargo workspace root (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/`、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/applications/backend/query-api/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-runtime/`、JSON serialization helper crate、lightweight HTTP client crate for downstream relay、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/008-auth-session-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`、`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/`、`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/`  
**Storage**: N/A for authoritative state、Git-managed repository files、既存 readiness/runtime env configuration、request correlation string generation for relay-only use  
**Testing**: `cargo test -p graphql-gateway --test unit`、`cargo test -p graphql-gateway --test feature -- --nocapture`、`cargo llvm-cov -p graphql-gateway --tests --summary-only`、Rust feature test with Docker containers + Firebase emulator + downstream services、public GraphQL contract review  
**Target Platform**: Rust `graphql-gateway` service on local Docker / Cloud Run-aligned runtime、Flutter mobile client 向け unified GraphQL endpoint front  
**Project Type**: backend gateway service implementation  
**Performance Goals**: allowlisted mutation/query の public binding が feature test で 100% 再現できること、既存 readiness endpoint を壊さないこと、public failure category が unit test で一貫再現できること、coverage 90% 以上を達成すること  
**Constraints**: initial slice は `POST /graphql` の public endpoint に限定する、allowlist は `registerVocabularyExpression` と `vocabularyCatalog` の 2 operation のみ、1 request 1 operation を前提とし曖昧な document は `ambiguous-operation` で拒否する、gateway は auth propagation と request correlation propagation のみを行い token verification / idempotency / projection ownership / workflow dispatch を持たない、public failure は `code` と `message` 必須の共通 envelope を使う、feature テストは Rust コードから Docker / Firebase emulator を使う、`src/lib.rs` のような抽象名は使わず責務名付き crate root を維持する  
**Scale/Scope**: 1 public GraphQL endpoint、2 allowlisted operations、2 downstream relay adapters、1 public failure envelope family、1 request correlation propagation rule、1 gateway crate refactor、5 runtime / CI touchpoints

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain change`. `docs/internal/domain/*.md` の aggregate、
      value object、repository contract は変更せず、public GraphQL binding と gateway relay の
      実装 slice のみを扱う。
- [x] Async generation visibility remains intact. gateway は completed payload を合成せず、
      mutation では accepted / reused-existing / failed、query では completed summary /
      status-only だけを relay する。
- [x] External dependencies remain behind ports/adapters. downstream `command-api` /
      `query-api` 呼び出しは relay adapter 越しに扱い、Firebase dependency probe は既存
      `shared-runtime` を再利用する。
- [x] User stories remain independently implementable and testable. public operation allowlist、
      auth/correlation propagation、runtime / feature validation は別 artifact としてレビュー可能。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態、subscription /
      entitlement を混同しない。gateway は downstream の visible guarantee を relay するだけで、
      独自の completed state を生成しない。
- [x] Identifier naming follows the constitution. `id` / `xxxId` を public GraphQL binding の
      新規正本語彙として導入せず、既存の `identifier` 命名を public transport 上でも維持する。

Post-design re-check: PASS. Verified against `/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/research.md`,
`/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/data-model.md`,
`/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/public-graphql-operation-contract.md`,
`/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/gateway-auth-correlation-contract.md`,
`/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/gateway-failure-envelope-contract.md`, and
`/Users/lihs/workspace/vocastock/specs/020-graphql-gateway-implementation/contracts/gateway-runtime-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/020-graphql-gateway-implementation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── gateway-auth-correlation-contract.md
│   ├── gateway-failure-envelope-contract.md
│   ├── gateway-runtime-boundary-contract.md
│   └── public-graphql-operation-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
Cargo.toml

applications/
└── backend/
    ├── graphql-gateway/
    │   ├── Cargo.toml
    │   ├── src/
    │   │   ├── gateway_routing/
    │   │   │   ├── mod.rs
    │   │   │   ├── graphql/
    │   │   │   │   ├── mod.rs
    │   │   │   │   ├── operation_allowlist.rs
    │   │   │   │   ├── public_request.rs
    │   │   │   │   ├── public_response.rs
    │   │   │   │   └── failure_envelope.rs
    │   │   │   ├── downstream/
    │   │   │   │   ├── mod.rs
    │   │   │   │   ├── command_relay.rs
    │   │   │   │   ├── query_relay.rs
    │   │   │   │   └── relay_client.rs
    │   │   │   └── runtime/
    │   │   │       ├── mod.rs
    │   │   │       ├── http_endpoint.rs
    │   │   │       ├── server_runtime.rs
    │   │   │       └── service_contract.rs
    │   │   └── server/
    │   │       └── main.rs
    │   └── tests/
    │       ├── feature.rs
    │       ├── feature/
    │       │   └── public_graphql_gateway.rs
    │       ├── support/
    │       │   ├── feature.rs
    │       │   └── unit.rs
    │       ├── unit.rs
    │       └── unit/
    │           └── gateway_routing/
    │               ├── mod.rs
    │               ├── graphql/
    │               │   ├── operation_allowlist.rs
    │               │   ├── public_request.rs
    │               │   ├── public_response.rs
    │               │   └── failure_envelope.rs
    │               ├── downstream/
    │               │   ├── command_relay.rs
    │               │   ├── query_relay.rs
    │               │   └── relay_client.rs
    │               ├── runtime/
    │               │   ├── http_endpoint.rs
    │               │   ├── server_runtime.rs
    │               │   └── service_contract.rs
    │               └── shared_runtime.rs
    ├── command-api/
    │   └── src/
    │       └── register_command_api/
    └── query-api/
        └── src/
            └── query_catalog_read/

packages/
└── rust/
    └── shared-runtime/
        └── src/
            └── lib.rs

docker/
└── applications/
    ├── graphql-gateway/
    │   └── Dockerfile
    └── compose.yaml

docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/

specs/
├── 008-auth-session-design/
├── 011-api-command-io-design/
├── 012-persistence-workflow-design/
├── 015-command-query-topology/
├── 016-application-docker-env/
├── 017-query-catalog-read/
├── 018-command-api-implementation/
└── 020-graphql-gateway-implementation/
```

**Structure Decision**: 中核実装は `applications/backend/graphql-gateway/` に閉じ、既存の
`src/gateway_routing/` を責務名付き crate root として維持する。その下で `graphql/` に public
GraphQL request / allowlist / response / failure envelope を置き、`downstream/` に
`command-api` / `query-api` への relay adapter と共通 client を置き、`runtime/` に
`/graphql` を含む HTTP dispatch と readiness/runtime 契約を置く。`tests/unit/` は
`src/gateway_routing/` を mirror し、`tests/feature/public_graphql_gateway.rs` は Rust コードから
Docker compose と Firebase emulator、`command-api`、`query-api` を起動・再利用して public
GraphQL binding を検証する。runtime / CI 契約を維持するため、
`docker/applications/graphql-gateway/Dockerfile`、`docker/applications/compose.yaml`、
`scripts/ci/run_application_container_smoke.sh`、`scripts/ci/run_rust_quality_checks.sh`、
`.github/workflows/ci.yml` もこの feature の付随更新対象に含める。017 / 018 の internal route
契約は downstream adapter の入力正本とし、外部 docs は canonical rule に変更がある場合にだけ更新する。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
