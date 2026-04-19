# Contract: Application Runtime Profile

## Purpose

各 deployable application が持つ container 実行契約を固定する。

## Inputs

| Field | Required | Description |
|-------|----------|-------------|
| `applicationName` | yes | canonical application 名 |
| `dockerfilePath` | yes | application-scoped Dockerfile の配置先 |
| `buildTarget` | yes | local / CI で共有する build target |
| `entryContract` | yes | container 起動 contract |
| `successSignal` | yes | canonical success signal |

## Rules

- `graphql-gateway`、`command-api`、`query-api`、`explanation-worker`、`image-worker`、`billing-worker` を対象にする
- Docker 関連ファイルは `docker/applications/<application>/` を正本とする
- application profile は `docker/firebase/` を直接所有物としてはならない
- `command-api` と `query-api` を同一 application profile に統合してはならない

## Output

application ごとに 1 つの runtime profile が定義されること。
