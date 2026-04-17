# コンポーネント

## UI

- ユーザーが直に触れる部分
- `VocabularyExpression` の登録、完了済み `Explanation` の閲覧、完了済み `VisualImage` の閲覧を扱う
- 生成中または失敗中は状態のみを表示し、中間生成物は表示しない

## Learner identity resolution

- 外部 identity を `Learner` へ解決する
- 認証そのものは扱わず、domain には学習者解決結果だけを渡す

## VocabularyExpression validation

- 登録対象の英語表現が本当に存在するのかを判定する
- `VocabularyExpressionText` を `NormalizedVocabularyExpressionText` へ正規化する

## Registration lookup

- 同一学習者内で、すでに登録済みの `VocabularyExpression` かを判定する

## Explanation generation

- `VocabularyExpression` から解説を生成する
- 生成には指定の AI サービスを利用する
- 完了時のみ解説 payload を返す

## Explanation reader

- `VocabularyExpression.currentExplanation` に対応する完了済み解説を取得する
- 必要に応じて解説履歴を取得する

## Image generation

- 完了済み `Explanation` から英語表現を視覚的に理解できる画像を生成する
- 完了時のみ画像 payload を返す

## Asset storage

- 生成した画像を何らかのストレージサービスに永続化する
- ストレージ上で画像を一意に識別する情報と再取得参照を返す

## Pronunciation media

- 発音サンプルを参照可能な形で返す

## Deferred Scope

- 認証、account lifecycle、session 管理は auth/session 設計で扱う
- command 受理、retry / regenerate の dispatch、workflow orchestration は backend command 設計で扱う
- query model、永続化実装、ベンダー固有 adapter はこの ADR の対象外とする
