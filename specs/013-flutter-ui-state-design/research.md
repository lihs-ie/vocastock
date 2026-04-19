# Research: Flutter 画面遷移 / UI 状態設計

## Decision 1: 入口導線は full-screen route group と app shell に分ける

- **Decision**: `Auth`、`Paywall`、`Restricted` は full-screen の別 route group とし、ログイン後の通常利用は app shell 配下で扱う。
- **Rationale**: 認証前、課金制限、利用停止は通常利用中の catalog / detail flow と責務が異なる。full-screen で分離した方が reader / gate の判定境界が明確になり、login 後の actor handoff 完了待ちも安全に表現できる。
- **Alternatives considered**:
  - 1 本の navigation stack に統合する: route guard と modal 制御が複雑になり、paywall / restricted の責務が通常利用フローへ漏れるため不採用。
  - modal overlay で被せる: login や revoked の hard stop には弱く、深い戻る履歴が不安定になるため不採用。

## Decision 2: `VocabularyExpression Detail` を状態集約画面にし、completed result だけ専用 detail に分ける

- **Decision**: 通常利用 shell では `VocabularyExpression Detail` を generation status 集約画面とし、completed explanation と completed image のみを専用 detail 画面で閲覧する。
- **Rationale**: registration 後の利用者はまず 1 つの語彙単位で進捗を確認したい。一方で本文や画像は completed のみを見せる必要があるため、状態集約面と result 閲覧面を分けた方が 012 の visibility rule に忠実である。
- **Alternatives considered**:
  - 1 画面にすべて集約する: 未完了 payload と completed result の境界が曖昧になりやすいため不採用。
  - explanation / image を最初から独立主画面にする: registration 直後の状態確認導線が分散し、モバイル遷移が重くなるため不採用。

## Decision 3: `expired` と `revoked` は異なる access policy を持つ

- **Decision**: `expired` は通常利用 shell 内で completed result の閲覧を維持しつつ、premium 操作や生成系操作は paywall へ戻す。`revoked` は full-screen の `Restricted` へ送る。
- **Rationale**: `expired` は課金切れであり、利用停止やセキュリティ異常ではない。既存学習結果の閲覧を完全に遮断するより、閲覧は許可しつつ upsell / restore を促す方が自然である。`revoked` はより強い停止理由を表すため、通常 shell から切り離す。
- **Alternatives considered**:
  - `expired` と `revoked` を同じ restricted flow にする: 状態の意味差が失われるため不採用。
  - 両方とも shell に残して個別 deny にする: hard-stop と soft-limit の境界が曖昧になるため不採用。

## Decision 4: `subscription status` は shell から到達できる canonical 画面に集約する

- **Decision**: `subscription status` は通常利用 shell から到達できる canonical 画面とし、paywall と `Restricted` はその回復セクションへ利用者を導く。
- **Rationale**: `active`、`grace`、`pending-sync` でも状態確認や restore を行いたい。paywall 配下だけに閉じると、通常利用中の自己診断と recovery 導線が二重化しやすい。
- **Alternatives considered**:
  - paywall 配下だけに置く: 課金制限がない利用者が状態確認しづらいため不採用。
  - restore 専用画面を別に持つ: status explanation と recovery flow が分裂するため不採用。

## Decision 5: Flutter screen は command intake を叩き、更新結果は reader / gate から再取得する

- **Decision**: mobile screen は workflow runtime や backend authoritative write を直接操作せず、すべて command intake を経由して状態更新を依頼し、画面表示は readers / gates から再取得した projection に限定する。
- **Rationale**: 009 の component boundary と 011 の command I/O を UI に一貫して反映するため。UI が workflow state を直接持つと 012 の stale read / completed visibility rule と衝突する。
- **Alternatives considered**:
  - screen が workflow 進行を直接保持する: source-of-truth が増えて整合が崩れるため不採用。
  - command response だけで完結する: eventual consistency と stale read の扱いが不十分になるため不採用。

## Decision 6: phone-first の shell とし、tablet / foldable 最適化は deferred scope に置く

- **Decision**: 013 は phone-first の route / state design を対象とし、tablet sidebar、navigation rail、foldable 2-pane などの大画面最適化は deferred scope に置く。
- **Rationale**: まずは login、registration、generation、paywall / restore の主要フローを一貫した 1 カラム移動で固定する方が実装準備に寄与する。大画面最適化は route topology 確定後に分離して扱える。
- **Alternatives considered**:
  - 最初から phone / tablet / foldable 全対応を固定する: 画面責務よりレイアウト分岐の議論が先行するため不採用。
  - iOS / Android で完全別設計にする: Flutter cross-platform の前提とずれるため不採用。

## Decision 7: status-only と completed result の文言責務を screen state に固定する

- **Decision**: loading、status-only、completed、retryable failure、hard stop を UI state variant として明示し、screen ごとに見せてよい payload と action を固定する。
- **Rationale**: generation failure、`pending-sync`、restore 中、stale read などが混在すると、単なる boolean flag では誤表示しやすい。screen state variant を明示した方がレビューと実装で解釈ぶれが減る。
- **Alternatives considered**:
  - screen ごとの自由記述に任せる: flow ごとの差分が比較しづらいため不採用。
  - backend state 名をそのまま UI 状態に使う: domain / runtime / UI の概念が混ざるため不採用。
