# Quickstart: ドメインモデリング

## 1. planning artifact を確認する

- [spec.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md) で対象範囲、`Learner`、学習者所有の `VocabularyExpression`、`VisualImage` 独立集約を確認する
- [research.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/research.md) で所有境界、一意性境界、current 参照、命名統一の判断を確認する
- [data-model.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/data-model.md) で aggregate、value object、状態遷移、履歴保持を確認する
- `contracts/` で識別子、概念分離、非同期表示、外部ポートの契約を確認する

## 2. repository-level source of truth を更新する

- `docs/internal/domain/learner.md` を新規追加し、`Learner` の source-of-truth にする
- `docs/internal/domain/vocabulary-expression.md` を新規追加し、学習者所有の `VocabularyExpression` と学習者内一意性の正本にする
- `docs/internal/domain/learning-state.md` を新規追加し、`LearningState` と `Proficiency` 分離の正本にする
- `docs/internal/domain/explanation.md` で `VocabularyExpression.currentExplanation` と `Explanation.currentImage` の責務を明確化する
- `docs/internal/domain/visual.md` で `VisualImage` の履歴保持と `previousImage` 規則を明確化する
- `docs/internal/domain/service.md` を learner identity を含む external port catalog に整合させる
- `docs/external/requirements.md` と `docs/external/adr.md` の語彙差分を埋める

## 3. cross-review を行う

- `Learner` が所有境界、`VocabularyExpression` が登録対象、`LearningState` が学習進捗として分離されているか確認する
- `normalizedText` の一意性が同一学習者内に閉じているか確認する
- `Frequency`、`Sophistication`、`Proficiency`、登録状態、生成状態が混同されていないか確認する
- explanation / image の regenerate 中も、直前の完了済み `currentExplanation` / `currentImage` だけが表示可能になっているか確認する
- 外部責務が `LearnerIdentityPort`、`WordValidationPort`、`RegistrationLookupPort`、`ExplanationGenerationPort`、`ImageGenerationPort`、`AssetStoragePort`、`PronunciationMediaPort` に整理されているか確認する

## 4. 次フェーズへ渡す

- `/speckit.tasks` では source-of-truth の新規追加、既存文書の再編、用語整合、契約整合を task 化する
- `/speckit.implement` では docs-first で `docs/internal/domain/*.md` と `docs/external/*.md` を同一変更セットで更新する
