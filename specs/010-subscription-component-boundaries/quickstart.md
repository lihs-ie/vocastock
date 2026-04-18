# Quickstart: Subscription Component Boundaries

## 1. topology を確認する

最初に [subscription-topology-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-topology-contract.md) を読み、010 が 009 のオニオン分離を再利用した subscription-specific boundary package であることを確認する。

確認ポイント:

- top-level boundary group が `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Subscription Reconciliation`、`External Adapters` に整理されていること
- `Domain Core` と `Application Coordination` は 009 側の内側基盤を再利用し、この feature で再定義していないこと

## 2. authority と state model を確認する

[subscription-authority-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-authority-contract.md) を読み、課金状態の最終正本が backend にあること、app は synced entitlement mirror だけを UI 制御に使うことを確認する。

確認ポイント:

- `active`、`grace`、`expired`、`pending-sync`、`revoked` の 5 状態が定義されていること
- `initiated`、`submitted`、`verifying`、`verified`、`rejected` の purchase state model が subscription state と別に定義されていること
- `grace` は paid entitlement を維持し、`pending-sync` は status 表示できても unlock 判定には使わないこと

## 3. entitlement と quota gate の分離を確認する

[entitlement-gate-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/entitlement-gate-contract.md) を読み、subscription state、entitlement、feature gate、usage limit が別責務になっていることを確認する。

確認ポイント:

- `Entitlement Policy` と `Subscription Feature Gate` が別 component として定義されていること
- usage 消費判定が `Usage Metering / Quota Gate` に分離されていること

## 4. purchase / restore / refresh のフローを確認する

[purchase-reconciliation-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/purchase-reconciliation-contract.md) を読み、購入完了、復元、状態再同期がどの component を通るかを確認する。

確認ポイント:

- purchase artifact 提出、verification、authoritative state 更新、mirror 読み出しが別工程になっていること
- purchase state progression が `verified` になるまで unlock 根拠に使われないこと
- store notification による cross-device reconciliation が別 workflow として定義されていること

## 5. adapter resilience を確認する

[subscription-authority-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-authority-contract.md) と [purchase-reconciliation-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/purchase-reconciliation-contract.md) を読み、timeout、retry、fallback が unlock 誤判定を起こさない形で定義されていることを確認する。

確認ポイント:

- `Mobile Storefront Adapter`、`Purchase Verification Adapter`、`Store Notification Adapter` ごとに timeout / retry / fallback が示されていること
- adapter 障害中は status 表示を継続しても未確認 entitlement を unlock 根拠にしないこと

## 6. deferred scope を確認する

最後に [subscription-deferred-scope-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-deferred-scope-contract.md) を読み、今回 ownership を持たない billing concern を確認する。

確認ポイント:

- auth/session は 008、command semantics は 007、product-wide taxonomy は 009 を参照すること
- pricing / tax / refund policy / vendor SDK detail は今回の対象外であること

## Review Sequence

1. [spec.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/spec.md)
2. [plan.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md)
3. [research.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/research.md)
4. [data-model.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/data-model.md)
5. [subscription-topology-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-topology-contract.md)
6. [subscription-authority-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-authority-contract.md)
7. [entitlement-gate-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/entitlement-gate-contract.md)
8. [purchase-reconciliation-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/purchase-reconciliation-contract.md)
9. [subscription-deferred-scope-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-deferred-scope-contract.md)
