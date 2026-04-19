# Implementation Plan: Flutter 画面遷移 / UI 状態設計

**Branch**: `013-flutter-ui-state-design` | **Date**: 2026-04-19 | **Spec**: [/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md)
**Input**: Feature specification from `/specs/013-flutter-ui-state-design/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock の mobile 実装前提として、Flutter client の route topology、screen state、
reader / gate / command binding、subscription 制限と回復導線を docs-first で固定する。
`Auth`、`Paywall`、`Restricted` は full-screen の別ルート群とし、ログイン後の通常利用は
app shell 配下で扱う。通常利用 shell では `VocabularyExpression Detail` を generation
status 集約画面とし、completed explanation と completed image のみを専用 detail へ分離する。
課金状態では backend authoritative subscription state を正本とし、`grace`、`pending-sync`、
`expired`、`revoked` の表示差分、canonical な `subscription status` 画面、restore /
recovery 導線を reader / gate 起点で整理する。008 の auth/session、009 の component boundary、
010 の subscription boundary、011 の command I/O、012 の persistence / workflow runtime を
正本参照し、widget 詳細、animation spec、platform-native visual branching は deferred scope に置く。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents, Flutter 3.41.5 client design assumptions  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/`、`specs/011-api-command-io-design/`、`specs/012-persistence-workflow-design/`、Flutter navigation / state management guidance、Apple HIG、Material Design 3  
**Storage**: Git-managed repository files、設計上で参照する abstract query readers、gate readers、command intake outputs、subscription status mirror、workflow status projection  
**Testing**: spec / constitution / architecture の手動クロスレビュー、navigation topology review、screen-to-source binding review、generation visibility review、subscription access / recovery review、deferred-scope review  
**Target Platform**: Flutter mobile client for iOS / Android、phone-first app shell、`Auth` / `Paywall` / `Restricted` full-screen route groups  
**Project Type**: documentation / mobile navigation and UI-state design  
**Performance Goals**: レビュー担当者が 10 分以内に主要画面と route group、reader / gate / command binding を説明できること、10 分以内に login・registration・paywall/restore の 3 フローを追跡できること、5 分以内に `pending-sync`、`grace`、`expired`、`revoked`、generation failure、stale read の表示方針を判定できること  
**Constraints**: product code は追加しない、未完了 explanation / image payload を表示しない、未確認 premium unlock を completed として扱わない、`Auth` / `Paywall` / `Restricted` は通常利用 shell と別ルート群に置く、`VocabularyExpression Detail` は status 集約のみを担い completed result は専用 detail に分離する、`expired` は completed result 閲覧を残すが premium 操作は paywall へ戻す、`revoked` は `Restricted` へ送る、subscription status の canonical 画面は通常利用 shell から到達可能にする、widget / animation / visual token / push notification / tablet 最適化は deferred scope とする  
**Scale/Scope**: 4 route groups、10 から 12 の主要 screen definitions、6 から 8 の reader / gate / command bindings、4 つの subscription access policies、4 つの recovery flows、5 つの contract 文書を含む docs-first の mobile UI-state design package を対象とする

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. 本 feature は `docs/internal/domain/*.md` を terminology source として参照し、aggregate semantics 自体は変更しない。画面遷移、reader / gate binding、visibility rule を docs-first で整理し、domain docs 更新は不要と明記する。
- [x] Async generation flows define visible result rules. explanation / image generation の runtime state は status 表示に反映してよいが、user-facing に見せるのは completed result だけであり、`VocabularyExpression Detail` と専用 detail の役割を分離する。
- [x] External dependencies remain behind ports/adapters. auth/session、command intake、readers、gate、subscription authority は既存 boundary の completed output / read model を参照し、Flutter screen は provider SDK や workflow runtime を直接扱わない。
- [x] User stories remain independently reviewable. 入口 route 設計、registration から result 閲覧、subscription recovery は別 contract と quickstart 手順で独立に確認できる。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態、purchase state、subscription state、entitlement、usage allowance を混同しない。UI でも state label と gate decision を分離する。
- [x] Identifier naming follows the constitution. 画面設計で扱う参照も `VocabularyExpressionIdentifier`、`ExplanationIdentifier`、`SessionIdentifier` のように正本命名を維持し、`id` / `xxxId` を導入しない。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/navigation-topology-contract.md`,
`contracts/screen-source-binding-contract.md`,
`contracts/generation-result-visibility-contract.md`,
`contracts/subscription-access-recovery-contract.md`, and
`contracts/ui-state-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/013-flutter-ui-state-design/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── generation-result-visibility-contract.md
│   ├── navigation-topology-contract.md
│   ├── screen-source-binding-contract.md
│   ├── subscription-access-recovery-contract.md
│   └── ui-state-boundary-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/
        ├── common.md
        ├── learner.md
        ├── vocabulary-expression.md
        ├── learning-state.md
        ├── explanation.md
        ├── visual.md
        └── service.md

specs/
├── 008-auth-session-design/
├── 009-component-boundaries/
├── 010-subscription-component-boundaries/
├── 011-api-command-io-design/
├── 012-persistence-workflow-design/
└── 013-flutter-ui-state-design/
```

**Structure Decision**: 013 は Flutter widget 実装や state management code を直接追加する feature ではなく、
その前提となる route topology、screen catalog、reader / gate / command binding、subscription access policy を
固定する設計パッケージとして扱う。認証 / actor handoff は 008、component placement は 009、課金 authority は 010、
command acceptance と message shape は 011、completed visibility と stale read rule は 012 を正本参照し、
013 はどの route group へ入り、どの screen がどの source-of-truth を読み、どこで status-only と completed result を
分けるかだけを定義する。最終的な product-wide architecture メモは `docs/external/adr.md` と
`docs/external/requirements.md` へ同期する前提だが、planning artifact では 013 配下に mobile review 導線を集約する。

## Complexity Tracking

> No constitution violations requiring justification were identified.
