# Feature Specification: API / Command I/O 設計

**Feature Branch**: `011-api-command-io-design`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "1. API / Command I/O 設計書 何を入口にするかを固定する文書です 例: request/response DTO、error code、actor handoff、idempotency key、認証済み actor の受け方 007 は command の責務境界を定義していますが、実際の入出力 shape はまだ弱いです"

## Clarifications

### Session 2026-04-19

- Q: command request に含める completed actor handoff の最小 shape → A: `actor reference`、`session reference`、`auth account reference` を受け取る
- Q: `idempotencyKey` の一意性スコープ → A: `actor` 単位で一意にする
- Q: `retryGeneration` の対象範囲 → A: `failed` の retry と `succeeded` の regenerate を 1 つの command で扱い、mode または reason で区別する
- Q: response における `message` の扱い → A: success / error の両方で `message` を必須にする

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 主要 command の入出力を固定する (Priority: P1)

実装担当者として、主要 command の request / response shape を同じ前提で参照したい。これにより、
client、backend、reviewer が command ごとに別の入出力解釈を持たずに実装へ進める。

**Why this priority**: command の責務境界だけでは、実際に何を受け取り何を返すかが揺れやすく、
後続の実装とレビューがぶれやすいため。

**Independent Test**: 第三者が設計書だけを読み、主要 command の request 必須項目、任意項目、
success response の shape、duplicate 時の返却内容を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 実装担当者が `registerVocabularyExpression` の入出力を確認したい, **When** 設計書を読む, **Then** actor handoff が `actor reference`、`session reference`、`auth account reference` を含む completed input であること、登録対象、開始抑止、idempotency key、success / error の両方で必須の response message を説明できる
2. **Given** 実装担当者が `requestExplanationGeneration`、`requestImageGeneration`、`retryGeneration` の入出力を確認したい, **When** 設計書を読む, **Then** 各 command の対象参照、前提条件、success response と、`retryGeneration` が retry / regenerate を明示 `mode` で区別することを説明できる
3. **Given** 同一学習者内で重複登録が発生する, **When** response 契約を見る, **Then** 新規作成ではなく既存対象参照と状態要約を返す shape を説明できる

---

### User Story 2 - error / idempotency / ownership の規則を固定する (Priority: P2)

実装担当者として、command の失敗時応答、再送時の扱い、actor と所有者整合の確認点を固定したい。
これにより、同じ失敗や再試行が実装ごとに別扱いになることを防ぎたい。

**Why this priority**: request / response shape だけあっても、error code、idempotency、ownership check が
曖昧だと API / command contract としては不十分だから。

**Independent Test**: 第三者が設計書だけを読み、ownership mismatch、not-ready、duplicate resend、
dispatch failure、validation failure の各ケースで何を返すかを一貫して説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** actor が対象 resource の所有者ではない, **When** command error 契約を見る, **Then** 拒否コードと返してよい要約情報を説明できる
2. **Given** 同じ actor から同じ idempotency key で command が再送される, **When** idempotency 規則を見る, **Then** 新規受付せず既知の受付結果または既存状態を返し、同じ actor に対する異なる本文は conflict として拒否する方針を説明できる
3. **Given** workflow dispatch が失敗する, **When** failure contract を見る, **Then** `pending` を確定せず失敗応答だけを返す規則を説明できる

---

### User Story 3 - client / auth / workflow との接続境界を固定する (Priority: P3)

設計担当者として、API / command I/O がどこまでを contract として持ち、どこから先を別正本に委ねるかを
整理したい。これにより、transport、workflow payload、query model まで同じ文書に混ぜずに済む。

**Why this priority**: command I/O 設計は auth/session、workflow、query、subscription gate と接続するため、
境界が曖昧なままだと後続 feature の責務まで再定義してしまうため。

**Independent Test**: 第三者が設計書だけを読み、どの情報が actor handoff 由来で、どの情報が command response に出せて、
どの詳細が deferred scope なのかを 5 分以内に割り当てられれば成立する。

**Acceptance Scenarios**:

1. **Given** auth/session と command の接続点を確認したい, **When** 設計書を読む, **Then** 認証済み actor の受け方と raw credential 非露出の境界を説明できる
2. **Given** workflow 実行詳細や provider 固有エラーを確認したい, **When** scope を確認する, **Then** command I/O で公開する情報と deferred scope の情報を区別できる

### Edge Cases

