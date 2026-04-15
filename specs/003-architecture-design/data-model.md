# Data Model: アーキテクチャ設計

## Entity: ArchitectureBoundary

**Purpose**: どの責務をどの境界が持ち、どこまで依存してよいかを表す主要単位。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | ArchitectureBoundaryIdentifier | 1 | 境界識別子 |
| name | BoundaryName | 1 | 例: Client Experience, Vocabulary Command |
| layer | BoundaryLayer | 1 | `experience`, `application`, `workflow`, `integration` |
| runtimeUnit | RuntimeUnitIdentifier | 1 | 主に実行される runtime |
| ownedCapabilities | CapabilityName[] | 1..n | その境界が主責務を持つ機能 |
| ownedStates | StateName[] | 0..n | 所有する状態概念 |
| inboundContracts | ContractReference[] | 0..n | 受け入れる command / query / event 契約 |
| outboundDependencies | DependencyReference[] | 0..n | 利用する repository / port / downstream boundary |
| prohibitedResponsibilities | ResponsibilityName[] | 0..n | 持ってはならない責務 |
| migrationPhase | MigrationPhaseIdentifier | 1 | 初めて成立する移行フェーズ |

**Validation rules**:

- 1 つの業務 capability は 1 つの `ArchitectureBoundary` だけが主責務を持つ
- `ownedStates` に含まれる状態は、他境界が直接更新してはならない
- `outboundDependencies` に外部依存を含む場合、それは `ExternalPortDefinition` 参照でなければならない
- 命名は `identifier` と概念名フィールドを用い、`id` / `xxxId` を禁止する

## Entity: RuntimeUnit

**Purpose**: 境界をホストする実行単位、または将来の deployable unit を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | RuntimeUnitIdentifier | 1 | runtime 識別子 |
| name | RuntimeName | 1 | 例: Flutter Client Runtime |
| kind | RuntimeKind | 1 | `client`, `application`, `worker` |
| hostedBoundaries | ArchitectureBoundaryIdentifier[] | 1..n | この runtime がホストする境界 |
| scalingMode | ScalingMode | 1 | `user-driven`, `request-driven`, `queue-driven` |
| deploymentIndependence | DeploymentIndependence | 1 | 単独デプロイ可否 |
| observabilityNeeds | ObservabilityNeed[] | 0..n | 監視・記録の必要事項 |
| failureIsolationLevel | FailureIsolationLevel | 1 | 障害分離の期待値 |

**Validation rules**:

- `kind = worker` の runtime は少なくとも 1 つの workflow 境界を持たなければならない
- `hostedBoundaries` の責務が衝突する場合、`migrationPhase` で段階分離方針を持たなければならない

## Entity: AsyncFlowDefinition

**Purpose**: 解説生成または画像生成の非同期ワークフロー定義を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | AsyncFlowDefinitionIdentifier | 1 | フロー識別子 |
| name | FlowName | 1 | 例: Explanation Generation |
| triggerBoundary | ArchitectureBoundaryIdentifier | 1 | 開始 command を受ける境界 |
| workerBoundary | ArchitectureBoundaryIdentifier | 1 | 実行責務を持つ workflow 境界 |
| sourceAggregate | AggregateName | 1 | 元になる業務集約 |
| completionArtifact | ArtifactName | 1 | 完了時に得られる成果物 |
| statuses | FlowStatus[] | 4 | `pending`, `running`, `succeeded`, `failed` |
| retryOwner | ArchitectureBoundaryIdentifier | 1 | 再試行を判断・実行する境界 |
| visibilityRule | VisibilityRuleIdentifier | 1 | ユーザー表示規則 |
| failurePolicy | FailurePolicy | 1 | 失敗時の保持・通知方針 |
| idempotencyKeySource | IdempotencyKeySource | 1 | 冪等性に使う業務キー |

**Validation rules**:

- `completionArtifact` は `status = succeeded` のときのみユーザー可視化できる
- 画像生成フローは、解説生成フローが `succeeded` である場合のみ開始できる
- 再試行は同一の業務キー、または明示的な再生成 command を使って冪等に扱う

**State transitions**:

- `pending -> running -> succeeded | failed`
- `failed -> pending`
- 画像生成のみ `succeeded -> pending` を再生成として許可

