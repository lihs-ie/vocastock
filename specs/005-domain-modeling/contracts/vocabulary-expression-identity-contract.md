# Contract: VocabularyExpression Identity

## Ownership

| Concept | Owns | References | Notes |
|--------|------|------------|-------|
| `Learner` | 学習者 identity 境界、所有関係 | `VocabularyExpression`, `LearningState` | 認証そのものは持たず、外部 identity を参照する |
| `VocabularyExpression` | 登録対象の識別、登録状態、解説生成状態 | `Learner`, `currentExplanation` | 単語と連語を同一概念で扱う学習者所有集約 |
| `Explanation` | 解説本文、意味単位、頻出度、知的度、画像 generation 状態 | `VocabularyExpression`, `currentImage` | current な表示結果を指す知識集約 |
| `Sense` | 意味単位、意味別の例文とコロケーション | `Explanation` | `Explanation` が所有する内部エンティティ |
| `VisualImage` | 画像アセット参照、履歴 | `Explanation`, `sense`, `previousImage` | `Explanation` から独立した集約 |
| `LearningState` | 習熟度 | `Learner`, `VocabularyExpression` | 学習進捗だけを扱う |

## Identifier Rules

| Concept | Identifier Type | Self Field | Related Fields |
|--------|------------------|------------|----------------|
| `Learner` | `LearnerIdentifier` | `identifier` | none |
| `VocabularyExpression` | `VocabularyExpressionIdentifier` | `identifier` | `learner`, `currentExplanation` |
| `Explanation` | `ExplanationIdentifier` | `identifier` | `vocabularyExpression`, `currentImage` |
| `Sense` | `SenseIdentifier` | `identifier` | none |
| `VisualImage` | `VisualImageIdentifier` | `identifier` | `explanation`, `sense`, `previousImage` |
| `LearningState` | `LearningStateIdentifier` | `identifier` | `learner`, `vocabularyExpression` |

## VocabularyExpression Kind

| VocabularyExpression Kind | Meaning | Shared Rules |
|---------------------------|---------|--------------|
| `word` | 単一英単語 | 登録、検証、解説生成、学習進捗の共通ルールに従う |
| `phrase` | 連語・複数語表現 | 上記と同じ識別・生成・学習ルールに従う |

## Uniqueness Scope

| Scope | Uniqueness Rule | Notes |
|------|------------------|-------|
| Same `Learner` | `normalizedVocabularyExpressionText` は一意 | 重複登録は拒否または更新判断の対象になる |
| Same `Explanation` | `Sense.identifier` と `Sense.order` は一意 | 意味単位は explanation 内だけで識別する |
| Different `Learner` | 同じ表現でも共存可能 | 学習者間で `VocabularyExpression` を共有しない |

## Guarantees

- `VocabularyExpression` は単語と連語を統一した学習者所有の登録対象概念である
- 同じ英語表現の重複判定は同一学習者内でのみ行う
- `Sense` は `VocabularyExpression` や `LearningState` の代替概念ではなく、`Explanation` の意味単位である
- `ExplanationIdentifier` や `VisualImageIdentifier` を登録対象の識別子として使わない
- `VisualImage` は `Explanation` の内部値ではなく独立集約として扱う
- `LearningState` は `Frequency` や `Sophistication` を持たず、習熟度のみを扱う
