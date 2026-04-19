# Quickstart: Flutter 画面遷移 / UI 状態設計レビュー

## 目的

013 の成果物を使い、Flutter client の画面遷移、UI 状態、reader / gate / command binding を
短時間でレビューする。

## 前提

- 008 は auth/session と actor handoff の正本
- 009 は component boundary の正本
- 010 は subscription authority と entitlement / quota 分離の正本
- 011 は command response と message shape の正本
- 012 は completed visibility、stale read、workflow runtime state の正本

## 手順 1: 入口 route を確認する

1. [navigation-topology-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/navigation-topology-contract.md) を開く
2. `Auth`、`AppShell`、`Paywall`、`Restricted` の 4 route group を確認する
3. `Login` -> `SessionResolving` -> `VocabularyCatalog` の通常入口と、paywall / restricted への分岐条件を確認する

期待結果:
- actor handoff completed 前に `AppShell` へ入らない
- `expired` は shell 内 completed result 閲覧を残す
- `revoked` は `RestrictedAccess` へ送られる

## 手順 2: registration から result 閲覧までを追跡する

1. [screen-source-binding-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/screen-source-binding-contract.md) を開く
2. `VocabularyRegistration` が `registerVocabularyExpression` を発火し、accepted 後に `VocabularyExpressionDetail` へ入ることを確認する
3. [generation-result-visibility-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/generation-result-visibility-contract.md) を開き、status-only と completed-only の切り分けを確認する

期待結果:
- `VocabularyExpressionDetail` は status 集約だけを行う
- completed explanation は `ExplanationDetail` だけで表示する
- completed image は `ImageDetail` だけで表示する
- 未完了 explanation / image payload はどの screen でも表示しない

## 手順 3: subscription recovery を追跡する

1. [subscription-access-recovery-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/subscription-access-recovery-contract.md) を開く
2. `pending-sync`、`grace`、`expired`、`revoked` の access policy を確認する
3. `Paywall` または `RestrictedAccess` から `SubscriptionStatus` の recovery section へ導く流れを確認する

期待結果:
- `grace` は paid entitlement を維持する
- `pending-sync` は状態表示できても premium unlock 根拠にしない
- `expired` は completed result 閲覧を残しつつ paywall へ戻す
- restore は canonical な `SubscriptionStatus` 画面の recovery section で扱う

## 手順 4: source-of-truth 境界を確認する

1. [ui-state-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/013-flutter-ui-state-design/contracts/ui-state-boundary-contract.md) を開く
2. concern ごとに 008 / 009 / 010 / 011 / 012 / 013 のどれが正本かを確認する

期待結果:
- 013 は screen / route / binding を定義する
- unlock 判定そのものは backend authority に残る
- workflow runtime や physical implementation detail は deferred scope に残る

## レビュー完了条件

- 主要 screen と reader / gate / command の対応を 10 分以内に説明できる
- login、registration、paywall / restore の 3 フローを 10 分以内に追跡できる
- `pending-sync`、`grace`、`expired`、`revoked`、generation failure、stale read の表示方針に解釈ぶれがない
