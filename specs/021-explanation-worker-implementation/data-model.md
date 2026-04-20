# Data Model: Explanation Worker Implementation

## Overview

021 は `explanation-worker` の workflow 実装を最小スライスで追加する。domain aggregate 自体の定義を
変える feature ではなく、accepted 済み explanation generation 要求の processing unit、runtime
state、completed explanation handoff、failure summary を worker 側でどう保持するかを固定する。

## Entities

### ExplanationGenerationWorkItem

**Purpose**: accepted 済み explanation generation 要求を worker が処理する単位。

| Field | Type | Description |
|-------|------|-------------|
| `identifier` | `ExplanationGenerationWorkItemIdentifier` | work item の一意識別子 |
| `businessKey` | `ExplanationGenerationBusinessKey` | replay / duplicate 判定用の業務キー |
| `vocabularyExpression` | `VocabularyExpressionIdentifier` | 処理対象の登録語彙 |
| `learner` | `LearnerIdentifier` | ownership 整合確認に使う学習者参照 |
| `triggerReason` | enum | initial slice では `registration-accepted` |
| `normalizedVocabularyExpressionText` | `NormalizedVocabularyExpressionText` | generation input と duplicate 判定の正本 |
| `requestCorrelation` | string | upstream request と worker log を相関させる値 |
| `workflowState` | `ExplanationWorkflowState` | 現在の lifecycle 状態 |

**Validation Rules**:

- initial slice では `triggerReason = registration-accepted` だけを受け付ける
- `businessKey` は同一 workflow に対して一意でなければならない
- `learner` と `vocabularyExpression` の ownership が一致しない場合は success へ進めない

### ExplanationWorkflowState

**Purpose**: explanation generation workflow の runtime lifecycle と retry 制御を保持する。

| Field | Type | Description |
|-------|------|-------------|
| `runtimeStatus` | enum | `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` |
| `attemptCount` | integer | 開始済み attempt 数 |
| `retryBudgetRemaining` | integer | 追加 retry 可能回数 |
| `nextAttemptAt` | timestamp? | `retry-scheduled` 時の再開予定 |
| `timeoutAt` | timestamp? | 現在 attempt の timeout 境界 |
| `candidateExplanation` | `CompletedExplanationCandidate`? | 保存済みだが handoff 未完了の completed result |
| `failureSummary` | `ExplanationFailureSummary`? | status-only 表示用の失敗要約 |

**Invariants**:

- `succeeded` は completed explanation 保存と current handoff 完了の両方が終わった時だけ許可される
- `retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` では incomplete explanation payload を持ってはならない
- `candidateExplanation` が存在する場合、再生成ではなく handoff completion の再試行を優先できる

### GenerationAttemptRecord

**Purpose**: 各 generation attempt の実行結果を記録する。

| Field | Type | Description |
|-------|------|-------------|
| `attemptNumber` | integer | 1 始まりの attempt 番号 |
| `providerRequestIdentifier` | string? | generation adapter 側 request 参照 |
| `startedAt` | timestamp | attempt 開始時刻 |
| `finishedAt` | timestamp? | attempt 終了時刻 |
| `outcome` | enum | `succeeded`、`retryable-failure`、`timed-out`、`non-retryable-failure`、`handoff-retry` |
| `redactedFailureReason` | string? | status-only に使える要約済み理由 |

**Rules**:

- provider / adapter の内部 detail は `redactedFailureReason` にそのまま持ち込まない
- 同一 `attemptNumber` を二重に finalization してはならない

### CompletedExplanationCandidate

**Purpose**: completed `Explanation` 保存までは成功しているが、current handoff 完了待ちの候補。

| Field | Type | Description |
|-------|------|-------------|
| `explanation` | `ExplanationIdentifier` | 保存済み explanation 参照 |
| `vocabularyExpression` | `VocabularyExpressionIdentifier` | handoff 対象 |
| `storedAt` | timestamp | 保存完了時刻 |
| `visibility` | enum | `hidden-until-handoff` または `current-applied` |
| `sourceWorkItem` | `ExplanationGenerationWorkItemIdentifier` | 元の work item |

**Rules**:

- `visibility = hidden-until-handoff` の間は user-visible completed payload として扱わない
- 同一 work item で candidate を複数作成してはならない

### CurrentExplanationHandoff

**Purpose**: `VocabularyExpression.currentExplanation` の切替結果を保持する。

| Field | Type | Description |
|-------|------|-------------|
| `vocabularyExpression` | `VocabularyExpressionIdentifier` | 切替対象 |
| `previousCurrent` | `ExplanationIdentifier`? | 直前 current |
| `candidate` | `ExplanationIdentifier` | 新たに採用を試みる completed explanation |
| `handoffStatus` | enum | `pending-switch`、`applied`、`kept-existing` |
| `appliedAt` | timestamp? | 切替完了時刻 |

**Rules**:

- `applied` になった時だけ `VocabularyExpression.currentExplanation` を更新できる
- retryable / terminal failure 時は `kept-existing` を許可し、既存 current を維持する

### ExplanationFailureSummary

**Purpose**: `query-api` が status-only で表示する failure 要約を保持する。

| Field | Type | Description |
|-------|------|-------------|
| `classification` | enum | `retryable`、`timeout`、`terminal`、`dead-letter` |
| `publicStatus` | enum | `retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` |
| `retryable` | bool | 再試行余地の有無 |
| `message` | string | redacted 済みの user-facing 要約 |
| `lastAttemptNumber` | integer | 直近 attempt |

**Rules**:

- `message` に provider credential、raw payload、internal stack trace を含めてはならない
- `publicStatus = retry-scheduled` の間は completed explanation 本文を返してはならない

## Relationships

- `ExplanationGenerationWorkItem` は 1 つの `ExplanationWorkflowState` を持つ
- `ExplanationWorkflowState` は 0..n の `GenerationAttemptRecord` を持ちうる
- `ExplanationWorkflowState.candidateExplanation` は 0..1 の `CompletedExplanationCandidate` を参照する
- `CompletedExplanationCandidate` は 0..1 の `CurrentExplanationHandoff` を伴う
- `ExplanationFailureSummary` は `ExplanationWorkflowState` に付随し、`query-api` の status-only read へ渡される

## State Transitions

1. accepted 済み registration 起点 request から `ExplanationGenerationWorkItem` を作る
2. `queued -> running` で generation adapter を開始する
3. generation adapter outcome:
   - retryable failure -> `retry-scheduled`
   - timeout -> `timed-out`
   - non-retryable failure -> `failed-final`
   - completed payload -> `CompletedExplanationCandidate` 保存へ進む
4. explanation 保存後:
   - handoff success -> `succeeded`
   - handoff retryable failure -> `retry-scheduled` または handoff retry path
   - handoff unrecoverable failure -> `failed-final` または `dead-lettered`
5. `succeeded` の時だけ `VocabularyExpression.currentExplanation` が新 candidate に切り替わる
