# Data Model: Billing Worker Implementation

## Overview

023 は `billing-worker` の workflow 実装を最小スライスで追加する。domain aggregate 自体の定義を
変える feature ではなく、submitted 済み purchase artifact と normalized store notification の
processing unit、runtime state、completed billing record handoff、failure summary を worker 側で
どう保持するかを固定する。正本 domain は `specs/010-subscription-component-boundaries/data-model.md`
と `specs/014-billing-entitlement-policy/data-model.md` を参照する。

## Entities

### BillingWorkItem

**Purpose**: submitted 済み purchase artifact または normalized store notification を worker が処理する単位。

| Field | Type | Description |
|-------|------|-------------|
| `identifier` | `BillingWorkItemIdentifier` | work item の一意識別子 |
| `businessKey` | `BillingBusinessKey` | replay / duplicate 判定用の業務キー |
| `subscription` | `SubscriptionIdentifier` | 処理対象 `Subscription` |
| `actor` | `ActorIdentifier` | ownership 整合確認に使う actor 参照 |
| `trigger` | enum | initial slice では `purchase-artifact-submitted` または `notification-received` |
| `purchaseArtifact` | `PurchaseArtifactReference`? | `purchase-artifact-submitted` 時に存在する canonical 参照 |
| `notificationPayload` | `NormalizedNotificationPayload`? | `notification-received` 時に存在する normalized 内容 |
| `requestCorrelation` | string | upstream request と worker log を相関させる値 |
| `workflowState` | `BillingWorkflowState` | 現在の lifecycle 状態 |

**Validation Rules**:

- initial slice では `trigger = purchase-artifact-submitted` または `trigger = notification-received` だけを受け付ける
- `businessKey` は同一 workflow に対して一意でなければならない
- `actor` と `subscription` の ownership が一致しない場合は success へ進めない
- `purchase-artifact-submitted` では `purchaseArtifact` が必須、`notification-received` では `notificationPayload` が必須

### BillingWorkflowState

**Purpose**: billing workflow の runtime lifecycle と retry 制御を保持する。

| Field | Type | Description |
|-------|------|-------------|
| `runtimeStatus` | enum | `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` |
| `attemptCount` | integer | 開始済み attempt 数 |
| `retryBudgetRemaining` | integer | 追加 retry 可能回数 |
| `nextAttemptAt` | timestamp? | `retry-scheduled` 時の再開予定 |
| `timeoutAt` | timestamp? | 現在 attempt の timeout 境界 |
| `candidateSnapshot` | `SubscriptionAuthoritySnapshotCandidate`? | 保存済みだが handoff 未完了の completed snapshot |
| `failureSummary` | `BillingFailureSummary`? | status-only 表示用の失敗要約 |

**Invariants**:

- `succeeded` は completed `BillingRecord` 保存と current handoff 完了の両方が終わった時だけ許可される
- `retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` では confirmed されていない entitlement snapshot を user-visible unlock 根拠として扱ってはならない
- `candidateSnapshot` が存在する場合、再検証ではなく handoff completion の再試行を優先できる

### VerificationAttemptRecord

**Purpose**: 各 verification attempt (purchase verification / notification ingest 共通) の実行結果を記録する。

| Field | Type | Description |
|-------|------|-------------|
| `attemptNumber` | integer | 1 始まりの attempt 番号 |
| `providerRequestIdentifier` | string? | verification adapter / notification adapter 側 request 参照 |
| `startedAt` | timestamp | attempt 開始時刻 |
| `finishedAt` | timestamp? | attempt 終了時刻 |
| `outcome` | enum | `verified`、`reconciled`、`retryable-failure`、`timed-out`、`non-retryable-failure`、`handoff-retry` |
| `redactedFailureReason` | string? | status-only に使える要約済み理由 |

**Rules**:

- provider / adapter の内部 detail (raw receipt、credential、provider stack trace) は `redactedFailureReason` にそのまま持ち込まない
- 同一 `attemptNumber` を二重に finalization してはならない

### SubscriptionAuthoritySnapshotCandidate

**Purpose**: completed `BillingRecord` 保存までは成功しているが、current handoff 完了待ちの candidate snapshot。

| Field | Type | Description |
|-------|------|-------------|
| `subscription` | `SubscriptionIdentifier` | 対象 `Subscription` |
| `purchaseStateName` | enum | `verified` (purchase verification 経由) または既存状態 (notification reconciliation 経由) |
| `subscriptionStateName` | enum | `active`、`grace`、`expired`、`pending-sync`、`revoked` |
| `entitlementBundleName` | enum | `free-basic`、`premium-generation` |
| `quotaProfileName` | enum | `free-monthly`、`standard-monthly`、`pro-monthly` |
| `effectivePeriod` | `SubscriptionEffectivePeriod` | term start / end / grace window |
| `calculatedAt` | timestamp | 算出時刻 |
| `source` | enum | `purchase-verification` または `notification-reconciliation` |
| `visibility` | enum | `hidden-until-handoff` または `current-applied` |
| `sourceWorkItem` | `BillingWorkItemIdentifier` | 元の work item |

