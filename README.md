# vocastock

英単語の解説生成と視覚イメージ生成を扱うプロジェクトです。

## Development

- 憲章: `.specify/memory/constitution.md`
- ドメイン文書: `docs/internal/domain/*.md`
- ローカル開発環境 baseline: `macOS 26.4.1 / Flutter 3.41.5 / Xcode 26.4 / Android Studio 2025.3 / CocoaPods 1.16.2 / Docker Desktop 4.69.0`
- セットアップ手順: [docs/development/flutter-environment.md](/Users/lihs/workspace/vocastock/docs/development/flutter-environment.md)
- CI / ruleset / runner 境界: [docs/development/ci-policy.md](/Users/lihs/workspace/vocastock/docs/development/ci-policy.md)
- version governance: [tooling/versions/approved-components.md](/Users/lihs/workspace/vocastock/tooling/versions/approved-components.md), [docs/development/security-version-review.md](/Users/lihs/workspace/vocastock/docs/development/security-version-review.md)
- host baseline 検証: `bash scripts/bootstrap/verify_macos_toolchain.sh`
- local setup 検証: `bash scripts/bootstrap/validate_local_setup.sh`
- ドメイン境界を変更する実装では、対象ドメイン文書の更新を必須とする
- 生成中または失敗中の中間生成結果はユーザーへ表示せず、完了済みの結果のみ表示する
- 識別子型は `XxxIdentifier` と命名し、`id` / `ID` / `xxxId` は使用しない
- 集約自身の識別子フィールド名は `identifier`、他概念の識別子フィールド名は
  `xxxIdentifier` ではなく `xxx` を使う
