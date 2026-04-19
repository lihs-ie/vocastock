# Contract: Persistence Allocation

## Purpose

authoritative write-side と read-side projection の保存責務、ownership、lookup 軸を固定する。

## Authoritative Allocation Matrix

| Concept | Authoritative Store | Primary Owner / Key | Uniqueness Rule | Primary Indexes |
|---------|---------------------|---------------------|-----------------|-----------------|
| `Learner` | `LearnerStore` | `identifier` | `authenticationSubject` は一意 | `identifier`, `authenticationSubject` |
| `VocabularyExpression` | `VocabularyExpressionStore` | `identifier`, `learner` | `learner + normalizedText` は一意 | `learner + normalizedText`, `learner + registrationStatus`, `learner + explanationGeneration` |
| `LearningState` | `LearningStateStore` | `identifier(learner + vocabularyExpression)` | 同じ learner / vocabularyExpression の組み合わせは 1 件 | `identifier`, `identifier.learner + proficiency` |
| `Explanation` | `ExplanationStore` | `identifier`, `vocabularyExpression` | `identifier` は一意 | `identifier`, `vocabularyExpression + timeline.updatedAt`, `vocabularyExpression + imageGeneration` |
| `VisualImage` | `VisualImageStore` | `identifier`, `explanation` | `identifier` は一意 | `identifier`, `explanation + timeline.updatedAt`, `explanation + sense + timeline.updatedAt` |
| authoritative subscription state | `SubscriptionAuthorityStore` | `actor` | actor ごとに 1 件 | `actor`, `subscriptionState + timeline.updatedAt` |
| purchase state | `PurchaseStateStore` | `storePurchase` | `storePurchase` は一意 | `storePurchase`, `authAccount + purchaseState`, `product + purchaseState` |
| entitlement snapshot | `EntitlementSnapshotStore` | `actor` | actor ごとに 1 スナップショット | `actor`, `sourceSubscriptionState + timeline.updatedAt` |
| usage allowance | `UsageAllowanceStore` | `actor + feature + allowanceWindow` | 上記組み合わせは一意 | `actor + feature + allowanceWindow`, `feature + allowanceWindow` |
| idempotency record | `IdempotencyStore` | `actor + idempotencyKey` | actor 単位で key 一意 | `actor + idempotencyKey`, `command + timeline.updatedAt` |
| workflow attempt | `WorkflowRuntimeStore` | `identifier` | 同一 workflow / target の active attempt は 0..1 | `identifier`, `workflowKind + targetReference + timeline.updatedAt`, `workflowKind + runtimeState` |
| dead-letter review | `DeadLetterReviewStore` | `identifier` | `workflowAttempt` ごとに 1 review unit | `identifier`, `workflowAttempt`, `reviewStatus + timeline.updatedAt` |

## Ownership Rules

- `Learner` は `VocabularyExpression` と `LearningState` の owner である
- `VocabularyExpression` は `Explanation` の current handoff 起点である
- `Explanation` は `VisualImage` の current handoff 起点である
- subscription / entitlement / allowance は actor 単位で authoritative に管理する
- workflow attempt は aggregate や purchase state を補助する runtime state であり、集約本体へ埋め込まない

## Allocation Rules

- current pointer を持つのは `VocabularyExpressionRecord.currentExplanation` と `ExplanationRecord.currentImage` のみである
- read projection は authoritative store を置き換えない
- authoritative store は completed result と status-only 情報の両方を持てるが、projection は visibility rule に従って completed だけを公開する
