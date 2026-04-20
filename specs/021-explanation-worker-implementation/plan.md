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
実装は Haskell module 群と port / adapter 境界に分割し、Haskell unit テスト、Rust の
Docker/Firebase feature harness、worker container / local stack validation、021 artifact 同期までを
含める。image workflow、billing workflow、public GraphQL 拡張、provider 固有最適化は scope 外とする。

## Technical Context

**Language/Version**: Haskell toolchain via GHC/LTS resolver、Rust 2021 for feature test harness、Bash、Markdown 1.x  
**Primary Dependencies**: `/Users/lihs/workspace/vocastock/applications/backend/explanation-worker/`、package-local Cabal manifest、`/Users/lihs/workspace/vocastock/docker/applications/explanation-worker/`、`/Users/lihs/workspace/vocastock/docker/applications/compose.yaml`、`/Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`/Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh`、`/Users/lihs/workspace/vocastock/docs/internal/domain/explanation.md`、`/Users/lihs/workspace/vocastock/docs/internal/domain/vocabulary-expression.md`、`/Users/lihs/workspace/vocastock/docs/internal/domain/service.md`、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/`、`/Users/lihs/workspace/vocastock/specs/007-backend-command-design/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`、`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/`  
**Storage**: Firestore-aligned workflow state store abstraction、completed `Explanation` store abstraction、`VocabularyExpression.currentExplanation` handoff store abstraction、Git-managed repository files、local Docker/Firebase emulator runtime state  
**Testing**: package-local `cabal test` unit suites under `tests/unit/*`、coverage-enabled Haskell test run、Rust feature harness under `tests/feature/*` with Docker containers + Firebase emulator、`bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`、`bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`  
**Target Platform**: internal Haskell worker on Cloud Run-aligned container runtime、local Docker + Firebase emulator validation path  
**Project Type**: backend worker service implementation  
**Performance Goals**: success / retryable failure / terminal failure の 3 系統が再現可能であること、worker の stable-run contract を壊さないこと、未完了 explanation 本文の露出を 0 件にすること、worker-owned coverage 90% 以上を達成すること  
**Constraints**: 004 の `Workflow = Haskell` と `Pub/Sub + Cloud Run worker + Firestore state` baseline を守ること、worker は public endpoint や query response を own しないこと、success は completed `Explanation` 保存と `currentExplanation` handoff の両成立が必要であること、duplicate / replay は business key 単位で idempotent に扱うこと、provider / adapter 詳細は failure summary に漏らさないこと、feature テストは Rust のコードで Docker / Firebase emulator を使うこと、テストは `tests/unit/*` / `tests/feature/*` / `tests/support/*` に配置すること  
**Scale/Scope**: 1 worker app、1 accepted registration-origin trigger family、1 explanation lifecycle state machine、1 completed-only visibility handoff rule、1 Haskell package skeleton、1 Rust feature harness、runtime / docs touchpoint 一式

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain semantic change`. `docs/internal/domain/explanation.md`、
      `docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/service.md` を source of
      truth として参照し、worker 実装は既存 aggregate / port semantics をコードへ写像する。
- [x] Async generation flow defines lifecycle states, retry behavior, timeout handling, dead-letter
      handling, and user-visible status rules. incomplete generated results are never exposed.
- [x] External generation, persistence, and validation dependencies remain behind ports/adapters.
      worker は provider SDK や Firestore / Pub/Sub detail を domain language に持ち込まない。
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
        │       └── WorkerRuntime.hs
        └── tests/
            ├── Cargo.toml
            ├── feature.rs
            ├── feature/
            │   └── explanation_worker.rs
            ├── support/
            │   └── feature.rs
            └── unit/
                └── ExplanationWorker/
                    ├── WorkItemContractSpec.hs
                    ├── WorkflowStateMachineSpec.hs
                    ├── GenerationPortSpec.hs
                    ├── ExplanationPersistenceSpec.hs
                    ├── CurrentExplanationHandoffSpec.hs
                    ├── FailureSummarySpec.hs
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
`tests/unit/ExplanationWorker/` に置き、feature テストは AGENTS ルールに合わせて Rust の専用
harness を `tests/Cargo.toml` + `tests/feature.rs` + `tests/feature/explanation_worker.rs` で
構成し、Docker container と Firebase emulator を起動して worker の success / retryable /
terminal path を end-to-end 検証する。runtime 正本は
`docker/applications/explanation-worker/` と `docker/applications/compose.yaml`、
validation 正本は `scripts/ci/run_application_container_smoke.sh` と
`scripts/bootstrap/validate_local_stack.sh` に同期する。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
