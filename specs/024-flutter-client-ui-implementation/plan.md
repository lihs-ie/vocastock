# Implementation Plan: Flutter Client UI Implementation

**Branch**: `024-flutter-client-ui-implementation` | **Date**: 2026-04-21 | **Spec**: [/Users/lihs/workspace/vocastock/specs/024-flutter-client-ui-implementation/spec.md](/Users/lihs/workspace/vocastock/specs/024-flutter-client-ui-implementation/spec.md)

## Summary

`applications/mobile/` に Flutter 3.41.5 クライアントを新規実装する。spec 013 canonical
screen catalog の 10 画面、4 route group (Auth / AppShell / Paywall / Restricted)、
subscription-access-recovery 全遷移を対象とする。State management は
`flutter_riverpod` 3.x + `riverpod_annotation` 4.x、routing は `go_router` 17.x、
GraphQL は `ferry` 0.16.x + `gql` 1.x で schema-first codegen、認証は
`firebase_auth` 6.x、購入は `in_app_purchase` 3.x を使用する。設計は spec 013 の
reader / gate / command binding をそのままコード構造に写像し、完了結果のみ表示を
Dart sealed class と widget テストで 2 層強制する。

## Technical Context

**Language/Version**: Dart 3.11.3 (Flutter 3.41.5 同梱)、Bash、Markdown 1.x  
**Primary Dependencies**: `applications/mobile/` 配下の Flutter アプリケーション、
`specs/013-flutter-ui-state-design/`、`specs/008-auth-session-design/`、
`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/`、
`specs/011-api-command-io-design/`、`specs/012-persistence-workflow-design/`、
`specs/014-billing-entitlement-policy/`、`specs/017-query-catalog-read/`、
`specs/020-graphql-gateway-implementation/`、`docs/internal/domain/*.md`、
`docs/development/flutter-environment.md`、`tooling/versions/approved-components.md`、
`.specify/memory/constitution.md`、`scripts/ci/run_quality_checks.sh`、
`scripts/ci/run_apple_build_smoke.sh`、`scripts/ci/run_android_build_smoke.sh`  
**Storage**: GraphQL gateway (`POST /graphql`) 経由の query / mutation、Firebase
Authentication emulator / production endpoint、ferry in-memory cache (initial slice
では disabled)、`in_app_purchase` platform-specific storefront。すべてドメインレイヤーの
ポート/アダプタ経由で接続し、SDK をドメインへ持ち込まない。  
**Testing**: Dart / Flutter の `flutter test` (unit + widget)、`integration_test`
package (後続の Phase で導入)、`flutter test --coverage` で lcov 生成し
`scripts/ci/run_flutter_coverage_gate.sh` で 90% gate。feature test は
`ProviderScope(overrides: ...)` で stub infrastructure に差し替え。  
**Target Platform**: iOS (StoreKit) / Android (BillingClient) の mobile client。web /
desktop / macOS / Linux / Windows は scope 外 (`flutter create --platforms
android,ios`)。  
**Project Type**: mobile-application implementation  
**Performance Goals**: spec 013 の reader / gate / command binding を忠実に実装する
こと、生成結果を完了のみ描画する型制約が runtime で 0 回 panic すること、polling
controller の CPU / battery 消費が iOS idle 時 1%/分未満に収まること  
**Constraints**: 憲章 I (identifier 命名)、憲章 II (shared package 制限)、憲章 III
(inner layer の事前定義)、憲章 IV (async 生成は完了のみ公開)、憲章 V (外部依存は
ポート越し)、憲章 VI (概念分離) を厳守する。Firebase ID token / refresh token を app
state に保持しない (backend 検証済みの `ActorReference` / `SessionReference` のみ保持)。
ferry cache は initial slice では disabled、projection lag 中は status-only に倒す。  
**Scale/Scope**: 1 Flutter app、4 route groups、10 screens、12 reader interfaces、
6 command interfaces、1 SubscriptionFeatureGate、5 UI state variants、7+ unit
test files、10 widget test files、5 feature test files、runtime / docs / CI
touchpoint 一式

## Constitution Check

*GATE: Must pass before Phase 0 development. Re-check after Phase 1 architecture.*

- [x] Domain impact is explicitly `no domain semantic change`. `docs/internal/domain/*.md`
      を source of truth として参照し、本実装は spec 013 が既に固定した UI binding を
      Flutter コードへ写像する。新規 aggregate / value object / domain service は追加しない。
- [x] Domain models、reader / gate / command coordination、UI state は `applications/mobile/`
      owning application 内に閉じる。`packages/rust/shared-*` / `applications/backend/*`
      に domain vocabulary や workflow state を持ち込まない。
