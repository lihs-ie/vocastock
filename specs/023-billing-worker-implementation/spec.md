# Feature Specification: Billing Worker Implementation

**Feature Branch**: `023-billing-worker-implementation`  
**Created**: 2026-04-21  
**Status**: Draft  
**Input**: User description: "6. billing-worker の実装を設計書に従って実装する。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 購入 artifact を authoritative subscription state へ反映できる (Priority: P1)

学習者として、購入した paid plan の artifact が verification adapter 越しに正しく検証され、
その結果だけが authoritative subscription state と entitlement snapshot へ反映されてほしい。
そうすることで、purchase が `verified` になるまで premium 機能が unlock されず、
完了した entitlement snapshot だけが UI の mirror へ流れることを保証したい。

**Why this priority**: `billing-worker` の最小価値は、submitted 済みの purchase artifact を
`verified` purchase state と paid subscription entitlement へ到達させ、confirmed でない
unlock を発生させないことにあるため。

**Independent Test**: 第三者が成果物だけを読み、submitted 済みの purchase artifact が
`queued` から `succeeded` へ進み、完了時だけ authoritative subscription state と
entitlement snapshot が切り替わることを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** actor に紐づく submitted purchase artifact が verification dispatch 済みである, **When** `billing-worker` がその artifact を成功裏に検証する, **Then** purchase state が `verified` へ進み、authoritative subscription state と entitlement snapshot が新しい bundle / quota profile で更新される
2. **Given** purchase verification 要求が `queued` または `running` である, **When** 利用者が read 側から状態を確認する, **Then** confirmed entitlement ではなく status-only だけが利用可能である
3. **Given** 既存の entitlement snapshot が存在する, **When** 新しい purchase verification 試行が完了前に失敗する, **Then** 既存の snapshot と mirror は維持され、premium unlock の根拠とはしない

---

### User Story 2 - 失敗、再試行、重複要求を一貫して扱える (Priority: P2)

運用担当者として、`billing-worker` が retryable failure、timeout、terminal failure、duplicate work を一貫して扱ってほしい。
そうすることで、同じ購入 artifact で subscription state が二重に切り替わったり、未確認 entitlement が confirmed 扱いされたり
することを防ぎたい。

**Why this priority**: billing workflow は非同期処理であり、失敗分類と idempotent handling が曖昧だと
012 の subscription workflow state machine と 010 の authority 境界が崩れるため。

**Independent Test**: 第三者が成果物だけを読み、retryable / terminal / duplicate / invalid-target の各ケースで
worker がどの状態へ遷移し、何を user-visible にしてはいけないかを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** purchase verification が retryable failure を返す, **When** `billing-worker` が failure を処理する, **Then** authoritative subscription state は paid へ進めず `retry-scheduled` へ遷移する
2. **Given** purchase verification が timeout または retry exhaustion に達する, **When** `billing-worker` が処理を終える, **Then** `failed-final` または `dead-lettered` へ遷移し、status-only failure として扱う
3. **Given** 同じ business key の purchase verification 要求が再送または重複到着する, **When** `billing-worker` がそれを処理する, **Then** authoritative subscription state や entitlement snapshot の重複切替を起こさない

---

### User Story 3 - store notification を取り込み subscription state を補正できる (Priority: P3)

backend 運用担当者として、App Store / Google Play の server notification を normalized 形式で取り込み、
authoritative subscription state と entitlement snapshot を補正できてほしい。そうすることで、端末経由の
purchase verification が遅れても、store 側の signal で `grace` / `expired` / `revoked` への遷移が正しく
反映されるようにしたい。

**Why this priority**: notification reconciliation が欠けると、`grace` 中の有料 entitlement 維持、
`expired` への free tier 戻し、`revoked` の hard-stop が信頼できなくなり、014 の access policy が破綻するため。

**Independent Test**: 第三者が成果物だけを読み、normalized notification が `queued` から `succeeded` へ進み、
subscription state と entitlement snapshot が補正される流れ、および notification 受信中に新規 paid entitlement が
付与されないことを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** normalized store notification を受信する, **When** `billing-worker` が notification を reconcile する, **Then** subscription state が `grace` / `expired` / `revoked` のいずれかに補正され、entitlement snapshot が再計算される
2. **Given** notification ingest が retryable failure を返す, **When** `billing-worker` が処理を継続する, **Then** 既存の mirror は維持され、新規 paid entitlement を付与しない
3. **Given** notification が malformed または signature invalid である, **When** `billing-worker` が処理する, **Then** `failed-final` または `dead-lettered` として扱い、status-only failure だけを残す

