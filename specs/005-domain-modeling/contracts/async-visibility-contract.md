# Contract: Async Visibility

## Explanation Visibility

| `VocabularyExpression.explanationGeneration` | User-visible Status | User-visible Content |
|---------------------------------------------|---------------------|----------------------|
| `pending` | 生成待ち | `currentExplanation` がなければ本文なし |
| `running` | 生成中 | `currentExplanation` があれば直前の完了済み解説のみ継続表示可能 |
| `succeeded` | 生成完了 | `currentExplanation` を表示してよい |
| `failed` | 生成失敗 | `currentExplanation` があれば直前の完了済み解説を維持してよく、未存在なら本文は表示しない |

## Image Visibility

| `Explanation.imageGeneration` | User-visible Status | User-visible Content |
|-------------------------------|---------------------|----------------------|
| `pending` | 生成待ち | `currentImage` がなければ画像なし |
| `running` | 生成中 | `currentImage` があれば直前の完了済み画像のみ継続表示可能 |
| `succeeded` | 生成完了 | `currentImage` を表示してよい |
| `failed` | 生成失敗 | `currentImage` があれば直前の完了済み画像を維持してよく、未存在なら画像は表示しない |

## Retry and Regeneration Rules

- `failed -> pending` は explanation / image の retry として許可する
- `succeeded -> running` は explanation / image の regenerate として許可する
- regenerate 開始時に `currentExplanation` / `currentImage` を消してはならない
- 新しい explanation / image が `succeeded` になった時だけ current 参照を切り替える
- 画像 regenerate 後も以前の `VisualImage` は `previousImage` を通じて履歴として保持する
- explanation が未完了の間は、新しい image 完了結果を current として公開してはならない
- 中間生成物、部分生成物、失敗時の不完全 payload はユーザーへ表示しない

## Guarantees

- ユーザーへ見せてよい生成物は、常に完了済みの `currentExplanation` / `currentImage` のみ
- 生成中または失敗中は状態表示のみ可能であり、新規の未完了生成物は見せない
- 冪等 retry により同じ依頼が再送されても、ユーザーへ不完全結果を見せない
