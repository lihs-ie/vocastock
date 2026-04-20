# Contract: Rust Path Gating

## Purpose

Rust quality job を full 実行する変更範囲と、no-op success に倒す条件を固定する。

## Detection Inputs

- base ref
- head ref
- Git diff で取得できる changed path 一覧

## Rust-Related Path Catalog

- `/Users/lihs/workspace/vocastock/Cargo.toml`
- `/Users/lihs/workspace/vocastock/Cargo.lock`
- `/Users/lihs/workspace/vocastock/applications/backend/**/*.rs`
- `/Users/lihs/workspace/vocastock/applications/backend/**/Cargo.toml`
- `/Users/lihs/workspace/vocastock/packages/rust/**/*.rs`
- `/Users/lihs/workspace/vocastock/packages/rust/**/Cargo.toml`
- `/Users/lihs/workspace/vocastock/docker/applications/**`
- `/Users/lihs/workspace/vocastock/docker/firebase/**`
- `/Users/lihs/workspace/vocastock/scripts/ci/**`
- `/Users/lihs/workspace/vocastock/scripts/firebase/**`
- `/Users/lihs/workspace/vocastock/scripts/lib/vocastock_env.sh`
- `/Users/lihs/workspace/vocastock/.github/workflows/ci.yml`

## Output Contract

- `rust_changed=true|false`
- `matched_paths=<newline-or-summary list>`
- `execution_mode=full|noop`

## No-op Rules

- `rust_changed=false` のときは `execution_mode=noop`
- no-op mode でも `rust-quality` job 名は消してはならない
- no-op mode では summary に「Rust path changes not detected」と同等の説明を残す

## Full Rules

- `matched_paths` に 1 件でも Rust-related path があれば `execution_mode=full`
- full mode では static / unit / feature の全 segment を実行しなければならない
