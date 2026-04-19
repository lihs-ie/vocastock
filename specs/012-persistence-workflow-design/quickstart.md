# Quickstart: 永続化 / Read Model と非同期 Workflow 設計

## 1. 前提文書を確認する

1. [requirements.md](/Users/lihs/workspace/vocastock/docs/external/requirements.md) と [adr.md](/Users/lihs/workspace/vocastock/docs/external/adr.md) を読み、全体の domain / component / subscription 境界を確認する
2. [plan.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/plan.md) を読み、command acceptance、duplicate reuse、dispatch failure の正本を確認する
3. [plan.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/plan.md) を読み、actor handoff と session completion の正本を確認する
4. [plan.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md) を読み、`Command Intake` / `Query Read` / `Async Generation` の責務分離を確認する
5. [plan.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/plan.md) と [plan.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/plan.md) を読み、subscription authority と command I/O の正本を確認する

## 2. 012 の設計成果物を読む

1. [research.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/research.md) で persistence allocation と runtime state machine の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/data-model.md) で authoritative store、projection、workflow attempt record、dead-letter review unit を確認する
3. [persistence-allocation-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/persistence-allocation-contract.md) と [read-model-assembly-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/read-model-assembly-contract.md) で保存先と projection 組み立て方を確認する
4. [generation-workflow-state-machine-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/generation-workflow-state-machine-contract.md) と [subscription-workflow-state-machine-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/subscription-workflow-state-machine-contract.md) で state 遷移、retry、timeout、fallback、dead-letter 相当を確認する
5. [persistence-runtime-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/contracts/persistence-runtime-boundary-contract.md) で deferred scope と prerequisite source-of-truth を確認する

## 3. 実装前レビューで確認すること

1. `Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、`VisualImage`、subscription / purchase / entitlement / allowance の authoritative store が一意に定義されていること
2. `learner + normalizedText`、`LearningStateIdentifier`、actor-scoped idempotency、`storePurchase` などの一意制約が整理されていること
3. `VocabularyCatalogProjection`、`ExplanationDetailProjection`、`ImageDetailProjection`、`SubscriptionStatusProjection`、`UsageAllowanceProjection` が authoritative state から構成されること
4. explanation / image workflow で current pointer 切替前に completed 保存が必要であり、partial success を completed として見せないこと
5. purchase verification / restore / notification reconciliation で purchase state と subscription state を混同していないこと
6. timeout / retry / fallback 中も未確認の paid unlock や未完了生成物を completed projection として返さないこと
7. retry exhaustion 後の dead-letter 相当が operator review 用終端として扱われ、user-facing completed result ではないこと

## 4. この feature で扱わないこと

1. PostgreSQL、Firestore、Redis、Pub/Sub、Cloud Tasks などの具体製品選定
2. GraphQL / HTTP query schema の wire format
3. provider payload schema、vendor SDK detail、adapter 実装
4. operator tooling UI や dashboard 実装
5. deployment topology、autoscaling、運用監視の具体設定
