# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

vocastock は英単語の解説生成と視覚イメージ生成を扱うアプリケーションの polyglot monorepo。Rust (API services + shared) と Haskell (workers) を組み合わせたバックエンド、Flutter クライアント、Firebase を中心とした CQRS 構成。

**開発モデル**: Spec Kit ベースの仕様駆動開発。憲章 `.specify/memory/constitution.md` が最上位、次に `docs/internal/domain/*.md` と `specs/NNN-*/` が続く。実装は必ず設計文書の更新と同じ変更セットで行う。

## Repository Structure

```
applications/backend/
├── graphql-gateway/      Rust — client-facing unified GraphQL endpoint
├── command-api/          Rust — command acceptance / write / dispatch
├── query-api/            Rust — completed result / status-only / subscription read
├── explanation-worker/   Haskell — explanation workflow consumer
├── image-worker/         Haskell — image workflow consumer
└── billing-worker/       billing / restore / notification reconciliation

packages/rust/
├── shared-auth/          sidecar-only: auth / session handoff
└── shared-runtime/       sidecar-only: logging / monitoring / readiness / correlation

docker/applications/      Dockerfile は `docker/applications/<application>/` が正本
docker/firebase/          repository-wide shared dependency stack (別管理)
.specify/memory/          constitution.md — 最上位の設計憲章
docs/internal/domain/     正本ドメイン文書 (common, learner, vocabulary-expression, learning-state, explanation, visual, service)
docs/external/            requirements.md, adr.md
specs/NNN-<slug>/         機能ごとの spec.md / plan.md / tasks.md など
```

## Core Architectural Principles (from constitution v2.1.0)

1. **アプリケーション単位のドメイン所有**: domain model / workflow state / application coordination は **owning application 配下** に実装する。複数 application に同名概念が必要でも、shared executable domain package を新設してはならない。
2. **shared package はサイドカー限定**: `packages/rust/shared-*` には logging / monitoring / auth-session handoff / request correlation / readiness probe / runtime helper のみ。aggregate / domain service / workflow state machine / persistence model / application use-case は禁止。
3. **inner layer package の事前定義**: 各 application の inner layer package / module の名前、配置先、依存方向は、実装前に `specs/NNN/plan.md` に明記する。
4. **非同期生成は完了結果のみ公開**: `pending` / `running` / `succeeded` / `failed` を区別し、ユーザーへは完了結果のみ表示。生成中や失敗中の本体は表示しない。
5. **外部依存はポート越し**: AI サービス、画像ストレージ等はドメイン層から直接呼ばず、ポート/アダプタ経由で接続。ベンダー SDK をドメインへ持ち込まない。
6. **学習概念を混同しない**: 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態を別概念として扱う。UI 文言、API、永続化、分析軸で混同しない。

## Naming Constraints (厳守)

- 識別子型は **`XxxIdentifier` 形式**。`id` / `ID` / `xxxId` は型名・フィールド名・契約名として使用禁止。
- 集約自身の識別子フィールド名は常に **`identifier`**。
- 集約が他集約/他概念の識別子を保持する場合、フィールド名は **概念名そのもの** (例: `User.bank: BankIdentifier`)。`bankIdentifier` や `bankId` は禁止。
- `Detail` / `Info` のような含意の広い語はドメイン命名に使用禁止。

## Rust Conventions

- Cargo workspace root: `/Users/lihs/workspace/vocastock/Cargo.toml` (`resolver = "2"`, edition 2021)。
- `workspace.lints.rust.unsafe_code = "forbid"`。
- **`lib.rs` 禁止**: crate root は `[lib].path` で責務が分かる名前にする (例: `src/register_command_api/mod.rs`, `src/query_catalog_read/mod.rs`, `src/gateway_routing/mod.rs`)。既存の `lib.rs` に集まった定義は責務ごとに分割して移す。
- レイヤー: `presentation → application → domain ← infrastructure`。
- アプリケーションは必ず `shared-auth` / `shared-runtime` を依存として使う。

## Haskell Conventions

- GHC `9.2.8`、`default-language: GHC2021`。
- package-local Cabal manifest (`<worker>.cabal`)。
- モジュール階層は `<WorkerName>/...` (例: `ExplanationWorker.WorkflowStateMachine`, `ImageWorker.AssetStoragePort`)。
- ポート/アダプタは separate module として切り出す (`GenerationPort`, `AssetStoragePort`, `ImagePersistence`, `CurrentExplanationHandoff` 等)。

## Test Rules

