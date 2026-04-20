# Data Model: Image Worker Implementation

## Overview

022 は `image-worker` の workflow 実装を最小スライスで追加する。domain aggregate 自体の定義を変える
feature ではなく、accepted 済み image generation 要求の processing unit、runtime state、asset
storage handoff、completed `VisualImage` candidate、`currentImage` adoption rule、failure summary を
worker 側でどう保持するかを固定する。

## Entities

### ImageGenerationWorkItem

**Purpose**: accepted 済み image generation 要求を worker が処理する単位。

| Field | Type | Description |
|-------|------|-------------|
| `identifier` | `ImageGenerationWorkItemIdentifier` | work item の一意識別子 |
| `businessKey` | `ImageGenerationBusinessKey` | replay / duplicate 判定用の業務キー |
| `explanation` | `ExplanationIdentifier` | 処理対象の completed explanation |
| `learner` | `LearnerIdentifier` | ownership 整合確認に使う学習者参照 |
| `sense` | `SenseIdentifier`? | 補助参照の optional target |
| `triggerReason` | enum | initial slice では `request-image-generation-accepted` |
| `acceptedAt` | timestamp | current adoption priority 判定に使う受理時刻 |
| `requestCorrelation` | string | upstream request と worker log を相関させる値 |
| `workflowState` | `ImageWorkflowState` | 現在の lifecycle 状態 |

**Validation Rules**:

- initial slice では `triggerReason = request-image-generation-accepted` だけを受け付ける
- `businessKey` は同一 workflow に対して一意でなければならない
- `explanation` は completed 状態でなければならない
- `sense` を持つ場合、その `Sense` は同じ `Explanation` 配下に属していなければならない

### ImageWorkflowState

**Purpose**: image generation workflow の runtime lifecycle と retry 制御を保持する。

| Field | Type | Description |
|-------|------|-------------|
| `runtimeStatus` | enum | `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` |
| `attemptCount` | integer | 開始済み attempt 数 |
| `retryBudgetRemaining` | integer | 追加 retry 可能回数 |
| `nextAttemptAt` | timestamp? | `retry-scheduled` 時の再開予定 |
| `timeoutAt` | timestamp? | 現在 attempt の timeout 境界 |
| `candidateImage` | `CompletedVisualImageCandidate`? | 保存済みだが current handoff 未完了、または stale success として保持する completed result |
| `failureSummary` | `ImageFailureSummary`? | status-only 表示用の失敗要約 |

**Invariants**:

- `succeeded` は asset reference 確定済み `VisualImage` 保存と `Explanation.currentImage` handoff 完了の両方が終わった時だけ許可される
- `retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` では incomplete image payload を持ってはならない
- `candidateImage` が存在する場合、再生成ではなく handoff completion または stale-success retention の判定を優先できる

### GenerationAttemptRecord

**Purpose**: 各 image generation attempt の実行結果を記録する。

| Field | Type | Description |
|-------|------|-------------|
| `attemptNumber` | integer | 1 始まりの attempt 番号 |
| `providerRequestIdentifier` | string? | generation adapter 側 request 参照 |
| `startedAt` | timestamp | attempt 開始時刻 |
| `finishedAt` | timestamp? | attempt 終了時刻 |
| `outcome` | enum | `succeeded`、`retryable-failure`、`timed-out`、`non-retryable-failure`、`asset-storage-retry`、`handoff-retry`、`stale-success` |
| `redactedFailureReason` | string? | status-only に使える要約済み理由 |

**Rules**:

- provider / adapter の内部 detail は `redactedFailureReason` にそのまま持ち込まない
- 同一 `attemptNumber` を二重に finalization してはならない
- `stale-success` は completed image を保持しても `currentImage` を更新しなかった成功を表す

### CompletedVisualImageCandidate

**Purpose**: asset reference 確定と `VisualImage` 保存までは成功しているが、current handoff 完了待ち
または stale-success として保持される completed image 候補。

| Field | Type | Description |
|-------|------|-------------|
| `visualImage` | `VisualImageIdentifier` | 保存済み image 参照 |
| `explanation` | `ExplanationIdentifier` | handoff 対象 |
| `sense` | `SenseIdentifier`? | 描写対象の optional sense |
| `assetReference` | string | stable に再取得可能な asset 参照 |
| `storedAt` | timestamp | 保存完了時刻 |
| `visibility` | enum | `hidden-until-handoff`、`current-applied`、`retained-non-current` |
| `sourceWorkItem` | `ImageGenerationWorkItemIdentifier` | 元の work item |

**Rules**:

- `visibility = hidden-until-handoff` の間は current image として user-visible にしてはならない
- `visibility = retained-non-current` は newer accepted request が current 採用権を持つ場合だけ許可される
- 同一 work item で candidate を複数作成してはならない

### CurrentImageHandoff

**Purpose**: `Explanation.currentImage` の切替結果を保持する。

| Field | Type | Description |
|-------|------|-------------|
| `explanation` | `ExplanationIdentifier` | 切替対象 |
| `previousCurrent` | `VisualImageIdentifier`? | 直前 current |
| `candidate` | `VisualImageIdentifier` | 新たに採用を試みる completed image |
| `handoffStatus` | enum | `pending-switch`、`applied`、`kept-existing`、`superseded-by-newer-request` |
| `appliedAt` | timestamp? | 切替完了時刻 |

**Rules**:

- `applied` になった時だけ `Explanation.currentImage` を更新できる
- retryable / terminal failure 時は `kept-existing` を許可し、既存 current を維持する
- newer accepted request が存在する場合は `superseded-by-newer-request` を使い、古い request の成功で current を上書きしてはならない

### ImageFailureSummary

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
- `publicStatus = retry-scheduled` の間は completed image payload を返してはならない

## Relationships

- `ImageGenerationWorkItem` は 1 つの `ImageWorkflowState` を持つ
- `ImageWorkflowState` は 0..n の `GenerationAttemptRecord` を持ちうる
- `ImageWorkflowState.candidateImage` は 0..1 の `CompletedVisualImageCandidate` を参照する
- `CompletedVisualImageCandidate` は 0..1 の `CurrentImageHandoff` を伴う
- `ImageFailureSummary` は `ImageWorkflowState` に付随し、`query-api` の status-only read へ渡される

## State Transitions

1. accepted 済み `requestImageGeneration` request から `ImageGenerationWorkItem` を作る
2. `queued -> running` で target validation、generation adapter、asset storage handoff を開始する
3. generation / asset storage outcome:
   - retryable failure -> `retry-scheduled`
   - timeout -> `timed-out`
   - deterministic precondition invalid or non-retryable failure -> `failed-final`
   - unknown/operator review needed -> `dead-lettered`
   - completed asset reference -> `CompletedVisualImageCandidate` 保存へ進む
4. `VisualImage` 保存後:
   - handoff success -> `succeeded`
   - handoff retryable failure -> `retry-scheduled`
   - newer accepted request が優先 -> `succeeded` 相当の completed result を `retained-non-current` として保持し、current は据え置く
5. `succeeded` の時だけ `Explanation.currentImage` が新 candidate に切り替わる
