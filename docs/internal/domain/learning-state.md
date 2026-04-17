# LearningState ドメインモデル

## この文書の役割

- `LearningState` を学習進捗の正本として定義する
- `Proficiency` を `VocabularyExpression` や `Explanation` から分離して固定する

## 関連文書

- [common.md](./common.md)
- [learner.md](./learner.md)
- [vocabulary-expression.md](./vocabulary-expression.md)

## 値オブジェクト

### LearningStateIdentifier

- 学習状態を一意に識別する値オブジェクト

### Proficiency

- `Learning`
- `Learned`
- `Internalized`
- `Fluent`

## 集約

### LearningState

- 学習者ごとの習熟状態を表す集約
- `Learner` と `VocabularyExpression` の関係上でのみ存在する

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| identifier | LearningStateIdentifier | 1 | 学習状態識別子 |
| learner | LearnerIdentifier | 1 | 対象学習者 |
| vocabularyExpression | VocabularyExpressionIdentifier | 1 | 対象登録表現 |
| proficiency | Proficiency | 1 | 習熟度 |
| timeline | Timeline | 1 | 作成・更新日時 |

不変条件:

- `learner + vocabularyExpression` は一意でなければならない
- `vocabularyExpression` は同じ `learner` が所有する `VocabularyExpression` でなければならない
- `proficiency` は `Learning`、`Learned`、`Internalized`、`Fluent` のいずれか
- `Frequency` と `Sophistication` を持ってはならない

## 責務

- 学習者ごとの主観的な定着状態だけを扱う
- 登録状態、解説生成状態、画像生成状態を代替してはならない
- 学習進捗の更新は `LearningState` だけで完結させる

## リポジトリ

### LearningStateRepository

- `findByLearnerAndVocabularyExpression(learner, vocabularyExpression)`
- `persist(state)`
