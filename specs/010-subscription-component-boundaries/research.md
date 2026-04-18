# Research: Subscription Component Boundaries

## Decision: 010 は 009 のオニオン分離を再利用し、subscription 専用 component family を定義する

**Rationale**: 既存の 009 は product-wide の component boundary discipline を固定している。
subscription feature が別のアーキテクチャ様式を持ち込むと、責務の見せ方が feature ごとに
ずれる。そこで 010 では 009 の内側基盤 / 外側責務の分離を再利用しつつ、billing 文脈に
必要な component family だけを追加定義する。

**Alternatives considered**:

- subscription 用に別のレイヤードアーキテクチャを採用する
- 009 の component taxonomy を直接上書きして billing を組み込む

## Decision: 課金状態の最終正本は backend authoritative subscription state が持ち、アプリは同期済み entitlement mirror だけで UI 制御する

**Rationale**: スマホアプリだけを正本にすると、複数端末、restore purchase、反映遅延、
返金や revoke を安全に扱えない。backend が正本を持ち、アプリには同期済みの entitlement
mirror だけを渡す形なら、セキュリティと UX を両立しやすい。

**Alternatives considered**:

- アプリ側を最終正本にする
- backend のみを都度参照し、アプリ mirror を持たない

## Decision: authoritative subscription state は `active` / `grace` / `expired` / `pending-sync` / `revoked` の 5 状態にする

**Rationale**: `active` / `inactive` の 2 状態では、支払い猶予、反映遅延、失効、revocation を
区別できない。5 状態に分けることで、unlock 判定、UI 表示、reconciliation の責務を明確に
できる。

**Alternatives considered**:

- `active` / `inactive` の 2 状態だけを使う
- `pending-sync` を持たず、すべて `inactive` に含める

## Decision: `grace` は一時継続状態として扱い、通常の有料 entitlement を維持する

**Rationale**: `grace` で即時ロックすると、課金更新遅延や store 由来の短期揺らぎで UX が
悪化する。`revoked` と `expired` を別に持つ以上、`grace` は paid entitlement 維持とする
方が state 分離の意味が明確になる。

**Alternatives considered**:

- `grace` で閲覧のみ許可し、生成を止める
- `grace` でも即時に有料機能を停止する

## Decision: `Entitlement Policy`、`Subscription Feature Gate`、`Usage Metering / Quota Gate` を分離する

**Rationale**: 契約で何が許可されるかと、今期の無料枠や上限を消費済みかは別概念である。
これを 1 つの `isPremium` や単一 gate に潰すと、plan 変更、無料枠、quota 超過、機能単位の
制限差分を安全に扱えない。unlock 権限、最終 gate、quota 消費判定を分ける方が拡張しやすい。

**Alternatives considered**:

- entitlement と quota 判定を 1 component にまとめる
- アプリ側 local counter で quota を管理する

## Decision: purchase state は `initiated` / `submitted` / `verifying` / `verified` / `rejected` の canonical model として subscription state から分離する

**Rationale**: 課金受付と契約状態反映は別タイミングで進むため、purchase 成功表示と
authoritative subscription state を 1 つの state へ潰すと `pending-sync` の意味が曖昧になる。
purchase state を別モデルにすることで、受付、検証中、検証成功、拒否を subscription state と
独立に説明できる。

**Alternatives considered**:

- purchase state を定義せず `pending-sync` に吸収する
- purchase state を storefront 側の local status のみで扱う

## Decision: purchase / restore / refresh は command intake、verification / notification は async reconciliation、status / entitlement / allowance は read-side に分離する

**Rationale**: purchase interaction、purchase verification、store notification 反映、UI 表示は
タイミングも失敗要因も異なる。1 つの billing component にまとめると、受付、同期、状態参照、
機能 gate が混線する。write-side、read-side、async reconciliation を分けた方が review しやすい。

**Alternatives considered**:

- purchase / restore / refresh を単一 billing service にまとめる
- status read と entitlement decision を同じ reader に押し込む

## Decision: mobile storefront、purchase verification、store notification は external adapters とし、pricing / tax / refund policy / SDK detail は deferred scope に残す

**Rationale**: この feature の目的は component boundary 定義であり、ストア設定、税務、
価格カタログ、SDK detail を確定することではない。外部境界だけを明示し、具体 policy や
vendor detail は別 feature に委ねた方が責務が二重化しない。

**Alternatives considered**:

- store-specific pricing / tax / refund detail まで 010 で定義する
- vendor SDK の選択と boundary 定義を同じ artifact で固定する

## Decision: mobile storefront、purchase verification、store notification adapter には timeout / retry / fallback を明示する

**Rationale**: 憲章は新しい外部依存に対して timeout、再試行、障害時の代替動作の記載を
要求している。billing では adapter 障害時に unlock を誤判定しないことが重要なので、
各 adapter の resilience を明示する。

**Alternatives considered**:

- resilience は実装時にのみ決め、計画書には書かない
- すべての adapter に共通の曖昧な fallback だけを定義する

## Decision: auth/session と backend command の既存正本は再定義せず、subscription component は接続境界だけを定義する

**Rationale**: actor handoff は 008、command semantics は 007 がすでに正本を持つ。
subscription feature がそれらの behavioral contract を再定義すると、auth / billing / command
の責務が衝突する。010 では billing 文脈から見た利用点だけを定義する。

**Alternatives considered**:

- 010 で actor resolution と command semantics を再度定義する
- auth/session を subscription package に取り込む
