# Explanation ドメインモデル

## この文書の役割

- `Explanation` を `VocabularyExpression` に紐づく知識集約として定義する
- `Sense` を `Explanation` 所有の意味単位として定義する
- `Frequency` と `Sophistication` の所有者を `Explanation` に固定する
- `currentImage` と `imageGeneration` の責務を明確化する
- meaning-to-image mapping の正本を [visual.md](./visual.md) と分担して固定する

## 関連文書

- [common.md](./common.md) - project-wide 用語、`Meaning` から `Sense` への移行メモ、単一 `currentImage` ルール
- [vocabulary-expression.md](./vocabulary-expression.md)
- [visual.md](./visual.md) - `VisualImage.sense`、履歴、current handoff 条件
- [service.md](./service.md) - sense-aware image generation を扱う外部ポート

## 値オブジェクト

### ExplanationIdentifier

- 解説を一意に識別する値オブジェクト
- 英語表現そのものではなく、生成済み解説結果を識別する

### SenseIdentifier

- 同一 `Explanation` 内の意味単位を識別する値オブジェクト
- related-field 命名は `sense` に統一し、`senseId` や `senseIdentifier` を使わない

### FrequencyLevel

- `often`
- `sometimes`
- `rarely`
- `hardlyEver`

### Frequency

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| level | FrequencyLevel | 1 | 頻出度レベル |
| reason | 文字列 | 1 | 判定理由 |

不変条件:

- `reason` は 1 文字以上 255 文字以下

### SophisticationLevel

- `advanced`
- `intermediate`
- `basic`
- `veryBasic`

### Sophistication

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| level | SophisticationLevel | 1 | 知的度レベル |
| reason | 文字列 | 1 | 判定理由 |

不変条件:

- `reason` は 1 文字以上 255 文字以下

### PhoneticSymbols

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| weak | 文字列 | 1 | 弱形 |
| strong | 文字列 | 1 | 強形 |

不変条件:

- `weak` は 1 文字以上 255 文字以下
- `strong` は 1 文字以上 255 文字以下

### Pronunciation

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| symbols | PhoneticSymbols | 1 | 発音記号 |
| sample | 参照 | 0..1 | 外部メディア参照 |

### Collocation

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| value | 文字列 | 1 | コロケーション |
| meaning | 文字列 | 1 | 意味 |

不変条件:

- `value` は 1 文字以上 255 文字以下
- `meaning` は 1 文字以上 255 文字以下

### ExampleSentence

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| value | 文字列 | 1 | 例文 |
| meaning | 文字列 | 1 | 日本語説明 |
| pronunciation | 文字列 | 1 | 例文の発音 |

不変条件:

- `value` は 1 文字以上 255 文字以下
- `meaning` は 1 文字以上 255 文字以下

### SimilarExpression

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| value | 文字列 | 1 | 類似表現 |
| meaning | 文字列 | 1 | 意味・ニュアンス |
| comparison | 文字列 | 1 | 元の `VocabularyExpression` との比較 |

不変条件:

- `value`、`meaning`、`comparison` は 1 文字以上 255 文字以下

### Etymology

- 1 文字以上 255 文字以下の文字列

### ImageGenerationStatus

- `pending`
- `running`
- `succeeded`
- `failed`

## エンティティ

### Sense

- `Explanation` が所有する意味単位の内部エンティティ
- explanation 全体の粗い `Meaning` ではなく、意味、状況、ニュアンス、例文、コロケーションを意味単位で束ねる

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| identifier | SenseIdentifier | 1 | 同一 `Explanation` 内での意味識別子 |
| label | 文字列 | 1 | 意味を短く表す代表ラベル |
| situation | 文字列 | 1 | 使われる状況 |
| nuance | 文字列 | 1 | ニュアンス |
| order | 正の整数 | 1 | 表示順序 |
| collocations | Collocation の一覧 | 0..5 | その意味に結びつくコロケーション |
| examples | ExampleSentence の一覧 | 0..3 | その意味に結びつく例文 |

不変条件:

- `label` は 1 文字以上 255 文字以下
- `situation` は 1 文字以上 255 文字以下
- `nuance` は 1 文字以上 255 文字以下
- `order` は 1 以上の整数
- `identifier` と `order` は同一 `Explanation` 内で重複してはならない
- `collocations` と `examples` は explanation 全体ではなく、その `Sense` の意味に対応していなければならない

## 集約

### Explanation

- `VocabularyExpression` に紐づく生成済み解説を表す知識集約
- 1 件以上の `Sense` を持ち、ユーザーへ表示する本文と画像生成の current 参照を保持する

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| identifier | ExplanationIdentifier | 1 | 解説識別子 |
| vocabularyExpression | VocabularyExpressionIdentifier | 1 | 元の登録対象 |
| senses | Sense の一覧 | 1..5 | 意味単位の一覧 |
| pronunciation | Pronunciation | 1 | 発音情報 |
| frequency | Frequency | 1 | 頻出度 |
| sophistication | Sophistication | 1 | 知的度 |
| etymology | Etymology | 1 | 語源 |
| similarities | SimilarExpression の一覧 | 1..5 | 類似表現 |
| imageGeneration | ImageGenerationStatus | 1 | 画像生成状態 |
| currentImage | VisualImageIdentifier | 0..1 | 現在表示中の完了済み画像 |
| timeline | Timeline | 1 | 作成・更新日時 |

不変条件:

- `vocabularyExpression` は常に 1 つの `VocabularyExpression` を参照する
- `senses` は 1 件以上 5 件以下でなければならない
- `senses` の `identifier` と `order` は同一 `Explanation` 内で一意でなければならない
- `frequency` と `sophistication` は `Explanation` が所有する
- `Proficiency` を持ってはならない
- `currentImage` は同じ `Explanation` に属する完了済み `VisualImage` だけを参照できる
- `currentImage` が `sense` を持つ画像を指す場合、その `sense` は同じ `Explanation.senses` のいずれかでなければならない
- `currentImage` が未設定でも、`imageGeneration` は状態を保持できる
- explanation 全体を代表する画像を current にする場合、`VisualImage.sense` は未設定でよい

## 画像生成ライフサイクル

- `pending -> running -> succeeded | failed`
- `failed -> pending` は retry として許可する
- `succeeded -> running` は regenerate として許可する
- regenerate 開始時に `currentImage` を消してはならない
- 新しい画像が `succeeded` になった時だけ `currentImage` を切り替える
- `failed` 時は、直前の完了済み `currentImage` があれば継続表示してよい
- 画像生成リクエストは explanation 全体または特定 `Sense` を対象にできるが、current 参照は常に 1 件だけである

## 表示ルール

- ユーザーへ表示してよい画像は完了済みの `currentImage` のみ
- 画像生成中または失敗中は状態だけを表示できる
- 未完了画像、不完全 payload、中間結果は表示してはならない
- `Explanation` が複数の `Sense` を持っていても、`currentImage` を配列化して複数同時表示してはならない

## リポジトリ

### ExplanationRepository

- `find(identifier)`
- `findCurrentByVocabularyExpression(vocabularyExpression)`
- `listByVocabularyExpression(vocabularyExpression)`
- `persist(explanation)`
