# Implementation Plan: Rust Quality CI

**Branch**: `019-rust-quality-ci` | **Date**: 2026-04-20 | **Spec**: [/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/spec.md](/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`.github/workflows/ci.yml` に `rust-quality` job を追加し、Rust 関連 path 変更時のみ
full 実行、非該当時は no-op success を返す required check として設計する。full 実行では
repo-local script により `cargo fmt --all -- --check`、`cargo clippy --workspace --all-targets -- -D warnings`、
`query-api` / `command-api` の unit test、全 Rust アプリ向け Docker/Firebase feature test を
一貫した log / artifact 出力付きで流す。feature scope を満たすため、`graphql-gateway` にも
Rust feature test harness を追加し、既存の emulator script と container contract を再利用する。

## Technical Context

**Language/Version**: GitHub Actions YAML、Bash、Rust 2021 workspace、Markdown 1.x  
**Primary Dependencies**: `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml`、`/Users/lihs/workspace/vocastock/Cargo.toml`、`/Users/lihs/workspace/vocastock/scripts/ci/install_toolchains.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/start_emulators.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/stop_emulators.sh`、`/Users/lihs/workspace/vocastock/scripts/firebase/smoke_local_stack.sh`、`/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh`、`/Users/lihs/workspace/vocastock/applications/backend/graphql-gateway/`、`/Users/lihs/workspace/vocastock/applications/backend/query-api/`、`/Users/lihs/workspace/vocastock/applications/backend/command-api/`、`/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`、`/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/`、`/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/`  
**Storage**: Git-managed workflow / script / test files、`.artifacts/ci/logs` と `.artifacts/ci/durations` の runtime artifact、Docker container / Firebase emulator の一時 runtime state  
**Testing**: `cargo fmt --all -- --check`、`cargo clippy --workspace --all-targets -- -D warnings`、`cargo test -p query-api --test unit`、`cargo test -p command-api --test unit`、`cargo test -p graphql-gateway --test feature -- --nocapture`、`cargo test -p query-api --test feature -- --nocapture`、`cargo test -p command-api --test feature -- --nocapture`、GitHub Actions workflow review  
**Target Platform**: GitHub-hosted `ubuntu-24.04` runner、local CI reproduction shell、Docker-compatible developer host  
**Project Type**: CI workflow and backend quality automation  
**Performance Goals**: Rust path 非該当 run は no-op success で速やかに完了すること、Rust quality failure 時に reviewer が 5 分以内に失敗 segment を特定できること、全 Rust アプリの feature test を required gate に載せること  
**Constraints**: required check 名は安定させる、Rust 関連 path 変更時のみ full 実行、変更無しでは no-op success、`query-api` / `command-api` の unit test は required、全 Rust アプリの feature test は Docker/Firebase 前提で実行、既存 `toolchain-validate` と整合、既存 Flutter / Android / vulnerability / smoke job を上書きしない、Rust アプリを触る場合は AGENTS の test / naming rule に従う  
**Scale/Scope**: 1 workflow job、2 helper scripts、1 path catalog、3 Rust application profiles、2 explicit unit suites、3 feature suites、1 Rust artifact bundle

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain change`. この feature は CI workflow、scripts、
      Rust test harness、artifact 出力を対象にし、`docs/internal/domain/*.md` の aggregate、
      value object、repository contract は変更しない。
- [x] Async generation visibility remains intact. feature test は Docker/Firebase runtime を
      CI で再現するだけで、未完了生成結果の user-visible rule は 016 / 017 / 018 の正本を
      再利用する。
- [x] External dependencies remain behind ports/adapters. Docker engine、Firebase emulator、
      GitHub Actions workflow、Cargo commands は既存 script / test harness 越しに扱い、
      ドメイン層へ vendor 依存を持ち込まない。
- [x] User stories remain independently implementable and testable. static gate、unit gate、
      feature gate、path gating / no-op success、artifact reporting は別 artifact として
      レビュー可能である。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態は今回も変更せず、
      CI runtime 概念と混同しない。
- [x] Identifier naming rule は維持する。`graphql-gateway` を含む Rust アプリ側で新しい
      module / test harness を追加する場合も `id` / `xxxId` を正本語彙として導入しない。

Post-design re-check: PASS. Verified against `/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/research.md`,
`/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/data-model.md`,
`/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/contracts/rust-quality-job-contract.md`,
`/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/contracts/rust-path-gating-contract.md`,
`/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/contracts/rust-test-catalog-contract.md`,
`/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/contracts/rust-feature-runtime-contract.md`, and
`/Users/lihs/workspace/vocastock/specs/019-rust-quality-ci/contracts/rust-artifact-reporting-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/019-rust-quality-ci/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── rust-artifact-reporting-contract.md
│   ├── rust-feature-runtime-contract.md
│   ├── rust-path-gating-contract.md
│   ├── rust-quality-job-contract.md
│   └── rust-test-catalog-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
Cargo.toml

.github/
└── workflows/
    └── ci.yml

applications/
└── backend/
    ├── graphql-gateway/
    │   ├── Cargo.toml
    │   ├── src/
    │   │   ├── gateway_routing/
    │   │   │   └── mod.rs
    │   │   └── server/
    │   │       └── main.rs
    │   └── tests/
    │       ├── feature.rs
    │       ├── feature/
    │       │   └── gateway_routing.rs
    │       ├── support/
    │       │   └── feature.rs
    │       ├── unit.rs
    │       └── unit/
    │           └── gateway_routing/
    │               └── mod.rs
    ├── query-api/
    │   ├── Cargo.toml
    │   └── tests/
    │       ├── unit.rs
    │       ├── feature.rs
    │       ├── feature/
    │       │   └── vocabulary_catalog.rs
    │       └── support/
    │           └── feature.rs
    └── command-api/
        ├── Cargo.toml
        └── tests/
            ├── unit.rs
            ├── feature.rs
            ├── feature/
            │   └── register_vocabulary_command.rs
            └── support/
                └── feature.rs

packages/
└── rust/
    ├── shared-auth/
    └── shared-runtime/

scripts/
├── ci/
│   ├── detect_rust_changes.sh
│   ├── install_toolchains.sh
│   ├── run_rust_quality_checks.sh
│   └── run_application_container_smoke.sh
├── firebase/
│   ├── start_emulators.sh
│   ├── stop_emulators.sh
│   └── smoke_local_stack.sh
└── lib/
    └── vocastock_env.sh

docker/
├── applications/
│   └── compose.yaml
└── firebase/
    ├── compose.yaml
    └── env/

docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── development/
    └── backend-container-environment.md

specs/
├── 006-ci-emulator-build/
├── 016-application-docker-env/
├── 017-query-catalog-read/
├── 018-command-api-implementation/
└── 019-rust-quality-ci/
```

**Structure Decision**: workflow の制御は `.github/workflows/ci.yml` に追加する
`rust-quality` job と、repo-local の `scripts/ci/detect_rust_changes.sh` /
`scripts/ci/run_rust_quality_checks.sh` に集約する。path gating は job の前段で実行し、
branch protection と整合する no-op success を返せるようにする。feature test を全 Rust
アプリへ広げるため、`graphql-gateway` も AGENTS の test / naming rule に従う形へ
再構成し、`src/lib.rs` / inline test 依存から責務名付き module + `tests/` 配下の harness へ
移す。`query-api` と `command-api` の既存 Rust feature test は shared emulator session を
再利用する前提で、CI runner 内の 1 回の emulator lifecycle に載せる。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