### Edge Cases

- 同じ purchase artifact に対する verification 要求が `queued` または `running` の間に再送される場合
- submitted purchase artifact が処理開始時点で subscription 不在、actor と ownership 不整合、または無効な product ID を参照している場合
- verification adapter が `verified` 相当を返しても、entitlement snapshot に必要な情報 (subscription term、plan code、grace window 等) が不完全な場合
- purchase state の `verified` 更新は成立したが、entitlement snapshot の commit が未完了の場合
- 既存の entitlement snapshot を保持したまま restore / reverify 相当の試行が timeout した場合
- provider / adapter の詳細 failure reason が user-facing status にそのまま漏れそうな場合
- worker restart 中に `running` work が残り、再開時に subscription state の二重遷移を起こしそうな場合
- notification の到着順序が逆転し、`grace → revoked` の後で `active` の古い notification を誤って反映しそうな場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: `specs/010-subscription-component-boundaries/data-model.md`、`specs/014-billing-entitlement-policy/data-model.md`、`docs/internal/domain/common.md`、`docs/internal/domain/service.md`
- **Invariants / Terminology**: `Subscription` は authoritative `active` / `grace` / `expired` / `pending-sync` / `revoked` を保持し、purchase state (`initiated` / `submitted` / `verifying` / `verified` / `rejected`)、entitlement bundle、quota profile、feature gate decision、usage limit、subscription state を混同しない
- **Async Lifecycle**: billing workflow は少なくとも `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を区別し、同一業務キーは idempotent に扱う
- **User Visibility Rule**: user-facing read は常に `query-api` 経由とし、confirmed entitlement snapshot だけを unlock 根拠にする。`queued`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` では status-only だけを許可する
- **Identifier Naming Rule**: identifier type は `XxxIdentifier` を維持し、aggregate 自身の識別子は `identifier`、関連参照は `subscription`、`actor`、`entitlementSnapshot` のような概念名を使う
- **External Ports / Adapters**: accepted command dispatch intake、`PurchaseVerificationPort`、`SubscriptionAuthorityPort`、`EntitlementRecalcPort`、`NotificationPort`、workflow state persistence、completed `BillingRecord` persistence、`Subscription.currentEntitlementSnapshot` handoff

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、`billing-worker` を purchase verification workflow と store notification reconciliation workflow 専用の worker deployment unit として定義しなければならない
- **FR-002**: 成果物は、actor-owned `Subscription` を対象とする submitted 済み purchase artifact を受け取り、workflow state を進行させなければならない
- **FR-003**: 成果物は、initial slice として store (App Store / Google Play) を source とする submitted 済み purchase artifact と normalized notification を処理対象に含めなければならない
- **FR-004**: 成果物は、completed `BillingRecord` (purchase state 更新 + entitlement snapshot) の保存と `Subscription.currentEntitlementSnapshot` の handoff が両方成立したときだけ success として扱わなければならない
- **FR-005**: 成果物は、`queued`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` のいずれでも、confirmed されていない entitlement snapshot を user-visible unlock 根拠として扱ってはならない
- **FR-006**: 成果物は、新しい verification 試行が success 前に失敗した場合、既存の `currentEntitlementSnapshot` を維持しなければならない
- **FR-007**: 成果物は、少なくとも `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を billing workflow の区別可能な状態として扱わなければならない
- **FR-008**: 成果物は、retryable failure、timeout、non-retryable failure を区別し、それぞれ retry scheduling または terminal failure へ写像しなければならない
- **FR-009**: 成果物は、同一業務キーの replay / duplicate work を idempotent に扱い、authoritative subscription state や entitlement snapshot の重複切替を起こしてはならない
- **FR-010**: 成果物は、処理開始時に subscription 不在、actor と ownership 不整合、または前提不正が判明した work item を completed `BillingRecord` なしの failure outcome として扱わなければならない
- **FR-011**: 成果物は、user-facing には status-only で十分な failure summary を保持できるようにしつつ、provider / adapter の詳細内部情報を completed payload や公開応答へ漏らしてはならない
- **FR-012**: 成果物は、`billing-worker` が query response、public GraphQL binding、explanation generation workflow、image generation workflow を own してはならないことを明示しなければならない
- **FR-013**: 成果物は、validation 経路として success、retryable failure、terminal failure、notification-reconciled の少なくとも 4 系統を再現可能にしなければならない
- **FR-014**: 成果物は、この feature の scope を purchase verification workflow と store notification reconciliation workflow に限定し、restore workflow、provider 固有最適化、store product catalog 管理、pricing change、tax、intro offer、coupon、public schema 拡張を deferred scope として明示しなければならない

