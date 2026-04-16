# セキュリティとバージョン見直し

## レビュー対象

- Flutter SDK
- Xcode
- Android Studio
- CocoaPods
- Docker Desktop
- Node.js
- Temurin JDK
- Firebase CLI
- Trivy CLI

## 現在の host baseline

- macOS host: `26.4.1`
- Flutter SDK: `3.41.5`
- Xcode: `26.4`
- Android Studio: `2025.3`
- CocoaPods: `1.16.2`
- Docker Desktop: `4.69.0`

## レビュー手順

1. vendor の support source を確認する
2. vendor の security source または release notes を確認する
3. host toolchain は実機で観測した version を確認し、旧 approved baseline を supersede するか判断する
4. [approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md) の該当行へ `approvedVersion`、`observedBaselineVersion`、`supportStatus`、`vulnerability-source`、`finding`、`disposition`、`reviewedAt` を記録する
5. 実機 baseline が旧 approved baseline を上回る場合は、同じ変更単位で `supersededVersion` と `baselineChangeReason` を埋める
6. `MEDIUM` 以上の未解決 finding があれば `approved` にしない
7. 次回 review 時期を更新する

## Catalog Evidence

version catalog は最低でも次の列を持つ。

| Column | Purpose |
|--------|---------|
| `approvedVersion` | 現在の承認済み exact version |
| `observedBaselineVersion` | 実機で確認した host baseline version |
| `supersededVersion` | 直前に supersede された approved version |
| `baselineChangeReason` | 実機 baseline へ追従した理由 |
| `supportStatus` | vendor が現在サポート中か |
| `supportSource` | サポート根拠の一次情報 |
| `severity` | 確認した finding の最大重要度 |
| `vulnerability-source` | security advisory / release note の参照元 |
| `finding` | 調査結果の要約 |
| `disposition` | `approved` / `blocked` / `superseded` |
| `reviewedAt` | 最終調査日 |
| `reviewCadence` | 次回見直し条件 |

## Latest-Machine Baseline Policy

- `observedBaselineVersion` は local host で実測できる値を記録する
- `approvedVersion` は原則 `observedBaselineVersion` と一致させる
- 更新前の approved 値が存在する場合は `supersededVersion` へ移し、`baselineChangeReason` を必ず埋める
- baseline 更新時は [flutter-environment.md](/Users/lihs/workspace/vocastock/docs/development/flutter-environment.md)、[ci-policy.md](/Users/lihs/workspace/vocastock/docs/development/ci-policy.md)、[approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md)、`scripts/bootstrap/verify_macos_toolchain.sh` を同じ変更単位で更新する
- CI runner は `ubuntu-24.04` / `macos-15` を維持するため、local host baseline と一致しなくてもよい。ただし差分は文書化する

## LTS / stable 判断ルール

- formal LTS があるものはサポート中 LTS を採用する
- formal LTS がないものは current stable 系統を採用する
- stable 採用時は「なぜ LTS ではなく stable なのか」を catalog と文書の両方に残す
- vendor が `deprecated` または `unsupported` と示した版は採用しない

## 再評価トリガー

- vendor の stable/LTS 更新
- vendor の security advisory 公開
- 実機 host baseline が approved version を上回ったとき
- `MEDIUM` 以上の finding が CI または手動レビューで見つかったとき
- 90 日経過

## Local Default / CI Secret 方針

- [docker/firebase/env/.env.example](/Users/lihs/workspace/vocastock/docker/firebase/env/.env.example) にはローカル既定値だけを置く
- `docker/firebase/env/.env` はローカル override 用で、repository へ commit しない
- CI では `FIREBASE_TOKEN` を使わない
- GitHub Actions では service account か OIDC ベースの認証を使う
- 本番 secret や長期 credential は repository へ commit しない
- actrun local path では Trivy を Docker image の pinned version で実行する
- local default を CI secret に流用しない

## 例外管理

- 一時例外を入れる場合は issue 参照、期限、代替統制を version catalog の `finding` 欄へ残す
- 期限切れの例外は次回 merge 前に必ず解消する
