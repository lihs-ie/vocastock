# Quickstart: Flutter開発環境基盤整備

## 1. 計画成果物を確認する

- `spec.md` で対象プラットフォーム、保護ブランチ、脆弱性 block 基準を確認する
- `research.md` で採用バージョンと一次情報の根拠を確認する
- `data-model.md` で version approval、local host、emulator、CI policy の管理対象を確認する
- `contracts/` で version approval、local emulator、CI policy の運用契約を確認する

## 2. 実装対象ディレクトリを用意する

- `docker/firebase/` に Firebase emulator 用 Dockerfile と compose 定義を置く
- `.github/workflows/` に required checks を実装する
- `scripts/bootstrap/` と `scripts/firebase/` に local 起動補助を置く
- `tooling/versions/approved-components.md` に採用バージョン証跡を記録する
- `docs/development/` にセットアップ手順と運用ルールを記録する

## 3. ローカル環境の smoke path を実装する

- macOS ホストへ承認済み Flutter / Xcode / Android Studio / Docker Desktop を導入する
- Docker 化した Firebase emulator stack を起動し、healthcheck が `ready` になることを確認する
- `flutter doctor --verbose`、`dart analyze`、`flutter test`、最小 build smoke を順に実行する
- 秘匿値が不要な範囲では local default だけで検証を開始できることを確認する
- `bash scripts/bootstrap/measure_local_setup_budget.sh start` と `finish` で 60 分 budget を計測する
- `bash scripts/firebase/measure_emulator_ready_time.sh` で 5 分 budget を計測する

## 4. CI と保護ブランチを有効化する

- `main`、`develop`、`release/*` に required status checks を割り当てる
- `ubuntu-24.04` で lint / test / emulator / vulnerability scan を実行する
- `macos-15` で iOS / macOS build smoke を実行する
- vulnerability scan は `MEDIUM,HIGH,CRITICAL` で fail することを確認する
- `bash scripts/ci/apply_github_ruleset.sh owner/repo` で ruleset payload を適用する
- `bash scripts/ci/check_ci_runtime_budget.sh` で CI runtime budget を確認する
- actrun で local 検証する場合は `actrun workflow run .github/workflows/ci.yml --local --include-dirty` を使う

## 5. 継続見直しルールを確認する

- 採用コンポーネントごとに support status と security review date を記録する
- vendor の stable/LTS 更新か security advisory 発生時に再評価する
- 例外を入れる場合は期間付きで記録し、次回見直し日を固定する
