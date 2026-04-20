# vocastock

英単語の解説生成と視覚イメージ生成を扱うプロジェクトです。

## Development

- 憲章: `.specify/memory/constitution.md`
- ドメイン文書: `docs/internal/domain/*.md`
- ローカル開発環境 baseline: `macOS 26.4.1 / Flutter 3.41.5 / Xcode 26.4 / Android Studio 2025.3 / CocoaPods 1.16.2 / Docker Desktop 4.69.0`
- セットアップ手順: [docs/development/flutter-environment.md](/Users/lihs/workspace/vocastock/docs/development/flutter-environment.md)
- CI / ruleset / runner 境界: [docs/development/ci-policy.md](/Users/lihs/workspace/vocastock/docs/development/ci-policy.md)
- version governance: [tooling/versions/approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md), [docs/development/security-version-review.md](/Users/lihs/workspace/vocastock/docs/development/security-version-review.md)
- backend 実装 skeleton: `applications/backend/graphql-gateway/`, `applications/backend/command-api/`, `applications/backend/query-api/`, `packages/rust/shared-auth/`, `packages/rust/shared-runtime/`
- backend container contract: [docs/development/backend-container-environment.md](/Users/lihs/workspace/vocastock/docs/development/backend-container-environment.md)
- application container validation: `bash scripts/bootstrap/validate_application_containers.sh`
- application container smoke: `bash scripts/ci/run_application_container_smoke.sh`
- rust change detection: `bash scripts/ci/detect_rust_changes.sh --base origin/main --head HEAD`
- rust quality gate: `bash scripts/ci/run_rust_quality_checks.sh --mode full`
- host baseline 検証: `bash scripts/bootstrap/verify_macos_toolchain.sh`
- local setup 検証: `bash scripts/bootstrap/validate_local_setup.sh`
- ドメイン境界を変更する実装では、対象ドメイン文書の更新を必須とする
- shared package は logging / monitoring / auth-session handoff / request correlation /
  runtime helper のような sidecar concern のみを持ち、domain model や application
  coordination を置かない
- domain model と workflow / use-case coordination は owning application 配下に定義し、
  application 間で shared executable domain package を作らない
- 設計時点で、各 application の inner layer package / module の名前、配置先、依存方向を
  `plan.md` に定義してから実装に入る
- 生成中または失敗中の中間生成結果はユーザーへ表示せず、完了済みの結果のみ表示する
- 識別子型は `XxxIdentifier` と命名し、`id` / `ID` / `xxxId` は使用しない
- 集約自身の識別子フィールド名は `identifier`、他概念の識別子フィールド名は
  `xxxIdentifier` ではなく `xxx` を使う

## Backend Containers

- Docker 関連ファイルは `docker/applications/<application>/` を正本とする
- API の既定 host port は `18180-18182` とし、Firebase emulator の `18080` 競合を避ける
- local / CI は同じ Dockerfile / target / entry contract を使い、生成済み image artifact の共有は必須にしない
- API service の canonical success signal は `HTTP readiness endpoint`
- worker の canonical success signal は `long-running consumer` の stable-run
- `run_application_container_smoke.sh` は API host port が埋まっている場合、一時 env を生成して空きポートへ自動退避する
- `run_local_stack_smoke.sh --with-application-containers` は Firebase emulator を起動した上で、API の `/dependencies/firebase` と worker の起動前疎通確認で接続検証する
- `rust-quality` は Rust path 非該当時に no-op success を返し、該当時は `fmt -> clippy -> query-api unit -> command-api unit -> feature-all` を実行する
- application container scope は backend / worker のみで、`docker/firebase/` は repository-wide shared dependency stack として別管理する

主要コマンド:

- contract validate: `bash scripts/bootstrap/validate_application_containers.sh`
- application smoke: `bash scripts/ci/run_application_container_smoke.sh`
- firebase + application smoke: `bash scripts/bootstrap/validate_local_stack.sh --with-application-containers`
