# Contract: Concept Separation

## Independent Concepts

| Concept | Meaning | Must Not Be Mixed With |
|--------|---------|------------------------|
| `Sense` | `Explanation` 内の意味単位 | `VocabularyExpression`, `LearningState`, generation status |
| `Frequency` | 英語表現がどの程度よく使われるか | `Proficiency`, `Sophistication`, `Sense`, generation status |
| `Sophistication` | 英語表現の知的・語彙的な難度 | `Frequency`, `Proficiency`, `Sense`, registration status |
| `Proficiency` | 学習者がどれだけ定着したか | `Frequency`, `Sophistication`, `Sense`, generation status |
| `RegistrationStatus` | 学習者がその表現を追跡中かどうか | explanation / image generation status, `Sense` |
| `ExplanationGenerationStatus` | 解説生成の進行状態 | image generation status, registration status |
| `ImageGenerationStatus` | 画像生成の進行状態 | explanation generation status, proficiency |

## Ownership Rules

| Concept | Owner |
|--------|-------|
| `Sense` | `Explanation` |
| `Frequency` | `Explanation` |
| `Sophistication` | `Explanation` |
| `Proficiency` | `LearningState` |
| `RegistrationStatus` | `VocabularyExpression` |
| `ExplanationGenerationStatus` | `VocabularyExpression` |
| `ImageGenerationStatus` | `Explanation` |

## Guarantees

- 語彙自体の属性、意味単位、学習進捗を同一フィールド群へ統合しない
- `Explanation` は `Sense` を持つが、`Proficiency` は持たない
- `LearningState` は `Frequency`、`Sophistication`、`Sense` を持たない
- `VocabularyExpression` は `Sense` を直接持たず、意味の構造化は `Explanation` の責務で扱う
- `ExplanationGenerationStatus` と `ImageGenerationStatus` は同じ語彙を使っても別状態として扱う
