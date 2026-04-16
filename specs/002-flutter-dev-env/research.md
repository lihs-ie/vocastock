# Research: Flutter開発環境基盤整備

## Decision: Flutter は `stable` 系統の 3.41.5 を基準バージョンとして採用する

**Rationale**: Flutter には Node.js のような formal LTS 表現がなく、公式ドキュメントは
最新の `stable` または `beta` を追うことを推奨している。Flutter の security policy でも
セキュリティ更新対象は current `stable` branch と明記されているため、3.41.5 を
基準線にするのが最も一貫している。

**Alternatives considered**:

- 古い stable patch を固定し続ける
- beta 系統を先行採用する

## Decision: Apple 系ツールチェーンは Xcode 26.4 と macOS 26.4.1 baseline を採用する

**Rationale**: 現在の実機は macOS 26.4.1 へ更新済みで、Xcode 26.4 が導入済みである。
旧 baseline の 26.3 へ合わせるためにダウングレードするより、公式にサポートされ、
実機で検証済みの 26.4 を新 baseline として採用し、その差分を version governance へ
反映する方が現実的である。CI runner は直ちには同一 baseline へ追従できないため、
`macos-15` との差分は運用上の追跡対象として明示する。

**Alternatives considered**:

- Xcode 26.3 にダウングレードして旧 baseline を維持する
- 旧系統の Xcode へ下げて CI との差分を増やす

## Decision: Android 系ツールチェーンは Android Studio 2025.3 を host baseline として採用する

**Rationale**: 実機の Android Studio app bundle は `2025.3` を報告しており、旧 baseline
の `2025.3.2` 表記と完全一致しない。host validation と運用文書は、実機で観測できる
version string を基準にした方が検証スクリプトと人手確認のズレを減らせる。stable 系統の
新しい baseline を維持しつつ、source 側では family と app-reported version の両方を
記録する方針を採る。

**Alternatives considered**:

- `2025.3.2` の文字列表現へ手動で合わせるため旧 app bundle を探す
- Panda 以前の stable を使い続ける
- Canary / RC を採用する

## Decision: Firebase エミュレーターは Docker 化した Firebase CLI 15.2.1 を基準にする

**Rationale**: ユーザー要件で Docker 上の Firebase エミュレーターが必要であり、公式の
単独エミュレーター用 Docker image を前提にしない方が構成管理しやすい。Firebase CLI の
最新 stable release である 15.2.1 は v15 系に入り、Java 21 未満の emulator 実行を
廃止しているため、コンテナ内の runtime を明確に揃えやすい。コンテナへ閉じ込めることで、
ホストに Firebase CLI / Node / Java を直接散らさず再現性を高められる。

**Alternatives considered**:

- ホストへ Firebase CLI を直接インストールする
- v14 系を維持して Java 要件を緩める

## Decision: Firebase エミュレーター用の runtime は Node.js 24.14.1 LTS と Temurin JDK 21 LTS を採用する

**Rationale**: Node.js の公式 release schedule では 24 系が LTS として提供されている。
Firebase CLI 14.25.0 以降は Node 24 をサポートし、Firebase CLI 15.0.0 では Java 21
未満での emulator 実行サポートが削除された。GitHub Actions `macos-15` image には
Java 21.0.10 が標準搭載されているため Java 側の追加セットアップは最小化しやすく、
Node 24 は workflow 側で明示的に pin すればよい。ローカルと CI の主 runtime を
21 LTS / 24 LTS に揃えることで、サポート期間と互換性の両方を取りやすい。

**Alternatives considered**:

- Node.js 22 LTS を採用する
- JDK 17 LTS を維持する
- JDK 25 LTS へ先行する

## Decision: iOS/macOS 依存は CocoaPods 1.16.2 を採用し、Ruby への依存は間接化する

**Rationale**: `macos-15` runner には CocoaPods 1.16.2 が標準搭載されており、Apple
platform build と CI の差分を減らせる。iOS/macOS build のために CocoaPods は必要だが、
local setup では Ruby version manager を追加必須にせず、Homebrew または runner
同等環境の利用を前提にした方が依存面が増えにくい。

**Alternatives considered**:

- Ruby toolchain を別途固定して CocoaPods をソースから管理する
- CocoaPods を使わず手動で依存解決する

## Decision: コンテナ基盤は Docker Desktop 4.69.0 を採用する

**Rationale**: 実機は Docker Desktop 4.69.0 へ更新済みであり、旧 baseline 4.60.1 より
新しい。ローカル環境の実用性と検証スクリプトの一致を優先し、実機で検証済みの新 baseline
へ追従する。old baseline を維持するために意図的に古い Docker Desktop を再導入する理由は
なく、support / security review を更新する方が保守上合理的である。

