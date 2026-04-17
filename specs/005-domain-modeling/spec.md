# Feature Specification: ドメインモデリング - Sense導入差分

**Feature Branch**: `009-sense-modeling`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "005をSense導入差分へ更新する"

## Clarifications

### Session 2026-04-17

- Q: 多義語の意味単位はどこに置くか → A: `Sense` を `Explanation` 所有の内部エンティティとして導入する
- Q: `VisualImage` は複数意味を扱うために `Explanation` の内部値へ戻すか → A: 独立集約のまま維持し、必要に応じて `sense` を参照する
- Q: `Sense` 導入時に `currentImage` は複数化するか → A: 今回は単一 `currentImage` を維持し、複数 current image は後続 scope とする

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 意味単位を明確化する (Priority: P1)

ドメイン設計者として、多義語の解説を意味単位で整理したい。そうすることで、意味、状況、
ニュアンス、例文、コロケーションがどの意味に属するかを一貫した言葉で説明できるようにしたい。

**Why this priority**: `Sense` を定義しないまま画像や例文を増やすと、どの意味を補助しているかが曖昧になるため。

**Independent Test**: 第三者が設計成果物だけを読み、`Sense`、`Explanation`、`VisualImage` の責務差分を 5 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 1 つの英語表現に複数の意味がある, **When** ドメインモデリング結果を確認する, **Then** 意味ごとの説明単位として `Sense` が定義されている
2. **Given** 例文やコロケーションを確認する, **When** どの意味に属するかを見る, **Then** explanation 全体ではなく対応する `Sense` に結びついている

---

### User Story 2 - 意味と画像の対応を定義する (Priority: P2)

実装担当者として、`Sense` 導入後も画像生成の current 参照、再試行、再生成、表示可否を壊さずに、
どの画像がどの意味を補助するかをドメインの言葉で整理したい。

**Why this priority**: 画像と意味の対応が曖昧だと、多義語で誤った画像を表示しても domain 上で検出できないため。

**Independent Test**: レビュー担当者が成果物だけを読み、sense-aware image generation と単一 `currentImage` の業務意味を説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** `Explanation` に複数の `Sense` がある, **When** 画像生成ルールを確認する, **Then** `VisualImage` が必要に応じて対応する `Sense` を参照できる
2. **Given** 画像再生成中または失敗中である, **When** ユーザー表示ルールを確認する, **Then** 直前の完了済み `currentImage` だけを維持し、中間生成結果は表示しない

---

### User Story 3 - 差分導入の境界を周辺文書へ反映する (Priority: P3)

レビュー担当者として、`Sense` 導入が既存の 005 全体設計を壊さず、どこまでが今回の対象で、
どこからが後続 scope かを周辺文書から一貫して確認したい。

**Why this priority**: `Sense` 導入差分と既存 005 全体スコープの境界が曖昧だと、plan と tasks が spec とずれ続けるため。

**Independent Test**: 要件文書、ADR、共通 glossary を横断して、`Sense` 導入、meaning-to-image mapping、後続 scope が矛盾なく説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 要件文書とドメイン文書を比較する, **When** `Sense`、`Meaning`、画像対応を確認する, **Then** 用語差分と移行方針が矛盾なく説明できる
2. **Given** ADR とドメイン文書を比較する, **When** 単一 `currentImage` の維持と複数 current image の後続 scope を確認する, **Then** 今回の対象範囲と後続範囲が一貫している

---

### Edge Cases

