# Research: 課金 Product / Entitlement Policy 設計

## Decision 1: 初期 plan catalog は `free`、`standard-monthly`、`pro-monthly` に固定する

**Rationale**: free を残したまま 2 つの paid plan を置くと、paywall、support、restore、
quota upsell の導線を最小限の複雑さで比較できる。annual や family plan を同時に入れるより、
初期運用で product ID と gate matrix の整合を保ちやすい。

**Alternatives considered**:

- `monthly` / `annual` の 2 plan: paid 差分が billing cadence だけになり、quota による差別化ができない
- `standard-monthly` / `standard-annual` / `pro-monthly` / `pro-annual`: catalog 数が増え、restore と support が複雑になる
- paid-only catalog: free の少量体験という要件に反する

## Decision 2: store product ID は plan code と 1:1 に対応する canonical SKU を採用する

**Rationale**: logical plan code と physical store SKU の対応が曖昧だと、purchase artifact の
解釈と support 運用が崩れる。初期は `vocastock.standard.monthly` と
`vocastock.pro.monthly` を canonical SKU として固定し、platform ごとの差分が必要なら
後続で mapping table を拡張する。

**Alternatives considered**:

- store ごとに完全に別名の SKU を採用する: mapping 管理コストが増える
- product ID を後回しにする: paywall と purchase verification の実装準備が進めにくい

## Decision 3: `standard-monthly` と `pro-monthly` は同じ premium entitlement bundle を共有する

**Rationale**: 初期の paid plan 差分を quota のみへ寄せると、entitlement bundle と feature gate
matrix を単純に保てる。新しい premium-only feature を plan 差分に持ち込むのは、catalog が
安定してからでも遅くない。

**Alternatives considered**:

- `pro-monthly` に追加 feature entitlement を付ける: gate matrix が急に複雑になる
- `standard-monthly` と `pro-monthly` で bundle を分ける: support と UI 文言の解釈ずれが増える

## Decision 4: quota は `free` / paid とも月次リセットにする

**Rationale**: store billing の cadence と quota reset を揃えると、subscription status、
support FAQ、usage allowance 表示が整合しやすい。free だけ日次にすると、comparison 表示と
paywall 文言が分かりにくくなる。

**Alternatives considered**:

- `free` は日次、paid は月次: 比較と説明が二重化する
- すべて日次: paid catalog との整合が弱い
- 累積上限: restore や renewal と噛み合いにくい

## Decision 5: 初期月次 quota は `10/3`、`100/30`、`300/100` にする

**Rationale**: `free` は体験可能だがすぐに premium 差分が見える量に抑え、`standard-monthly` と
`pro-monthly` は explanation / image の両方で明確な段差をつける。image は explanation より
原価が高い前提で、保守的な初期値にする。

**Alternatives considered**:

- より高い free quota: upsell 差分が弱くなる
- より低い paid quota: subscription の魅力が下がる
- explanation と image を同数にする: 原価差分を表現しにくい

## Decision 6: subscription state effect は `active/grace = paid profile`、`pending-sync/expired = free profile`、`revoked = hard-stop` にする

**Rationale**: 010 の authority rule と 013 の access policy を両立するには、未確認 state では
premium unlock を与えず、失効後は free fallback、取り消し時は hard-stop にするのが最も安全。
`grace` は paid entitlement 維持が既存正本なので、そのまま paid quota profile も維持する。

**Alternatives considered**:

- `pending-sync` を paid と同等に扱う: 未確認 unlock を生み危険
- `expired` で全生成を停止する: free でも生成を許可する今回の方針と矛盾する
- `revoked` でも free fallback を許す: 013 の `Restricted` 方針とずれる

## Decision 7: pricing / tax / refund / coupon は deferred scope に置く

**Rationale**: 014 は商品設計と entitlement policy の正本であり、商用施策や会計ロジックまで
抱え込むと責務が過大になる。これらは billing catalog の運用や後続 feature へ切り出した方が、
014 のレビュー観点がぶれない。

**Alternatives considered**:

- 価格表や税務表も同時に定義する: 実装前の policy 設計としてはスコープ過大
- refund policy をここで固定する: store policy と support policy の依存が強すぎる
