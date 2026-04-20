# Feature Specification: Command API Implementation

**Feature Branch**: `018-command-api-implementation`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: "2. command-apiの実装を行う。既存の設計書に従って実装を行う"

## Clarifications

### Session 2026-04-20

- Q: dispatch failure 時の authoritative write の扱い → A: dispatch が失敗したら registration write も確定させず、`dispatch-failed` を返して全体を未成立として扱う
- Q: `text` の canonical normalization rule → A: 前後空白を除去し、小文字化し、連続する内部空白を 1 つに畳み込む
- Q: `startExplanation` 省略時の既定値 → A: 省略時は `true` とみなし、通常は explanation 開始対象にする

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 登録 command を受理できる (Priority: P1)

backend 実装担当者として、`command-api` から `registerVocabularyExpression` を受理できるようにしたい。そうすることで、語彙登録の write-side 入口を `query-api` や worker と混同せずに接続できるようにしたい。

**Why this priority**: `registerVocabularyExpression` は `command-api` の最小価値であり、これが無いと command 側の actor handoff、idempotency、accepted 応答の接続確認が進まないため。

**Independent Test**: 第三者が成果物だけを読み、登録 request を送ったときに `accepted` と `reused-existing` がどう返るか、また `status handle` がどう使われるかを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** completed actor handoff、`idempotencyKey`、新規の登録対象 text がある, **When** `registerVocabularyExpression` を受理する, **Then** `command-api` は `accepted`、target 参照、状態要約、`statusHandle`、必須 `message` を返す
2. **Given** 同一 actor に対して既存の正規化 text がある, **When** 別 key で同じ登録要求を送る, **Then** `command-api` は新規作成ではなく `reused-existing` と duplicate reuse 情報を返す
3. **Given** `startExplanation = false` が明示される, **When** 登録要求を受理する, **Then** `command-api` は登録は受け付けるが explanation 開始は既定動作から外した状態要約を返す
4. **Given** `startExplanation` が省略される, **When** 登録要求を受理する, **Then** `command-api` は `startExplanation = true` と同等に扱い、通常の explanation 開始対象として状態要約を返す

---

### User Story 2 - auth/session と idempotency を既存契約どおりに扱える (Priority: P2)

backend 実装担当者として、`command-api` が既存の token verification / actor handoff 契約と actor-scoped idempotency を再利用してほしい。そうすることで、command 側だけ別の認証解釈や replay 判定を持たずに済むようにしたい。

**Why this priority**: `command-api` は `query-api` と別 deployment unit であるため、auth/session と idempotency の解釈がずれると command/query の整合が崩れるため。

**Independent Test**: 第三者が成果物だけを読み、active handoff 成功、missing/invalid token、same-request replay、same-key conflict を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** token verification と actor handoff が成功している, **When** 登録 command を送る, **Then** `command-api` はその actor の command としてのみ受理する
2. **Given** token verification、session 解決、または actor 解決に失敗する, **When** 登録 command を送る, **Then** `command-api` は write を行わず、provider 固有 credential detail を露出しない失敗だけを返す
3. **Given** 同じ actor が同じ `idempotencyKey` と同じ正規化 request を再送する, **When** `command-api` が replay を判定する, **Then** 新しい dispatch を行わず既知の受付結果を返す
4. **Given** 同じ actor が同じ `idempotencyKey` だが異なる正規化 request を送る, **When** `command-api` が replay を判定する, **Then** `idempotency-conflict` を返して write を行わない

---

### User Story 3 - dispatch と visible guarantee を守ったまま運用できる (Priority: P3)

backend / mobile 実装担当者として、`command-api` が accepted 応答だけを返し、completed payload を返さず、dispatch failure では受付確定しないようにしたい。そうすることで、`query-api` の status-only / completed-only 規則と矛盾しない command 側の visible guarantee を保ちたい。

**Why this priority**: `command-api` が completed payload を返したり dispatch failure 後に accepted を返したりすると、015 / 012 / 013 で固定した可視性と durable handoff の前提が崩れるため。