- actor handoff は成功しているが、対象 resource の所有者整合に失敗する場合
- `registerVocabularyExpression` で duplicate registration が発生し、既存状態が `not-started`、`failed`、`pending`、`running` のいずれかである場合
- `requestImageGeneration` が完了済み `Explanation` を持たない target に対して送られる場合
- 同じ idempotency key で request 本文が異なる再送が来る場合
- client には success に見えるが、workflow dispatch failure により受付不成立となる場合
- internal failure detail は保持したいが、client へは要約 error だけを返すべき場合
- `pending-sync` の subscription / entitlement 状態が存在しても、command I/O は未確認 unlock 情報を返してはならない場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None。`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/learning-state.md` は terminology source として参照し、aggregate semantics 自体は変更しない
- **Invariants / Terminology**: `Learner`、`VocabularyExpression`、`Explanation`、`VisualImage`、`Sense`、`RegistrationStatus`、`ExplanationGenerationStatus`、`ImageGenerationStatus`、subscription / entitlement は別概念として維持し、command I/O では状態要約だけを返す
- **Async Lifecycle**: command request は受理、拒否、重複再利用、dispatch failure を区別し、長時間処理の本体は別 workflow 境界へ委譲する。未完了成果物そのものは response に含めない
- **User Visibility Rule**: client に返してよいのは target 参照、状態要約、受理結果、error code、user-facing message に限り、未完了解説や未完了画像 payload は返さない
- **Identifier Naming Rule**: 識別子型は `XxxIdentifier`、集約自身の識別子は `identifier`、関連参照は概念名で表現し、`id` / `xxxId` / `xxxIdentifier` を導入しない
- **External Ports / Adapters**: actor handoff は `specs/008-auth-session-design/`、command semantics は `specs/007-backend-command-design/`、component boundary は `specs/009-component-boundaries/`、subscription / entitlement gate 影響は `specs/010-subscription-component-boundaries/` を正本として参照する

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、少なくとも `registerVocabularyExpression`、`requestExplanationGeneration`、`requestImageGeneration`、`retryGeneration` の canonical request / response DTO を定義し、`retryGeneration` では retry / regenerate の区別入力を持たなければならない
- **FR-002**: 成果物は、各 request DTO について必須項目、任意項目、actor handoff 項目、target 参照項目、idempotency key を区別して定義し、`retryGeneration` には retry / regenerate を区別する明示 `mode` を含めなければならない
- **FR-003**: 成果物は、各 success response DTO について受理結果、target 識別情報、状態要約、duplicate reuse 情報、必須の user-facing message を定義しなければならない
- **FR-004**: 成果物は、duplicate registration 時に新規作成を行わず、既存 `VocabularyExpression` 参照と現在状態を返す response shape を定義しなければならない
- **FR-005**: 成果物は、error response contract として少なくとも validation failure、ownership mismatch、not-ready、duplicate idempotency conflict、dispatch failure、internal failure の区別を定義しなければならない
- **FR-006**: 成果物は、error code、必須の user-facing message、internal-only detail を別概念として整理し、client に返す範囲を定義しなければならない
- **FR-007**: 成果物は、actor handoff が auth/session 由来の completed output だけを受け取り、少なくとも `actor reference`、`session reference`、`auth account reference` を含み、raw token、provider credential、session secret を command request に含めない規則を定義しなければならない
- **FR-008**: 成果物は、idempotency key を actor 単位で一意に扱い、同じ actor に対する key 一致時に何を同一要求とみなし、同じ key で本文が異なる場合にどう拒否するかを定義しなければならない
- **FR-009**: 成果物は、workflow dispatch failure 時に command 全体を不成立とし、受付済み `pending` 状態を success response として返さない規則を定義しなければならない
- **FR-010**: 成果物は、command I/O が返す状態要約と、workflow / provider / persistence の内部詳細を分離しなければならない
- **FR-011**: 成果物は、command I/O で公開する ownership check の結果と、内部でのみ使う authorization detail を区別しなければならない
- **FR-012**: 成果物は、transport 固有 schema、workflow payload 内部 schema、query response schema、provider 固有 error detail を deferred scope として明示しなければならない
- **FR-013**: 成果物は、`startExplanation = false` のような開始抑止入力がどの command request で許可されるかを定義しなければならない
- **FR-014**: 成果物は、subscription / entitlement が `pending-sync` など未確認状態でも、command response が premium unlock を確定情報として返さない規則を明示しなければならない
- **FR-015**: 成果物は、後続実装者が 007 / 008 / 009 / 010 のどの成果物を前提にすべきかを入出力 contract 観点で示さなければならない

### Key Entities *(include if feature involves data)*

- **CommandRequestEnvelope**: command 名、actor handoff、idempotency key、target 参照、request body を束ねる request 単位
- **CommandResponseEnvelope**: 受理結果、target 識別情報、状態要約、必須の user-facing message を束ねる response 単位
- **ActorHandoffInput**: `actor reference`、`session reference`、`auth account reference` を含む completed handoff を、raw credential なしで command 境界へ渡す入力単位
- **CommandError**: error code、必須の user-facing message、internal detail classification を持つ失敗表現
- **IdempotencyKey Rule**: actor 単位で一意に扱い、同一要求判定と conflict 判定に使う識別単位。`retryGeneration` では retry / regenerate mode を含めて判定する
- **StateSummary**: `RegistrationStatus`、`ExplanationGenerationStatus`、`ImageGenerationStatus` など client へ返してよい要約状態
- **DuplicateReuseResult**: duplicate request 時に既存 target を返す場合の response 情報

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー参加者が 10 分以内に、4 つの主要 command の request 必須項目と success response 項目を 100% 対応付けられる
- **SC-002**: ownership mismatch、not-ready、dispatch failure、idempotency conflict の返却規則について、レビュー時の解釈ぶれが 0 件になる
- **SC-003**: client に返してよい要約情報と internal-only detail の境界について、第三者が 5 分以内に説明できる
- **SC-004**: 007 / 008 / 009 / 010 との接続点に関する入出力上の矛盾がレビュー時に 0 件である

## Assumptions

- この feature は product code 実装ではなく、API / command I/O の docs-first 設計成果物を対象とする
- canonical command 名は 007 の command 定義を引き継ぐ
- actor handoff の正本は 008 にあり、011 では command request に入る completed handoff の最小 shape を `actor reference`、`session reference`、`auth account reference` として整理する
- command I/O は transport 非依存の contract とし、HTTP / GraphQL / RPC など具体 transport binding は別 feature で扱う
- command response は未完了 payload を返さず、target 参照、状態要約、必須の user-facing message だけを返す
- duplicate request や retry request の判定は actor 単位で一意な idempotency key と業務対象参照の組み合わせで行い、`retryGeneration` では retry / regenerate の区別も判定要素に含める
- workflow 実行詳細、provider 固有失敗理由、永続化 schema、query response shape はこの feature の主要対象外とする
- subscription / entitlement に関する最終 unlock 可否は 010 の正本に委ね、011 では command I/O へ露出する情報境界だけを扱う
