# Feature Specification: ドメインモデリング

**Feature Branch**: `005-domain-modeling`  
**Created**: 2026-04-15  
**Status**: Draft  
**Input**: User description: "ドメインモデリングを行う。私と議論しながら進めていきましょう。"

## Clarifications

### Session 2026-04-16

- Q: 習熟度 (`Proficiency`) は誰に属する状態として扱うか → A: 学習者ごとの状態として扱う
- Q: 学習者 identity は今回のドメインモデルでどう扱うか → A: 学習者を独立集約として扱う
- Q: `VocabularyExpression` は誰に属する概念として扱うか → A: 各学習者が自分の `VocabularyExpression` を所有する
- Q: 同じ英語表現の重複登録はどの粒度で禁止するか → A: 同一学習者内だけ一意にする
- Q: 画像再生成時、以前の `VisualImage` はどう扱うか → A: 履歴として保持し、現在画像だけ別参照で示す
- Q: `Entry` の標準名を何にするか → A: `VocabularyExpression` を標準名にする
- Q: `EntryLearningState` の置き換え名を何にするか → A: `LearningState` を標準名にする
- Q: `VocabularyExpression` への派生名をどう扱うか → A: 識別子型、repository、値オブジェクトを含めて `VocabularyExpression*` / `LearningState*` に全面改名する
- Q: `EntryExpression` 系の値オブジェクト名を何にするか → A: `VocabularyExpressionText` / `NormalizedVocabularyExpressionText` を標準名にする

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 主要概念の境界を定める (Priority: P1)

ドメイン設計者として、vocastock の主要概念とその境界を一貫した言葉で整理したい。そうすることで、
後続の設計、実装、レビューで同じ言葉を同じ意味で使えるようにしたい。

**Why this priority**: 概念境界が曖昧なままでは、集約、状態、責務の切り方がぶれ続けるため。

**Independent Test**: 第三者が設計成果物だけを読み、主要概念、責務境界、不変条件を 5 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 既存文書に概念の重複や不足がある, **When** ドメインモデリング結果を確認する, **Then** 主要概念、責務、関係が一貫した用語で定義されている
2. **Given** 新しい実装担当者が成果物を読む, **When** 英単語登録、解説生成、画像生成、学習状態管理の関係を確認する, **Then** 追加説明なしで概念の境界を理解できる

---

### User Story 2 - 非同期生成の業務意味を定める (Priority: P2)

実装担当者として、解説生成と画像生成の状態、再試行、再生成、表示可否をドメインの言葉で整理したい。
そうすることで、完了済み結果のみを表示するルールを壊さずに設計できる。

**Why this priority**: 非同期生成の扱いが曖昧だと、中間結果の誤表示や重複処理の不整合が起きやすいため。

**Independent Test**: レビュー担当者が成果物だけを読み、生成依頼から完了・失敗・再生成までの状態遷移と表示ルールを説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 解説生成または画像生成を扱う設計レビューを行う, **When** 成果物を確認する, **Then** `pending`、`running`、`succeeded`、`failed` と再試行条件が定義されている
2. **Given** ユーザー表示ルールを確認する, **When** 生成途中または失敗時の扱いを見る, **Then** 中間生成結果は表示せず状態のみが見えることが定義されている

---

### User Story 3 - 文書横断で用語を統一する (Priority: P3)

レビュー担当者として、要件、ADR、既存ドメイン文書の前提が揃った状態にしたい。そうすることで、
後続の architecture、tech stack、実装計画と矛盾しない土台を持ちたい。

**Why this priority**: ドメイン文書だけが正しくても、周辺文書と食い違うと設計判断が再びぶれるため。

**Independent Test**: 要件文書、ADR、ドメイン文書を横断して、主要概念と責務境界の矛盾がないと第三者が判定できれば成立する。

**Acceptance Scenarios**:

1. **Given** 要件文書とドメイン文書を比較する, **When** 頻出度、知的度、習熟度、生成状態を確認する, **Then** 概念の違いと関係が矛盾なく説明できる
2. **Given** ADR とドメイン文書を比較する, **When** 外部サービスとの責務分担を確認する, **Then** ドメイン内責務と外部依存責務の境界が一貫している

---

### Edge Cases

