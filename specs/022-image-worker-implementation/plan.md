# Implementation Plan: Image Worker Implementation

**Branch**: `022-image-worker-implementation` | **Date**: 2026-04-20 | **Spec**: [/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/spec.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`image-worker` の初期実装を `applications/backend/image-worker/` に追加する。runtime は 004 / 015 / 016
の正本どおり Haskell worker + Pub/Sub trigger + Firestore-aligned state + asset storage adapter を前提とし、
accepted 済み `requestImageGeneration` 起点の image generation 要求のうち、completed `Explanation` を対象とする
ものだけを処理対象とする。worker は `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、
`failed-final`、`dead-lettered` の lifecycle を持ち、completed `VisualImage` の asset reference 確定、
`VisualImage` 保存、`Explanation.currentImage` handoff の両方が user-visible success 条件になる。新しい accepted
request は古い request より current 採用優先権を持ち、handoff 失敗後の保存済み画像は non-current completed として
保持したまま handoff だけを再試行する。実装は Haskell module 群と port / adapter 境界に分割し、Haskell unit テスト、
Haskell の Docker/Firebase feature suite、worker container / local stack validation、022 artifact 同期までを
含める。multiple current image / meaning gallery、billing workflow、public GraphQL 拡張、provider 固有最適化は
scope 外とする。

## Technical Context

**Language/Version**: Haskell via GHC `9.2.8`、`GHC2021`、Bash、Markdown 1.x  
**Primary Dependencies**: `/Users/lihs/workspace/vocastock/applications/backend/image-worker/`、package-local Cabal manifest、`/Users/lihs/workspace/vocastock/docker/applications/image-worker/`、`/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`、`/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh`、`/Users/lihs/workspace/vocastock/docs/internal/domain/visual.md`、`/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`、`/Users/lihs/workspace/vocastock/docs/internal/domain/service.md`、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/`、`/Users/lihs/workspace/vocastock/specs/007-backend-command-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`  
**Storage**: Firestore-aligned image workflow state store abstraction、completed `VisualImage` store abstraction、`Explanation.currentImage` handoff store abstraction、stable asset storage adapter abstraction、Git-managed repository files、local Docker/Firebase emulator runtime state  
**Testing**: package-local `cabal test` unit suites under `tests/unit/*`、package-local `cabal test feature` suite under `tests/feature/*`、coverage-enabled Haskell test run、`bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`  
**Target Platform**: internal Haskell worker on Cloud Run-aligned container runtime、local Docker + Firebase emulator validation path  
**Project Type**: backend worker service implementation  
**Performance Goals**: success / retryable failure / terminal failure の 3 系統が再現可能であること、worker の stable-run contract を壊さないこと、未完了 image payload の露出を 0 件にすること、worker-owned coverage 90% 以上を達成すること  
**Constraints**: 004 の `Workflow = Haskell` と `Pub/Sub + Cloud Run worker + Firestore state + asset adapter` baseline を守ること、worker は public endpoint や query response を own しないこと、success は asset reference 確定済みの completed `VisualImage` 保存と `currentImage` handoff の両条件が必要であること、handoff 失敗後の保存済み画像は non-current completed として保持すること、より新しい accepted request だけが current 採用権を持つこと、deterministic な target / ownership / precondition invalid は `failed-final` に写像すること、feature テストは Haskell から Docker / Firebase emulator を使うこと、テストは `tests/unit/*` / `tests/feature/*` / `tests/support/*` に配置すること  
**Scale/Scope**: 1 worker app、1 accepted `requestImageGeneration` trigger family、1 image lifecycle state machine、1 single-current handoff rule、1 Haskell package skeleton、1 Haskell feature suite、1 asset storage adapter contract、runtime / docs touchpoint 一式

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain semantic change`. `docs/internal/domain/visual.md`、
      `docs/internal/domain/explanation.md`、`docs/internal/domain/service.md` を source of truth
      として参照し、worker 実装は既存 aggregate / port semantics をコードへ写像する。
- [x] Domain models、workflow state、application coordination は `image-worker` の owning
      application 内に閉じ、shared package は logging、monitoring、auth/session handoff、
      request correlation、runtime probe のような sidecar concern に限定する。
- [x] Inner layer module boundary は `applications/backend/image-worker/src/ImageWorker/` 配下で
      `WorkItemContract`、`TargetResolution`、`WorkflowStateMachine`、`ImageGenerationPort`、
      `AssetStoragePort`、`ImagePersistence`、`CurrentImageHandoff`、`FailureSummary`、
      `WorkerRuntime` に分割し、outer runtime から内側へ一方向依存にする。
- [x] Async generation flow defines lifecycle states、idempotent retry behavior、newest-accepted
      adoption priority、user-visible status rules。incomplete generated results are never exposed.
- [x] External generation、asset storage、persistence、validation dependencies remain behind
      ports/adapters. worker は provider SDK、asset SDK、Firestore / Pub/Sub detail を domain
      language に持ち込まない。
- [x] User stories remain independently implementable and testable. success path、failure/retry /
      stale-success handling、worker runtime boundary は別 artifact としてレビュー可能である。
- [x] Frequency、sophistication、registration state、explanation generation state、image state を
      混同しない。worker は image workflow だけを own する。
- [x] Identifier naming follows the constitution. `id` / `xxxId` を新しい正本語彙として導入せず、
      aggregate 自身は `identifier`、関連参照は `explanation`、`sense` などの概念名を使う。

Post-design re-check: PASS. Verified against
`/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/research.md`,
`/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/data-model.md`,
`/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-generation-port-contract.md`,
`/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-asset-storage-contract.md`,
`/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-visibility-handoff-contract.md`,
`/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-work-item-contract.md`,
`/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-workflow-state-contract.md`, and
`/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-worker-runtime-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/022-image-worker-implementation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── image-asset-storage-contract.md
│   ├── image-generation-port-contract.md
│   ├── image-visibility-handoff-contract.md
│   ├── image-work-item-contract.md
│   ├── image-worker-runtime-boundary-contract.md
│   └── image-workflow-state-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
applications/
└── backend/
    ├── README.md
    └── image-worker/
        ├── cabal.project
        ├── image-worker.cabal
        ├── app/
        │   └── Main.hs
        ├── src/
        │   └── ImageWorker/
        │       ├── WorkItemContract.hs
        │       ├── TargetResolution.hs
        │       ├── WorkflowStateMachine.hs
        │       ├── ImageGenerationPort.hs
        │       ├── AssetStoragePort.hs
        │       ├── ImagePersistence.hs
        │       ├── CurrentImageHandoff.hs
        │       ├── FailureSummary.hs
        │       └── WorkerRuntime.hs
        └── tests/
            ├── feature/
            │   ├── Main.hs
            │   └── ImageWorker/
            │       └── FeatureSpec.hs
            ├── support/
            │   ├── FeatureSupport.hs
            │   └── TestSupport.hs
            └── unit/
                ├── Main.hs
                └── ImageWorker/
                    ├── WorkItemContractSpec.hs
                    ├── TargetResolutionSpec.hs
                    ├── WorkflowStateMachineSpec.hs
                    ├── ImageGenerationPortSpec.hs
                    ├── AssetStoragePortSpec.hs
                    ├── ImagePersistenceSpec.hs
                    ├── CurrentImageHandoffSpec.hs
                    ├── FailureSummarySpec.hs
                    └── WorkerRuntimeSpec.hs

docker/
└── applications/
    ├── compose.yaml
    └── image-worker/
        ├── Dockerfile
        └── entrypoint.sh

docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/
        ├── explanation.md
        ├── service.md
        └── visual.md

scripts/
├── bootstrap/
│   └── validate_local_stack.sh
├── ci/
│   └── run_application_container_smoke.sh
└── firebase/
    ├── start_emulators.sh
    └── stop_emulators.sh

specs/
├── 004-tech-stack-definition/
├── 007-backend-command-design/
├── 011-api-command-io-design/
├── 012-persistence-workflow-design/
├── 015-command-query-topology/
├── 016-application-docker-env/
└── 022-image-worker-implementation/
```

**Structure Decision**: 実装の中心は `applications/backend/image-worker/` に置き、app-local Cabal
package として worker runtime を新設する。`app/Main.hs` は boot と stable-run 起動だけを担う。
inner layer は `src/ImageWorker/` 配下で明示的に分割し、`WorkerRuntime` を application coordination
layer、`WorkItemContract` / `TargetResolution` / `WorkflowStateMachine` / `FailureSummary` を
workflow-domain layer、`ImageGenerationPort` / `AssetStoragePort` / `ImagePersistence` /
`CurrentImageHandoff` を port contract layer とする。allowed dependency は
`Main -> WorkerRuntime -> {Workflow-domain, Port contracts}` であり、workflow-domain は port
contracts に依存せず、port 実装 detail は outer runtime adapter 側へ閉じる。`TargetResolution` は
completed `Explanation`、optional `Sense`、learner ownership の妥当性を解決し、
`WorkflowStateMachine` は newest-accepted adoption priority、retry / timeout / failed-final /
dead-lettered rule、saved-but-non-current candidate rule を担う。`ImageGenerationPort` は provider
generation 契約、`AssetStoragePort` は stable asset reference handoff 契約、`ImagePersistence` は
`VisualImage` 保存と stale-success 保持を、`CurrentImageHandoff` は `Explanation.currentImage` の単一
current 切替を担う。unit テストは `src/ImageWorker/` を mirror した Haskell spec を
`tests/unit/ImageWorker/` に置き、feature テストは `tests/feature/Main.hs` +
`tests/feature/ImageWorker/FeatureSpec.hs` + `tests/support/FeatureSupport.hs` の Haskell suite として
構成し、Docker container と Firebase emulator を起動して success / retryable / terminal path を
end-to-end 検証する。runtime 正本は `docker/applications/image-worker/` と
`docker/applications/compose.yaml`、validation 正本は `scripts/ci/run_application_container_smoke.sh` と
`scripts/bootstrap/validate_local_stack.sh` に同期する。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
