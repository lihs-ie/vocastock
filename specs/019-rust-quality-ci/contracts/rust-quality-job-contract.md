# Contract: Rust Quality Job

## Purpose

`rust-quality` job が CI 上で担う責務、step 順序、success / failure 条件を固定する。

## Job Contract

- Job 名は `rust-quality` とする
- `toolchain-validate` 完了後に実行する
- job 自体は常に workflow 上に存在する
- 最初に Rust path 変更有無を判定し、`full` または `noop` mode を決定する

## Step Order

1. repository checkout
2. Rust path change detection
3. no-op mode の場合: summary 出力後に success 終了
4. full mode の場合:
   - toolchain prerequisite の確保
   - `cargo fmt --all -- --check`
   - `cargo clippy --workspace --all-targets -- -D warnings`
   - `cargo test -p query-api --test unit`
   - `cargo test -p command-api --test unit`
   - 全 Rust アプリの feature test
5. `.artifacts/ci` upload

## Success Rules

- no-op mode では required check 名を維持した success とする
- full mode では上記 segment がすべて成功した場合のみ success とする
- partial pass を success と見なしてはならない

## Failure Rules

- 失敗した segment 名を summary / stage file に残す
- failure 時も artifact upload を省略してはならない
- 既存の Flutter / Android / vulnerability / smoke 系 job の責務を吸収してはならない
