# Data Model: 技術スタック定義

## Entity: BoundaryStackProfile

**Purpose**: 1 つの責務境界に対する採用 stack を表す基準定義。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | BoundaryStackProfileIdentifier | 1 | profile 識別子 |
| boundary | ArchitectureBoundaryIdentifier | 1 | 対象の責務境界 |
| primaryLanguage | LanguageProfile | 0..1 | 主要言語。managed service 中心の境界では省略可 |
| primaryLibrary | LibraryProfile | 0..1 | 主要ライブラリ。例: `graphql_flutter` |
| runtimePlatform | RuntimePlatformProfile | 1 | 実行基盤 |
| interfaceStyle | InterfaceStyle | 1 | 主な入出力契約形式 |
| managedServices | ManagedServiceProfile[] | 0..n | 利用する managed service 群 |
| adapterStyle | AdapterStyle | 1 | 外部接続の標準方式 |
| supportPolicy | SupportPolicyRecordIdentifier | 1 | support / review 方針 |
| migrationWave | MigrationWaveIdentifier | 1 | 適用開始波 |
| exceptionAllowance | ExceptionAllowance | 1 | 例外可否の初期方針 |

**Validation rules**:

- 1 つの `ArchitectureBoundary` には 1 つの primary `BoundaryStackProfile` だけを割り当てる
- command/query profile の `primaryLanguage` は Rust、workflow profile の `primaryLanguage` は Haskell でなければならない
- client profile の `primaryLibrary` は `graphql_flutter` でなければならない
- image workflow が asset storage を使う場合、`managedServices` に Drive family を持っていても access は `AssetStoragePort` 越しでなければならない
- client boundary の profile は AI provider や Google Drive API を直接依存先に含めてはならない

## Entity: SharedStandard

**Purpose**: 全境界または複数境界で共有される技術標準を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | SharedStandardIdentifier | 1 | 標準識別子 |
| name | StandardName | 1 | 例: GraphQL over HTTPS |
| appliesTo | ArchitectureBoundaryIdentifier[] | 1..n | 適用対象境界 |
| requirementType | RequirementType | 1 | `mandatory`, `recommended`, `prohibited` |
| rationale | Rationale | 1 | 採用理由 |
| compatibilityConstraints | CompatibilityConstraintIdentifier[] | 0..n | 関連制約 |

**Validation rules**:

- `requirementType = prohibited` の標準は、例外記録なしに採用してはならない
- 複数 boundary に適用する標準は、境界ごとに意味が変わってはならない

## Entity: CompatibilityConstraint

**Purpose**: 採用技術同士が整合するために満たすべき条件を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | CompatibilityConstraintIdentifier | 1 | 制約識別子 |
| producer | BoundaryStackProfileIdentifier | 1 | 制約の起点 profile |
| consumer | BoundaryStackProfileIdentifier | 1 | 制約の受け手 profile |
| subject | ConstraintSubject | 1 | 例: auth propagation, schema compatibility, correlation id |
| rule | ConstraintRule | 1 | 守るべき整合条件 |
| verificationMethod | VerificationMethod | 1 | どう確認するか |
| failureImpact | FailureImpact | 1 | 不整合時の影響 |

**Validation rules**:

- `producer` と `consumer` が同一の場合は shared standard として扱う
- `verificationMethod` は人手レビューだけでなく、将来の自動検証方針を説明できなければならない
- GraphQL 契約に関する制約は client library と Rust command/query runtime の両方を参照しなければならない

## Entity: SupportPolicyRecord

**Purpose**: 採用技術または managed service family の support / review ルールを表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | SupportPolicyRecordIdentifier | 1 | policy 識別子 |
| component | ComponentName | 1 | 対象技術または service family |
| versionStrategy | VersionStrategy | 1 | `exact`, `family`, `implementation-wave-pin` |
| supportSource | SourceReference[] | 1..n | support 根拠 |
| reviewCadence | ReviewCadence | 1 | 見直し周期 |
| escalationRule | EscalationRule | 1 | support 逸脱時の扱い |
| disposition | PolicyDisposition | 1 | `proposed`, `approved`, `superseded`, `blocked` |
| reviewedAt | Date | 1 | 最終確認日 |