- 既存文書で `Explanation` が画像を直接持つ定義と `VisualImage` を独立概念として扱う定義が競合する場合
- 単語と連語を同じ識別子体系で扱うか、別概念として扱うかで不変条件が変わる場合
- 同一学習者が同じ英語表現を再登録しようとした場合に、重複として拒否するか更新として扱うかが曖昧な場合
- 画像再生成時に、過去画像を破棄するのか履歴として保持するのかが曖昧な場合
- 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態が混同される場合
- 同じ解説に対して画像生成が重複依頼されたとき、何を同一依頼とみなすか曖昧な場合
- 外部の単語検証、解説生成、画像生成、アセット保存の責務がドメイン内に入り込む場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: `docs/internal/domain/common.md`, `docs/internal/domain/explanation.md`, `docs/internal/domain/service.md`, `docs/internal/domain/visual.md`, `docs/internal/domain/learner.md`, `docs/internal/domain/vocabulary-expression.md`, `docs/internal/domain/learning-state.md`
- **Invariants / Terminology**: 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態は別概念として保ち、相互変換や代替関係として扱わない。正規名称は `VocabularyExpression` と `LearningState` を使い、識別子型、repository、値オブジェクトなどの派生名も `VocabularyExpression*` / `LearningState*` に統一する。文字列表現の値オブジェクトは `VocabularyExpressionText` と `NormalizedVocabularyExpressionText` を正規名称とする
- **Async Lifecycle**: 解説生成と画像生成は少なくとも `pending`、`running`、`succeeded`、`failed` を持ち、再試行と再生成は冪等性を壊さない前提で定義する
- **User Visibility Rule**: ユーザーに見せる生成物は完了済み結果のみとし、生成中・失敗時は状態のみを表示対象とする
- **Identifier Naming Rule**: 識別子型は `XxxIdentifier`、集約自身の識別子フィールドは `identifier`、関連識別子フィールドは概念名で定義し、`id`、`ID`、`xxxId`、`xxxIdentifier` は使わない
- **External Ports / Adapters**: 単語存在確認、登録済み判定、解説生成、画像生成、アセット保存、外部発音リソース参照をドメイン外責務として整理する

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、vocastock プロジェクト全体のドメインを対象とし、core flow、学習管理、周辺サブドメインを含む全体境界を明示しなければならない
- **FR-002**: 成果物は、対象範囲に含まれる主要概念について、意味、責務、関係、不変条件、用語上の区別を定義しなければならない
- **FR-003**: 成果物は、英単語と連語を同一の `VocabularyExpression` 概念として扱い、その識別、分類、不変条件の共通ルールを定義しなければならない。`VocabularyExpression` は各学習者が所有する登録対象として扱わなければならない
- **FR-003a**: 成果物は、同じ英語表現の `VocabularyExpression` を同一学習者内で一意に扱い、重複登録判定は学習者境界の内側で行うことを定義しなければならない
- **FR-004**: 成果物は、頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態を別概念として定義し、その関係と非関係を明文化しなければならない。特に習熟度は学習者ごとに所有される状態として扱わなければならない
- **FR-005**: 成果物は、解説生成と画像生成について、依頼、進行、完了、失敗、再試行、再生成の業務意味を定義しなければならない
- **FR-006**: 成果物は、`VisualImage` を `Explanation` とは独立した集約として扱い、生成、再生成、保存先参照、現在表示中画像との関係を定義しなければならない
- **FR-006a**: 成果物は、画像再生成時に以前の `VisualImage` を履歴として保持し、現在表示中の画像だけを別参照で示す関係を定義しなければならない
- **FR-007**: 成果物は、ユーザーに見せてよい情報と内部状態を区別し、中間生成結果を表示しないルールを定義しなければならない
- **FR-008**: 成果物は、単語検証、生成、保存などの外部責務をドメイン内概念と区別し、ポート越しに扱う前提を定義しなければならない
- **FR-009**: 成果物は、要件、ADR、既存ドメイン文書の用語差分を整理し、どの用語を正として採用するかを示さなければならない。特に `VocabularyExpression` と `LearningState` を正規名称とし、識別子型、repository、値オブジェクトなどの派生名も同じ語幹へ統一しなければならない。文字列表現の値オブジェクト名は `VocabularyExpressionText` と `NormalizedVocabularyExpressionText` を採用しなければならない
- **FR-010**: 成果物は、学習者を独立集約として定義し、`VocabularyExpression` および学習進捗との関係、および外部 identity / 認証責務との境界を示さなければならない
- **FR-011**: 成果物は、今回扱わない論点を明示し、後続 feature へ委ねる範囲を示さなければならない

### Key Entities *(include if feature involves data)*

- **VocabularyExpression**: 学習者が所有する登録対象となる英語表現を表す中心概念であり、単語または連語の扱いを定義対象とし、同一学習者内で一意に管理される。以前は `Entry` と呼んでいた概念の正規名称とする
- **Learner**: 学習者本人を表す独立集約であり、自身が所有する `VocabularyExpression` と学習進捗の起点となる
- **Explanation**: 登録対象に対する解説を表す概念であり、意味、発音、頻出度、知的度、例文、類似表現、語源との関係を持つ
- **VisualImage**: 解説に対応する視覚的表現を表す概念であり、画像生成状態、保存先参照、再生成後の履歴保持の責務境界を持つ
- **LearningState**: 学習者ごとの習熟状態を表す概念であり、`Learner` と `VocabularyExpression` の関係上で語彙自体の属性と分離された学習進捗を担う。以前は `EntryLearningState` と呼んでいた概念の正規名称とする
- **Learning Indicators**: 頻出度、知的度、習熟度など、学習上の異なる評価軸を表す概念群であり、習熟度は `LearningState` 側で扱う
- **Generation State**: 解説生成と画像生成の依頼から完了までを表す業務状態概念であり、表示可否と再試行条件の判断基準になる

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 成果物を読んだ第三者が、対象範囲内の主要概念、責務境界、不変条件を 5 分以内に説明できる
- **SC-002**: 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態の混同に関する文書上の矛盾が 0 件になる
- **SC-003**: 解説生成と画像生成について、状態遷移、再試行条件、ユーザー表示ルールをレビュー担当者が曖昧さなく判定できる
- **SC-004**: 要件文書、ADR、ドメイン文書を横断確認したとき、主要概念と責務境界の食い違いが 0 件になる

## Assumptions

- 今回の主要成果物はプロジェクト全体のドメインモデル文書とその整合整理であり、アプリケーションコードの実装変更は含まない
- 既存の architecture / tech stack の決定は所与とし、今回はその上でドメイン言語と責務境界を整理する
- 完了済み結果のみをユーザーに表示するルールは前提として維持する
- 外部サービスの具体製品選定や API 詳細は扱わず、業務責務とポート境界のみを整理対象とする
