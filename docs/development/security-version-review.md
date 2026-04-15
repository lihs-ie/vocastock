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

## レビュー手順

1. vendor の support source を確認する
2. vendor の security source または release notes を確認する
3. [approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md) の該当行へ `supportStatus`、`vulnerability-source`、`finding`、`disposition`、`reviewedAt` を記録する
4. `MEDIUM` 以上の未解決 finding があれば `approved` にしない
5. 次回 review 時期を更新する

## Evidence セクション

version catalog は最低でも次の列を持つ。

| Column | Purpose |
|--------|---------|
| `supportStatus` | vendor が現在サポート中か |
| `severity` | 確認した finding の最大重要度 |
| `vulnerability-source` | security advisory / release note の参照元 |
| `finding` | 調査結果の要約 |
| `disposition` | `approved` / `blocked` / `superseded` |
| `reviewedAt` | 最終調査日 |
| `reviewCadence` | 次回見直し条件 |

## LTS / stable 判断ルール

- formal LTS があるものはサポート中 LTS を採用する
- formal LTS がないものは current stable 系統を採用する
- stable 採用時は「なぜ LTS ではなく stable なのか」を catalog と文書の両方に残す
- vendor が `deprecated` または `unsupported` と示した版は採用しない

## 再評価トリガー

- vendor の stable/LTS 更新
- vendor の security advisory 公開
- `MEDIUM` 以上の finding が CI または手動レビューで見つかったとき
- 90 日経過

## CI 認証と secret 方針

- CI では `FIREBASE_TOKEN` を使わない
- GitHub Actions では service account か OIDC ベースの認証を使う
- ローカル既定値は [docker/firebase/env/.env.example](/Users/lihs/workspace/vocastock/docker/firebase/env/.env.example) に置く
- 本番 secret や長期 credential は repository へ commit しない
- actrun local path では Trivy を Docker image の pinned version で実行する

## 例外管理

- 一時例外を入れる場合は issue 参照、期限、代替統制を version catalog の `finding` 欄へ残す
- 期限切れの例外は次回 merge 前に必ず解消する