- **TDD 必須** (探索 → Red → Green → Refactoring)。
- 配置: `tests/unit/*` (unit)、`tests/feature/*` (integration — Firebase エミュレータ + Docker)、`tests/support/*` (helper)。インラインテスト (`#[cfg(test)] mod tests`) は使わない。
- 対応規則: `src/sample1.rs` → `tests/unit/sample1.rs` のようにファイル単位で対応させる。
- **カバレッジ 90% 以上が絶対条件** (unit / feature 共通)。
- Rust では `Cargo.toml` の `[[test]]` エントリ (`name = "unit"`, `name = "feature"`) で unit/feature を分ける。
- Haskell では `test-suite unit` と `test-suite feature` を `.cabal` に分ける。feature は Docker/emulator を起動する形で `process`, `directory`, `filepath` を使う。

## Common Commands

**Rust quality gate** (workspace 全体):
```bash
bash scripts/ci/run_rust_quality_checks.sh --mode full
# fmt → clippy → query-api unit → command-api unit → feature-all
```

**Rust 個別サービスのテスト** (例: command-api):
```bash
cargo test -p command-api --test unit
cargo test -p command-api --test feature
```

**Haskell worker のビルド/テスト**:
```bash
cd applications/backend/explanation-worker
cabal build all
cabal test unit
cabal test feature
```

**アプリケーションコンテナ検証**:
```bash
bash scripts/bootstrap/validate_application_containers.sh      # contract validate
bash scripts/ci/run_application_container_smoke.sh             # application smoke (ポート競合時は空きポートへ自動退避)
bash scripts/bootstrap/validate_local_stack.sh --with-application-containers  # Firebase emulator + application smoke
```

**Firebase emulator のみ**:
```bash
bash scripts/firebase/start_emulators.sh
bash scripts/firebase/smoke_local_stack.sh
bash scripts/firebase/stop_emulators.sh
```

**ホスト環境検証**:
```bash
bash scripts/bootstrap/verify_macos_toolchain.sh   # host baseline 検証
bash scripts/bootstrap/validate_local_setup.sh     # local setup 検証
```

**Rust 変更検出** (CI と同じロジックをローカル再現):
```bash
bash scripts/ci/detect_rust_changes.sh --base origin/main --head HEAD
```

## Docker / Container Contract

- Docker 関連ファイルは **`docker/applications/<application>/` が正本**。
- API の既定 host port は **`18180-18182`** (Firebase emulator の `18080` と競合回避)。
- local / CI は同じ Dockerfile / target / entry contract を使う (image artifact 共有は必須ではない)。
- **canonical success signal**:
  - API service → `HTTP readiness endpoint` (`VOCAS_READINESS_PATH`, 既定 `/readyz`)
  - worker → `long-running consumer` の stable-run (`VOCAS_WORKER_STABLE_RUN_SECONDS`)
- `rust-quality` ジョブは Rust path 非該当時は no-op success、該当時は `fmt → clippy → query-api unit → command-api unit → feature-all` を実行する。

## Development Workflow

1. **仕様確認**: 対象機能の `specs/NNN-*/spec.md` を確認。変更が必要なら同じ PR で更新。
2. **plan の inner layer 定義**: 新規実装前に `plan.md` に inner layer package の名前/配置/依存方向を記述。
3. **ドメイン文書の同期更新**: ドメイン境界を変える変更は `docs/internal/domain/*.md` を **同じ変更セットで更新**。先行実装は禁止。
4. **TDD**: テスト (Red) → 実装 (Green) → リファクタ (Improve)。
5. **pre-commit 検証** (該当する場合すべて):
   - Rust: `cargo fmt --all` / `cargo clippy --all-targets -- -D warnings` / `cargo test --all`
   - Haskell: `cabal build all` / `cabal test all`
   - Container: `bash scripts/bootstrap/validate_application_containers.sh`
6. **commit**: Conventional Commits + scope 必須 (例: `feat(command-api): ...`, `feat(explanation-worker): ...`, `chore(ci): ...`)。

## Key References

- 憲章: `.specify/memory/constitution.md` (変更は MAJOR/MINOR/PATCH でバージョン管理)
- ドメイン正本: `docs/internal/domain/{common,learner,vocabulary-expression,learning-state,explanation,visual,service}.md`
- ADR / 要件: `docs/external/{adr,requirements}.md`
- Backend container contract: `docs/development/backend-container-environment.md`
- CI policy: `docs/development/ci-policy.md`
- 承認済みコンポーネントバージョン: `tooling/versions/approved-components.md`
- auto-generated guidelines: `AGENTS.md` (最新の Spec Kit 出力)

## Special Notes

- 生成中または失敗中の中間生成結果はユーザーへ表示しない。完了済み結果のみ表示する。
- shared package 配下へ domain を入れようとしたら、それは憲章違反 — owning application 配下に移す。
- 新しい外部依存を追加する場合、タイムアウト/再試行/障害時代替動作を `plan.md` に必ず記載する。
- `references/` ディレクトリは参考実装のコピー。vocastock 本体の実装対象ではない。
