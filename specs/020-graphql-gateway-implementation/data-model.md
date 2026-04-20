# Data Model: GraphQL Gateway Implementation

## Overview

020 は `graphql-gateway` の public GraphQL binding を最小スライスで実装する。domain aggregate を
変更する feature ではなく、public request、routing、failure shaping、downstream relay の構造を
固定する。

## Entities

### UnifiedGraphqlRequest

**Purpose**: client-facing `/graphql` endpoint で受ける request envelope。

| Field | Type | Description |
|-------|------|-------------|
| `query` | string | GraphQL document 本文 |
| `operationName` | string? | 複数 operation document の選択に使う optional field |
| `variables` | object? | public operation へ渡す JSON variables |
| `authorizationHeader` | string? | client 受信値をそのまま downstream へ渡す auth header |
| `requestCorrelation` | string | client 提供値または gateway 採番値 |

**Validation Rules**:

- `query` は空文字であってはならない
- initial slice では 1 request 1 operation だけを許可する
- `operationName` が必要な場面で欠落し、routing 先が一意に決まらない場合は `ambiguous-operation`

### GatewayRoutingDecision

**Purpose**: public GraphQL operation を downstream service へ割り当てる判定結果。

| Field | Type | Description |
|-------|------|-------------|
| `operationKind` | enum | `mutation` または `query` |
| `operationName` | string | allowlist で許可された public operation 名 |
| `downstreamService` | enum | `command-api` または `query-api` |
| `downstreamRoute` | string | internal HTTP route |
| `visibleGuarantee` | enum | `accepted-only` または `completed-or-status-only` |

**Invariants**:

- `registerVocabularyExpression` は必ず `command-api` に割り当てる
- `vocabularyCatalog` は必ず `query-api` に割り当てる
- allowlist 外 operation は `GatewayRoutingDecision` を生成せず `unsupported-operation`

### PublicMutationResult

**Purpose**: `registerVocabularyExpression` mutation の public response family。

| Field | Type | Description |
|-------|------|-------------|
| `acceptance` | enum | `accepted` または `reused-existing` |
| `vocabularyExpression` | string | downstream から受け取る語彙参照 |
| `statusHandle` | string | accepted / reused-existing の追跡参照 |
| `message` | string | user-facing message |
| `duplicateReuse` | object? | duplicate reuse 時のみ存在 |
| `replayedByIdempotency` | bool | replay 判定結果 |

**Visibility Rules**:

- completed explanation payload、image payload、query projection payload を含めない
- `dispatch-failed`、`idempotency-conflict`、auth failure は `GatewayFailureEnvelope` 側へ写像する

### PublicCatalogResult

**Purpose**: `vocabularyCatalog` query の public response family。

| Field | Type | Description |
|-------|------|-------------|
| `collectionState` | enum | `empty` または `populated` |
| `items` | array | completed summary または status-only catalog items |
| `message` | string? | public catalog 説明を必要時に補う optional field |

**Visibility Rules**:

- item ごとの `visibility` は `completed-summary` または `status-only`
- detail payload、pending-sync entitlement 確定情報、intermediate payload を含めない

### PublicFailureResponse

**Purpose**: public endpoint failure を GraphQL-style に返す top-level body。

| Field | Type | Description |
|-------|------|-------------|
| `errors` | array<GatewayFailureEnvelope> | public failure object の list |

**Invariants**:

- initial slice では `errors[0]` に主要 failure を 1 件入れて返す
- success の `data` shape と混在させない

### GatewayFailureEnvelope

**Purpose**: `errors[]` の各要素として返す failure object。

| Field | Type | Description |
|-------|------|-------------|
| `code` | string | `unsupported-operation`、`ambiguous-operation`、`downstream-unavailable` など |
| `message` | string | user-facing failure explanation |
| `retryable` | bool? | 再試行可能性を補助的に表す optional flag |

**Invariants**:

- `code` と `message` は必須
- raw token、provider credential、internal route URL、secret detail を含めない

### RequestCorrelationContext

**Purpose**: public request と downstream relay を追跡する correlation 情報。

| Field | Type | Description |
|-------|------|-------------|
| `incomingValue` | string? | client 提供値 |
| `generatedValue` | string? | gateway が欠落時に生成する値 |
| `effectiveValue` | string | downstream へ伝播する最終値 |

**Rules**:

- client 提供値があればそれを優先する
- 欠落時のみ gateway が新規に採番する
- auth header と同様、gateway は transport metadata としてだけ扱う

## Relationships

- `UnifiedGraphqlRequest` は 0 または 1 個の `GatewayRoutingDecision` を持つ
- `GatewayRoutingDecision` は `PublicMutationResult` または `PublicCatalogResult` へ成功写像する
- routing 不能または downstream failure 時は `PublicFailureResponse.errors[]` を返す
- `RequestCorrelationContext` は `UnifiedGraphqlRequest` と `GatewayRoutingDecision` の双方に付随する

## State Transitions

1. `/graphql` が `UnifiedGraphqlRequest` を受ける
2. allowlist / operation validation に成功すると `GatewayRoutingDecision` を生成する
3. gateway が downstream relay を実行する
4. downstream success:
   - mutation -> `PublicMutationResult`
   - query -> `PublicCatalogResult`
5. validation failure または downstream failure:
   - `PublicFailureResponse`
