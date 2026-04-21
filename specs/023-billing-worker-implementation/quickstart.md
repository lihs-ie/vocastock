# Quickstart: Billing Worker Implementation

## Goal

`billing-worker` が submitted 済み purchase artifact と normalized store notification を worker runtime として処理し、
completed `BillingRecord` (purchase state 更新 + entitlement snapshot) の保存と
`Subscription.currentEntitlementSnapshot` handoff が両方成立した時だけ success にし、
retryable / terminal failure では status-only だけを残し、notification reconciliation 中は新規 paid entitlement を
付与しないことを確認する。

## Review Flow

1. [research.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/research.md) を読み、
   Haskell runtime baseline、stable-run のみの canonical success signal、submitted purchase artifact + normalized
   notification に絞った initial slice、二段階 success、malformed payload の terminal 扱い、duplicate handling、
   notification reconciliation が新規 unlock を付与しない方針、テスト方針の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/data-model.md) で、
   `BillingWorkItem`、`BillingWorkflowState`、`SubscriptionAuthoritySnapshotCandidate`、
   `CurrentSubscriptionHandoff`、`BillingFailureSummary` を確認する
3. [billing-work-item-contract.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/billing-work-item-contract.md)
   と [purchase-verification-workflow-contract.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/purchase-verification-workflow-contract.md)
   で intake、purchase state transition、retry / timeout / dead-letter rule を確認する
4. [store-notification-workflow-contract.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/store-notification-workflow-contract.md)
   で notification intake、補正方針、新規 unlock 付与禁止ルールを確認する
5. [billing-visibility-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/billing-visibility-handoff-contract.md)
   で confirmed-only visibility、candidate handoff、entitlement snapshot commit contract を確認する
6. [billing-worker-runtime-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/billing-worker-runtime-boundary-contract.md)
   で stable-run、Docker/Firebase feature test、scope 外責務を確認する

## Implementation Verification

1. `cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test`
2. `cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test --enable-coverage`
3. `cd /Users/lihs/workspace/vocastock/applications/backend/billing-worker && cabal test feature`
4. `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`
5. `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`

`run_application_container_smoke.sh` 完了後は
`/Users/lihs/workspace/vocastock/.artifacts/ci/logs/application-container-smoke.summary`
に `billing_worker_validation.success`、
`billing_worker_validation.retryable-failure`、
`billing_worker_validation.terminal-failure`、
`billing_worker_validation.notification-reconciled`
が個別 record として残ることを確認する。

## What Must Be True

1. `billing-worker` は submitted 済み purchase artifact と normalized store notification だけを処理すること
2. worker runtime は `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を区別すること
3. success は completed `BillingRecord` 保存と `Subscription.currentEntitlementSnapshot` handoff 完了の両方が必要であること
4. handoff 完了前の candidate snapshot は confirmed entitlement snapshot として扱わないこと
5. retryable failure、timeout、terminal failure は completed `BillingRecord` を作らず、status-only 要約だけを残すこと
6. malformed / incomplete verification payload は `failed-final` として扱い、partial snapshot を保存しないこと
7. duplicate / replay work は business key 単位で idempotent に扱い、authoritative subscription state や entitlement snapshot の重複切替を起こさないこと
8. notification reconciliation は補正経路であり、retry / timeout / failure 中に新規 paid entitlement を付与しないこと
9. worker は public endpoint や query response を own せず、canonical success signal は stable-run であること
10. feature テストは Haskell のコードから Docker container と Firebase emulator を使って動くこと
11. runtime validation では `success`、`retryable-failure`、`terminal-failure`、`notification-reconciled` を別シナリオとして再現し、`VOCAS_BILLING_RESULT` を summary に記録すること

## Deferred Scope

- restore workflow の worker 側実装 (012 に別 runtime trace あり)
- Apple App Store / Google Play 固有 SDK の実 adapter 実装
- store product catalog 管理 / pricing change / tax / intro offer / coupon / family plan
- image workflow と `image-worker` の追加変更
- explanation workflow との cross-concern
- provider 固有最適化 / モデル選定 hardening
- public GraphQL operation の拡張