## Entity: UserVisibilityRule

**Purpose**: 内部状態とユーザーに見せてよい情報の対応を定義する。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | VisibilityRuleIdentifier | 1 | 規則識別子 |
| flow | AsyncFlowDefinitionIdentifier | 1 | 対象フロー |
| visibleStatuses | FlowStatus[] | 1..n | ユーザーへ見せる状態表示 |
| visibleArtifactCondition | ArtifactVisibilityCondition | 1 | 成果物を見せてよい条件 |
| hiddenDataClasses | HiddenDataClass[] | 0..n | 中間生成物や詳細エラーなど |
| retryHintPolicy | RetryHintPolicy | 1 | 再試行導線の見せ方 |
| failureMessagePolicy | FailureMessagePolicy | 1 | 失敗時のメッセージ粒度 |

**Validation rules**:

- `visibleArtifactCondition` は常に `status = succeeded` を含まなければならない
- `hiddenDataClasses` には中間生成物と provider 固有エラー詳細を含める

## Entity: ExternalPortDefinition

**Purpose**: 外部依存との接続契約を表し、caller boundary との責務を固定する。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | ExternalPortDefinitionIdentifier | 1 | ポート識別子 |
| name | PortName | 1 | 例: ExplanationGenerationPort |
| callerBoundary | ArchitectureBoundaryIdentifier | 1 | 呼び出し責務を持つ境界 |
| interactionMode | InteractionMode | 1 | `request-response`, `async-request`, `store-and-return-reference` |
| requestPayload | PayloadShape | 1 | 入力情報の要約 |
| successPayload | PayloadShape | 1 | 成功時出力の要約 |
| failureModes | FailureMode[] | 1..n | タイムアウトや拒否など |
| idempotencyRequirement | IdempotencyRequirement | 1 | 冪等要求 |
| timeoutPolicy | TimeoutPolicy | 1 | タイムアウト方針 |
| fallbackPolicy | FallbackPolicy | 1 | 代替動作や中止条件 |

**Validation rules**:

- `callerBoundary` は domain model ではなく application / workflow / integration 境界でなければならない
- `successPayload` は未完了成果物をユーザー可視前提で返してはならない
- `failureModes` ごとに retry または fail-fast の扱いを定義しなければならない

## Entity: MigrationPhase

**Purpose**: 現状から target architecture へ到達する段階的な移行単位を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | MigrationPhaseIdentifier | 1 | フェーズ識別子 |
| name | PhaseName | 1 | 例: Architecture Fixed Foundation |
| objective | Objective | 1 | そのフェーズの達成目的 |
| enabledBoundaries | ArchitectureBoundaryIdentifier[] | 1..n | 有効化される境界 |
| requiredContracts | ContractReference[] | 1..n | 満たすべき契約文書 |
| exitCriteria | ExitCriterion[] | 1..n | 次フェーズへ進む条件 |
| successor | MigrationPhaseIdentifier | 0..1 | 次フェーズ |

**Validation rules**:

- フェーズは `current-state` から `phase-3` まで単方向に進む
- どのフェーズでも「完了済み結果のみ表示」の規則を破ってはならない
- フェーズを跨いで責務が移る場合、移譲先境界と契約更新が同時に定義されていなければならない

**State transitions**:

- `current-state -> phase-1-foundation -> phase-2-workflow-isolation -> phase-3-runtime-optimization`

## Relationships

- `RuntimeUnit` 1 : n `ArchitectureBoundary`
- `AsyncFlowDefinition` n : 1 `ArchitectureBoundary` (`workerBoundary`)
- `UserVisibilityRule` 1 : 1 `AsyncFlowDefinition`
- `ExternalPortDefinition` n : 1 `ArchitectureBoundary` (`callerBoundary`)
- `MigrationPhase` 1 : n `ArchitectureBoundary`

## Value Objects

### BoundaryLayer

- `experience`
- `application`
- `workflow`
- `integration`

### RuntimeKind

- `client`
- `application`
- `worker`

### FlowStatus

- `pending`
- `running`
- `succeeded`
- `failed`

### InteractionMode

- `request-response`
- `async-request`
- `store-and-return-reference`

### FailureIsolationLevel

- `shared`
- `bounded`
- `isolated`