- [x] Inner layer module boundary は `applications/mobile/lib/src/` 配下で `domain/` →
      `application/` ← `infrastructure/` / `presentation/` に分割し、外側 layer から
      内側への一方向依存にする。具体名と配置は本 plan の "Project Structure" 節で固定する。
- [x] Async generation flow は spec 013 visibility contract に従い、`pending` /
      `running` / `failed` / `timed-out` / `failed-final` / `dead-lettered` 段階の
      本体 payload を UI に露出しない。Dart sealed class (`StatusOnlyExplanationDetail`
      / `CompletedExplanationDetail` など) で型的にも分離する。
- [x] External generation、auth、purchase、persistence の依存はすべて `application/`
      layer の port interface の裏にあり、`infrastructure/` adapter でのみ SDK を触る。
      `firebase_auth` / `ferry` / `in_app_purchase` の型が `domain/` / `application/`
      に漏れない。
- [x] User stories remain independently implementable and testable. Phase 2 (auth) /
      Phase 3 (catalog + registration) / Phase 4 (detail + polling) / Phase 5
      (completed detail) / Phase 6 (subscription + paywall + restricted) / Phase 7
      (recovery) は別 PR 粒度にレビュー可能。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態、purchase state、
      subscription state、entitlement、usage allowance を混同しない。UI でも state label
      と gate decision を分離する。
- [x] Identifier naming follows the constitution. 参照型は `VocabularyExpressionIdentifier`
      / `ExplanationIdentifier` / `VisualImageIdentifier` / `SenseIdentifier` /
      `LearnerIdentifier` / `ActorReferenceIdentifier` / `SessionIdentifier` /
      `AuthAccountIdentifier` / `IdempotencyKey` とする。`id` / `xxxId` 型名と field 名は
      lint と PR review で拒絶する。

## Project Structure

### Documentation (this feature)

```text
specs/024-flutter-client-ui-implementation/
├── spec.md
├── plan.md
```

### Source Code (repository root)

Inner layer module boundary:

```text
applications/mobile/
├── pubspec.yaml                          # Flutter 3.41.5 / Dart 3.11.3 / 最新 package constraints
├── analysis_options.yaml                 # very_good_analysis + strict-casts / strict-inference / strict-raw-types
├── build.yaml                            # riverpod_generator + ferry_generator 設定
├── android/                              # flutter create 生成 (org com.vocastock)
├── ios/                                  # flutter create 生成
├── lib/
│   ├── main.dart                         # ProviderScope + VocastockApp のみ
│   └── src/
│       ├── app.dart                      # MaterialApp.router ルート
│       ├── domain/                       # 依存: (なし, pure Dart)
│       │   ├── identifier/               # VocabularyExpressionIdentifier, ExplanationIdentifier, ...
│       │   ├── common/                   # ActorReference, UserFacingMessage, Timeline
│       │   ├── status/                   # RegistrationStatus, ExplanationGenerationStatus, ...
│       │   ├── vocabulary/               # VocabularyExpression 参照型
│       │   ├── explanation/              # Explanation / Sense 参照型
│       │   ├── visual/                   # VisualImage 参照型
│       │   ├── subscription/             # Entitlement, UsageAllowance, Plan, FeatureGateDecision
│       │   └── ui_state/                 # UIStateVariant sealed class
│       ├── application/                  # 依存: domain
│       │   ├── reader/                   # *Reader interface + Riverpod providers
│       │   ├── gate/                     # SubscriptionFeatureGate, entry guards
│       │   ├── command/                  # *Command interface + AsyncNotifier
│       │   ├── polling/                  # PollingController
│       │   └── envelope/                 # CommandResponseEnvelope, CommandError
│       ├── infrastructure/               # 依存: domain, application (port interface を実装)
│       │   ├── auth/                     # firebase_auth_adapter, backend_token_verifier
│       │   ├── graphql/                  # ferry_client, operations/, mapper/
│       │   ├── reader/                   # *_reader_graphql.dart (本実装)
│       │   ├── command/                  # *_command_graphql.dart
│       │   ├── purchase/                 # in_app_purchase_adapter
│       │   ├── stub/                     # InMemoryReader / StubCommand (backend 未実装時)
│       │   └── environment.dart          # ReaderBindings 切替 (stub / local-docker / production)
│       └── presentation/                 # 依存: domain, application (infrastructure には直接触れない)
│           ├── router/                   # go_router 定義 + redirect
│           ├── auth/                     # login / session_resolving screens
│           ├── shell/                    # app_shell (StatefulShellRoute)
│           ├── catalog/                  # vocabulary_catalog / vocabulary_registration
│           ├── detail/                   # vocabulary_expression / explanation / image detail screens
│           ├── subscription/             # subscription_status screen
│           ├── paywall/                  # paywall screen
│           ├── restricted/               # restricted_access screen
│           ├── widget/                   # StatusBadge, RetryAction (共通 UI parts)
│           └── variant/                  # UIStateVariant → View mapping
└── test/
    ├── unit/                             # lib/src mirror
    ├── feature/                          # 画面遷移 + reader/command interaction
    ├── support/                          # FakeReader / FakeCommand / golden helper
    └── smoke_test.dart                   # Phase 0 bootstrap smoke (Phase 1 で分割)
```

