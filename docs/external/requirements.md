# ストーリー

## ユーザー

- ユーザーが自分の `VocabularyExpression` を登録する
  - `VocabularyExpression` は単語と連語を同一概念として扱う
  - 重複登録判定は同一学習者内の `NormalizedVocabularyExpressionText` で行う
- 未登録であれば、登録した `VocabularyExpression` に対して解説生成を行う
  - 時間がかかるため非同期で行う
- ユーザーは完了済み `Explanation` から視覚的イメージ画像を生成できる
  - 時間がかかるため非同期で行う
  - 生成された画像は何らかのストレージサービスに永続化される
- ユーザーには解説と画像の完全な生成結果のみを表示する
  - 生成中または失敗中は状態のみを表示し、中間生成結果は表示しない
- 画像が生成されている解説は `currentImage` を表示に反映する

## 要件

- `Explanation` は生成時にネイティブスピーカーがよく使うかを `Frequency` としてレベル分けする
- `Explanation` は語彙の知的・語彙的な難度を `Sophistication` として管理する
- `Learner` は自分が所有する `VocabularyExpression` を管理できる
- 学習者ごとの定着度は `LearningState.proficiency` として管理する
  - `Frequency` や `Sophistication` とは異なる概念として扱う
- `RegistrationStatus`、`ExplanationGenerationStatus`、`ImageGenerationStatus` は別概念として管理する

## Deferred Scope

- 認証、credential、session 管理は auth/session 設計で扱う
- command 受理、workflow orchestration、dispatch failure は backend command 設計で扱う
- query model、永続化実装、外部 vendor adapter 実装は別 feature とする

## 開発基盤メモ

- 開発時の host baseline、CI runner 境界、version governance は `docs/development/*.md` と `tooling/versions/approved-components.md` を正とする