**Independent Test**: 第三者が成果物だけを読み、accepted 応答、dispatch failure、completed payload 非返却、readiness 契約を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** authoritative write と dispatch が成立する, **When** 登録 command を受理する, **Then** `command-api` は completed result ではなく accepted / status handle を返す
2. **Given** authoritative write 前後で dispatch が成立しない, **When** 登録 command を処理する, **Then** `command-api` は `dispatch-failed` を返し、accepted を返さない
3. **Given** container runtime が `command-api` を起動する, **When** readiness を確認する, **Then** 既存の `HTTP readiness endpoint` 契約と矛盾しない

### Edge Cases

- 同一 actor が同じ `idempotencyKey` で `text` または `startExplanation` だけ異なる登録要求を再送する場合
- 別 key だが同じ正規化 text を送ったため、same-request replay ではなく duplicate registration reuse を返す場合
- `text` に大文字小文字差、前後空白、連続内部空白だけの差があるが、同一正規化 text として扱うべき場合
- `startExplanation` が省略され、既定値として explanation 開始対象に含めるべき場合
- `startExplanation = false` を指定した登録要求で、既存状態が `not-started` または `failed` でも explanation 開始を再開してはならない場合
- token verification は通るが ownership 解決または learner 解決に失敗し、write を開始してはならない場合
- authoritative write は可能でも dispatch が失敗した場合、registration write を確定させずに `dispatch-failed` を返し、accepted と `pending` を返してはならない場合
- `command-api` の応答に explanation 本文、image payload、premium unlock 確定情報など completed payload を含めてしまいそうな場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None。`docs/internal/domain/*.md` の aggregate semantics 自体は変更しない
- **Invariants / Terminology**: `registerVocabularyExpression`、`accepted`、`reused-existing`、`statusHandle`、`duplicateReuse`、`idempotency-conflict`、`dispatch-failed`、completed actor handoff の語彙を既存正本に揃え、query / worker の責務と混同しない
- **Async Lifecycle**: `command-api` は command acceptance、idempotency、authoritative write、workflow dispatch 起点だけを担い、長時間処理本体は worker へ委譲する。dispatch failure では accepted を返さず、registration write も確定させず、completed payload も返さない
- **User Visibility Rule**: `command-api` が返してよいのは accepted / reused-existing、target 参照、状態要約、`statusHandle`、必須 `message` に限り、未完了・完了済みを問わず generated payload 本体を返してはならない
- **Identifier Naming Rule**: 既存の `XxxIdentifier`、`identifier`、関連概念名ベースの命名規則を維持し、transport 向けに `id` / `xxxId` を新たな正本語彙として導入しない
- **External Ports / Adapters**: token verification / actor handoff は `shared-auth::VerifiedActorContext` 相当の completed context を再利用し、authoritative write store、actor-scoped idempotency store、workflow dispatch port を利用対象とする。`query-api`、worker、gateway は変更対象にしない

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、`command-api` に `registerVocabularyExpression` を受け付ける internal command route を定義しなければならない
- **FR-002**: 成果物は、登録 command request が少なくとも completed actor handoff、`idempotencyKey`、`text`、任意の `startExplanation` を受け取り、`startExplanation` 省略時は `true` を既定値として扱うことを定義しなければならない
- **FR-003**: 成果物は、新規登録成功時に `accepted`、target 参照、状態要約、`statusHandle`、必須 `message` を返さなければならない
- **FR-004**: 成果物は、同一 actor 内で既存の正規化 text がある場合に新規作成を行わず、`reused-existing` と duplicate reuse 情報を返さなければならない。正規化 text は前後空白除去、小文字化、連続内部空白の 1 文字化を適用した canonical text とする
- **FR-005**: 成果物は、same-request replay を actor 単位の `idempotencyKey` と正規化 request で判定し、同一 replay では新しい dispatch を行わず既知の受付結果を返さなければならない
- **FR-006**: 成果物は、同じ actor に対して同じ `idempotencyKey` だが異なる正規化 request が来た場合に `idempotency-conflict` を返し、write を行ってはならない
- **FR-007**: 成果物は、token verification / actor handoff の既存 behavioral contract を再利用し、`shared-auth::VerifiedActorContext` を command 対象 actor の completed context として扱わなければならない
- **FR-008**: 成果物は、token verification、session 解決、actor 解決の失敗時に write を行わず、raw token、provider credential、session secret を response に含めてはならない
- **FR-009**: 成果物は、`startExplanation = false` を `registerVocabularyExpression` にのみ許可し、その場合は explanation 開始を抑止した状態要約を返さなければならない。`startExplanation` 省略時は explanation 開始対象として扱わなければならない
- **FR-010**: 成果物は、authoritative write と workflow dispatch が成立した場合だけ accepted 応答を返し、dispatch failure 時は `dispatch-failed` を返して accepted を返してはならず、registration write も確定させてはならない
- **FR-011**: 成果物は、`command-api` が completed explanation payload、image payload、query projection payload、premium unlock 確定情報を返してはならないことを定義しなければならない
- **FR-012**: 成果物は、initial slice において authoritative write store、idempotency store、dispatch port を in-memory / stub で代替してよい一方、受理規則、visible guarantee、error 契約自体は既存正本どおりに維持しなければならない
- **FR-013**: 成果物は、`command-api` の runtime が既存の `HTTP readiness endpoint` 契約を維持し、新しい command route 追加後も container smoke と矛盾しないことを定義しなければならない
- **FR-014**: 成果物は、007 / 011 / 012 / 015 / 016 のどの rule を再利用しているかを後続実装者が追跡できるよう、依存正本を明示しなければならない

