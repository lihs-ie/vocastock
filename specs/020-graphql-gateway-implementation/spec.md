# Feature Specification: GraphQL Gateway Implementation

**Feature Branch**: `020-graphql-gateway-implementation`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: "3. graphql-gatewayの実装を設計書に従って行う"

## Clarifications

### Session 2026-04-20

- Q: initial slice の public GraphQL operation 公開範囲 → A: initial slice では `registerVocabularyExpression` と `vocabularyCatalog` の 2 operation だけを allowlist し、それ以外は `unsupported-operation` として拒否する
- Q: 複数 GraphQL operation を含む document の扱い → A: initial slice では 1 request に 1 operation だけを許可し、複数 operation や operationName 未指定で曖昧な document は `ambiguous-operation` として拒否する
- Q: public GraphQL failure response の最小形 → A: すべての public failure は `code` と `message` を必須にした共通 envelope で返し、必要なら `retryable` のような最小補助 flag だけを持たせる
- Q: auth propagation と request correlation の最小ルール → A: auth header は client 受信値をそのまま downstream へ伝播し、request correlation は client 提供値を優先し、無ければ gateway が 1 つ採番して downstream へ渡す

## User Scenarios & Testing *(mandatory)*

### User Story 1 - unified GraphQL endpoint から command/query を呼べる (Priority: P1)

アプリ実装担当者として、client から 1 つの GraphQL endpoint だけを呼びたい。そうすることで、
`command-api` と `query-api` の内部 route を直接意識せずに、登録 mutation と catalog query を同じ入口から利用できるようにしたい。

**Why this priority**: `graphql-gateway` の最小価値は unified endpoint の提供であり、これが無いと
015 で固定した topology と 017 / 018 で実装した内部 service が接続できないため。

**Independent Test**: 第三者が成果物だけを読み、同じ public GraphQL endpoint から
`registerVocabularyExpression` mutation と `vocabularyCatalog` query を送ったときに、どちらがどの backend service へ渡され、
どの visible guarantee を保つかを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 認証済み利用者が `registerVocabularyExpression` mutation を送る, **When** `graphql-gateway` が request を処理する, **Then** `command-api` へ routing し、`accepted` または `reused-existing` を public GraphQL response として返す
2. **Given** 認証済み利用者が `vocabularyCatalog` query を送る, **When** `graphql-gateway` が request を処理する, **Then** `query-api` へ routing し、completed summary または status-only を public GraphQL response として返す
3. **Given** client が内部 service route を知らない, **When** public GraphQL endpoint を使う, **Then** command/query の両方を同一 endpoint から利用できる
4. **Given** initial slice の allowlist 外 operation が送られる, **When** `graphql-gateway` が request を処理する, **Then** downstream へ転送せず `unsupported-operation` を返す
5. **Given** 1 request に複数 operation を含む document、または operationName 未指定で曖昧な document が送られる, **When** `graphql-gateway` が request を処理する, **Then** downstream へ転送せず `ambiguous-operation` を返す

---

### User Story 2 - auth propagation と gateway 非所有責務を守る (Priority: P2)

backend 実装担当者として、`graphql-gateway` が auth header と request correlation を downstream へ伝播しつつ、
token verification、idempotency、read projection ownership を持たないようにしたい。そうすることで、
gateway が topology 上の前段 routing だけを担い、`command-api` / `query-api` の責務を壊さずに済むようにしたい。

**Why this priority**: gateway が認証や state ownership を取り込むと、015 の deployment boundary と
008 / 017 / 018 の既存契約が崩れるため。

**Independent Test**: 第三者が成果物だけを読み、gateway が伝播してよい情報と保持してはいけない責務を
10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** client request に auth header と request correlation が含まれる, **When** `graphql-gateway` が downstream を呼ぶ, **Then** 必要な header / correlation context だけを伝播し、自身は token verification の最終正本にならない
2. **Given** downstream service が token verification または actor handoff に失敗する, **When** `graphql-gateway` が error を返す, **Then** raw token、provider credential、internal route detail を露出しない public failure として返す
3. **Given** mutation / query の処理責務を確認する, **When** gateway の役割を見る, **Then** idempotency store、read projection、workflow dispatch、reconciliation を gateway が own しないことを説明できる
4. **Given** client request に request correlation が無い, **When** `graphql-gateway` が downstream を呼ぶ, **Then** gateway が 1 つ採番し、auth header は受信値を維持したまま downstream へ渡す

---

