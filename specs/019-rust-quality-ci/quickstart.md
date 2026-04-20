# Quickstart: Rust Quality CI

## 1. 前提確認

1. `bash /Users/lihs/workspace/vocastock/scripts/ci/install_toolchains.sh`
2. Docker が起動していることを確認する
3. Firebase emulator 用の env が存在しない場合は、`docker/firebase/env/.env.example` を baseline として使う

## 2. Rust 変更判定を再現する

1. `bash /Users/lihs/workspace/vocastock/scripts/ci/detect_rust_changes.sh --base origin/main --head HEAD`
2. 出力された summary で `execution_mode=full` または `execution_mode=noop` を確認する
3. `.artifacts/ci/logs/rust-quality.detected-paths.txt` に matched path が保存されることを確認する
4. Rust 関連 path を変更していない run では、required check 名を維持した no-op success になることを確認する

## 3. full gate をローカル再現する

1. `bash /Users/lihs/workspace/vocastock/scripts/ci/run_rust_quality_checks.sh --mode full`
2. 実行順が `fmt -> clippy -> unit-query -> unit-command -> feature-all` であることを確認する
3. `.artifacts/ci/logs/rust-quality.summary.md`、`.artifacts/ci/logs/rust-quality.stage`、`.artifacts/ci/logs/rust-quality.stages.tsv` を確認する

## 4. individual command を spot check する

1. `cargo fmt --all -- --check`
2. `cargo clippy --workspace --all-targets -- -D warnings`
3. `cargo test -p query-api --test unit`
4. `cargo test -p command-api --test unit`
5. `cargo test -p graphql-gateway --test feature -- --nocapture`
6. `cargo test -p query-api --test feature -- --nocapture`
7. `cargo test -p command-api --test feature -- --nocapture`

## 5. CI artifact を確認する

1. success/failure どちらでも `.artifacts/ci` が upload 対象に含まれることを確認する
2. Rust path 非該当 run では no-op summary と duration が残ることを確認する
3. `rust-quality.fmt.log`、`rust-quality.clippy.log`、`rust-quality.unit-query.log`、`rust-quality.unit-command.log` が出力されることを確認する
4. feature test failure 時は `rust-quality.feature-all.log` と `rust-quality.feature-<application>.log` から停止点を追跡できることを確認する
