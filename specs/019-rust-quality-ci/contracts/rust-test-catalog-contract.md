# Contract: Rust Test Catalog

## Purpose

Rust quality job がどの Cargo package にどの test suite を要求するかを固定する。

## Static Commands

- `cargo fmt --all -- --check`
- `cargo clippy --workspace --all-targets -- -D warnings`

## Unit Test Contract

| Application | Command | Required |
|-------------|---------|----------|
| `query-api` | `cargo test -p query-api --test unit` | Yes |
| `command-api` | `cargo test -p command-api --test unit` | Yes |
| `graphql-gateway` | N/A in this feature | No |

## Feature Test Contract

| Application | Command | Docker Required | Firebase Required |
|-------------|---------|-----------------|------------------|
| `graphql-gateway` | `cargo test -p graphql-gateway --test feature -- --nocapture` | Yes | Yes |
| `query-api` | `cargo test -p query-api --test feature -- --nocapture` | Yes | Yes |
| `command-api` | `cargo test -p command-api --test feature -- --nocapture` | Yes | Yes |

## Catalog Rules

- 全 Rust アプリケーションは feature test catalog に含まれなければならない
- `graphql-gateway` はこの feature で Rust feature test harness を追加する前提とする
- unit test contract の追加対象は `query-api` と `command-api` に限定する
- どの command がどの application に対応するかを summary から追跡できなければならない
