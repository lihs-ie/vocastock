# Flutter 開発環境

## 対象範囲

- 公式サポートするローカル開発ホストは `macOS 15.6+` のみ
- 対象プラットフォームは `iOS`、`Android`、`macOS`
- Firebase のローカル再現範囲は [firebase.json](/Users/lihs/workspace/vocastock/firebase.json) の `emulators` を source of truth とする

## 承認済みホストツール

| Component | Approved Version | Notes |
|-----------|------------------|-------|
| Flutter SDK | `3.41.5` | stable 系統 |
| Xcode | `26.3` | macOS 15.6+ を前提 |
| Android Studio | `Panda 2 (2025.3.2)` | Android SDK / emulator 管理に使用 |
| CocoaPods | `1.16.2` | iOS / macOS build 用 |
| Docker Desktop | `4.60.1` | Firebase emulator 実行用 |

詳細な採用根拠は [approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md) を参照してください。

## クイックスタート

1. `bash scripts/bootstrap/setup_macos.sh`
2. `bash scripts/bootstrap/measure_local_setup_budget.sh start`
3. 手動で承認済みバージョンを導入する
4. `bash scripts/bootstrap/verify_macos_toolchain.sh`
5. `bash scripts/bootstrap/validate_local_setup.sh`
6. `bash scripts/firebase/start_emulators.sh`
7. `bash scripts/firebase/smoke_local_stack.sh`
8. `bash scripts/firebase/measure_emulator_ready_time.sh`
9. `bash scripts/bootstrap/measure_local_setup_budget.sh finish`

## Firebase サービス在庫

[firebase.json](/Users/lihs/workspace/vocastock/firebase.json) に定義した emulator 対象が repository の source of truth です。現在の基準在庫は次のとおりです。

| Service | Container Port | Purpose |
|---------|----------------|---------|
| UI | `4000` | emulator dashboard |
| Hosting | `5000` | 静的配信のローカル確認 |
| Authentication | `9099` | 認証フローのローカル確認 |
| Firestore | `8080` | ドキュメント DB のローカル確認 |
| Storage | `9199` | ファイル保存のローカル確認 |
| Hub | `4400` | emulator coordination |
| Logging | `4500` | emulator log streaming |

新しく Firebase サービスをプロジェクトで使う場合は、`firebase.json` とこの文書を同一変更セットで更新してください。

## エンドポイント一覧

host 側の既定公開ポートは [docker/firebase/env/.env.example](/Users/lihs/workspace/vocastock/docker/firebase/env/.env.example) を基準にする。

| Endpoint | URL |
|----------|-----|
| Emulator UI | `http://127.0.0.1:14000` |
| Hosting | `http://127.0.0.1:15000` |
| Firestore | `127.0.0.1:18080` |
| Authentication | `127.0.0.1:19099` |
| Storage | `127.0.0.1:19199` |

## ローカル既定値

- Firebase emulator のローカル既定値は [docker/firebase/env/.env.example](/Users/lihs/workspace/vocastock/docker/firebase/env/.env.example) を基準にする
- 実値は `docker/firebase/env/.env` に置き、repository へ commit しない
- 実運用 secret はここへ置かず、CI secret または service account 側で扱う

## 予算超過時の対応

- ローカル構築が `60 分` を超えたら `bash scripts/bootstrap/measure_local_setup_budget.sh finish` の出力を記録する
- emulator ready が `5 分` を超えたら [docker/firebase/compose.yaml](/Users/lihs/workspace/vocastock/docker/firebase/compose.yaml) の build/log を確認し、[security-version-review.md](/Users/lihs/workspace/vocastock/docs/development/security-version-review.md) の見直し条件と照合する
- 超過時は `.artifacts/firebase/logs/emulators.log` と `flutter doctor --verbose` の結果を issue に添付する

## トラブルシューティング

- `flutter` が見つからない: Flutter SDK `3.41.5` を入れ直し、PATH を更新する
- `xcodebuild` が失敗する: `sudo xcodebuild -license accept` を実行し、Command Line Tools を Xcode 26.3 に合わせる
- Docker 起動に失敗する: Docker Desktop を起動し、`docker info` が通ることを確認する
- emulator port が衝突する: `docker/firebase/env/.env` 側の host port を変える
- Flutter プロジェクトがまだ無い: 現段階の scripts と CI は repository bootstrap mode として動作し、`pubspec.yaml` 追加後に build/test 実行へ切り替わる
