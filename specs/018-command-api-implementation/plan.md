# Implementation Plan: Command API Implementation

**Branch**: `018-command-api-implementation` | **Date**: 2026-04-20 | **Spec**: [/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/spec.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`command-api` に `registerVocabularyExpression` の最小 write slice を実装する。対象は
`applications/backend/command-api/` に限定し、既存の readiness / Firebase dependency probe を
維持したまま、`command-api` 内部 route としての登録 command 受理、011 由来の request /
response envelope、actor-scoped idempotency、`accepted / reused-existing` と
`statusHandle`、`dispatch-failed`、`startExplanation = false`、省略時
`startExplanation = true`、canonical text normalization、dispatch failure 時に write を
確定させない rollback 前提の in-memory / stub write/idempotency/dispatch port、Rust の
unit / feature テスト、coverage 90% 以上の達成を追加する。`query-api`、worker 本体、
GraphQL schema 全体、Firestore 本実装、gateway での public binding は今回の scope 外とする。

## Technical Context

**Language/Version**: Rust 2021 workspace、Markdown 1.x、Bash  
**Primary Dependencies**: Cargo workspace root (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-auth/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-runtime/`、JSON serialization helper crate、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/007-backend-command-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`  
**Storage**: rollback 可能な in-memory authoritative write stub、actor-scoped idempotency stub、workflow dispatch stub、Git-managed repository files、existing readiness / runtime env configuration  
**Testing**: `cargo test -p command-api --test unit`、`cargo test -p command-api --test feature`、`cargo llvm-cov -p command-api --tests --summary-only`、Rust feature test with Docker container + Firebase emulator、request/response contract review  
**Target Platform**: Rust `command-api` service on local Docker / Cloud Run-aligned runtime、unified endpoint 背後の internal command service  
**Project Type**: backend service implementation  
**Performance Goals**: register command の accepted / reused-existing / failure 判定がテストで一貫再現されること、既存 readiness endpoint を壊さないこと、completed payload を返さない visible guarantee を維持すること、coverage 90% 以上を達成すること  
**Constraints**: `command-api` は accepted / reused-existing / rejected / failed と `statusHandle` だけを返す、completed payload を返さない、`dispatch-failed` 時は accepted を返さず registration write も確定させない、`shared-auth::VerifiedActorContext` を再利用する、`startExplanation = false` は登録 command にのみ許可し、省略時は `true` として扱う、`text` の canonical normalization は前後空白除去・小文字化・連続内部空白の 1 文字化で固定する、`src/lib.rs` のような抽象名は使わず責務名付き crate root に分割する、unit テストは `src` mirror 配置、feature テストは Rust コードで Docker / Firebase emulator を使う、GraphQL schema 全体や Firestore 本実装は扱わない  
**Scale/Scope**: 1 internal command route、1 command (`registerVocabularyExpression`)、1 accepted response family、1 duplicate reuse path、1 idempotency replay/conflict path、1 dispatch-failed + rollback path、1 omitted-default-true path、1 command-api crate refactor

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain change`. `docs/internal/domain/*.md` の aggregate、
      value object、repository contract は変更せず、`command-api` の command acceptance
      surface と in-memory / stub port 実装だけを扱う。
- [x] Async generation visibility remains intact. `command-api` は accepted / statusHandle
      だけを返し、不完全な生成結果や completed payload をユーザーへ見せない。dispatch failure
      では accepted を返さず、write も確定させない。
- [x] External dependencies remain behind ports/adapters. token verification / actor handoff
      は `shared-auth` を再利用し、authoritative write、idempotency、dispatch は stub port
      越しに導入する。
- [x] User stories remain independently implementable and testable. register acceptance、
      auth/idempotency reuse、dispatch/visibility guarantee は別 artifact としてレビュー可能。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態、subscription /
      entitlement を混同しない。`command-api` は registration / explanation summary だけを
      返し、query payload や completed asset を返さない。
- [x] Identifier naming follows the constitution. `id` / `xxxId` を新規正本語彙として
      導入せず、関連参照は概念名ベースで扱う。

Post-design re-check: PASS. Verified against `/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/research.md`,
`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/data-model.md`,
`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/register-vocabulary-command-contract.md`,
`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/command-auth-idempotency-contract.md`,
`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/command-dispatch-visibility-contract.md`, and
`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/command-runtime-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/018-command-api-implementation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── command-auth-idempotency-contract.md
│   ├── command-dispatch-visibility-contract.md
│   ├── command-runtime-boundary-contract.md
│   └── register-vocabulary-command-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
Cargo.toml

applications/
└── backend/
    └── command-api/
        ├── Cargo.toml
        ├── src/
        │   ├── register_command_api/
        │   │   ├── mod.rs
        │   │   ├── command/
        │   │   │   ├── mod.rs
        │   │   │   ├── acceptance.rs
        │   │   │   ├── request.rs
        │   │   │   └── response.rs
        │   │   ├── http/
        │   │   │   ├── mod.rs
        │   │   │   └── endpoint.rs
        │   │   └── runtime/
        │   │       ├── mod.rs
        │   │       ├── command_store.rs
        │   │       ├── dispatch_port.rs
        │   │       ├── service_contract.rs
        │   │       └── stub_token_verifier.rs
        │   └── server/
        │       └── main.rs
        └── tests/
            ├── feature.rs
            ├── feature/
            │   └── register_vocabulary_command.rs
            ├── support/
            │   ├── feature.rs
            │   └── unit.rs
            ├── unit.rs
            └── unit/
                └── register_command_api/
                    ├── mod.rs
                    ├── command/
                    │   ├── acceptance.rs
                    │   ├── request.rs
                    │   └── response.rs
                    ├── http/
                    │   └── endpoint.rs
                    └── runtime/
                        ├── command_store.rs
                        ├── dispatch_port.rs
                        ├── service_contract.rs
                        └── stub_token_verifier.rs

packages/
└── rust/
    ├── shared-auth/
    │   └── src/
    │       └── lib.rs
    └── shared-runtime/
        └── src/
            └── lib.rs

docker/
└── applications/
    └── command-api/
        └── Dockerfile

docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/

scripts/
├── ci/
│   └── run_application_container_smoke.sh
└── bootstrap/
    └── validate_local_stack.sh

specs/
├── 007-backend-command-design/
├── 011-api-command-io-design/
├── 012-persistence-workflow-design/
├── 015-command-query-topology/
├── 016-application-docker-env/
└── 018-command-api-implementation/
```

**Structure Decision**: 実装は `applications/backend/command-api/` に閉じ、`src/lib.rs` /
`src/main.rs` の flat 構成から、責務名付き crate root `src/register_command_api/` と
`src/server/main.rs` へ分割する。`command/` には request / response / acceptance rule を置き、
request parser は `text` の canonical normalization と `startExplanation` omitted default
`true` を担う。`http/` には internal route と failure mapping を置き、`runtime/` には token
verification reuse、authoritative write / idempotency / dispatch stub port を配置し、
dispatch failure 時は registration write を確定させない rollback 前提を持たせる。テストは
`tests/unit/` を `src/register_command_api/` mirror にし、
`tests/feature/register_vocabulary_command.rs` を Rust コードで Docker compose と Firebase
emulator を使う feature test とする。runtime / Docker の正本は 016 を引き継ぐため、必要が
ない限り `docker/applications/command-api/Dockerfile` の責務を広げない。external docs は
canonical rule の変更がない限り更新対象にしない。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
