# ドメインサービス / 外部ポート

## この文書の役割

- ドメインが外部へ依存する責務を port として整理する
- 認証実装、AI vendor、ストレージ SDK などの実装詳細を domain language に持ち込まない

## 関連文書

- [common.md](./common.md)
- [learner.md](./learner.md)
- [vocabulary-expression.md](./vocabulary-expression.md)
- [explanation.md](./explanation.md)
- [visual.md](./visual.md)

## ポート一覧

### LearnerIdentityPort

目的:

- 外部 identity を `Learner` 境界へ結びつける

| 入力 | 出力 | 保証 |
|---|---|---|
| `authenticationSubject` | `learner?`, `found` | credential や session の実装詳細を返さず、`Learner` 解決に必要な結果だけを返す |

### WordValidationPort

目的:

- 登録対象の英語表現が有効かを判定し、必要なら正規化結果を返す

| 入力 | 出力 | 保証 |
|---|---|---|
| `text`, `kind` | `exists`, `normalizedVocabularyExpressionText`, `rejectionReason?` | 同じ入力に対して一貫した判定を返し、登録や生成の副作用を持たない |

### RegistrationLookupPort

目的:

- 同一学習者内で既存登録済みの `VocabularyExpression` があるかを確認する

| 入力 | 出力 | 保証 |
|---|---|---|
| `learner`, `normalizedVocabularyExpressionText`, `kind` | `registered`, `vocabularyExpression?` | 重複登録判定は同一学習者境界の内側だけで行い、生成副作用を持たない |

### ExplanationGenerationPort

目的:

- `VocabularyExpression` に対する解説生成を依頼し、状態更新に必要な結果を返す

| 入力 | 出力 | 保証 |
|---|---|---|
| `vocabularyExpression`, `normalizedVocabularyExpressionText` | `requestIdentifier`, `status`, `explanationPayload?`, `failureReason?` | 完了時のみ解説本文を返し、未完了時は状態だけを返す |

### ImageGenerationPort

目的:

- 完了済み `Explanation` に基づく画像生成を依頼し、画像生成状態を返す

| 入力 | 出力 | 保証 |
|---|---|---|
| `explanation`, `sense?`, `imagePromptContext` | `requestIdentifier`, `status`, `imagePayload?`, `failureReason?` | `sense` を指定する場合は同じ `Explanation` に属する意味単位だけを受け付け、完了時のみ画像成果物を返し、retry / regenerate も同じ契約で扱う |

### AssetStoragePort

目的:

- 画像成果物を永続化し、安定した識別子と取得参照を返す

| 入力 | 出力 | 保証 |
|---|---|---|
| `binaryOrAssetPayload`, `metadata(explanation, sense?)` | `image`, `storageReference` | 返却された参照で再取得でき、識別子は一意であり、必要に応じて explanation 全体画像か特定 `Sense` 画像かを後続で追跡できる |

### PronunciationMediaPort

目的:

- 発音サンプルを参照可能な形で取得する

| 入力 | 出力 | 保証 |
|---|---|---|
| `text` | `sampleReference?` | 取得不能時は失敗理由または空結果を返し、解説本文の生成責務と混同しない |

## ポート分離ルール

- domain は vendor 名、SDK 型、transport 形式を知らない
- auth provider の credential / session 管理は外部責務であり、この文書では扱わない
- generator や storage の実装差し替えは port 契約を崩さずに行える必要がある
- domain は完了済み結果だけを表示対象とし、中間画像 payload の公開可否は `status` と `Explanation.currentImage` で判断する
