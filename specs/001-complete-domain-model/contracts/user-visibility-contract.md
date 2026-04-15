# Contract: User Visibility Rules

## Explanation Visibility

| Explanation Status | User-visible Status | User-visible Content |
|--------------------|--------------------|----------------------|
| `pending` | 生成待ち | なし |
| `running` | 生成中 | なし |
| `succeeded` | 生成完了 | 解説本文を表示してよい |
| `failed` | 生成失敗 | 失敗状態のみ表示し、解説本文は表示しない |

## Image Visibility

| Image Status | User-visible Status | User-visible Content |
|--------------|--------------------|----------------------|
| `pending` | 生成待ち | なし |
| `running` | 生成中 | なし |
| `succeeded` | 生成完了 | 画像を表示してよい |
| `failed` | 生成失敗 | 失敗状態のみ表示し、画像は表示しない |

## Cross-cutting Rules

- ユーザーへ表示してよい生成物は `succeeded` 状態に対応する完了済み結果のみ
- `failed` 状態では再試行や再生成の導線は表示してよいが、中間生成物は表示しない
- `Explanation` が未完了の間は `VisualImage` を表示してはならない
- 状態表示はユーザーへ見せてよいが、内部エラー詳細は業務上必要な粒度に要約する
