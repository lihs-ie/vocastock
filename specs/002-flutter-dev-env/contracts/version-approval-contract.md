# Contract: Version Approval

## Purpose

開発基盤で採用するすべてのコンポーネントについて、バージョン採用根拠を一貫した形式で
記録する。

## Record Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| identifier | VersionApprovalRecordIdentifier | yes | 承認記録識別子 |
| component | ToolchainComponentIdentifier | yes | 対象コンポーネント |
| approvedVersion | string | yes | 具体的な採用 version |
| releaseChannel | string | yes | `lts` または `stable` |
| supportSourceUrls | string[] | yes | 公式サポート根拠の URL |
| securitySourceUrls | string[] | yes | 公式 security 情報または release note の URL |
| supportStatus | string | yes | `supported`, `security-fix-only`, `deprecated`, `unsupported` |
| openFindings | SecurityFinding[] | yes | 未解決事項の一覧 |
| decision | string | yes | 採用理由 |
| reviewCadence | string | yes | 見直し条件 |
| reviewedAt | datetime | yes | 最終確認日時 |

## Rules

- `approvedVersion` は exact version を使い、`latest` や major-only を禁止する
- `releaseChannel = stable` は formal LTS 不在の理由を `decision` に含める
- `openFindings` に `MEDIUM` 以上が含まれる場合、当該 record は merge 可能状態にできない
- source は vendor 公式または当該プロジェクトの公式 repository に限る
- 例外を認める場合でも、期限、代替策、担当者を別途記録しなければならない

## Minimum Approved Components

- Flutter SDK
- Xcode
- Android Studio
- CocoaPods
- Docker Desktop
- Node.js
- Temurin JDK
- Firebase CLI
- CI vulnerability scanner