### User Story 3 - public binding と runtime 契約を検証できる (Priority: P3)

運用担当者として、`graphql-gateway` の runtime が readiness を維持し、local / CI で public binding を再現できてほしい。
そうすることで、command/query service が起動している環境で gateway の公開入口を継続的に検証できるようにしたい。

**Why this priority**: public endpoint は entrypoint なので、runtime 契約と end-to-end 検証が無いと
command/query の個別実装が正しくても利用開始点で破綻するため。

**Independent Test**: 第三者が成果物だけを読み、gateway の readiness 契約と public GraphQL end-to-end 検証方法を
10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** `graphql-gateway` container runtime が起動する, **When** readiness を確認する, **Then** 既存の API application 契約と矛盾しない readiness signal を返す
2. **Given** local / CI 環境で `graphql-gateway`、`command-api`、`query-api`、Firebase emulator が起動している, **When** public GraphQL endpoint の feature test を実行する, **Then** mutation / query の public binding を end-to-end で確認できる
3. **Given** downstream service unavailable や unsupported operation が発生する, **When** gateway が request を処理する, **Then** public endpoint として説明可能な failure category を返す
4. **Given** unsupported operation、ambiguous operation、downstream unavailable、downstream auth failure のいずれかが発生する, **When** `graphql-gateway` が public failure を返す, **Then** `code` と `message` を必須にした共通 failure envelope で返す

### Edge Cases

- GraphQL document に mutation と query が混在し、gateway が routing 先を一意に決められない場合
- 1 request に複数 operation を含み、operationName が無いか、allowlist 判定が曖昧になる場合
- operation kind は判定できるが、この feature の allowlist 外 operation が要求される場合
- `command-api` は `accepted` を返すが、gateway が completed payload を生成して返してしまいそうな場合
- `query-api` が status-only を返すべき状態で、gateway が completed と誤認させる public payload を組み立ててしまいそうな場合
- auth header が欠落している、または downstream auth failure が起きた場合
- `command-api` または `query-api` が unavailable / timeout で応答できない場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None。domain aggregate semantics 自体は変更しない
- **Invariants / Terminology**: `graphql-gateway` は unified GraphQL endpoint、routing、request correlation だけを担い、`command-api`、`query-api`、accepted、status-only、completed summary の既存語彙をそのまま public binding へ投影する
- **Async Lifecycle**: gateway 自身は workflow を起動せず、mutation では `command-api` の accepted / reused-existing / failed を relay し、query では `query-api` の completed summary / status-only を relay する
- **User Visibility Rule**: gateway は completed payload を合成してはならず、`command-api` の accepted / status handle 規則と `query-api` の completed-only / status-only 規則をそのまま維持する
- **Identifier Naming Rule**: gateway は downstream の `identifier` 命名を `id` へ勝手に変換せず、既存の identifier naming rule を public GraphQL binding でも維持する
- **External Ports / Adapters**: client-facing GraphQL request、`command-api` command route、`query-api` read route、auth header propagation、request correlation propagation

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、client-facing の unified GraphQL endpoint を `graphql-gateway` に定義しなければならない
- **FR-002**: 成果物は、initial slice として少なくとも `registerVocabularyExpression` mutation と `vocabularyCatalog` query を public GraphQL operation として公開しなければならない
- **FR-002a**: 成果物は、initial slice の public GraphQL operation を `registerVocabularyExpression` と `vocabularyCatalog` の 2 件だけの allowlist とし、それ以外を `unsupported-operation` として拒否しなければならない
- **FR-003**: 成果物は、mutation を `command-api`、query を `query-api` へ routing する規則を定義しなければならない
- **FR-003a**: 成果物は、initial slice では 1 request に 1 operation だけを許可し、複数 operation や operationName 未指定で routing 先が一意に決まらない document を `ambiguous-operation` として拒否しなければならない
- **FR-004**: 成果物は、`registerVocabularyExpression` mutation で `command-api` の `accepted`、`reused-existing`、`dispatch-failed`、`idempotency-conflict` などの既存 visible guarantee を壊さずに public response へ写像しなければならない
- **FR-005**: 成果物は、`vocabularyCatalog` query で `query-api` の completed summary / status-only 規則を壊さずに public response へ写像しなければならない
- **FR-006**: 成果物は、gateway が auth header と request correlation context を downstream へ伝播しつつ、token verification の最終正本になってはならないことを定義しなければならない
- **FR-006a**: 成果物は、auth header を client 受信値のまま downstream へ伝播し、request correlation は client 提供値を優先し、無い場合だけ gateway が 1 つ採番して downstream へ渡さなければならない
- **FR-007**: 成果物は、gateway が idempotency store、read projection、workflow dispatch、reconciliation を own してはならないことを定義しなければならない
- **FR-008**: 成果物は、unsupported operation、ambiguous operation kind、downstream unavailable、downstream auth failure を public endpoint として区別可能な failure category に整理しなければならない
- **FR-008a**: 成果物は、public failure response を `code` と `message` を必須にした共通 envelope とし、必要なら `retryable` などの最小補助 flag だけを追加してよい
- **FR-009**: 成果物は、public failure response に raw token、provider credential、internal route URL、downstream-only secret detail を含めてはならない
- **FR-010**: 成果物は、gateway runtime が既存の API application 契約に従う readiness signal を維持し、public GraphQL route 追加後も container/runtime 契約と矛盾してはならない
- **FR-011**: 成果物は、local / CI の双方で `graphql-gateway`、`command-api`、`query-api`、Firebase emulator を使う public GraphQL feature test を実行できるようにしなければならない
- **FR-012**: 成果物は、017 / 018 で定義した internal route や response 契約を gateway 実装が再利用することを後続実装者が追跡できるようにしなければならない
- **FR-013**: 成果物は、この feature の scope を `registerVocabularyExpression` mutation と `vocabularyCatalog` query の public binding に限定し、GraphQL schema 全体の拡張や worker 起点の operation 追加は deferred として明示しなければならない

