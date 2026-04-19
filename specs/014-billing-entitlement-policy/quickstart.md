# Quickstart: 課金 Product / Entitlement Policy 設計レビュー

## 1. Canonical Catalog を確認する

1. [product-catalog-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/product-catalog-contract.md) を開く
2. `free`、`standard-monthly`、`pro-monthly` の 3 plan と product ID 対応を確認する
3. `standard-monthly` と `pro-monthly` が同じ premium bundle を共有することを確認する

期待結果:

- `free` は store product を持たない
- `standard-monthly` は `vocastock.standard.monthly`
- `pro-monthly` は `vocastock.pro.monthly`

## 2. Entitlement と Quota の差分を確認する

1. [entitlement-policy-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/entitlement-policy-contract.md) を開く
2. [quota-policy-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/quota-policy-contract.md) を開く
3. free と paid の feature set が同じで、差分は quota profile で表現されることを確認する

期待結果:

- `free-basic` は explanation / image を少量許可する
- `premium-generation` は `standard-monthly` と `pro-monthly` の両方で共有される
- quota はすべて月次リセットである
- 初期月次 quota は `10/3`、`100/30`、`300/100` である

## 3. Feature Gate Matrix を確認する

1. [feature-gate-matrix-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/feature-gate-matrix-contract.md) を開く
2. `catalog-viewing`、`vocabulary-registration`、`explanation-generation`、`image-generation`、`completed-result-viewing`、`subscription-status-access`、`restore-access` の 7 key を確認する
3. `free`、`paid active`、`paid grace`、`pending-sync`、`expired`、`revoked` の outcome が allow / limited / deny で定義されていることを確認する

期待結果:

- `pending-sync` は premium unlock を与えず、safe fallback を使う
- `expired` は free profile fallback を使う
- `revoked` は hard-stop と recovery 導線だけを残す

## 4. Subscription State Effect を確認する

1. [subscription-state-effect-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/subscription-state-effect-contract.md) を開く
2. `active`、`grace`、`pending-sync`、`expired`、`revoked` が bundle、quota、UI access、recovery にどう影響するかを確認する
3. 013 の `Paywall` / `Restricted` / `SubscriptionStatus` と矛盾しないかを確認する

期待結果:

- `grace` は paid quota profile を維持する
- `expired` は free quota へ戻る
- `revoked` は `Restricted` と回復セクションだけを許可する

## 5. Source-of-Truth と Deferred Scope を確認する

1. [billing-policy-deferred-scope-contract.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/contracts/billing-policy-deferred-scope-contract.md) を開く
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/data-model.md) の `Source-of-Truth Alignment` を確認する
3. 010 / 011 / 012 / 013 と 014 の責務境界が衝突していないことを確認する

期待結果:

- pricing amount、tax、refund、coupon、intro offer、family plan、vendor SDK detail は deferred
- 014 は product catalog / entitlement / quota / gate matrix / state effect だけを正本にする
