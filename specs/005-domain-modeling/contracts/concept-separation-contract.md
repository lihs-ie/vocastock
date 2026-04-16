# Contract: Concept Separation

## Independent Concepts

| Concept | Meaning | Must Not Be Mixed With |
|--------|---------|------------------------|
| `Frequency` | 英語表現がどの程度よく使われるか | `Proficiency`, `Sophistication`, generation status |
| `Sophistication` | 英語表現の知的・語彙的な難度 | `Frequency`, `Proficiency`, registration status |
| `Proficiency` | 学習者がどれだけ定着したか | `Frequency`, `Sophistication`, generation status |
| `RegistrationStatus` | 学習者がその表現を追跡中かどうか | explanation / image generation status |
| `ExplanationGenerationStatus` | 解説生成の進行状態 | image generation status, registration status |
| `ImageGenerationStatus` | 画像生成の進行状態 | explanation generation status, proficiency |

## Ownership Rules

| Concept | Owner |
|--------|-------|
| `Frequency` | `Explanation` |
| `Sophistication` | `Explanation` |
| `Proficiency` | `LearningState` |
| `RegistrationStatus` | `VocabularyExpression` |
| `ExplanationGenerationStatus` | `VocabularyExpression` |
| `ImageGenerationStatus` | `Explanation` |

## Guarantees

- 語彙自体の属性と学習進捗を同一フィールド群へ統合しない
- `Explanation` は `Proficiency` を持たない
- `LearningState` は `Frequency` と `Sophistication` を持たない
- `VocabularyExpression` は `ImageGenerationStatus` を持たず、画像生成の current / history は `Explanation` と `VisualImage` の責務で扱う
- `ExplanationGenerationStatus` と `ImageGenerationStatus` は同じ語彙を使っても別状態として扱う
