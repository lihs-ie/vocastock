# Contract: Domain Port Catalog

## LearnerIdentityPort

**Purpose**: 外部 identity を domain の `Learner` 境界へ結びつける。

| Input | Output | Guarantees |
|-------|--------|------------|
| `authenticationSubject` | `learner?`, `found` | 認証・credential の実装詳細を返さず、`Learner` 解決に必要な結果だけを返す |

## WordValidationPort

**Purpose**: 登録対象の英語表現が有効かを判定し、必要なら正規化結果を返す。

| Input | Output | Guarantees |
|-------|--------|------------|
| `text`, `kind` | `exists`, `normalizedVocabularyExpressionText`, `rejectionReason?` | 同じ入力に対して一貫した判定を返し、登録や生成の副作用を持たない |

## RegistrationLookupPort

**Purpose**: 同一学習者内で既存登録済みの `VocabularyExpression` があるかを確認する。

| Input | Output | Guarantees |
|-------|--------|------------|
| `learner`, `normalizedVocabularyExpressionText`, `kind` | `registered`, `vocabularyExpression?` | 重複登録判定は同一学習者境界の内側だけで行い、生成副作用を持たない |

## ExplanationGenerationPort

**Purpose**: `VocabularyExpression` に対する解説生成を依頼し、状態更新に必要な結果を返す。

| Input | Output | Guarantees |
|-------|--------|------------|
| `vocabularyExpression`, `normalizedVocabularyExpressionText` | `requestIdentifier`, `status`, `explanationPayload?`, `failureReason?` | 完了時のみ解説本文を返し、未完了時は状態だけを返す |

## ImageGenerationPort

**Purpose**: 完了済み `Explanation` と必要に応じて対象 `Sense` に基づく画像生成を依頼し、画像生成状態を返す。

| Input | Output | Guarantees |
|-------|--------|------------|
| `explanation`, `sense?`, `imagePromptContext` | `requestIdentifier`, `status`, `imagePayload?`, `failureReason?` | 完了時のみ画像成果物を返し、意味単位を指定する場合は同一 `Explanation` 配下の `Sense` だけを受理し、再生成も同じ契約で扱う |

## AssetStoragePort

**Purpose**: 画像成果物を永続化し、安定した識別子と取得参照を返す。

| Input | Output | Guarantees |
|-------|--------|------------|
| `binaryOrAssetPayload`, `metadata` | `image`, `storageReference` | 返却された参照で再取得でき、識別子は一意である |

## PronunciationMediaPort

**Purpose**: 発音サンプルを参照可能な形で取得する。

| Input | Output | Guarantees |
|-------|--------|------------|
| `text` | `sampleReference?` | 取得不能時は失敗理由または空結果を返し、解説本文の生成責務と混同しない |
