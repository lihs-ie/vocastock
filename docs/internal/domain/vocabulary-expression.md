# VocabularyExpression ドメインモデル

## この文書の役割

- `VocabularyExpression` を学習者が所有する登録対象の正本として定義する
- `VocabularyExpressionText` と `NormalizedVocabularyExpressionText` を固定する
- 解説生成状態、retry / regenerate、`currentExplanation` の表示ルールを明文化する

## 関連文書

- [common.md](./common.md)
- [learner.md](./learner.md)
- [learning-state.md](./learning-state.md)
- [explanation.md](./explanation.md)
- [service.md](./service.md)

## 値オブジェクト

### VocabularyExpressionIdentifier

- 登録対象を一意に識別する値オブジェクト

### VocabularyExpressionText

- ユーザーが登録した英語表現

不変条件:

- 1 文字以上

### NormalizedVocabularyExpressionText

- 重複判定に使う正規化済み英語表現

不変条件:

- 同一学習者内で一意でなければならない

### VocabularyExpressionKind

- `word`
- `phrase`

### RegistrationStatus

- `active`
- `archived`

### ExplanationGenerationStatus

- `pending`
- `running`
- `succeeded`
- `failed`

## 集約

### VocabularyExpression

- 学習者が所有する登録対象となる英語表現
- 単語と連語を同一概念で扱う

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| identifier | VocabularyExpressionIdentifier | 1 | 登録対象識別子 |
| learner | LearnerIdentifier | 1 | 所有学習者 |
| text | VocabularyExpressionText | 1 | 登録された表現 |
| normalizedText | NormalizedVocabularyExpressionText | 1 | 重複判定用表現 |
| kind | VocabularyExpressionKind | 1 | 単語か連語か |
| registrationStatus | RegistrationStatus | 1 | 登録状態 |
| explanationGeneration | ExplanationGenerationStatus | 1 | 解説生成状態 |
| currentExplanation | ExplanationIdentifier | 0..1 | 現在表示中の完了済み解説 |
| timeline | Timeline | 1 | 作成・更新日時 |

不変条件:

- `learner + normalizedText` は同一学習者内で一意でなければならない
- `kind` は `word` または `phrase`
- `currentExplanation` は同じ `VocabularyExpression` に属する完了済み `Explanation` だけを参照できる
- `registrationStatus` と `explanationGeneration` を混同してはならない

## 解説生成ライフサイクル

- `pending -> running -> succeeded | failed`
- `failed -> pending` は retry として許可する
- `succeeded -> running` は regenerate として許可する
- regenerate 開始時に `currentExplanation` を消してはならない
- 新しい解説が `succeeded` になった時だけ `currentExplanation` を切り替える
- regenerate 失敗時は、直前の完了済み `currentExplanation` があれば維持してよい

## 表示ルール

- ユーザーへ見せてよい本文は完了済み `currentExplanation` のみ
- `pending` / `running` / `failed` では状態のみを表示できる
- 未完了解説や部分生成結果を表示してはならない

## LearningState との関係

- `VocabularyExpression` 自体は `Proficiency` を持たない
- 習熟度は [learning-state.md](./learning-state.md) の `LearningState` が扱う

## リポジトリ

### VocabularyExpressionRepository

- `find(identifier)`
- `findByLearnerAndNormalizedText(learner, normalizedText)`
- `listByLearner(learner)`
- `persist(vocabularyExpression)`
- `archive(identifier)`
