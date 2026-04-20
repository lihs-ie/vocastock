# vocastock Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-20

# Development Style

TDD で開発する（探索 → Red → Green → Refactoring）。
KPI やカバレッジ目標が与えられたら、達成するまで試行する。
不明瞭な指示は質問して明確にする。

## Test Rules

- インラインテストではなく `tests` ディレクトリ配下に書く
- ユニットテストは `tests/unit/*`、統合テストは `tests/feature/*`、テストヘルパーは `tests/support/*` に配置する
- ユニットテストは実コードのファイルごとに対応するファイルを用意する。例: `src/sample1.rs` に対して `tests/unit/sample1.rs`
- feature テストは Rust のコードで、Firebase エミュレータと Docker コンテナを使ったテストとして作成する
- テストカバレッジは unit / feature 共通で 90% 以上を絶対条件とする

## Rust File Rules

- アプリケーション実装コードでは抽象的な `lib.rs` というファイル名を禁止する
- Rust の crate root は Cargo の `[lib].path` で責務が分かる名前にする
- 既存の `lib.rs` に集まった定義は、責務ごとに分割して意味のあるファイル名へ移す

# Code Specification

- 関心の分離を保つ
- 状態とロジックを分離する
- 可読性と保守性を重視する
- 静的検査可能なルールはプロンプトではなく、その環境の linterで記述する

