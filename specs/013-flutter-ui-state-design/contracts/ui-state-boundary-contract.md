# Contract: UI State Boundary

## Purpose

013 が固定する責務、既存 feature から受け継ぐ責務、後続 feature へ委ねる責務を整理する。

## Source Of Truth Matrix

| Concern | Source Of Truth | 013 で扱う範囲 |
|---------|-----------------|----------------|
| auth / session / actor handoff completion | `specs/008-auth-session-design/` | route guard と `SessionResolving` 画面への反映だけを扱う |
| component placement / read vs write split | `specs/009-component-boundaries/` | `Presentation` 側の screen / binding へ反映する |
| subscription authority / entitlement / quota | `specs/010-subscription-component-boundaries/` | UI での access policy と recovery flow へ反映する |
| command envelope / message / acceptance | `specs/011-api-command-io-design/` | screen action と message surface への反映だけを扱う |
| completed visibility / stale read / workflow runtime meaning | `specs/012-persistence-workflow-design/` | status-only と completed detail の分離へ反映する |

## Deferred Scope

| Concern | Source Of Truth | Why Deferred |
|---------|-----------------|-------------|
| widget-level component library | future Flutter implementation feature | 013 は route / screen / state の定義までに留める |
| motion curve / animation spec | future motion design feature | 状態遷移責務と visual motion detail は別である |
| color token / typography token / art direction finalization | future design-system feature | 現在は情報設計と state design が優先である |
| tablet / foldable / split-view optimization | future responsive UI feature | 013 は phone-first flow を固定する |
| push notification / widget entry points | future client integration feature | main app navigation と別責務である |

## Boundary Rules

- 013 は screen、route group、reader / gate / command binding、UI state variant を定義するが、backend authoritative state 自体は定義しない
- 013 は status-only と completed detail の分離を保持し、workflow runtime state を直接 UI route 名へ流用してはならない
- 013 は canonical な `SubscriptionStatus` 画面を持つが、unlock 判定そのものは backend authority に残す
- 013 は Flutter navigation の conceptual topology を定義するが、具体的な router package、widget tree、state management library は定義しない
