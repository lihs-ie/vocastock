# Contract: Async Visibility

## Purpose

解説生成と画像生成の非同期状態、保存責務、再試行責務、ユーザー表示規則を固定する。

## Command Entry Points

| Flow | Trigger Command | Accepted By | Immediate Response |
|------|-----------------|-------------|--------------------|
| Explanation Generation | register vocabulary / request explanation generation | Vocabulary Command | 受付結果と状態 `pending` を返す。解説本文は返さない |
| Image Generation | request image generation / regenerate image | Vocabulary Command | 受付結果と状態 `pending` を返す。画像本体は返さない |

## Explanation Flow

| Status | Owner Boundary | Stored Data | User-visible Status | User-visible Content |
|--------|----------------|-------------|---------------------|----------------------|
| `pending` | Vocabulary Command | 対象語彙、受付済み command 情報 | 生成待ち | なし |
| `running` | Explanation Workflow | request tracking、進行中状態、内部ログ参照 | 生成中 | なし |
| `succeeded` | Explanation Workflow | 完了済み `Explanation`、関連状態更新 | 生成完了 | 解説本文を表示してよい |
| `failed` | Explanation Workflow | 失敗状態、要約済み failure reason | 生成失敗 | 失敗状態のみ表示し、解説本文は表示しない |

## Image Flow

| Status | Owner Boundary | Stored Data | User-visible Status | User-visible Content |
|--------|----------------|-------------|---------------------|----------------------|
| `pending` | Vocabulary Command | 対象解説、受付済み command 情報 | 生成待ち | なし |
| `running` | Image Workflow | request tracking、進行中状態、内部ログ参照 | 生成中 | なし |
| `succeeded` | Image Workflow | 完了済み `VisualImage`、storage reference、関連状態更新 | 生成完了 | 画像を表示してよい |
| `failed` | Image Workflow | 失敗状態、要約済み failure reason | 生成失敗 | 失敗状態のみ表示し、画像は表示しない |

## Cross-flow Rules

- 画像生成は対応する解説が `succeeded` である場合のみ受け付ける
- ユーザーに見せてよい成果物は常に `succeeded` に対応する完了結果のみ
- `pending`、`running`、`failed` では状態表示や再試行導線を見せてよいが、中間生成物は表示しない
- 再試行は Vocabulary Command が command を受理し、各 workflow が同一業務キーで冪等に処理する
- 詳細な provider エラーは内部ログに保持し、ユーザーには要約済み状態だけを見せる
