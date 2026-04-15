# Contract: Local Emulator

## Purpose

Docker 上で再現する Firebase エミュレーター環境の入出力、前提条件、完了条件を定義する。

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `firebase.json` | yes | emulator 対象サービスと container 内 port 設定 |
| `.firebaserc` | yes | local project alias 定義 |
| `docker/firebase/compose.yaml` | yes | コンテナ構成 |
| `docker/firebase/Dockerfile` | yes | Node / Java / Firebase CLI の固定化 |
| local env file | yes | host 側へ公開する port を含む秘匿不要な既定値 |
| seed data directory | optional | ローカル初期データ |

## Required Runtime Contract

| Concern | Requirement |
|---------|-------------|
| Container runtime | Docker Desktop approved version 上で起動できること |
| Node runtime | 承認済み Node.js LTS を使うこと |
| Java runtime | 承認済み JDK LTS を使うこと |
| Firebase CLI | 承認済み exact version を使うこと |
| Service coverage | プロジェクトで利用する全 Firebase サービスを定義すること |
| Healthcheck | `ready` 判定前に service 別 healthcheck を通すこと |
| Persistence | 開発用途では reset 可能な volume-backed 構成を基本とすること |

## Outputs

| Output | Description |
|--------|-------------|
| emulator ready signal | ローカル検証を開始できる状態通知 |
| service endpoint catalog | 接続先 URL / port の一覧 |
| startup logs | 起動失敗時の切り分け用ログ |
| reset path | データ初期化方法 |

## Rules

- host 側に Firebase CLI を必須前提としない
- 機密情報なしで起動できる local default を優先する
- 実運用 secret が必要な機能は emulator で代替不能な理由を明記する
- emulator 未対応サービスがある場合、その理由と local fallback を `docs/development/` に記録する
