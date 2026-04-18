# Contract: Component Allocation

## Purpose

現行のフラットな component 一覧を canonical component catalog へ割り当て、keep / split / add / defer を固定する。

## Current-to-Canonical Mapping

| Current Item | Canonical Component(s) | Top-Level Responsibility | Action | Notes |
|--------------|------------------------|--------------------------|--------|-------|
| `UI` | `UI` | `Presentation` | keep | completed `Explanation` / `VisualImage` と status の表示だけを担う |
| `Learner identity resolution` | `Learner Identity Resolution` | `Actor/Auth Boundary` | narrow | auth/session 実装詳細を除外し、`Learner` 解決だけへ責務を絞る |
| _(missing)_ | `Actor Session Handoff` | `Actor/Auth Boundary` | add | auth/session 境界の出力を product 内へ渡す明示 component を追加する |
| `VocabularyExpression validation` | `Vocabulary Expression Validation Policy` + `Vocabulary Expression Validation Adapter` | `Command Intake` + `External Adapters` | split | normalization / policy と external lexicon check を分離する |
| `Registration lookup` | `Registration Lookup` | `Command Intake` | keep | 同一学習者内の duplicate registration check を担う |
| _(missing)_ | `Vocabulary Expression Registration Intake` | `Command Intake` | add | 登録要求受理の起点を明示する |
| `Explanation generation` | `Explanation Generation Request Intake` + `Explanation Generation Workflow` + `Explanation Generation Provider Adapter` | `Command Intake` + `Async Generation` + `External Adapters` | split | request acceptance、workflow、provider call を分離する |
| `Explanation reader` | `Explanation Reader` + `Generation Status Reader` | `Query Read` | split | completed result / history read と status read を分離する |
| `Image generation` | `Image Generation Request Intake` + `Image Generation Workflow` + `Image Generation Provider Adapter` | `Command Intake` + `Async Generation` + `External Adapters` | split | optional `Sense` 指定を受理しつつ workflow は別 component とする |
| _(missing)_ | `Visual Image Reader` | `Query Read` | add | completed `VisualImage` と current image 解決を reader として明示する |
| `Asset storage` | `Asset Storage Adapter` + `Asset Access Adapter` | `External Adapters` | split | asset persist と access/reference resolution を分離する |
| `Pronunciation media` | `Pronunciation Media Reader` + `Pronunciation Media Adapter` | `Query Read` + `External Adapters` | split | app-facing read と external media fetch を分離する |

## Allocation Rules

- 現行の 1 項目が request acceptance / workflow / read / adapter を跨ぐ場合、single component のまま残してはならない
- `Command Intake` に属する component は completed payload を返す reader として扱ってはならない
- `Query Read` に属する component は workflow 起動や duplicate lookup を担ってはならない
- `External Adapters` に属する component は user-facing contract 名で current list に現れていても、必要に応じて app-facing reader と分離しなければならない

## New Components Added By This Feature

- `Actor Session Handoff`
- `Vocabulary Expression Registration Intake`
- `Visual Image Reader`
- `Generation Status Reader`
- `Asset Access Adapter`

## Explicit Non-Allocations

- auth account lifecycle、provider sign-in、session invalidation detail は `specs/008-auth-session-design/` の責務であり、009 の canonical component としては保持しない
- retry / regenerate semantics、dispatch failure、workflow start rule は `specs/007-backend-command-design/` の責務であり、009 では component placement だけを定義する
