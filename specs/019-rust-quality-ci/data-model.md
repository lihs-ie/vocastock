# Data Model: Rust Quality CI

## RustQualityScope

| Field | Type | Description |
|-------|------|-------------|
| `workflow_name` | string | required check として公開される CI job 名 |
| `rust_changed` | boolean | Rust 関連 path に変更があるかどうか |
| `matched_paths` | string[] | change-detection がヒットした path 一覧 |
| `execution_mode` | enum(`full`, `noop`) | full gate 実行か no-op success か |

**Validation Rules**

- `workflow_name` は branch protection が参照する一定の値でなければならない
- `execution_mode=noop` の場合、`rust_changed=false` でなければならない
- `execution_mode=full` の場合、static / unit / feature の全 segment を実行対象に含めなければならない

## RustApplicationQualityProfile

| Field | Type | Description |
|-------|------|-------------|
| `application` | string | Rust アプリケーション名 |
| `cargo_package` | string | Cargo package 名 |
| `source_paths` | string[] | change-detection 対象に含める source / manifest path |
| `unit_command` | string? | required unit test command。対象外なら `null` |
| `feature_command` | string | Docker/Firebase 前提の required feature test command |
| `requires_emulator` | boolean | feature test が Firebase emulator を必要とするか |
| `requires_container_runtime` | boolean | feature test が Docker container 起動を必要とするか |

### Planned Profiles

| application | cargo_package | unit_command | feature_command |
|-------------|---------------|--------------|-----------------|
| `graphql-gateway` | `graphql-gateway` | `null` | `cargo test -p graphql-gateway --test feature -- --nocapture` |
| `command-api` | `command-api` | `cargo test -p command-api --test unit` | `cargo test -p command-api --test feature -- --nocapture` |
| `query-api` | `query-api` | `cargo test -p query-api --test unit` | `cargo test -p query-api --test feature -- --nocapture` |

**Validation Rules**

- すべての Rust アプリケーションは `feature_command` を持たなければならない
- `query-api` と `command-api` は `unit_command` を持たなければならない
- `graphql-gateway` は feature scope により `feature_command` を新設する前提で扱う

## RustExecutionSegment

| Field | Type | Description |
|-------|------|-------------|
| `segment_name` | enum | `fmt` / `clippy` / `unit-query` / `unit-command` / `feature-all` |
| `enabled_when` | string | その segment を実行する条件 |
| `writes_logs_to` | string[] | summary / log / duration の出力先 |
| `failure_signal` | string | stage file や exit code での失敗表現 |

### Segment Order

1. `fmt`
2. `clippy`
3. `unit-query`
4. `unit-command`
5. `feature-all`

**Validation Rules**

- `feature-all` は emulator session と Docker runtime が利用可能な状態で開始しなければならない
- `fmt` または `clippy` が失敗した場合は後続 segment を成功扱いにしてはならない
- `noop` mode では上記 segment を実行せず、no-op summary のみを書き出す

## RustFeatureRuntimeSession

| Field | Type | Description |
|-------|------|-------------|
| `emulator_started` | boolean | Rust quality runner が emulator session を起動したか |
| `reuse_running` | boolean | 各 crate feature test が既存 emulator を再利用する設定か |
| `application_sequence` | string[] | feature test を流すアプリケーション順序 |
| `cleanup_required` | boolean | session 終了時に emulator 停止と一時 env の掃除が必要か |

**Validation Rules**

- `application_sequence` は全 Rust アプリケーションを一度ずつ含まなければならない
- `reuse_running=true` の場合、crate 側 feature test は独自に emulator を再起動してはならない

## RustQualityArtifactBundle

| Field | Type | Description |
|-------|------|-------------|
| `summary_file` | path | 実行モード、hit path、通過 segment をまとめた summary |
| `stage_file` | path | 最終到達 stage または failure stage |
| `segment_logs` | path[] | fmt / clippy / unit / feature ごとの log |
| `duration_files` | path[] | job 全体および主要 segment の duration |
| `upload_policy` | enum(`always`) | success/failure を問わず upload する方針 |

**Validation Rules**

- artifact bundle は `noop` mode と `full` mode の両方で生成されなければならない
- `feature-all` が失敗した場合、どの Rust アプリで止まったかを summary または log から追えること
