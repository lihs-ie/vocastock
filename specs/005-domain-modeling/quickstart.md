# Quickstart: ドメインモデリング

## 1. planning artifact を確認する

- [spec.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md) で 005 の project-wide domain 境界を確認する
- [plan.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/plan.md) で `Sense` を `Explanation` 内部エンティティとして導入する設計判断を確認する
- [research.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/research.md) で meaning-image mapping、単一 current image 維持、説明責務再編の判断を確認する
- [data-model.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/data-model.md) で aggregate、entity、value object、状態遷移、履歴保持を確認する
- `contracts/` で識別子、概念分離、非同期表示、外部ポート、sense-image mapping の契約を確認する

## 2. repository-level source of truth を更新する

- `docs/internal/domain/common.md` に `Sense` を project-wide 用語として追加し、`Meaning` からの移行メモを明記する
- `docs/internal/domain/explanation.md` で `Explanation.senses`、`Sense`、例文とコロケーションの ownership を正本化する
- `docs/internal/domain/visual.md` で `VisualImage.sense` と `previousImage` の整合条件を正本化する
- `docs/external/requirements.md` と `docs/external/adr.md` に、多義語の意味単位と画像対応の前提を同期する

## 3. cross-review を行う

- `Sense` が `Explanation` 所有の内部エンティティとして定義されているか確認する
- `Learner`、`VocabularyExpression`、`LearningState` の ownership boundary が `Sense` 導入で変わっていないか確認する
- `LearningStateIdentifier` が `learner + vocabularyExpression` を表す複合識別子として整理されているか確認する
- `Frequency`、`Sophistication`、`Proficiency`、登録状態、生成状態が `Sense` と混同されていないか確認する
- 例文とコロケーションが explanation 全体ではなく対応する `Sense` に結びついているか確認する
- `VisualImage.sense` が同一 `Explanation` 配下の意味だけを指せるか確認する
- explanation / image の regenerate 中も、直前の完了済み `currentExplanation` / `currentImage` だけが表示可能になっているか確認する

## 4. 次フェーズへ渡す

- `/speckit.tasks` では `Sense` 用語導入、`Explanation` / `VisualImage` 再編、外部文書整合、契約整合を task 化する
- `/speckit.implement` では docs-first で `docs/internal/domain/*.md` と `docs/external/*.md` を同一変更セットで更新する