### Key Entities *(include if feature involves data)*

- **BillingWorkItem**: submitted 済み purchase artifact または normalized notification を表す処理単位。target `Subscription`、actor、業務キー、起点理由 (`purchase-artifact-submitted` / `notification-received`)、現在の workflow state を持つ
- **BillingWorkflowState**: `queued` から terminal state までの lifecycle、attempt 回数、retry eligibility、timeout 判定を表す状態
- **SubscriptionAuthoritySnapshot**: user-visible にしてよい commit 済みの subscription state、entitlement bundle、quota profile、effective period を保持する snapshot
- **CurrentSubscriptionHandoff**: completed `SubscriptionAuthoritySnapshot` を `Subscription.currentEntitlementSnapshot` として採用するか、既存 current を維持するかの判断結果
- **BillingFailureSummary**: status-only 表示に使う failure 要約。retryable か terminal か、再試行余地があるかを示す

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が 10 分以内に、submitted purchase artifact が completed `BillingRecord` と `currentEntitlementSnapshot` handoff へ到達する条件を説明できる
- **SC-002**: validation で、success 1 系統、retryable failure 1 系統、terminal failure 1 系統、notification-reconciled 1 系統を再現しても、confirmed されていない entitlement snapshot が user-visible unlock と誤認されるケースが 0 件である
- **SC-003**: duplicate / replay work を含む検証で、同一業務要求に対する authoritative subscription state や entitlement snapshot の重複切替が 0 件である
- **SC-004**: レビュー時に `billing-worker`、`command-api`、`query-api`、`explanation-worker`、`image-worker` の責務境界について判断不能ケースが 0 件である

## Assumptions

- initial slice は既存の accepted purchase intake を再利用し、`startExplanation` 等のドメイン側 gate は upstream で判定済みとする
- standalone `requestRestorePurchase` command の public intake は、upstream acceptance が未実装なら後続 slice で接続してよい
- purchase verification adapter、store notification adapter の実実装は contract を満たす stub / mock でもよく、Apple / Google 固有 SDK 適用は後続 slice で扱う
- auth/session handoff、duplicate purchase 判定、quota / entitlement gate は worker ではなく upstream boundary で処理済みである
- user-visible read は `query-api` が継続して担当し、worker は completed entitlement snapshot を直接返さない
- restore workflow は 012 で別経路として定義されているため、本 feature の主要対象外とする
- deployment catalog と worker runtime 契約は `specs/015-command-query-topology/` および `specs/016-application-docker-env/` の正本を踏襲する

## Dependencies

- `specs/010-subscription-component-boundaries/` — subscription boundary 正本
- `specs/014-billing-entitlement-policy/` — product catalog、entitlement bundle、quota profile、feature gate matrix、state effect
- `specs/012-persistence-workflow-design/` — subscription workflow state machine、persistence allocation
- `specs/015-command-query-topology/` — worker deployment topology
- `specs/016-application-docker-env/` — container contract
- `specs/021-explanation-worker-implementation/` — worker implementation pattern reference

## Deferred Scope

- restore workflow の worker 側実装 (012 に別 runtime trace あり)
- Apple App Store / Google Play 固有 SDK の実 adapter 実装
- store product catalog 管理 / pricing change / tax / intro offer / coupon / family plan
- image workflow と `image-worker` の追加変更
- explanation workflow との cross-concern
- provider 固有最適化 / モデル選定 hardening
- public GraphQL operation の拡張
