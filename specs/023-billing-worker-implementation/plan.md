# Implementation Plan: Billing Worker Implementation

**Branch**: `023-billing-worker-implementation` | **Date**: 2026-04-21 | **Spec**: [/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/spec.md](/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/spec.md`

## Summary

`billing-worker` の初期実装を `applications/backend/billing-worker/` に追加する。runtime は
004 / 015 / 016 の正本どおり Haskell worker + Pub/Sub trigger + Firestore-aligned state を
前提とし、submitted 済みの purchase artifact と normalized store notification を処理対象とする。
worker は `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、
`dead-lettered` の lifecycle を持ち、completed `BillingRecord` (purchase state 更新 + entitlement snapshot)
の保存と `Subscription.currentEntitlementSnapshot` handoff の両方が成立した時だけ success と扱う。
confirmed されていない entitlement snapshot は user-visible unlock 根拠にせず、既存 current は
non-success では維持する。実装は Haskell module 群と port / adapter 境界に分割し、Haskell unit
テスト、Haskell の Docker/Firebase feature suite、worker container / local stack validation、
023 artifact 同期までを含める。restore workflow、store product catalog 管理、provider 固有最適化、
public GraphQL 拡張は scope 外とする。

## Technical Context

**Language/Version**: Haskell via GHC `9.2.8`、`GHC2021`、Bash、Markdown 1.x  
**Primary Dependencies**: `/Users/lihs/workspace/vocastock/applications/backend/billing-worker/`、package-local Cabal manifest、`/Users/lihs/workspace/vocastock/docker/applications/billing-worker/`、`/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`、`/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh`、`/Users/lihs/workspace/vocastock/docs/internal/domain/common.md`、`/Users/lihs/workspace/vocastock/docs/internal/domain/service.md`、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/`、`/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/014-billing-entitlement-policy/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`、`/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/`  
**Storage**: Firestore-aligned billing workflow state store abstraction、completed `BillingRecord` store abstraction、`Subscription.currentEntitlementSnapshot` handoff store abstraction、Git-managed repository files、local Docker/Firebase emulator runtime state  
**Testing**: package-local `cabal test` unit suites under `tests/unit/*`、package-local `cabal test feature` suite under `tests/feature/*`、coverage-enabled Haskell test run、`bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`  
**Target Platform**: internal Haskell worker on Cloud Run-aligned container runtime、local Docker + Firebase emulator validation path  
**Project Type**: backend worker service implementation  
**Performance Goals**: success / retryable failure / terminal failure / notification-reconciled の 4 系統が再現可能であること、worker の stable-run contract を壊さないこと、confirmed でない entitlement snapshot の露出を 0 件にすること、worker-owned coverage 90% 以上を達成すること  
**Constraints**: 004 の `Workflow = Haskell` と `Pub/Sub + Cloud Run worker + Firestore state` baseline を守ること、worker は public endpoint や query response を own しないこと、success は completed `BillingRecord` 保存と `currentEntitlementSnapshot` handoff の両成立が必要であること、duplicate / replay は business key 単位で idempotent に扱うこと、provider / adapter 詳細は failure summary に漏らさないこと、feature テストは Docker / Firebase emulator を使うこと、テストは `tests/unit/*` / `tests/feature/*` / `tests/support/*` に配置すること、purchase state と authoritative subscription state を同じ runtime state で表現しないこと、notification reconciliation は補正経路であり timeout / failure 中に新規 paid entitlement を付与しないこと  
**Scale/Scope**: 1 worker app、1 submitted purchase artifact family + 1 normalized notification family、1 billing lifecycle state machine、1 confirmed-only visibility handoff rule、1 Haskell package skeleton、1 Haskell feature suite、runtime / docs touchpoint 一式

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain semantic change`. `specs/010-subscription-component-boundaries/data-model.md` と `specs/014-billing-entitlement-policy/data-model.md` を source of truth として参照し、worker 実装は既存 aggregate / port semantics をコードへ写像する。
- [x] Async generation flow defines lifecycle states, retry behavior, timeout handling, dead-letter handling, and user-visible status rules. confirmed でない entitlement snapshot は unlock 根拠にしない。
- [x] External purchase verification、store notification ingestion、subscription authority、entitlement recalculation、HTTP runtime dependencies remain behind ports/adapters. worker は provider SDK や Firestore / Pub/Sub detail を domain language に持ち込まない。
- [x] User stories remain independently implementable and testable. purchase verification、failure/retry/idempotency、notification reconciliation は別 artifact としてレビュー可能である。
- [x] subscription state、purchase state、entitlement bundle、quota profile、feature gate decision、usage limit を混同しない。worker は billing workflow (purchase + notification) だけを own する。
- [x] Identifier naming follows the constitution. `id` / `xxxId` を新しい正本語彙として導入せず、aggregate 自身は `identifier`、関連参照は `subscription`、`actor`、`entitlementSnapshot` などの概念名を使う。

Post-design re-check: PASS. Verified against
`/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/research.md`,
`/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/data-model.md`,
`/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/billing-work-item-contract.md`,
`/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/purchase-verification-workflow-contract.md`,
`/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/store-notification-workflow-contract.md`,
`/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/billing-visibility-handoff-contract.md`, and
`/Users/lihs/workspace/vocastock/specs/023-billing-worker-implementation/contracts/billing-worker-runtime-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/023-billing-worker-implementation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── billing-visibility-handoff-contract.md
│   ├── billing-work-item-contract.md
│   ├── billing-worker-runtime-boundary-contract.md
│   ├── purchase-verification-workflow-contract.md
│   └── store-notification-workflow-contract.md
├── spec.md
└── tasks.md
```

### Source Code (repository root)

```text
applications/
└── backend/
    ├── README.md
    └── billing-worker/
        ├── cabal.project
        ├── billing-worker.cabal
        ├── app/
        │   └── Main.hs
        ├── src/
        │   └── BillingWorker/
        │       ├── WorkItemContract.hs
        │       ├── WorkflowStateMachine.hs
        │       ├── PurchaseVerificationPort.hs
        │       ├── SubscriptionAuthorityPort.hs
        │       ├── EntitlementRecalcPort.hs
        │       ├── NotificationPort.hs
        │       ├── BillingPersistence.hs
        │       ├── CurrentSubscriptionHandoff.hs
        │       ├── FailureSummary.hs
        │       └── WorkerRuntime.hs
        └── tests/
            ├── feature/
            │   ├── Main.hs
            │   └── BillingWorker/
            │       └── FeatureSpec.hs
            ├── support/
            │   ├── FeatureSupport.hs
            │   └── TestSupport.hs
            └── unit/
                ├── Main.hs
                └── BillingWorker/
                    ├── WorkItemContractSpec.hs
                    ├── WorkflowStateMachineSpec.hs
                    ├── PurchaseVerificationPortSpec.hs
                    ├── SubscriptionAuthorityPortSpec.hs
                    ├── EntitlementRecalcPortSpec.hs
                    ├── NotificationPortSpec.hs
                    ├── BillingPersistenceSpec.hs
                    ├── CurrentSubscriptionHandoffSpec.hs
                    ├── FailureSummarySpec.hs
                    └── WorkerRuntimeSpec.hs

docker/
└── applications/
    ├── compose.yaml
    └── billing-worker/
        ├── Dockerfile
        └── entrypoint.sh

scripts/
├── bootstrap/
│   └── validate_local_stack.sh
├── ci/
│   └── run_application_container_smoke.sh
└── lib/
    └── vocastock_env.sh

specs/
├── 004-tech-stack-definition/
├── 010-subscription-component-boundaries/
├── 012-persistence-workflow-design/
├── 014-billing-entitlement-policy/
├── 015-command-query-topology/
├── 016-application-docker-env/
├── 021-explanation-worker-implementation/
└── 023-billing-worker-implementation/
```

**Structure Decision**: 実装の中心は `applications/backend/billing-worker/` に置き、
Haskell package-local Cabal package として worker runtime を新設する。`app/Main.hs` は boot と
stable-run 起動だけを担い、worker-owned logic は `src/BillingWorker/` の責務別 module
へ分割する。`WorkItemContract` は intake payload と duplicate key 判定を、`WorkflowStateMachine`
は lifecycle 遷移と retry / timeout / dead-letter rule を、`PurchaseVerificationPort`、
`SubscriptionAuthorityPort`、`EntitlementRecalcPort`、`NotificationPort` は confirmed-only 生成 /
reconciliation adapter 契約を、`BillingPersistence` と `CurrentSubscriptionHandoff` は success を
構成する二段階確定を担う。unit テストは `src/BillingWorker/` を mirror した Haskell spec を
`tests/unit/BillingWorker/` に置き、feature テストは `tests/feature/Main.hs` +
`tests/feature/BillingWorker/FeatureSpec.hs` + `tests/support/FeatureSupport.hs` の Haskell
suite として構成し、Docker container と Firebase emulator を起動して worker の success /
retryable / terminal / notification-reconciled path を end-to-end 検証する。`billing-worker` は
外向き HTTP surface を持たず、stable-run long-running consumer のみを canonical success signal とする。
runtime 正本は `docker/applications/billing-worker/` と `docker/applications/compose.yaml`、
validation 正本は `scripts/ci/run_application_container_smoke.sh` と
`scripts/bootstrap/validate_local_stack.sh` に同期する。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
