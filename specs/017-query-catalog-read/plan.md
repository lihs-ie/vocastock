# Implementation Plan: Query Catalog Read

**Branch**: `017-query-catalog-read` | **Date**: 2026-04-19 | **Spec**: [/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/spec.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`query-api` に `VocabularyCatalogProjection` の最小 read slice を実装する。対象は
`applications/backend/query-api/` に限定し、既存の readiness / Firebase dependency probe を
維持したまま、`query-api` 内部 route としての `GET /vocabulary-catalog`、completed summary /
status-only を分離する response shape、`shared-auth::VerifiedActorContext` による token
verification / actor handoff 再利用、in-memory / stub の projection source、`cargo test`
による contract 検証を追加する。`command-api`、worker、GraphQL schema 全体、Firestore 本実装、
gateway での public mapping は今回の scope 外とする。

## Technical Context

**Language/Version**: Rust 2021 workspace、Markdown 1.x、Bash  
**Primary Dependencies**: Cargo workspace root (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/query-api/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-auth/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-runtime/`、Rust standard library HTTP skeleton、JSON serialization helper crate、`docs/external/adr.md`、`docs/external/requirements.md`、`specs/008-auth-session-design/`、`specs/012-persistence-workflow-design/`、`specs/013-flutter-ui-state-design/`、`specs/015-command-query-topology/`、`specs/016-application-docker-env/`  
**Storage**: in-memory / stub read projection source for initial slice、Git-managed repository files、existing readiness / runtime env configuration  
**Testing**: `cargo test -p query-api --test unit`、`cargo test -p query-api --test feature`、response-shape review、read-only boundary review  
**Target Platform**: Rust `query-api` service on local Docker / Cloud Run-aligned runtime、unified endpoint 背後の internal read service  
**Project Type**: backend service implementation  
**Performance Goals**: catalog endpoint の completed / status-only 判定が単体テストで 100% 再現できること、既存 readiness endpoint を壊さないこと、projection lag 中に provisional completed payload を返さないこと  
**Constraints**: `query-api` は read-only のまま維持する、workflow 起動 / retry dispatch / authoritative write を持たない、token verification / actor handoff は既存 shared contract を再利用する、GraphQL schema 全体は拡張しない、Firestore 本実装は必須にしない、`VocabularyExpressionDetail` 用 detail payload を catalog response に混ぜない  
**Scale/Scope**: `VocabularyCatalogProjection` 1 internal route、catalog response 1 系統、actor handoff reuse 1 系統、projection source abstraction 1 個、query-api crate 内ユニット / endpoint テスト更新

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain change`. `docs/internal/domain/*.md` の aggregate、
      value object、repository contract は変更せず、query read surface と projection
      assembly の実装 slice のみを扱う。
- [x] Async generation visibility remains intact. catalog read は completed summary と
      status-only だけを返し、不完全な生成結果や provisional completed payload を
      ユーザーへ見せない。
- [x] External dependencies remain behind ports/adapters. token verification / actor handoff
      は `shared-auth` を再利用し、projection source は in-memory / stub abstraction 越しに
      導入する。
- [x] User stories remain independently implementable and testable. catalog endpoint、
      auth/session reuse、UI visibility guarantee は別 artifact としてレビュー可能。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態、subscription /
      entitlement を混同しない。catalog response は summary / status のみを返し、
      detail payload や premium unlock 確定情報を前倒し公開しない。
- [x] Identifier naming follows the constitution. `id` / `xxxId` を新規正本語彙として
      導入せず、関連参照は概念名ベースで扱う。

Post-design re-check: PASS. Verified against `/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/research.md`,
`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/data-model.md`,
`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/vocabulary-catalog-read-contract.md`,
`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/query-auth-handoff-contract.md`,
`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/catalog-visibility-contract.md`, and
`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/query-read-scope-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/017-query-catalog-read/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── catalog-visibility-contract.md
│   ├── query-auth-handoff-contract.md
│   ├── query-read-scope-boundary-contract.md
│   └── vocabulary-catalog-read-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
Cargo.toml

applications/
└── backend/
    └── query-api/
        ├── Cargo.toml
        ├── src/
            ├── query_catalog_read.rs
            ├── catalog_model.rs
            ├── catalog_read.rs
            ├── catalog_source.rs
            ├── service_contract.rs
            ├── stub_token_verifier.rs
            └── main.rs
        └── tests/
            ├── feature.rs
            ├── feature/
            │   └── vocabulary_catalog.rs
            ├── support/
            │   ├── feature.rs
            │   └── unit.rs
            └── unit.rs

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
    └── query-api/
        └── Dockerfile

docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/

specs/
├── 008-auth-session-design/
├── 012-persistence-workflow-design/
├── 013-flutter-ui-state-design/
├── 015-command-query-topology/
├── 016-application-docker-env/
└── 017-query-catalog-read/
```

**Structure Decision**: 実装は `applications/backend/query-api/` に閉じ、`src/query_catalog_read.rs`
を責務名付き crate root とし、`catalog_model.rs`、`catalog_read.rs`、`catalog_source.rs`、
`service_contract.rs`、`stub_token_verifier.rs` へ catalog read の定義を分割する。`src/main.rs` に
`query-api` 内部 route である `GET /vocabulary-catalog` と auth/session 入口を置く。
`tests/unit.rs` と `tests/feature.rs` を Rust test harness とし、`tests/unit/*`、
`tests/feature/*`、`tests/support/*` を正本テスト配置とする。feature テストは Rust の
integration test から Docker compose と Firebase emulator を起動・接続して検証する。`shared-auth` は
`VerifiedActorContext` を含む既存 contract の再利用に留める。`shared-runtime` の readiness /
dependency probe はそのまま維持する。runtime / Docker の正本は 016 を引き継ぐため、必要が
ない限り `docker/applications/query-api/Dockerfile` は変更しない。external docs は canonical
rule の変更が無い限り更新対象にしない。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