**Rules**:

- `visibility = hidden-until-handoff` の間は confirmed entitlement snapshot として扱わない
- 同一 work item で candidate を複数作成してはならない
- notification reconciliation 経路では `purchaseStateName` を `verified` へ昇格させず、既存状態を維持する

### CurrentSubscriptionHandoff

**Purpose**: `Subscription.currentEntitlementSnapshot` の切替結果を保持する。

| Field | Type | Description |
|-------|------|-------------|
| `subscription` | `SubscriptionIdentifier` | 切替対象 |
| `previousCurrent` | `EntitlementSnapshotIdentifier`? | 直前 current |
| `candidate` | `EntitlementSnapshotIdentifier` | 新たに採用を試みる completed snapshot |
| `handoffStatus` | enum | `pending-switch`、`applied`、`kept-existing` |
| `appliedAt` | timestamp? | 切替完了時刻 |

**Rules**:

- `applied` になった時だけ `Subscription.currentEntitlementSnapshot` を更新できる
- retryable / terminal failure 時は `kept-existing` を許可し、既存 current を維持する

### BillingFailureSummary

**Purpose**: `query-api` が status-only で表示する failure 要約を保持する。

| Field | Type | Description |
|-------|------|-------------|
| `classification` | enum | `retryable`、`timeout`、`terminal`、`dead-letter` |
| `publicStatus` | enum | `retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` |
| `retryable` | bool | 再試行余地の有無 |
| `message` | string | redacted 済みの user-facing 要約 |
| `lastAttemptNumber` | integer | 直近 attempt |

**Rules**:

- `message` に provider credential、raw receipt payload、internal stack trace を含めてはならない
- `publicStatus = retry-scheduled` の間は confirmed entitlement snapshot を unlock 根拠として返してはならない

## Relationships

- `BillingWorkItem` は 1 つの `BillingWorkflowState` を持つ
- `BillingWorkflowState` は 0..n の `VerificationAttemptRecord` を持ちうる
- `BillingWorkflowState.candidateSnapshot` は 0..1 の `SubscriptionAuthoritySnapshotCandidate` を参照する
- `SubscriptionAuthoritySnapshotCandidate` は 0..1 の `CurrentSubscriptionHandoff` を伴う
- `BillingFailureSummary` は `BillingWorkflowState` に付随し、`query-api` の status-only read へ渡される

## State Transitions

1. submitted purchase artifact または normalized notification から `BillingWorkItem` を作る
2. `queued -> running` で対応する adapter (verification または notification ingest) を開始する
3. adapter outcome:
   - retryable failure -> `retry-scheduled`
   - timeout -> `timed-out`
   - non-retryable failure -> `failed-final`
   - verified / reconciled payload -> `SubscriptionAuthoritySnapshotCandidate` 保存へ進む
4. candidate 保存後:
   - handoff success -> `succeeded`
   - handoff retryable failure -> `retry-scheduled` または handoff retry path
   - handoff unrecoverable failure -> `failed-final` または `dead-lettered`
5. `succeeded` の時だけ `Subscription.currentEntitlementSnapshot` が新 candidate に切り替わる

## Concept Separation (憲章 VI 遵守)

| 概念 | 所在 | billing-worker が扱うか |
|------|------|------------------------|
| purchase state (`initiated` / `submitted` / `verifying` / `verified` / `rejected`) | Subscription 集約 | ✅ 更新する |
| authoritative subscription state (`active` / `grace` / `expired` / `pending-sync` / `revoked`) | Subscription 集約 | ✅ 更新する |
| entitlement bundle (`free-basic` / `premium-generation`) | EntitlementSnapshot | ✅ snapshot 経由で commit する |
| quota profile (`free-monthly` / `standard-monthly` / `pro-monthly`) | EntitlementSnapshot | ✅ snapshot 経由で commit する |
| feature gate decision | Feature Gate component (010) | ❌ 読み出し側の責務 |
| usage limit 消費判定 | Usage Metering / Quota Gate (010) | ❌ 別コンポーネント責務 |
| Frequency / Sophistication / Proficiency | Learner / Vocabulary 集約 | ❌ 学習指標は別概念 |
| 登録状態 / 生成状態 | VocabularyExpression / Explanation / VisualImage | ❌ explanation / image worker の責務 |