### Key Entities *(include if feature involves data)*

- **UnifiedGraphqlRequest**: public endpoint で受ける operation document、variables、operation name、auth header、request correlation を束ねた request 単位
- **GatewayRoutingDecision**: public GraphQL operation を `command-api` または `query-api` のどちらへ渡すかを表す routing 判定
- **PublicMutationResult**: `registerVocabularyExpression` mutation の public response として返す accepted / reused-existing / failed family
- **PublicCatalogResult**: `vocabularyCatalog` query の public response として返す completed summary / status-only catalog payload
- **GatewayFailureCategory**: unsupported operation、validation failure、downstream unavailable、downstream auth failure などの public endpoint failure 表現
- **RequestCorrelationContext**: client request と downstream call を追跡するために gateway が伝播する correlation 情報

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が 10 分以内に、public GraphQL operation 2 件の routing 先と visible guarantee を 100% 対応付けられる
- **SC-002**: 第三者が 5 分以内に、gateway が伝播する情報と own してはいけない責務を説明できる
- **SC-003**: local / CI の feature test により、public GraphQL endpoint 経由で mutation 1 件と query 1 件を end-to-end で再現できる
- **SC-004**: unsupported operation、downstream unavailable、auth failure の failure category について、レビュー時の解釈ぶれが 0 件になる

## Assumptions

- initial slice は `registerVocabularyExpression` mutation と `vocabularyCatalog` query の public GraphQL binding に限定する
- initial slice の allowlist 外 operation は downstream へ best-effort 転送せず、gateway で `unsupported-operation` として扱う
- initial slice では 1 request 1 operation を前提とし、複数 operation document や operationName 未指定の曖昧な document は gateway で `ambiguous-operation` として扱う
- `command-api` と `query-api` の internal contract は既存実装を再利用し、gateway はそれらの前段 routing と public binding だけを担う
- backend 側の token verification / actor handoff は `command-api` と `query-api` がそれぞれ行い、gateway 自身は auth propagation に留める
- gateway は completed payload を合成せず、`command-api` の accepted / status handle と `query-api` の completed-only / status-only を public transport 上で維持する
- auth header は gateway が内容を再解釈せずに伝播し、request correlation は client 値を優先しつつ、欠落時のみ gateway が補完する
- GraphQL schema 全体の拡張、worker 起点 operation、cache / rate limit / alert policy、provider 固有 observability detail はこの feature の主要対象外とする
- topology と gateway 非所有責務は `specs/015-command-query-topology/` を正本参照とする
- command mutation 側の public binding は `specs/011-api-command-io-design/` と `specs/018-command-api-implementation/` を正本参照とする
- query 側の public binding は `specs/012-persistence-workflow-design/` と `specs/017-query-catalog-read/` を正本参照とする
- auth/session の behavioral contract は `specs/008-auth-session-design/`、runtime / readiness / container scope は `specs/016-application-docker-env/` を正本参照とする