**Validation rules**:

- `versionStrategy = exact` の場合は concrete version が別台帳で参照可能でなければならない
- `disposition = approved` の policy は support 逸脱時の escalation rule を必須とする
- Google Drive API のような external service family は adapter compatibility rule を必須とする

**State transitions**:

- `proposed -> approved`
- `proposed -> blocked`
- `approved -> superseded`
- `blocked -> proposed`

## Entity: StackExceptionRecord

**Purpose**: 標準外技術を期限付きで導入するための例外記録を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | StackExceptionRecordIdentifier | 1 | 例外識別子 |
| requestedBoundary | ArchitectureBoundaryIdentifier | 1 | 対象境界 |
| requestedComponent | ComponentName | 1 | 例外対象技術 |
| justification | Justification | 1 | 必要理由 |
| compensatingControls | CompensatingControl[] | 0..n | 代替統制 |
| expiresAt | Date | 1 | 失効日 |
| owner | ResponsibleRole | 1 | 見直し責任 |
| status | ExceptionStatus | 1 | `requested`, `approved`, `rejected`, `expired` |
| migrationWave | MigrationWaveIdentifier | 1 | どの波の暫定措置か |

**Validation rules**:

- `status = approved` の例外は `expiresAt` と `owner` を必須とする
- 例外は期限なしで承認してはならない
- Rust/Haskell の責務分離、GraphQL 契約、Google Drive asset adapter を壊す例外は compensating control を必須とする

**State transitions**:

- `requested -> approved | rejected`
- `approved -> expired`

## Entity: MigrationWave

**Purpose**: 現状から採用 stack へ到達する段階移行単位を表す。

| Field | Type | Cardinality | Description |
|-------|------|-------------|-------------|
| identifier | MigrationWaveIdentifier | 1 | 波識別子 |
| name | WaveName | 1 | 例: Client and GraphQL Foundation |
| objective | Objective | 1 | 波の目的 |
| enabledProfiles | BoundaryStackProfileIdentifier[] | 1..n | 有効化される stack profile |
| prerequisites | Prerequisite[] | 0..n | 着手前提 |
| exitCriteria | ExitCriterion[] | 1..n | 完了条件 |
| successor | MigrationWaveIdentifier | 0..1 | 次の波 |

**Validation rules**:

- 波は `current-state` から段階的に前進し、後退を前提にしてはならない
- どの wave でも「完了済み結果のみ表示」の rule を壊してはならない
- workflow hardening wave は Pub/Sub、Firestore state、Haskell worker を同時に説明できなければ完了してはならない

**State transitions**:

- `current-state -> wave-1-foundation -> wave-2-service-runtime -> wave-3-workflow-hardening`

## Relationships

- `BoundaryStackProfile` n : 1 `SupportPolicyRecord`
- `SharedStandard` n : n `CompatibilityConstraint`
- `CompatibilityConstraint` n : 1 `BoundaryStackProfile` (`producer`)
- `CompatibilityConstraint` n : 1 `BoundaryStackProfile` (`consumer`)
- `StackExceptionRecord` n : 1 `MigrationWave`
- `MigrationWave` 1 : n `BoundaryStackProfile`

## Value Objects

### InterfaceStyle

- `graphql-over-https`
- `pubsub-event-envelope`
- `durable-state-handoff`
- `asset-reference-contract`
- `structured-observability-signals`

### AdapterStyle

- `port-adapter-http-json`
- `port-adapter-graphql`
- `pubsub-subscriber-adapter`
- `managed-service-sdk-at-edge-only`

### VersionStrategy

- `exact`
- `family`
- `implementation-wave-pin`

### PolicyDisposition

- `proposed`
- `approved`
- `superseded`
- `blocked`

### ExceptionStatus

- `requested`
- `approved`
- `rejected`
- `expired`
