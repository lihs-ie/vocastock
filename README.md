# vocastock

英単語の解説生成と視覚イメージ生成を扱うプロジェクトです。

## Development

- 憲章: `.specify/memory/constitution.md`
- ドメイン文書: `docs/internal/domain/*.md`
- ドメイン境界を変更する実装では、対象ドメイン文書の更新を必須とする
- 生成中または失敗中の中間生成結果はユーザーへ表示せず、完了済みの結果のみ表示する
- 識別子型は `XxxIdentifier` と命名し、`id` / `ID` / `xxxId` は使用しない
- 集約自身の識別子フィールド名は `identifier`、他概念の識別子フィールド名は
  `xxxIdentifier` ではなく `xxx` を使う