**Alternatives considered**:

- 4.60.1 へダウングレードして旧 baseline を維持する
- 4.57.0 付近の安定版へ固定する
- ホストの素の Docker Engine のみを前提にする

## Decision: 承認済み host baseline は実機で検証済みの version と同一変更で更新する

**Rationale**: 実機の host toolchain が旧 approvedVersion より新しくなった場合、環境自体は
利用可能でも verify script と version catalog が false negative を出す。baseline 差分、
更新理由、support/security source を同一変更へまとめることで、ローカル環境、文書、
検証スクリプト、CI の traceability を保ちやすい。

**Alternatives considered**:

- 実機を常に旧 approvedVersion へダウングレードする
- 実機差分を口頭運用だけで吸収する

## Decision: CI は `ubuntu-24.04` と `macos-15` の二系統で構成する

**Rationale**: Docker ベースの emulator / vulnerability scan / repository-wide lint は
`ubuntu-24.04` がコスト効率に優れ、iOS / macOS build smoke は `macos-15` が必須である。
GitHub-hosted runners を使うことで、self-hosted runner の patch 管理や機密面の管理負荷を
増やさずに済む。

**Alternatives considered**:

- すべてを `macos-15` に寄せる
- self-hosted runner を前提にする

## Decision: 脆弱性検査は Trivy を用い、`MEDIUM,HIGH,CRITICAL` で fail させる

**Rationale**: Trivy の公式 CLI / GitHub Action は severity と exit-code を明示的に
設定できる。今回の clarified requirement は Medium 以上で統合ブロックなので、
filesystem scan を repository 全体に実行し、例外は明示的な ignore 記録付きに限定するのが
要件に合う。

**Alternatives considered**:

- `HIGH,CRITICAL` のみを fail 条件にする
- レポートだけ出して merge は止めない

## Decision: 保護対象は `main`、`develop`、`release/*` とし、required status checks を必須にする

**Rationale**: GitHub branch protection rules は、ブランチ名パターンごとに passing status
checks を必須化できる。clarification で保護対象は確定済みなので、CI 設計はこの 3 系統へ
required checks を割り当てる前提で固定する。

**Alternatives considered**:

- `main` のみを保護する
- CI は回すが branch protection では強制しない

## Decision: CI 認証は `FIREBASE_TOKEN` を使わず、サービスアカウント系認証を前提にする

**Rationale**: Firebase CLI の公式 README では `firebase login:ci` による user token は
deprecated とされ、service account を推奨している。ローカル既定値と CI secrets を分離し、
人手ログイン情報を CI へ持ち込まない方が安全である。

**Alternatives considered**:

- `FIREBASE_TOKEN` を repository secret として保存する
- 各開発者の個人認証状態を CI に流用する

## Sources Reviewed

- Flutter install and upgrade guidance: [docs.flutter.dev/install/upgrade](https://docs.flutter.dev/install/upgrade)
- Flutter SDK archive and current doc version context: [docs.flutter.dev/release/archive](https://docs.flutter.dev/release/archive)
- Flutter security policy: [github.com/flutter/flutter/security](https://github.com/flutter/flutter/security)
- Apple Xcode system requirements: [developer.apple.com/jp/xcode/system-requirements/](https://developer.apple.com/jp/xcode/system-requirements/)
- Android Studio releases: [developer.android.com/studio/releases](https://developer.android.com/studio/releases)
- Android Gradle Plugin 9.1 release notes: [developer.android.com/build/releases/agp-9-1-0-release-notes](https://developer.android.com/build/releases/agp-9-1-0-release-notes)
- Firebase Local Emulator Suite install/configure: [firebase.google.com/docs/emulator-suite/install_and_configure](https://firebase.google.com/docs/emulator-suite/install_and_configure)
- Firebase CLI releases: [github.com/firebase/firebase-tools/releases](https://github.com/firebase/firebase-tools/releases)
- Node.js releases: [nodejs.org/en/about/previous-releases](https://nodejs.org/en/about/previous-releases)
- GitHub-hosted runner images: [github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md)
- GitHub branch protection rules: [docs.github.com/.../managing-a-branch-protection-rule](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)
- Docker Desktop release notes: [docs.docker.com/docker-for-windows/release-notes/](https://docs.docker.com/docker-for-windows/release-notes/)
- Trivy latest CLI configuration: [trivy.dev/docs/latest/references/configuration/cli/trivy_config/](https://trivy.dev/docs/latest/references/configuration/cli/trivy_config/)
- Trivy GitHub Action: [github.com/aquasecurity/trivy-action](https://github.com/aquasecurity/trivy-action)
