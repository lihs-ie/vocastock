# Data Model: Flutter開発環境基盤整備

## Entity: ToolchainComponent

**Purpose**: ローカル開発または CI で必要となる単一のツールチェーン要素を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | ToolchainComponentIdentifier | 1 | コンポーネント識別子 |
| name | ComponentName | 1 | 例: Flutter SDK, Xcode, Firebase CLI |
| category | ToolchainCategory | 1 | `host_sdk`, `container_runtime`, `ci_runtime`, `security_tool`, `platform_tool` のいずれか |
| approvedVersion | ApprovedVersion | 1 | 採用する正規バージョン文字列 |
| releaseChannel | ReleaseChannel | 1 | `lts` または `stable` |
| installScope | InstallScope | 1 | `host`, `container`, `ci`, `shared` のいずれか |
| supportWindow | SupportWindow | 1 | 公式サポート期間または採用根拠 |
| approval | VersionApprovalRecordIdentifier | 1 | バージョン採用根拠への参照 |
| hostProfiles | HostPlatformProfileIdentifier[] | 0..n | 適用対象ホスト群 |

**Validation rules**:

- `approvedVersion` は曖昧な major のみ指定を許可せず、patch を含む具体値を持つ
- `releaseChannel = lts` の場合、support source に vendor の LTS 根拠が必要
- `releaseChannel = stable` の場合、formal LTS 不在の理由を `approval` に必ず記録する

## Entity: VersionApprovalRecord

**Purpose**: 採用バージョンのサポート状況、脆弱性調査、採用理由、見直し条件を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | VersionApprovalRecordIdentifier | 1 | 承認記録識別子 |
| component | ToolchainComponentIdentifier | 1 | 対象コンポーネント |
| supportStatus | SupportStatus | 1 | `supported`, `security-fix-only`, `deprecated`, `unsupported` |
| securityReview | SecurityReview | 1 | 調査日、確認元、結果、例外有無 |
| observedBaseline | ObservedBaseline | 0..1 | 実機で確認した host baseline version と観測日 |
| baselineDelta | BaselineDelta | 0..1 | 旧承認値との差分と更新理由 |
| rationale | ApprovalRationale | 1 | 採用理由の要約 |
| alternatives | AlternativeDecision[] | 0..n | 検討した候補 |
| reviewCadence | ReviewCadence | 1 | 見直し周期 |
| approvalStatus | ApprovalStatus | 1 | `candidate`, `approved`, `superseded`, `blocked` |
| approvedAt | DateTime | 1 | 承認日時 |

**Validation rules**:

- `supportStatus` が `unsupported` の記録は `approvalStatus = approved` を許可しない
- `securityReview` に Medium 以上の未解決事項がある場合は `approvalStatus = blocked`
- `observedBaseline` が存在し、`approvedVersion` と異なる場合は `baselineDelta` が必須
- `reviewCadence` は 90 日以内、または vendor release 発生時のいずれか早い方で見直す

**State transitions**:

- `candidate -> approved`
- `candidate -> blocked`
- `approved -> superseded`
- `blocked -> candidate`

## Entity: HostPlatformProfile

**Purpose**: 公式サポートするローカル開発ホストの条件と前提を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | HostPlatformProfileIdentifier | 1 | ホスト環境識別子 |
| operatingSystem | OperatingSystem | 1 | `macOS` |
| supportedVersions | SupportedVersionRange | 1 | 例: `26.4.1+` |
| architecture | HostArchitecture[] | 1..2 | `arm64`, `x86_64` |
| requiredComponents | ToolchainComponentIdentifier[] | 1..n | 必須 host-side コンポーネント |
| optionalComponents | ToolchainComponentIdentifier[] | 0..n | 補助的な任意コンポーネント |
| knownConstraints | ConstraintNote[] | 0..n | 既知制約 |
| secretProfile | SecretHandlingProfileIdentifier | 1 | 機密設定方針 |

**Validation rules**:

- `operatingSystem` は今回 `macOS` のみ
- `requiredComponents` には Flutter SDK、Xcode、Android Studio、Docker Desktop を含む

## Entity: EmulatorStackProfile

