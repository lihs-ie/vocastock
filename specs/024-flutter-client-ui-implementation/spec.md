# Feature Specification: Flutter Client UI Implementation

**Branch**: `024-flutter-client-ui-implementation` | **Date**: 2026-04-21 | **Source Design**: [spec 013-flutter-ui-state-design](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/spec.md)

## Summary

spec 013 で docs-first に固定した Flutter client の route topology / screen state /
reader-gate-command binding / subscription access policy を、実際の Flutter
アプリケーション `applications/mobile/` として新規実装する。本 feature は設計を
変更せず、spec 013 とその 5 つの contracts を唯一の正本として参照し、Auth / AppShell /
Paywall / Restricted の 4 route group と 10 画面を段階的にコード化する。認証は spec
008、command I/O は spec 011、永続化・workflow runtime は spec 012、課金 entitlement
は spec 014、query catalog read は spec 017、GraphQL gateway は spec 020 を参照する。

## Scope

- `applications/mobile/` に Flutter 3.41.5 ベースのクライアント実装を新規追加する。
- spec 013 canonical screen catalog の 10 画面を実装する (`Login`, `SessionResolving`,
  `VocabularyCatalog`, `VocabularyRegistration`, `VocabularyExpressionDetail`,
  `ExplanationDetail`, `ImageDetail`, `SubscriptionStatus`, `Paywall`, `RestrictedAccess`)。
- 4 route group と subscription-access-recovery 全遷移 (`active`, `grace`,
  `pendingSync`, `expired`, `revoked`) を実装する。
- unit / feature / widget テストを `tests/unit/` / `tests/feature/` /
  `tests/support/` に配置し、ライブラリカバレッジ 90%+ を維持する。
- CI は既存 `ci.yml` の `flutter-static-checks` と `apple-build.yml` の
  `apple-build-smoke`、`android-build-smoke` を再利用する。

## Out of Scope (deferred)

- design system token / animation / motion spec / widget style (spec 013 本文で deferred)
- tablet / foldable / split-view 最適化 (spec 013 本文で deferred)
- push notification entry point (spec 013 本文で deferred)
- 多言語対応 (initial slice は英語のみ)
- 新規ドメイン概念の追加 (`docs/internal/domain/*.md` の更新は伴わない)
- backend endpoint の新規追加 (spec 017 / 018 / 020 側で段階的に実装)

## Success Criteria

1. `cd applications/mobile && flutter analyze --fatal-warnings --fatal-infos` が 0
   warning / 0 info で pass する。
2. `cd applications/mobile && flutter test --coverage` が 90%+ のラインカバレッジで
   pass する (code generated ファイル / stub adapter を除外集計)。
3. `bash scripts/ci/run_quality_checks.sh` と `bash scripts/ci/run_apple_build_smoke.sh`
   が現状 green を維持する (Flutter project 検出後の doctor / analyze / test を通過)。
4. spec 013 canonical screen catalog の 10 画面すべてが widget test で render 検証
   済みであり、screen-source-binding-contract.md の reader / gate / command 対応が
   unit + feature test で検証されている。
5. generation-result-visibility-contract.md の「完了結果のみ表示」規則が Dart の
   sealed class 型システムで強制され、未完了 payload に触れる経路が存在しないことが
   unit test で証明される。
6. subscription-access-recovery-contract.md の 5 subscription state × feature gate
   の遷移行列が feature test で網羅されている。

## Non-Goals Verification

- domain aggregate / workflow state machine / command semantics の変更なし。
- `packages/rust/shared-*` / `applications/backend/*` に新たな domain vocabulary を
  追加しない。
- GraphQL gateway の allowlist を mobile-client 側から独自拡張しない (spec 020 で
  allowlist 済みの operation のみ使用)。

## Assumptions

- backend (graphql-gateway, command-api, query-api, explanation-worker,
  image-worker, billing-worker) は spec 017 / 018 / 020 / 021 / 022 / 023 で段階的に
  実装中であり、mobile-client は初期段階では stub reader / command に fallback できる
  構造を持つ (infrastructure 層の adapter 差し替え)。
- Firebase Authentication は emulator baseline (`127.0.0.1:9099`) を使用し、本番
  environment では production endpoint に切り替わる (spec 002, 008)。
- iOS target deployment は Firebase SDK 最低要件に合わせる (initial slice 想定値)。
- bundle identifier は `com.vocastock.app` (`flutter create --org com.vocastock
  --project-name vocastock_mobile` で生成済み、後続で Firebase project と紐付ける)。

## Dependencies

- spec 013 contracts (5 本): navigation-topology / screen-source-binding /
  generation-result-visibility / subscription-access-recovery / ui-state-boundary。
- spec 008 (auth session design), 009 (component boundaries), 010 (subscription
  component boundaries), 011 (API command I/O), 012 (persistence workflow), 014
  (billing entitlement policy), 017 (query catalog read), 020 (GraphQL gateway)。
- ドメイン正本: `docs/internal/domain/{common,learner,vocabulary-expression,
  learning-state,explanation,visual,service}.md`。
- 憲章: `.specify/memory/constitution.md` (identifier 命名、完了結果のみ表示、概念分離)。

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| backend endpoint が段階的実装のため初期は stub 依存が大きい | infrastructure 層で `ReaderBindings` を環境変数切替 (`stub` / `local-docker` / `production`) にし、feature test は stub で green を維持 |
| Flutter / Dart エコシステムの version drift | pubspec.yaml の `^` 指定で最新 minor を受け入れ、`flutter pub outdated` を CI で参考出力する |
| 完了結果のみ表示の強制が弱い実装になるとスペック違反 | Dart sealed class (`CompletedExplanationDetail` / `StatusOnlyExplanationDetail`) で型レベル強制 + unit test で「未完了 payload 参照経路ゼロ」を検証 |
| projection lag による provisional completed 漏洩 | ferry cache を initial slice で disabled に固定、polling で freshness を再判定 |