## Active Technologies
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/development/*.md` (003-architecture-design)
- Git-managed repository files、設計上で参照する抽象的な永続化ストアとアセットストア (003-architecture-design)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/` (005-domain-modeling)
- Git-managed repository files、設計上で参照する抽象的な explanation storage と image asset storage (005-domain-modeling)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/` (005-domain-modeling)
- Git-managed repository files、設計上で参照する抽象的な learner store、explanation store、image asset store (005-domain-modeling)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/` (005-domain-modeling)
- Flutter 3.41.5 (stable), Dart SDK bundled with Flutter 3.41.5, shell scripts, YAML, GitHub Actions YAML + Flutter SDK 3.41.5, Xcode 26.4, Android Studio 2025.3, CocoaPods 1.16.2, Temurin JDK 21.0.10+7 LTS, Node.js 24.14.1 LTS, Firebase CLI 15.2.1, Docker Desktop 4.69.0, GitHub-hosted runners, Trivy Action 0.33.1 (005-domain-modeling)
- Git-managed repository files, Docker volumes for emulator data, GitHub Actions artifacts for CI reports (005-domain-modeling)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/service.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`、`specs/005-domain-modeling/` (007-backend-command-design)
- Git-managed repository files、設計上で参照する抽象的な command-side persistence、workflow state store、identity reference store (007-backend-command-design)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/service.md`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/` (008-auth-session-design)
- Git-managed repository files、設計上で参照する抽象的な auth account store、external identity link store、session store、actor resolution store (008-auth-session-design)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/service.md`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`、Flutter client auth UI、Firebase Authentication、Firebase ID token verification on backend (008-auth-session-design)
- Git-managed repository files、設計上で参照する抽象的な auth account store、external identity link store、session store、actor / learner resolution store、Firebase Authentication user records (008-auth-session-design)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/` (009-sense-modeling)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`、`specs/007-backend-command-design/`、`specs/008-auth-session-design/` (010-component-boundaries)
- Git-managed repository files、設計上で参照する抽象的な command state store、query read store、asset store、auth/session boundary outputs (010-component-boundaries)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/service.md`、`specs/007-backend-command-design/`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/` (010-component-boundaries)
- Git-managed repository files、設計上で参照する抽象的な subscription state store、purchase state store、entitlement store、usage metering store、store purchase artifact / notification ingest store (010-component-boundaries)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md`、`specs/007-backend-command-design/`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/` (011-api-command-io-design)
- Git-managed repository files、設計上で参照する抽象的な actor handoff output、command request log、idempotency store、workflow state store (011-api-command-io-design)
- Git-managed repository files、設計上で参照する抽象的な actor handoff output、command request log、actor-scoped idempotency store、workflow state store (011-api-command-io-design)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md`、`specs/007-backend-command-design/`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/`、`specs/011-api-command-io-design/` (012-persistence-workflow-design)
- Git-managed repository files、設計上で参照する抽象的な learner store、vocabulary expression store、learning state store、explanation store、visual image store、subscription authority store、purchase state store、entitlement snapshot store、usage allowance store、workflow runtime state store、dead-letter review store、read projection store (012-persistence-workflow-design)
- Markdown 1.x, YAML/JSON reference documents, Flutter 3.41.5 client design assumptions + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/`、`specs/011-api-command-io-design/`、`specs/012-persistence-workflow-design/`、Flutter navigation / state management guidance、Apple HIG、Material Design 3 (013-flutter-ui-state-design)
- Git-managed repository files、設計上で参照する abstract query readers、gate readers、command intake outputs、subscription status mirror、workflow status projection (013-flutter-ui-state-design)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/010-subscription-component-boundaries/`、`specs/011-api-command-io-design/`、`specs/012-persistence-workflow-design/`、`specs/013-flutter-ui-state-design/`、mobile storefront catalog 運用前提、backend entitlement / quota policy 前提 (014-billing-entitlement-policy)
- Git-managed repository files、設計上で参照する抽象的な product catalog store、entitlement policy table、quota policy table、feature gate rule set、subscription state effect table (014-billing-entitlement-policy)
- Markdown 1.x, YAML, JSON documentation artifacts + 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/004-tech-stack-definition/`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/`、`specs/011-api-command-io-design/`、`specs/012-persistence-workflow-design/`、`specs/013-flutter-ui-state-design/`、`specs/014-billing-entitlement-policy/` (015-command-query-topology)
- 抽象的な Cloud Run deployment topology、Firestore authoritative write / read projection、Pub/Sub durable handoff、Firebase Authentication、Google Drive asset storage (015-command-query-topology)
- Dockerfile syntax 1.x、Docker Compose specification、Bash、Rust 2021 workspace manifests、Markdown 1.x documentation artifacts + Docker-compatible runtime、Docker Compose、Cargo workspace (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`applications/backend/*`、`packages/rust/shared-auth`、`docker/firebase/`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/004-tech-stack-definition/`、`specs/011-api-command-io-design/`、`specs/012-persistence-workflow-design/`、`specs/015-command-query-topology/` (016-application-docker-env)
- Git-managed repository files、container image layers、local compose network、application env files、existing repository-wide local dependency stack (016-application-docker-env)
- Dockerfile syntax 1.x、Docker Compose specification、Bash、Rust 2021 workspace manifests、Markdown 1.x documentation artifacts + Docker-compatible runtime、Docker Compose、Cargo workspace (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/*`、`/Users/lihs/workspace/vocastock/packages/rust/shared-auth`、`/Users/lihs/workspace/vocastock/docker/firebase/`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/` (016-application-docker-env)
- Rust 2021 workspace、Markdown 1.x、Bash + Cargo workspace root (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/query-api/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-auth/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-runtime/`、Rust standard library HTTP skeleton、JSON serialization helper crate、`docs/external/adr.md`、`docs/external/requirements.md`、`specs/008-auth-session-design/`、`specs/012-persistence-workflow-design/`、`specs/013-flutter-ui-state-design/`、`specs/015-command-query-topology/`、`specs/016-application-docker-env/` (017-query-catalog-read)
- in-memory / stub read projection source for initial slice、Git-managed repository files、existing readiness / runtime env configuration (017-query-catalog-read)
- Rust 2021 workspace、Markdown 1.x、Bash + Cargo workspace root (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-auth/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-runtime/`、JSON serialization helper crate、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/007-backend-command-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/` (018-command-api-implementation)
- in-memory authoritative write stub、actor-scoped idempotency stub、workflow dispatch stub、Git-managed repository files、existing readiness / runtime env configuration (018-command-api-implementation)
- rollback 可能な in-memory authoritative write stub、actor-scoped idempotency stub、workflow dispatch stub、Git-managed repository files、existing readiness / runtime env configuration (018-command-api-implementation)
- GitHub Actions YAML、Bash、Rust 2021 workspace、Markdown 1.x + `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml`、`/Users/lihs/workspace/vocastock/Cargo.toml`、`/Users/lihs/workspace/vocastock/scripts/ci/install_toolchains.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/start_emulators.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/stop_emulators.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/smoke_local_stack.sh`、`/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh`、`/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/`、`/Users/lihs/workspace/vocastock/applications/backend/query-api/`、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`、`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/`、`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/` (019-rust-quality-ci)
- Git-managed workflow / script / test files、`.artifacts/ci/logs` と `.artifacts/ci/durations` の runtime artifact、Docker container / Firebase emulator の一時 runtime state (019-rust-quality-ci)
- Rust 2021 workspace、Markdown 1.x、Bash + Cargo workspace root (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/`、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/applications/backend/query-api/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-runtime/`、JSON serialization helper crate、lightweight HTTP client crate for downstream relay、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/008-auth-session-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`、`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/`、`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/` (020-graphql-gateway-implementation)
- N/A for authoritative state、Git-managed repository files、既存 readiness/runtime env configuration、request correlation string generation for relay-only use (020-graphql-gateway-implementation)

- Markdown 1.x, YAML, JSON + Spec Kit workflow, existing domain documents, requirements memo, ADR memo (001-complete-domain-model)

## Project Structure

```text
docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/
        ├── common.md
        ├── explanation.md
        ├── service.md
        └── visual.md

specs/
└── 001-complete-domain-model/
    ├── contracts/
    ├── data-model.md
    ├── plan.md
    ├── quickstart.md
    ├── research.md
    └── spec.md
```

## Commands

- Inspect current feature spec: `sed -n '1,220p' specs/001-complete-domain-model/spec.md`
- Inspect current implementation plan: `sed -n '1,260p' specs/001-complete-domain-model/plan.md`
- Search domain terminology across docs: `rg -n "VocabularyEntry|Explanation|VisualImage|Identifier|Proficiency|Generation" docs specs`

## Code Style

Markdown 1.x, YAML, JSON: Keep terminology consistent across `docs/internal/domain/`,
`docs/external/`, and `specs/`. When a domain boundary changes, update the affected
domain docs in the same change set. Identifier types must use `XxxIdentifier`,
an aggregate's own identifier field must be `identifier`, and related identifier
fields must use concept names such as `bank`, `entry`, or `image`.

## Recent Changes
- 020-graphql-gateway-implementation: Added Rust 2021 workspace、Markdown 1.x、Bash + Cargo workspace root (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/`、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/applications/backend/query-api/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-runtime/`、JSON serialization helper crate、lightweight HTTP client crate for downstream relay、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/008-auth-session-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`、`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/`、`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/`
- 019-rust-quality-ci: Added GitHub Actions YAML、Bash、Rust 2021 workspace、Markdown 1.x + `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml`、`/Users/lihs/workspace/vocastock/Cargo.toml`、`/Users/lihs/workspace/vocastock/scripts/ci/install_toolchains.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/start_emulators.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/stop_emulators.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/smoke_local_stack.sh`、`/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh`、`/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/`、`/Users/lihs/workspace/vocastock/applications/backend/query-api/`、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`、`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/`、`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/`
- 018-command-api-implementation: Added Rust 2021 workspace、Markdown 1.x、Bash + Cargo workspace root (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-auth/`、`/Users/lihs/workspace/vocastock/packages/rust/shared-runtime/`、JSON serialization helper crate、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/007-backend-command-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
