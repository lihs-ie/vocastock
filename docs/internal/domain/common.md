# 共通ドメインモデル

## Source-of-Truth Index

| 文書 | 正本となる概念 | 役割 |
|---|---|---|
| [learner.md](./learner.md) | `Learner`、`AuthenticationSubject` | 学習者の所有境界と外部 identity 境界 |
| [vocabulary-expression.md](./vocabulary-expression.md) | `VocabularyExpression`、`VocabularyExpressionText`、`NormalizedVocabularyExpressionText` | 学習者が所有する登録対象と解説生成状態 |
| [learning-state.md](./learning-state.md) | `LearningState`、`LearningStateIdentifier`、`Proficiency` | 学習進捗と習熟度 |
| [explanation.md](./explanation.md) | `Explanation`、`Sense`、`Frequency`、`Sophistication` | 解説本文、意味単位、画像生成状態 |
| [visual.md](./visual.md) | `VisualImage`、`StorageReference` | 画像アセット、意味対応、履歴 |
| [service.md](./service.md) | external port catalog | 外部責務の境界 |

## Sense 導入レビューアンカー

- `Sense` は `Explanation` が所有する内部エンティティである
- `Sense` は多義語の意味単位を表し、`Meaning` は移行メモ上の旧表現としてのみ残す
- `VisualImage` は独立集約のまま維持し、必要に応じて `sense` で意味単位を指せる
- `Explanation.currentImage` は `Sense` 導入後も 0..1 件の単一 current 参照を維持する
- 複数 current image の同時公開は follow-on scope とし、この文書群では扱わない

## 集約関係の概要

```mermaid
classDiagram
    class Learner
    class VocabularyExpression
    class Explanation
    class Sense
    class VisualImage
    class LearningState
    class LearningStateIdentifier

    Learner --> VocabularyExpression : owns
    Learner --> LearningState : tracks
    VocabularyExpression --> Explanation : currentExplanation
    Explanation --> Sense : contains
    Explanation --> VisualImage : currentImage
    VisualImage --> Sense : depicts
    VisualImage --> VisualImage : previousImage
    LearningState --> LearningStateIdentifier : identifier
    LearningStateIdentifier --> Learner : learner
    LearningStateIdentifier --> VocabularyExpression : vocabularyExpression
```

- `Learner` は所有境界であり、認証方式そのものは保持しない
- `VocabularyExpression` は学習者が所有する登録対象で、単語と連語を同一概念で扱う
- `Explanation` は `VocabularyExpression` の完了済み解説結果を表し、1 件以上の `Sense` を持つ
- `Sense` は意味、状況、ニュアンス、例文、コロケーションを束ねる `Explanation` 配下の意味単位である
- `VisualImage` は `Explanation` に属する独立集約で、必要に応じて特定の `Sense` を描写しつつ履歴を保持する
- `LearningState` は `Learner` と `VocabularyExpression` の関係上にある習熟度専用集約であり、`LearningStateIdentifier` はその関係を表す複合識別子である

## 正規用語と移行メモ

| 正規用語 | 非推奨 / 旧称 | 補足 |
|---|---|---|
| `VocabularyExpression` | `Entry` | 学習者が所有する登録対象の正規名称 |
| `LearningState` | `EntryLearningState` | 学習進捗の正規名称 |
| `VocabularyExpressionText` | `EntryExpressionText` | 登録時の文字列表現 |
| `NormalizedVocabularyExpressionText` | `NormalizedEntryExpressionText` | 重複判定用の正規化表現 |
| `Sense` | `Meaning`, `Meaning.values` | `Explanation` 所有の意味単位として再編した正規名称 |

- 旧称はこの移行メモ以外では使わない
- 外部向け説明で日本語を併記する場合も、英語の正規名称は上表に合わせる
- `Meaning` は正本概念としては維持せず、`Explanation.senses` へ置き換える
- explanation 全体を代表する画像は `VisualImage.sense = null` で表し、意味対応のある画像だけ `sense` を持つ

## 命名規約

- 識別子型は必ず `XxxIdentifier` 形式にする
- 集約自身の識別子フィールド名は常に `identifier` にする
- 他集約や他概念への参照フィールドは `learner`、`vocabularyExpression`、`currentExplanation`、`currentImage` のように概念名そのものを使う
- 派生命名は `VocabularyExpression*` / `LearningState*` に統一する
- 文字列表現の値オブジェクト名は `VocabularyExpressionText` と `NormalizedVocabularyExpressionText` を採用する
- `Sense` の識別子は `SenseIdentifier` とし、関連参照フィールド名は `sense` を使う
- 複合識別子が必要な場合も `XxxIdentifier` に閉じ込め、集約本体へ同じ参照フィールドを重複保持しない

## 概念分離

| 概念 | 所有者 | 混同してはならない対象 |
|---|---|---|
| `Sense` | `Explanation` | `Frequency`、`Sophistication`、`Proficiency`、登録状態、生成状態 |
| `Frequency` | `Explanation` | `Sophistication`、`Proficiency`、生成状態 |
| `Sophistication` | `Explanation` | `Frequency`、`Proficiency`、登録状態 |
| `Proficiency` | `LearningState` | `Frequency`、`Sophistication`、生成状態 |
| `RegistrationStatus` | `VocabularyExpression` | 解説生成状態、画像生成状態 |
| `ExplanationGenerationStatus` | `VocabularyExpression` | `ImageGenerationStatus`、`RegistrationStatus` |
| `ImageGenerationStatus` | `Explanation` | `ExplanationGenerationStatus`、`Proficiency` |

## 非同期表示の共通ルール

- ユーザーへ見せてよい生成物は完了済みの `currentExplanation` と `currentImage` だけである
- regenerate 開始時に `currentExplanation` / `currentImage` を消してはならない
- 新しい解説または画像が `succeeded` になった時だけ current 参照を切り替える
- 生成中または失敗中は状態表示だけを行い、不完全な生成物は表示しない
- `Explanation` が複数の `Sense` を持っていても、表示対象の `currentImage` は常に 0..1 件である
- `currentImage` が `sense` を持つ場合、その `sense` は同じ `Explanation` に属する意味単位でなければならない
- explanation 全体を代表する画像は `sense` を持たず、意味ごとの画像と同じ表示ルールに従う

## Deferred Scope / Follow-on Boundaries

- credential 管理、session 管理、provider ごとの認証導線は auth/session 設計で扱う
- command 受理、dispatch failure、workflow orchestration は backend command 設計で扱う
- query model、永続化マッピング、adapter 実装、ベンダー固有 SDK はこの文書群の対象外とする
- 複数 current image の同時公開、meaning gallery、`Explanation` 直下の裸画像配列は後続 feature で扱う
- この文書群は project-wide domain language の正本であり、後続 feature はここで固定した概念境界を前提にする
