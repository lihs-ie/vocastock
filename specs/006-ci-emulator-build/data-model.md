# Data Model: CI Emulator Build Optimization

## Entity: EmulatorImageBaseline

**Purpose**: reusable emulator image の正規参照、invalidations、ownership を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | EmulatorImageBaselineIdentifier | 1 | baseline record の識別子 |
| baselineHash | BaselineHash | 1 | Docker / config source-of-truth から計算した hash |
| imageReference | ImageReference | 1 | 例: `ghcr.io/<owner>/<repo>/firebase-emulators:<baselineHash>` |
| buildInputs | BuildInputDigest[] | 1..n | `Dockerfile`、`compose.yaml`、`firebase.json`、runtime version の digest |
| distributionChannel | DistributionChannel | 1 | `ghcr`, `workflow-artifact`, `local-only` のいずれか |
| invalidationTriggers | InvalidationTrigger[] | 1..n | baseline を無効化する条件 |
| owner | OwnershipProfile | 1 | build/publish の責務を持つ workflow / team |
| readinessBudgetSeconds | integer | 1 | reusable image path の ready budget |

**Validation rules**:

- `baselineHash` は source-of-truth 入力が変わったら必ず変化しなければならない
- `imageReference` は repository ごとに一意でなければならない
- `distributionChannel = ghcr` の場合、`owner` は package write 権限を持つ workflow である必要がある
- `readinessBudgetSeconds` は `VOCAS_EMULATOR_READY_BUDGET_SECONDS` と整合していなければならない

## Entity: ImagePreparationExecution

**Purpose**: image を解決、build、cache export、publish する 1 回の operational run を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | ImagePreparationExecutionIdentifier | 1 | preparation run の識別子 |
| baseline | EmulatorImageBaselineIdentifier | 1 | 対象 baseline |
| trigger | PreparationTrigger | 1 | `push`, `pull_request`, `workflow_dispatch`, `workflow_call` |
| cacheStrategy | CacheStrategy | 1 | `gha-buildx`, `none` |
| resolvedSource | ResolvedImageSource | 1 | `existing-ghcr`, `rebuilt-and-published`, `rebuilt-and-artifacted`, `failed` |
| artifactBundle | ArtifactBundle | 0..1 | same-run downstream 向け tarball 情報 |
| lifecycleState | ExecutionLifecycleState | 1 | `pending`, `running`, `succeeded`, `failed` |
| stopStage | StopStage | 0..1 | 停止した stage |
| startedAt | DateTime | 1 | 開始時刻 |
| completedAt | DateTime | 0..1 | 終了時刻 |

**Validation rules**:

- `resolvedSource = rebuilt-and-published` の場合、`distributionChannel` は `ghcr` を含む
- `artifactBundle` は trusted push が使えない場合でも same-run reuse を成立させる場合にのみ保持する
- `lifecycleState = failed` の場合、`stopStage` を必須とする

**State transitions**:

- `pending -> running -> succeeded`
- `pending -> running -> failed`
- `failed -> running` (same baseline に対する retry)

## Entity: EmulatorSmokeExecution

**Purpose**: required check `emulator-smoke` が reusable image を消費して ready 判定まで進む 1 回の run を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | EmulatorSmokeExecutionIdentifier | 1 | smoke run の識別子 |
| baseline | EmulatorImageBaselineIdentifier | 1 | 参照した baseline |
| requiredCheckName | CheckName | 1 | 常に `emulator-smoke` |
| imageSource | ResolvedImageSource | 1 | 実際に使った image source |
| imageReference | ImageReference | 1 | load/pull した image ref |
| startupMode | StartupMode | 1 | `ci-prepared-image` または `local-build` |
| stageDurations | StageDuration[] | 1..n | stage 別 duration |
| lifecycleState | ExecutionLifecycleState | 1 | `pending`, `running`, `succeeded`, `failed` |
| stopStage | StopStage | 0..1 | 失敗または遅延が発生した stage |
| diagnosticLog | CIDiagnosticLogBundleIdentifier | 1 | 記録した log bundle |

**Validation rules**:

- CI path では `startupMode = ci-prepared-image` でなければならず、inline build を許可しない
- `lifecycleState = failed` の場合、`stopStage` を必須とする
- `stageDurations` は少なくとも `image-resolution`、`container-start`、`readiness-wait` を含む

**State transitions**:

- `pending -> running -> succeeded`
- `pending -> running -> failed`
- `failed -> running` (same baseline / rerun)

## Entity: CIDiagnosticLogBundle

**Purpose**: maintainer が停止点を追加調査なしで判定するための構造化ログ集合を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | CIDiagnosticLogBundleIdentifier | 1 | log bundle 識別子 |
| execution | EmulatorSmokeExecutionIdentifier or ImagePreparationExecutionIdentifier | 1 | 対象 run |
| stageRecords | StageRecord[] | 1..n | stage 開始・終了・duration・result |
| composeStatusSnapshot | ComposeStatusSnapshot | 0..1 | `docker compose ps` の記録 |
| containerLogTail | ContainerLogTail | 0..1 | failure 時の末尾ログ |
| artifactPaths | ArtifactPath[] | 1..n | `.artifacts/ci` or `.artifacts/firebase` 内の出力先 |
| retentionProfile | RetentionProfile | 1 | artifact retention 方針 |

**Validation rules**:

- `stageRecords` は順序付きでなければならない
- failure bundle には `composeStatusSnapshot` または `containerLogTail` のいずれかを必須とする
- artifact path は maintainer 向け log / duration / report のみに限定する

## Relationships

- `EmulatorImageBaseline` 1 : n `ImagePreparationExecution`
- `EmulatorImageBaseline` 1 : n `EmulatorSmokeExecution`
- `ImagePreparationExecution` 0..1 : 1 `CIDiagnosticLogBundle`
- `EmulatorSmokeExecution` 1 : 1 `CIDiagnosticLogBundle`

## Value Objects

### DistributionChannel

- `ghcr`
- `workflow-artifact`
- `local-only`

### ResolvedImageSource

- `existing-ghcr`
- `rebuilt-and-published`
- `rebuilt-and-artifacted`
- `workflow-artifact`
- `failed`

### ExecutionLifecycleState

- `pending`
- `running`
- `succeeded`
- `failed`

### StopStage

- `image-resolution`
- `image-build`
- `image-publish`
- `image-pull`
- `artifact-load`
- `container-start`
- `readiness-wait`
- `cleanup`
