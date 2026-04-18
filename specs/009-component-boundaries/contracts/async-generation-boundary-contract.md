# Contract: Async Generation Boundary

## Purpose

`Explanation generation` と `Image generation` の long-running workflow を、request acceptance、workflow execution、result reading、adapter connection に分離して固定する。

## Explanation Flow Boundary

| Concern | Component | Responsibility |
|---------|-----------|----------------|
| request acceptance | `Explanation Generation Request Intake` | 解説生成要求を受け付け、workflow 起動要求へ変換する |
| workflow execution | `Explanation Generation Workflow` | `VocabularyExpression` から completed `Explanation` / `Sense` を生成する |
| provider connection | `Explanation Generation Provider Adapter` | explanation provider との接続を担う |
| completed result read | `Explanation Reader` | completed `Explanation` と履歴を返す |
| status read | `Generation Status Reader` | `pending` / `running` / `succeeded` / `failed` を返す |

## Image Flow Boundary

| Concern | Component | Responsibility |
|---------|-----------|----------------|
| request acceptance | `Image Generation Request Intake` | completed `Explanation` と optional `Sense` を前提に画像生成要求を受け付ける |
| workflow execution | `Image Generation Workflow` | completed `Explanation` から `VisualImage` を生成し、必要な storage handoff を行う |
| provider connection | `Image Generation Provider Adapter` | image provider との接続を担う |
| asset persist | `Asset Storage Adapter` | 画像保存と stable asset reference 発行を担う |
| asset access | `Asset Access Adapter` | stored asset の read reference 解決を担う |
| completed result read | `Visual Image Reader` | completed `VisualImage` と `Explanation.currentImage` 解決を返す |
| status read | `Generation Status Reader` | image generation status を返す |

## Workflow Rules

- `Explanation Generation Workflow` と `Image Generation Workflow` は別 component として定義しなければならない
- `Async Generation` 配下の component は UI と直接通信してはならず、completed result の user-facing return を own してはならない
- incomplete generated result は workflow 内部状態としてのみ存在し、user-facing read contract へ現れてはならない
- `Generation Status Reader` は status を返してよいが、incomplete explanation payload や incomplete image payload を返してはならない

## Optional Sense Rule

- `Image Generation Request Intake` は optional `Sense` 指定を受け付けてよい
- `Image Generation Workflow` は `Sense` 指定がある場合でも completed `Explanation` を前提に動かなければならない
- `Explanation Generation Workflow` は `Sense` を completed output の一部として返してよいが、`Image Generation Workflow` の existence を前提にしてはならない

## Visibility Rule

- `Presentation` が参照してよいのは `Explanation Reader`、`Visual Image Reader`、`Generation Status Reader` の contract のみである
- `Async Generation` 配下の component 名を UI state の代替概念として使ってはならない
