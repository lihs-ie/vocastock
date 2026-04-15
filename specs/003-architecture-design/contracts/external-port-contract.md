# Contract: External Port

## Purpose

外部依存への接続点、caller boundary、入出力責務、失敗時方針を定義する。

## Port Catalog

| Port | Caller Boundary | Input | Output | Guarantees |
|------|-----------------|-------|--------|------------|
| `WordValidationPort` | Vocabulary Command | `term` | `exists`, `normalizedTerm`, `rejectionReason?` | 登録前の検証のみを行い、副作用を持たない |
| `ExplanationGenerationPort` | Explanation Workflow | `entry`, `normalizedTerm`, `generationContext` | `requestIdentifier`, `status`, `explanationPayload?`, `failureReason?` | 完了時のみ解説 payload を返し、未完了時は状態情報のみ返す |
| `PronunciationMediaPort` | Explanation Workflow | `term` | `sampleReference?`, `failureReason?` | 発音参照を返すが、解説生成責務そのものは持たない |
| `ImageGenerationPort` | Image Workflow | `explanation`, `imagePromptContext` | `requestIdentifier`, `status`, `imagePayload?`, `failureReason?` | 完了時のみ画像 payload を返し、再生成でも同一契約を使う |
| `AssetStoragePort` | Image Workflow | `imagePayload`, `metadata` | `image`, `storageReference` | 保存後に再取得可能な安定参照を返す |

## Rules

- Client Experience はどの external port にも直接接続してはならない
- 外部依存のタイムアウト、再試行、障害時の扱いは caller-owned adapter が持つ
- `ExplanationGenerationPort` と `ImageGenerationPort` の未完了出力は内部状態としてのみ扱い、ユーザー可視化してはならない
- `AssetStoragePort` の返す `storageReference` は永続化済み画像の単一参照でなければならない
- provider 差し替え時も port 名と意味論を維持し、domain model を変更しない