**Purpose**: Docker 化された Firebase エミュレーター構成を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | EmulatorStackProfileIdentifier | 1 | emulator stack 識別子 |
| controller | ToolchainComponentIdentifier | 1 | Firebase CLI |
| runtimeNode | ToolchainComponentIdentifier | 1 | Node.js runtime |
| runtimeJava | ToolchainComponentIdentifier | 1 | Java runtime |
| services | FirebaseServiceProfile[] | 1..n | 再現対象 Firebase サービス |
| publicPorts | PortBinding[] | 1..n | 開放ポート定義 |
| persistenceMode | PersistenceMode | 1 | `ephemeral`, `volume-backed` |
| seedStrategy | SeedStrategy | 1 | 初期データ投入方針 |
| lifecycleState | LifecycleState | 1 | `stopped`, `starting`, `ready`, `failed` |
| hostProfile | HostPlatformProfileIdentifier | 1 | 対応ホスト |

**Validation rules**:

- `services` はプロジェクトで利用する全 Firebase サービスを網羅しなければならない
- `lifecycleState = ready` になるまで healthcheck が通過していなければならない
- `publicPorts` はローカル既定値として衝突回避可能な範囲に収まる必要がある

**State transitions**:

- `stopped -> starting -> ready | failed`
- `ready -> stopped`
- `failed -> starting`

## Entity: CICheckDefinition

**Purpose**: 1 つの CI ジョブまたは required status check を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | CICheckDefinitionIdentifier | 1 | チェック識別子 |
| name | CheckName | 1 | 例: `toolchain-validate`, `flutter-test`, `vulnerability-scan` |
| runnerClass | RunnerClass | 1 | `ubuntu-24.04` または `macos-15` |
| triggerSet | TriggerSet | 1 | push / pull_request / manual の組み合わせ |
| prerequisites | CheckDependency[] | 0..n | 依存チェック |
| outputs | CheckOutput[] | 0..n | log, report, artifact など |
| blockingPolicy | BlockingPolicy | 1 | merge を止める条件 |
| branchPolicies | BranchProtectionPolicyIdentifier[] | 1..n | 適用対象ブランチ規約 |

**Validation rules**:

- `blockingPolicy` は `main` / `develop` / `release/*` 向けでは必須
- vulnerability 系チェックは `MEDIUM,HIGH,CRITICAL` を fail 条件に含む

## Entity: BranchProtectionPolicy

**Purpose**: 保護対象ブランチと required checks の対応を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | BranchProtectionPolicyIdentifier | 1 | 規約識別子 |
| pattern | BranchPattern | 1 | `main`, `develop`, `release/*` など |
| requiredChecks | CICheckDefinitionIdentifier[] | 1..n | 必須 check 群 |
| reviewRequirement | ReviewRequirement | 1 | 最低レビュー条件 |
| revalidationPolicy | RevalidationPolicy | 1 | push 後の再評価条件 |
| mergeStrategy | MergeStrategy | 1 | 許可する merge 形式 |

**Validation rules**:

- `pattern` は GitHub branch protection rule と一致する書式を使う
- `requiredChecks` が空の policy は保護対象として扱わない

## Entity: SecretHandlingProfile

**Purpose**: ローカル既定値と秘匿情報の分離方針を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | SecretHandlingProfileIdentifier | 1 | 機密設定識別子 |
| localDefaults | LocalDefaultSetting[] | 0..n | `.env.local.example` などに置ける既定値 |
| protectedSecrets | SecretRequirement[] | 0..n | CI / deploy 用 secret |
| ciAuthentication | AuthenticationMode | 1 | `service-account`, `oidc`, `none` |
| prohibitedMechanisms | ProhibitedMechanism[] | 0..n | 例: `firebase-login-token` |
| rotationPolicy | RotationPolicy | 1 | 更新ルール |

**Validation rules**:

- `localDefaults` に本番 secret を含めてはならない
- `prohibitedMechanisms` には `FIREBASE_TOKEN` を含める

## Relationships

- `ToolchainComponent` 1 : 1 `VersionApprovalRecord`
- `HostPlatformProfile` 1 : n `ToolchainComponent`
- `EmulatorStackProfile` n : 1 `HostPlatformProfile`
- `CICheckDefinition` n : n `BranchProtectionPolicy`
- `SecretHandlingProfile` 1 : n `HostPlatformProfile`

## Value Objects

### ReleaseChannel

- `lts`
- `stable`

### ApprovalStatus

- `candidate`
- `approved`
- `superseded`
- `blocked`

### ObservedBaseline

- `version`
- `observedAt`
- `source`

### BaselineDelta

- `previousApprovedVersion`
- `changeReason`
- `followUpRequired`

### LifecycleState

- `stopped`
- `starting`
- `ready`
- `failed`
