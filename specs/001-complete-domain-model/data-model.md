# Data Model: ドメインモデル設計書の完成

## Aggregate: VocabularyEntry

**Purpose**: ユーザーが追跡対象として登録した英単語または連語を表す基準集約。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | VocabularyEntryIdentifier | 1 | 正規化された登録識別子 |
| term | Term | 1 | ユーザーが登録した原語 |
| registrationStatus | RegistrationStatus | 1 | 登録状態 |
| explanationStatus | ExplanationGenerationStatus | 1 | 解説生成状態 |
| imageStatus | ImageGenerationStatus | 1 | 画像生成状態 |
| explanation | ExplanationIdentifier | 0..1 | 完了済み解説への参照 |
| image | VisualImageIdentifier | 0..1 | 完了済み画像への参照 |
| learningProgress | LearningProgress | 1 | 個人的な習熟度の追跡 |
| timeline | Timeline | 1 | 作成・更新日時 |

**Validation rules**:

- `identifier` と `term` は 1 文字以上 255 文字以下
- `explanation` は `explanationStatus = succeeded` のときのみ保持可能
- `image` は `imageStatus = succeeded` のときのみ保持可能
- `imageStatus = succeeded` の場合、対応する `explanation` が存在しなければならない

**State transitions**:

- `registrationStatus`: `active -> archived`
- `explanationStatus`: `pending -> running -> succeeded | failed`
- `explanationStatus`: `failed -> pending` を許可
- `imageStatus`: `pending -> running -> succeeded | failed`
- `imageStatus`: `failed -> pending`、`succeeded -> running` を再生成として許可

## Aggregate: Explanation

**Purpose**: 語彙に対する生成済み解説を表す知識集約。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | ExplanationIdentifier | 1 | 解説識別子 |
| entry | VocabularyEntryIdentifier | 1 | 元の登録語彙 |
| meaning | Meaning | 1 | 意味のまとまり |
| pronunciation | Pronunciation | 1 | 発音と発音記号 |
| frequency | Frequency | 1 | 頻出度と理由 |
| sophistication | Sophistication | 1 | 知的度と理由 |
| collocations | Collocation[] | 1..10 | コロケーション |
| examples | ExampleSentence[] | 1..3 | 例文 |
| etymology | Etymology | 1 | 語源 |
| similarities | SimilarExpression[] | 1..5 | 類似表現 |
| timeline | Timeline | 1 | 作成・更新日時 |

**Validation rules**:

- `meaning.values` は 1 件以上
- `collocations` は 1 件以上 10 件以下
- `examples` は 1 件以上 3 件以下
- `similarities` は 1 件以上 5 件以下

## Aggregate: VisualImage

**Purpose**: 解説から生成された視覚化結果を表す画像集約。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | VisualImageIdentifier | 1 | 画像識別子 |
| explanation | ExplanationIdentifier | 1 | 生成元解説 |
| storageReference | StorageReference | 1 | 永続化先を一意に参照する値 |
| timeline | Timeline | 1 | 作成・更新日時 |

**Validation rules**:

- `storageReference` は再取得可能で安定した値でなければならない
- 同一 `identifier` は 1 つの永続化先のみを指す

## Value Objects

### LearningProgress

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| proficiency | Proficiency | 1 | 習熟度 |
| updatedAt | DateTime | 1 | 習熟度の最終更新日時 |

### RegistrationStatus

- `active`
- `archived`

### ExplanationGenerationStatus

- `pending`
- `running`
- `succeeded`
- `failed`

### ImageGenerationStatus

- `pending`
- `running`
- `succeeded`
- `failed`

### Existing domain value objects retained

- `Frequency`
- `Sophistication`
- `Meaning`
- `PhoneticSymbols`
- `Pronunciation`
- `Collocation`
- `ExampleSentence`
- `SimilarExpression`
- `Etymology`
- `Timeline`

## Relationships

- `VocabularyEntry` 1 : 0..1 `Explanation`
- `Explanation` 1 : 0..n `VisualImage`
- `VocabularyEntry` 1 : 1 `LearningProgress`
- `VocabularyEntry.image` は `Explanation` に紐づく最新の完了済み画像を指す

## Domain Events

### ExplanationGenerated

| Field | Type | Description |
|-------|------|-------------|
| entry | VocabularyEntryIdentifier | 対象語彙 |
| explanation | ExplanationIdentifier | 完了した解説 |
| occurredAt | DateTime | 発生日時 |

### ExplanationGenerationFailed

| Field | Type | Description |
|-------|------|-------------|
| entry | VocabularyEntryIdentifier | 対象語彙 |
| reason | FailureReason | 失敗理由 |
| occurredAt | DateTime | 発生日時 |

### ImageGenerated

| Field | Type | Description |
|-------|------|-------------|
| explanation | ExplanationIdentifier | 対象解説 |
| image | VisualImageIdentifier | 完了した画像 |
| occurredAt | DateTime | 発生日時 |

### ImageRegenerated

| Field | Type | Description |
|-------|------|-------------|
| explanation | ExplanationIdentifier | 対象解説 |
| beforeImage | VisualImageIdentifier | 以前の画像 |
| afterImage | VisualImageIdentifier | 新しい画像 |
| occurredAt | DateTime | 発生日時 |

## Repository Contracts

- `VocabularyEntryRepository`
  - `find(identifier)`
  - `search(criteria)`
  - `persist(entry)`
  - `terminate(identifier)`
- `ExplanationRepository`
  - `find(identifier)`
  - `findByEntry(entry)`
  - `search(criteria)`
  - `persist(explanation)`
- `VisualImageRepository`
  - `find(identifier)`
  - `findByExplanation(explanation)`
  - `searchByExplanation(explanation)`
  - `persist(image)`
