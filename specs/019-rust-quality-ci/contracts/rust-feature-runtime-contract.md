# Contract: Rust Feature Runtime

## Purpose

Rust quality job の feature segment が Docker container と Firebase emulator をどう扱うかを固定する。

## Runtime Rules

- emulator session は Rust quality job 内で 1 回だけ起動する
- feature test 実行中は `VOCAS_FEATURE_REUSE_RUNNING=1` を使って既存 emulator session を共有する
- feature test の実行順は `graphql-gateway -> query-api -> command-api` を既定とする
- feature test 終了後は job が起動した emulator session を停止する
- Linux runner でも `host.docker.internal` を解決できるよう、application compose は `host-gateway` mapping を持たなければならない

## Failure Handling

- emulator 起動失敗は `feature-all` の failure として扱う
- どの application の feature test で停止したかを stage file または summary に記録する
- container build / readiness / dependency probe の failure を raw log だけに埋もれさせてはならない

## Visibility Rules

- feature segment の成功条件は、全 Rust アプリケーションの feature test 成功である
- 1 アプリでも失敗した場合、segment 全体を success 扱いにしてはならない
