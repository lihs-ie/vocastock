# Flutter 開発環境

## 対象範囲

- 公式サポートするローカル開発ホストは、実機で検証済みの `macOS 26.4.1` baseline のみ
- 対象プラットフォームは `iOS`、`Android`、`macOS`
- Firebase のローカル再現範囲は [firebase.json](/Users/lihs/workspace/vocastock/firebase.json) の `emulators` を source of truth とする
- CI runner は `ubuntu-24.04` と `macos-15` を使い、local host baseline と intentionally 分離する

## 承認済みホストツール

| Component | Approved Version | Notes |
|-----------|------------------|-------|
| macOS Host | `26.4.1` | 最新実機で検証済みの baseline |
| Flutter SDK | `3.41.5` | stable 系統 |
| Xcode | `26.4` | macOS 26.4.1 baseline 上で検証済み |
| Android Studio | `2025.3` | 実機 app bundle が報告する version を正とする |
| CocoaPods | `1.16.2` | iOS / macOS build 用 |
| Docker Desktop | `4.69.0` | Firebase emulator 実行用 |

詳細な採用根拠と baseline 差分は [approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md) と [security-version-review.md](/Users/lihs/workspace/vocastock/docs/development/security-version-review.md) を参照してください。

## クイックスタート

1. `bash scripts/bootstrap/setup_macos.sh`
2. `bash scripts/bootstrap/measure_local_setup_budget.sh start`
3. `macOS 26.4.1 / Flutter 3.41.5 / Xcode 26.4 / Android Studio 2025.3 / CocoaPods 1.16.2 / Docker Desktop 4.69.0` に揃える
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
- `.env.example` に置けるのは port や emulator service inventory のようなローカル既定値のみ
- 実値は `docker/firebase/env/.env` に置き、repository へ commit しない
- 実運用 secret はここへ置かず、CI secret または service account / OIDC 側で扱う
- `FIREBASE_TOKEN` のような長期 token は local / CI ともに正規手段にしない

## CI runner との差分

- local host baseline は `macOS 26.4.1 / Xcode 26.4 / Android Studio 2025.3 / Docker Desktop 4.69.0`
- Linux required checks は `ubuntu-24.04` 上の command-line toolchain で実行する
- Apple build smoke は `macos-15` 上で実行し、local host app bundle version との完全一致は要求しない
- local host baseline を更新した場合は [ci-policy.md](/Users/lihs/workspace/vocastock/docs/development/ci-policy.md)、[approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md)、`scripts/bootstrap/verify_macos_toolchain.sh` を同じ変更で更新する

## 予算超過時の対応

- ローカル構築が `60 分` を超えたら `bash scripts/bootstrap/measure_local_setup_budget.sh finish` の出力を記録する
- emulator ready が `5 分` を超えたら [docker/firebase/compose.yaml](/Users/lihs/workspace/vocastock/docker/firebase/compose.yaml) の build/log を確認し、[security-version-review.md](/Users/lihs/workspace/vocastock/docs/development/security-version-review.md) の見直し条件と照合する
- 超過時は `.artifacts/firebase/logs/emulators.log` と `flutter doctor --verbose` の結果を issue に添付する

## トラブルシューティング

- `flutter` が見つからない: Flutter SDK `3.41.5` を入れ直し、PATH を更新する
- `sw_vers` が一致しない: `macOS 26.4.1` baseline とズレている。差分を採用するなら version governance を同じ変更で更新する
- `xcodebuild` が失敗する: `sudo xcodebuild -license accept` を実行し、Command Line Tools を Xcode 26.4 に合わせる
- Android Studio version が期待値と違う: `plutil -extract CFBundleShortVersionString raw -o - /Applications/Android\\ Studio.app/Contents/Info.plist` で実測値を確認する
- Docker 起動に失敗する: Docker Desktop `4.69.0` を起動し、`docker info` が通ることを確認する
- emulator port が衝突する: `docker/firebase/env/.env` 側の host port を変える
- Flutter プロジェクトがまだ無い: 現段階の scripts と CI は repository bootstrap mode として動作し、`pubspec.yaml` 追加後に build/test 実行へ切り替わる
