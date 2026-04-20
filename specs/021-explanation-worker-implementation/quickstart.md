# Quickstart: Explanation Worker Implementation

## Goal

`explanation-worker` が accepted 済み explanation generation 要求を worker runtime として処理し、
completed `Explanation` の保存と `currentExplanation` handoff が両方成立した時だけ success にし、
retryable / terminal failure では status-only だけを残すことを確認する。

## Review Flow

1. [research.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/research.md) を読み、
   Haskell runtime baseline、Servant `0.20.3.0` 採用方針、registration-origin initial slice、
   二段階 success、malformed payload の terminal 扱い、duplicate handling、テスト方針の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/data-model.md) で、
   `ExplanationGenerationWorkItem`、`ExplanationWorkflowState`、`CompletedExplanationCandidate`、
   `CurrentExplanationHandoff`、`ExplanationFailureSummary` を確認する
3. [explanation-work-item-contract.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-work-item-contract.md)
   と [explanation-workflow-state-contract.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-workflow-state-contract.md)
   で intake、state transition、retry / timeout / dead-letter rule を確認する
4. [explanation-visibility-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-visibility-handoff-contract.md)
   と [explanation-generation-port-contract.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-generation-port-contract.md)
   で completed-only visibility、candidate handoff、generation result contract を確認する
5. [explanation-worker-runtime-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/021-explanation-worker-implementation/contracts/explanation-worker-runtime-boundary-contract.md)
   で stable-run、Docker/Firebase feature test、scope 外責務を確認する

## Implementation Verification

1. `cd /Users/lihs/workspace/vocastock/applications/backend/explanation-worker && cabal test`
2. `cd /Users/lihs/workspace/vocastock/applications/backend/explanation-worker && cabal test --enable-coverage`
3. `cd /Users/lihs/workspace/vocastock/applications/backend/explanation-worker && cabal test feature`
4. `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`
5. `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`

`run_application_container_smoke.sh` 完了後は
`/Users/lihs/workspace/vocastock/.artifacts/ci/logs/application-container-smoke.summary`
に `explanation_worker_validation.success`、
`explanation_worker_validation.retryable-failure`、
`explanation_worker_validation.terminal-failure`
が個別 record として残ることを確認する。

## What Must Be True

1. `explanation-worker` は accepted 済み registration 起点 work item のうち `startExplanation` 非抑止だけを処理すること
2. worker runtime は `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を区別すること
3. success は completed `Explanation` 保存と `VocabularyExpression.currentExplanation` handoff 完了の両方が必要であること
4. handoff 完了前の candidate explanation は user-visible completed payload として扱わないこと
5. retryable failure、timeout、terminal failure は completed explanation を作らず、status-only 要約だけを残すこと
6. malformed / incomplete generation payload は `failed-final` として扱い、partial explanation を保存しないこと
7. duplicate / replay work は business key 単位で idempotent に扱い、completed write や current switch を重複させないこと
8. worker は public endpoint や query response を own せず、canonical success signal は stable-run であること
9. HTTP runtime adapter が必要な場合は Servant `0.20.3.0` / `servant-server` `0.20.3.0` を non-public surface に限定して使うこと
10. feature テストは Haskell のコードから Docker container と Firebase emulator を使って動くこと
11. runtime validation では `success`、`retryable-failure`、`terminal-failure` を別シナリオとして再現し、`VOCAS_EXPLANATION_RESULT` を summary に記録すること

## Deferred Scope

- standalone `requestExplanationGeneration` intake
- image workflow と `image-worker` の実装
- billing / entitlement / quota policy
- provider 固有最適化、prompt tuning、モデル選定 hardening
- public GraphQL operation の追加
