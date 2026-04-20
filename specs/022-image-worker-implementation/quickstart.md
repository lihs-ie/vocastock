# Quickstart: Image Worker Implementation

## Goal

`image-worker` が accepted 済み image generation 要求を worker runtime として処理し、
asset reference 確定済みの completed `VisualImage` 保存と `currentImage` handoff の条件を満たした時だけ
current image を切り替え、retryable / terminal failure では status-only だけを残すことを確認する。

## Review Flow

1. [research.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/research.md) を読み、
   Haskell runtime baseline、accepted `requestImageGeneration` initial slice、generation port と
   asset storage port の分離、saved-but-non-current rule、newest-accepted adoption priority、
   deterministic invalid target mapping、テスト方針の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/data-model.md) で、
   `ImageGenerationWorkItem`、`ImageWorkflowState`、`CompletedVisualImageCandidate`、
   `CurrentImageHandoff`、`ImageFailureSummary` を確認する
3. [image-work-item-contract.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-work-item-contract.md)
   と [image-workflow-state-contract.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-workflow-state-contract.md)
   で intake、state transition、retry / timeout / dead-letter / stale-success rule を確認する
4. [image-generation-port-contract.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-generation-port-contract.md)
   と [image-asset-storage-contract.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-asset-storage-contract.md)
   で provider generation と asset storage handoff の契約を確認する
5. [image-visibility-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-visibility-handoff-contract.md)
   と [image-worker-runtime-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/022-image-worker-implementation/contracts/image-worker-runtime-boundary-contract.md)
   で completed-only visibility、single-current handoff、runtime scope 外責務を確認する

## Implementation Verification

1. `cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test`
2. `cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test --enable-coverage`
3. `cd /Users/lihs/workspace/vocastock/applications/backend/image-worker && cabal test feature`
4. `bash /Users/lihs/workspace/vocastock/scripts/ci/run_application_container_smoke.sh`
5. `bash /Users/lihs/workspace/vocastock/scripts/bootstrap/validate_local_stack.sh --reuse-running --with-application-containers`

`run_application_container_smoke.sh` 完了後は
`/Users/lihs/workspace/vocastock/.artifacts/ci/logs/application-container-smoke.summary`
に `image_worker_validation.success`、
`image_worker_validation.retryable-failure`、
`image_worker_validation.terminal-failure`
が個別 record として残ることを確認する。

## What Must Be True

1. `image-worker` は accepted 済み `requestImageGeneration` work item だけを処理すること
2. worker runtime は `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を区別すること
3. success は stable asset reference を持つ completed `VisualImage` 保存と `Explanation.currentImage` handoff 完了の両方が必要であること
4. handoff 完了前の candidate image は current image として user-visible に扱わないこと
5. 保存済み `VisualImage` があっても handoff failure 時は non-current completed として保持し、handoff だけを再試行すること
6. より新しい accepted request が current 採用権を持ち、古い request の遅延成功は current を上書きしないこと
7. retryable failure、timeout、terminal failure は current image を切り替えず、status-only 要約だけを残すこと
8. deterministic invalid target / ownership mismatch / 未完了 explanation / invalid sense は `failed-final` として扱うこと
9. worker は public endpoint や query response を own せず、canonical success signal は stable-run であること
10. feature テストは Haskell のコードから Docker container と Firebase emulator を使って動くこと
11. runtime validation では `success`、`retryable-failure`、`terminal-failure` を別シナリオとして再現し、summary に個別記録すること

## Deferred Scope

- public `requestImageGeneration` intake 実装そのもの
- multiple current image / meaning gallery
- billing / entitlement / quota policy
- provider 固有最適化、prompt tuning、モデル選定 hardening
- public GraphQL operation の追加
