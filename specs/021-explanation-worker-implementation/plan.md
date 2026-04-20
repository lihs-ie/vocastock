# Implementation Plan: Explanation Worker Implementation

**Branch**: `021-explanation-worker-implementation` | **Date**: 2026-04-20 | **Spec**: [/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/spec.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`explanation-worker` の初期実装を `applications/backend/explanation-worker/` に追加する。runtime
は 004 / 015 / 016 の正本どおり Haskell worker + Pub/Sub trigger + Firestore-aligned state を
前提とし、accepted 済みの registration 起点 explanation generation 要求のうち
`startExplanation` が抑止されていないものだけを処理対象とする。worker は
`queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、
`dead-lettered` の lifecycle を持ち、completed `Explanation` の保存と
`VocabularyExpression.currentExplanation` handoff の両方が成立した時だけ success と扱う。
未完了 explanation 本文は user-visible にせず、既存 current は non-success では維持する。
実装は Haskell module 群と port / adapter 境界に分割し、Haskell unit テスト、Haskell の
Docker/Firebase feature suite、worker container / local stack validation、021 artifact 同期までを
含める。HTTP runtime adapter が必要な箇所は Servant `0.20.3.0` / `servant-server` `0.20.3.0`
で non-public surface として構成し、image workflow、billing workflow、public GraphQL 拡張、
provider 固有最適化は scope 外とする。

## Technical Context

**Language/Version**: Haskell via GHC `9.2.8`、Servant `0.20.3.0` / `servant-server` `0.20.3.0`、Bash、Markdown 1.x  
**Primary Dependencies**: `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/`、package-local Cabal manifest、Servant `0.20.3.0`、`servant-server` `0.20.3.0`、`/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/`、`/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`、`/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh`、`/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`、`/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`、`/Users/lihs/workspace/vocastock/docs/internal/domain/service.md`、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/`、`/Users/lihs/workspace/vocastock/specs/007-backend-command-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`  
**Storage**: Firestore-aligned workflow state store abstraction、completed `Explanation` store abstraction、`VocabularyExpression.currentExplanation` handoff store abstraction、Git-managed repository files、local Docker/Firebase emulator runtime state  
**Testing**: package-local `cabal test` unit suites under `tests/unit/*`、package-local `cabal test feature` suite under `tests/feature/*`、coverage-enabled Haskell test run、`bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`  
**Target Platform**: internal Haskell worker on Cloud Run-aligned container runtime、local Docker + Firebase emulator validation path  
**Project Type**: backend worker service implementation  
**Performance Goals**: success / retryable failure / terminal failure の 3 系統が再現可能であること、worker の stable-run contract を壊さないこと、未完了 explanation 本文の露出を 0 件にすること、worker-owned coverage 90% 以上を達成すること  
**Constraints**: 004 の `Workflow = Haskell` と `Pub/Sub + Cloud Run worker + Firestore state` baseline を守ること、worker は public endpoint や query response を own しないこと、Servant は internal runtime adapter に限定すること、success は completed `Explanation` 保存と `currentExplanation` handoff の両成立が必要であること、duplicate / replay は business key 単位で idempotent に扱うこと、provider / adapter 詳細は failure summary に漏らさないこと、feature テストは Docker / Firebase emulator を使うこと、テストは `tests/unit/*` / `tests/feature/*` / `tests/support/*` に配置すること  
**Scale/Scope**: 1 worker app、1 accepted registration-origin trigger family、1 explanation lifecycle state machine、1 completed-only visibility handoff rule、1 Haskell package skeleton、1 Haskell feature suite、1 Servant-based internal runtime adapter surface、runtime / docs touchpoint 一式

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain semantic change`. `docs/internal/domain/explanation.md`、
      `docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/service.md` を source of
      truth として参照し、worker 実装は既存 aggregate / port semantics をコードへ写像する。
- [x] Async generation flow defines lifecycle states, retry behavior, timeout handling, dead-letter
      handling, and user-visible status rules. incomplete generated results are never exposed.
- [x] External generation, persistence, validation、HTTP runtime dependencies remain behind ports/adapters.
      worker は provider SDK や Firestore / Pub/Sub / Servant detail を domain language に持ち込まない。
- [x] User stories remain independently implementable and testable. success path、failure/retry/idempotency、
      worker runtime boundary は別 artifact としてレビュー可能である。
- [x] Frequency、sophistication、registration state、explanation generation state、image state を
      混同しない。worker は explanation workflow だけを own する。
- [x] Identifier naming follows the constitution. `id` / `xxxId` を新しい正本語彙として導入せず、
      aggregate 自身は `identifier`、関連参照は `vocabularyExpression`、`sense` などの概念名を使う。

Post-design re-check: PASS. Verified against
`/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/research.md`,
`/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/data-model.md`,
`/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-work-item-contract.md`,
`/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-workflow-state-contract.md`,
`/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-visibility-handoff-contract.md`,
`/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-generation-port-contract.md`, and
`/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-worker-runtime-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/021-explanation-worker-implementation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── explanation-generation-port-contract.md
│   ├── explanation-visibility-handoff-contract.md
│   ├── explanation-work-item-contract.md
│   ├── explanation-worker-runtime-boundary-contract.md
│   └── explanation-workflow-state-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
applications/
└── backend/
    ├── README.md
    └── explanation-worker/
        ├── cabal.project
        ├── explanation-worker.cabal
        ├── app/
        │   └── Main.hs
        ├── src/
        │   └── ExplanationWorker/
        │       ├── WorkItemContract.hs
        │       ├── WorkflowStateMachine.hs
        │       ├── GenerationPort.hs
        │       ├── ExplanationPersistence.hs
        │       ├── CurrentExplanationHandoff.hs
        │       ├── FailureSummary.hs
        │       ├── RuntimeHttp.hs
        │       └── WorkerRuntime.hs
        └── tests/
            ├── feature/
            │   ├── Main.hs
            │   └── ExplanationWorker/
            │       └── FeatureSpec.hs
            ├── support/
            │   ├── FeatureSupport.hs
            │   └── TestSupport.hs
            └── unit/
                ├── Main.hs
                └── ExplanationWorker/
                    ├── WorkItemContractSpec.hs
                    ├── WorkflowStateMachineSpec.hs
                    ├── GenerationPortSpec.hs
                    ├── ExplanationPersistenceSpec.hs
                    ├── CurrentExplanationHandoffSpec.hs
                    ├── FailureSummarySpec.hs
                    ├── RuntimeHttpSpec.hs
                    └── WorkerRuntimeSpec.hs

docker/
└── applications/
    ├── compose.yaml
    └── explanation-worker/
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
        └── vocabulary-expression.md

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
└── 021-explanation-worker-implementation/
```

**Structure Decision**: 実装の中心は `applications/backend/explanation-worker/` に置き、
Haskell package-local Cabal package として worker runtime を新設する。`app/Main.hs` は boot と
stable-run 起動だけを担い、worker-owned logic は `src/ExplanationWorker/` の責務別 module
へ分割する。`WorkItemContract` は intake payload と duplicate key 判定を、`WorkflowStateMachine`
は lifecycle 遷移と retry / timeout / dead-letter rule を、`GenerationPort` は completed-only
generation adapter 契約を、`ExplanationPersistence` と `CurrentExplanationHandoff` は success を
構成する二段階確定を担う。unit テストは `src/ExplanationWorker/` を mirror した Haskell spec を
`tests/unit/ExplanationWorker/` に置き、feature テストは `tests/feature/Main.hs` +
`tests/feature/ExplanationWorker/FeatureSpec.hs` + `tests/support/FeatureSupport.hs` の Haskell
suite として構成し、Docker container と Firebase emulator を起動して worker の success /
retryable / terminal path を end-to-end 検証する。HTTP runtime adapter が必要な場合は
`src/ExplanationWorker/RuntimeHttp.hs` に Servant `0.20.3.0` / `servant-server` `0.20.3.0`
ベースの non-public surface を集約し、worker-owned state machine から分離する。runtime 正本は
`docker/applications/explanation-worker/` と `docker/applications/compose.yaml`、
validation 正本は `scripts/ci/run_application_container_smoke.sh` と
`scripts/bootstrap/validate_local_stack.sh` に同期する。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
