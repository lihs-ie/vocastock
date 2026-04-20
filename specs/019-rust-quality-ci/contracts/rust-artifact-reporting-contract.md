# Contract: Rust Artifact Reporting

## Purpose

Rust quality job の実行結果を reviewer が追跡できる artifact 出力を固定する。

## Required Outputs

- `.artifacts/ci/logs/rust-quality.summary.md`
- `.artifacts/ci/logs/rust-quality.stage`
- `.artifacts/ci/logs/rust-quality.detected-paths.txt`
- `.artifacts/ci/logs/rust-quality.stages.tsv`
- `.artifacts/ci/logs/rust-quality.fmt.log`
- `.artifacts/ci/logs/rust-quality.clippy.log`
- `.artifacts/ci/logs/rust-quality.unit-query.log`
- `.artifacts/ci/logs/rust-quality.unit-command.log`
- `.artifacts/ci/logs/rust-quality.feature-all.log`
- `.artifacts/ci/logs/rust-quality.feature-graphql-gateway.log`
- `.artifacts/ci/logs/rust-quality.feature-query-api.log`
- `.artifacts/ci/logs/rust-quality.feature-command-api.log`
- `.artifacts/ci/durations/rust-quality.seconds`

## Upload Rules

- artifact 名は Rust quality 専用に識別できるものを使う
- success / failure の両方で upload する
- no-op mode でも summary と duration は残す

## Review Rules

- summary から `execution_mode`、hit path、完了済み segment を読めなければならない
- failure stage と log file 名が 1 対 1 で追跡できなければならない
