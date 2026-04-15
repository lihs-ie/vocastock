# Contract: Domain Port Catalog

## WordValidationPort

**Purpose**: 登録対象の語彙が有効かを判定し、必要なら正規化結果を返す。

| Input | Output | Guarantees |
|-------|--------|------------|
| `term` | `exists`, `normalizedTerm`, `rejectionReason?` | 同じ入力に対して一貫した判定を返し、登録や生成の副作用を持たない |

## ExplanationGenerationPort

**Purpose**: 登録済み語彙に対する解説生成を依頼し、状態更新に必要な結果を返す。

| Input | Output | Guarantees |
|-------|--------|------------|
| `entry`, `normalizedTerm` | `requestIdentifier`, `status`, `explanationPayload?`, `failureReason?` | 完了時のみ解説本文を返し、未完了時は状態情報だけを返す |

## ImageGenerationPort

**Purpose**: 完了済み解説に基づく画像生成を依頼し、画像生成状態を返す。

| Input | Output | Guarantees |
|-------|--------|------------|
| `explanation`, `imagePromptContext` | `requestIdentifier`, `status`, `imagePayload?`, `failureReason?` | 完了時のみ画像成果物を返し、再生成を同じ契約で扱える |

## AssetStoragePort

**Purpose**: 生成済み画像を永続化し、安定した識別子と取得参照を返す。

| Input | Output | Guarantees |
|-------|--------|------------|
| `binaryOrAssetPayload`, `metadata` | `image`, `storageReference` | 返却された参照で再取得でき、識別子は一意である |

## PronunciationMediaPort

**Purpose**: 発音サンプルを参照可能な形で取得する。

| Input | Output | Guarantees |
|-------|--------|------------|
| `term` | `sampleReference?` | 取得不能時は失敗理由または空結果を返し、解説本文の生成責務と混同しない |