### Dependency Direction

```text
presentation ──▶ application ──▶ domain
                    ▲
infrastructure ─────┘
(infrastructure も domain を参照するが、application の interface を実装する)
```

**Forbidden**:
- `domain/` から `application/` / `infrastructure/` / `presentation/` への参照
- `presentation/` から `infrastructure/` への直接参照 (application layer 経由のみ)
- `firebase_auth` / `ferry` / `in_app_purchase` の型が `domain/` / `application/` に
  漏れること
- `packages/rust/shared-*` への domain 追加

### Phased Delivery

| Phase | 対象 | 完了条件 |
|-------|------|----------|
| 0 | bootstrap (`applications/mobile/` 骨格 + smoke test + CI 再利用) | `flutter analyze --fatal-warnings --fatal-infos` 0 issue / `flutter test` 1+ pass |
| 1 | architecture foundation (domain + application interfaces + SubscriptionFeatureGate) | unit test 90%+、feature-gate-matrix 42 ケース網羅 |
| 2 | auth flow (Login / SessionResolving) | feature test unauth → handoff → /catalog pass |
| 3 | AppShell + Catalog + Registration | feature test 新規登録 + duplicate reuse pass |
| 4 | VocabularyExpressionDetail + Polling | feature test 5 ケース (pending / completed / retry / paywall redirect) pass |
| 5 | ExplanationDetail / ImageDetail | feature test completed-only 型制約が通る |
| 6 | Subscription + Paywall + Restricted | feature test 5 subscription state × access policy matrix pass |
| 7 | recovery / edge case | spec 013 Edge Cases 9 項目すべて feature test pass |

## Verification Strategy

### Local

```bash
cd applications/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze --fatal-warnings --fatal-infos
flutter test --coverage
bash ../../scripts/ci/run_flutter_coverage_gate.sh lcov.info 90
```

### CI (既存 workflow の再利用)

- `.github/workflows/ci.yml`:
  - `toolchain-validate` (version catalog check)
  - `flutter-static-checks` → `scripts/ci/run_quality_checks.sh` が `applications/mobile/`
    を自動検出して `flutter doctor` / `dart analyze` / `flutter test` を実行
  - `android-build-smoke` → `scripts/ci/run_android_build_smoke.sh`
  - `emulator-smoke`, `application-container-smoke` は backend-only
- `.github/workflows/apple-build.yml`:
  - `apple-build-smoke` (macos-15) → `scripts/ci/run_apple_build_smoke.sh` が
    `flutter build ios --simulator --debug --no-codesign` を実行

新規 workflow ファイルは不要。`scripts/ci/run_flutter_coverage_gate.sh` のみ Phase 0 で
新設し、閾値は Phase 1 完了後に `run_quality_checks.sh` から呼び出す step 追加を検討する。

## Constitution Compliance Notes (post-design re-check)

- **Identifier naming**: すべての UI / application / infrastructure layer で
  `XxxIdentifier` / `identifier` / 概念名を使い、`id` / `xxxId` は存在しない。違反は
  review で拒絶。
- **Completed-only visibility**: `presentation/variant/` の sealed View mapping と
  `domain/explanation/*` / `domain/visual/*` の sealed Completed / StatusOnly 型で 2 層
  強制する。
- **Concept separation**: RegistrationStatus / ExplanationGenerationStatus /
  ImageGenerationStatus / SubscriptionState / PurchaseState / Proficiency / Frequency /
  Sophistication は別 enum、別ファイル、別 widget mapping で表現する。UI 文言も各
  concept を混同しない。
- **Sidecar-only shared packages**: mobile-client は `packages/rust/shared-*` を直接
  参照しない。Dart 側での再実装 (identifier, actor reference, user-facing message) を
  `applications/mobile/lib/src/domain/common/` 配下に閉じる。