- 単一の `Explanation` に `Sense` が 1 件しかない場合でも、`Sense` 導入によって説明が過剰に複雑にならないこと
- `VisualImage` が explanation 全体を代表する画像であり、特定の `Sense` に結びつかない場合を許可するかどうかが曖昧な場合
- 画像再生成時に `previousImage` と `sense` の関係が崩れ、異なる意味の画像履歴を誤って連結してしまう場合
- `Meaning.values` の旧表現が残り、`Sense` と explanation-wide meaning の二重管理になる場合
- `Sense` を導入したことにより、`Frequency`、`Sophistication`、`Proficiency` が意味単位へ吸収されたように誤読される場合
- `currentImage` を複数 current image と誤解し、完了済み結果のみ表示する rule が崩れる場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: `docs/internal/domain/common.md`, `docs/internal/domain/explanation.md`, `docs/internal/domain/service.md`, `docs/internal/domain/visual.md`
- **Invariants / Terminology**: `Sense` は `Explanation` 所有の意味単位であり、頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態とは別概念として保つ。`ExampleSentence` と `Collocation` は `Sense` に属し、`Frequency` と `Sophistication` は引き続き `Explanation` に属する。`currentImage` は単一参照のままとする
- **Async Lifecycle**: 解説生成と画像生成は少なくとも `pending`、`running`、`succeeded`、`failed` を持ち、再試行と再生成は冪等性を壊さない前提で定義する。`Sense` を導入しても、画像生成は新しい成功時だけ `currentImage` を切り替える
- **User Visibility Rule**: ユーザーに見せる生成物は完了済みの `currentExplanation` と `currentImage` のみとし、生成中・失敗時は状態のみを表示対象とする。`Explanation` が複数の `Sense` を持っていても、今回の current image は 1 件のみ表示対象とする
- **Identifier Naming Rule**: 識別子型は `XxxIdentifier`、集約自身の識別子フィールドは `identifier`、関連識別子フィールドは概念名で定義し、`id`、`ID`、`xxxId`、`xxxIdentifier` は使わない。`Sense` を導入する場合は `SenseIdentifier` を使う
- **External Ports / Adapters**: 解説生成、画像生成、アセット保存、外部発音リソース参照をドメイン外責務として整理する。画像生成は必要に応じて対象 `Sense` を指定できるが、ベンダー固有実装は持ち込まない

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、既存の 005 ドメインモデルを前提とした差分機能として、`Explanation` への `Sense` 導入範囲を明示しなければならない
- **FR-002**: 成果物は、`Sense` を `Explanation` 所有の意味単位として定義し、その意味、責務、関係、不変条件、用語上の区別を示さなければならない
- **FR-003**: 成果物は、`ExampleSentence` と `Collocation` を explanation-wide の配列ではなく、対応する `Sense` に属する情報として定義しなければならない
- **FR-004**: 成果物は、`Frequency`、`Sophistication`、`Proficiency`、登録状態、解説生成状態、画像生成状態を `Sense` と混同しないように定義しなければならない
- **FR-005**: 成果物は、`VisualImage` を `Explanation` とは独立した集約として維持しつつ、必要に応じてどの `Sense` を描写する画像かを示す関係を定義しなければならない
- **FR-006**: 成果物は、`Explanation.currentImage` を単一の current 参照として維持し、`Sense` 導入だけを理由に複数 current image を導入してはならない
- **FR-006a**: 成果物は、画像再生成時に以前の `VisualImage` を履歴として保持し、`previousImage` と `sense` の関係が矛盾しない条件を定義しなければならない
- **FR-007**: 成果物は、`Sense` を導入した後も、ユーザーに見せてよい生成物と内部状態を区別し、中間生成結果を表示しないルールを維持しなければならない
- **FR-008**: 成果物は、sense-aware な画像生成と保存の責務をドメイン内概念と区別し、外部ポート越しに扱う前提を定義しなければならない
- **FR-009**: 成果物は、`Meaning` から `Sense` への用語差分と移行メモを整理し、要件、ADR、既存ドメイン文書でどの用語を正として採用するかを示さなければならない
- **FR-010**: 成果物は、`Learner`、`VocabularyExpression`、`LearningState` の既存 ownership boundary を再定義せず、今回の差分が `Explanation` / `VisualImage` 中心の変更であることを明示しなければならない
- **FR-011**: 成果物は、今回扱わない論点として「複数 current image を同時に公開する設計」を明示し、後続 feature へ委ねる範囲を示さなければならない

### Key Entities *(include if feature involves data)*

- **Explanation**: `VocabularyExpression` に対する解説を表す概念であり、`Sense`、発音、頻出度、知的度、類似表現、語源、画像生成状態、現在表示中画像との関係を持つ
- **Sense**: `Explanation` が所有する意味単位であり、意味ラベル、状況、ニュアンス、意味ごとの例文、意味ごとのコロケーションを担う
- **VisualImage**: 解説に対応する視覚的表現を表す独立集約であり、画像生成状態、保存先参照、再生成後の履歴保持、必要に応じた `Sense` 参照の責務境界を持つ
- **Meaning-to-Image Mapping**: どの画像が explanation 全体を代表するか、またはどの `Sense` を補助するかを表す関係概念であり、単一 `currentImage` を維持したまま意味対応を説明する判断基準になる

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 成果物を読んだ第三者が、`Sense`、`Explanation`、`VisualImage` の責務差分と ownership boundary を 5 分以内に説明できる
- **SC-002**: `Sense`、`Meaning`、`Frequency`、`Sophistication`、`Proficiency`、登録状態、生成状態の混同に関する文書上の矛盾が 0 件になる
- **SC-003**: レビュー担当者が、sense-aware image generation と単一 `currentImage` の表示ルールを 5 分以内に判定できる
- **SC-004**: 要件文書、ADR、ドメイン文書を横断確認したとき、`Sense` 導入差分と後続 scope の食い違いが 0 件になる

## Assumptions

- 005 の既存 docs-first 実装は完了しており、今回はそのうち `Explanation` / `VisualImage` / glossary 周辺の差分更新を行う
- `Learner`、`VocabularyExpression`、`LearningState` の ownership boundary と命名統一は既存 005 の成果物を正本として再利用する
- 完了済み結果のみをユーザーに表示するルールは前提として維持する
- 外部サービスの具体製品選定や API 詳細は扱わず、sense-aware な業務責務とポート境界のみを整理対象とする
- 複数 current image の同時公開は今回の scope 外であり、`Sense` 導入後の follow-on feature で扱う