### Key Entities *(include if feature involves data)*

- **RegisterVocabularyExpressionRequest**: completed actor handoff、`idempotencyKey`、`text`、任意の `startExplanation` を持つ登録要求であり、`text` は canonical comparison 用に前後空白除去、小文字化、連続内部空白の 1 文字化を受け、`startExplanation` 省略時は `true` として解釈される
- **AcceptedCommandResult**: `accepted` または `reused-existing`、target 参照、状態要約、`statusHandle`、必須 `message` を持つ成功応答
- **DuplicateReuseResult**: duplicate registration 時に既存 target、現在状態、再開有無の要約を返す補足情報
- **VerifiedActorContext**: token verification 後に `command-api` が対象 actor を確定するための completed auth/session context であり、018 では `shared-auth` の既存型を再利用する
- **IdempotencyDecision**: same-request replay、duplicate reuse、`idempotency-conflict` を区別する判定結果
- **DispatchConsistency Rule**: authoritative write と workflow dispatch が不整合な accepted を生まないための受付規則

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が 10 分以内に、登録 command の request 必須項目と accepted 応答項目を 100% 対応付けられる
- **SC-002**: same-request replay、duplicate reuse、`idempotency-conflict` の 3 ケースについて、レビュー時の解釈ぶれが 0 件になる
- **SC-003**: 第三者が 5 分以内に、`command-api` が completed payload を返さず accepted / status handle だけを返す理由を説明できる
- **SC-004**: 第三者が 10 分以内に、007 / 011 / 012 / 015 / 016 のどの rule が `command-api` 実装へ反映されるかを追跡できる

## Assumptions

- 今回の feature は `command-api` の最小 write slice に限定し、initial scope は `registerVocabularyExpression` の実装とする
- client からは既存の unified endpoint 越しに到達しうるが、この feature で実装・検証対象とする route は `command-api` 内部の service route とし、gateway での公開 binding は deferred とする
- initial slice では Firestore などの本実装まで必須にせず、authoritative write store、idempotency store、dispatch port の in-memory / stub 代替を許可する
- dispatch failure は registration write rollback を伴う未成立として扱い、partial success を残さない前提とする
- duplicate reuse と idempotency replay の比較対象 text は、前後空白除去、小文字化、連続内部空白の 1 文字化を適用した canonical text とする
- `requestExplanationGeneration`、`requestImageGeneration`、`retryGeneration`、worker 本体、`query-api`、GraphQL schema 全体は今回の対象外とする
- command semantics は `specs/007-backend-command-design/`、request / response / error / idempotency 契約は `specs/011-api-command-io-design/` を正本参照とする
- authoritative write / idempotency record / workflow ordering は `specs/012-persistence-workflow-design/` を正本参照とする
- command/query separation と accepted / status handle visible guarantee は `specs/015-command-query-topology/` を正本参照とする
- runtime / readiness / container scope は `specs/016-application-docker-env/` を正本参照とする
