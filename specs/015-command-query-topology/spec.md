# Feature Specification: Command/Query Deployment Topology

**Feature Branch**: `015-command-query-topology`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "Command Intake と Query Read を MVP から別 Cloud Run service に分離する deployment topology を定義し、正本へ反映する変更箇所を整理する"

## Clarifications

### Session 2026-04-19

- Q: `command-api` / `query-api` 分離後の auth/session 検証配置 → A: `command-api` と `query-api` がそれぞれ backend で token 検証と actor handoff を行い、契約は shared module で揃える
- Q: command 直後の projection lag の扱い → A: `command-api` は accepted / status handle を返し、`query-api` は projection 反映までは status-only を返す
- Q: client から見た API endpoint の分け方 → A: client からは常に 1 つの unified GraphQL endpoint に見せ、内部だけ command/query を分離する
- Q: unified GraphQL endpoint の実体をどこに置くか → A: `graphql-gateway` を独立 deployment unit として置き、client はそこだけを呼ぶ

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Command と Query の配置先を分離する (Priority: P1)

設計担当者として、`Command Intake` と `Query Read` を MVP から別 deployment unit に分離したい。そうすることで、write と read の責務混在を避けたまま、実装開始時の service 境界を迷わず決められるようにしたい。

**Why this priority**: `Command Intake` と `Query Read` の同居を許すと、以後の API、認可、read model、運用責務が再び混ざるため。

**Independent Test**: 第三者が成果物だけを読み、MVP 構成で command 側 deployment unit と query 側 deployment unit が別であり、それぞれの責務差分を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** MVP の backend topology を確認する, **When** command 系と query 系の配置を見る, **Then** `Command Intake` と `Query Read` は別 deployment unit に割り当てられている
2. **Given** 任意の backend responsibility を確認する, **When** 配置先を判断する, **Then** command acceptance / idempotency / workflow dispatch 起点は command 側、completed result / status / entitlement read は query 側へ一意に割り当てられる

---

### User Story 2 - 非同期 worker と外部境界の配置を固定する (Priority: P2)

実装担当者として、workflow worker、auth/session 境界、subscription reconciliation、external adapter がどの deployment unit に属するかを把握したい。そうすることで、backend service、worker、managed service の切れ目を一貫した前提で実装に落とせるようにしたい。

**Why this priority**: command/query を分けても、workflow や auth/session の配置が曖昧なままだと、結局 service 間責務が再び混ざるため。

**Independent Test**: 第三者が成果物だけを読み、auth/session handoff、explanation/image workflow、subscription reconciliation、adapter 呼び出しの配置先を 10 分以内に追跡できれば成立する。

**Acceptance Scenarios**:

1. **Given** explanation 生成、image 生成、subscription reconciliation の flow を確認する, **When** 実行主体を見る, **Then** command/query service と独立した async worker deployment unit に割り当てられている
2. **Given** auth/session や external adapter の責務を確認する, **When** 配置先を見る, **Then** client、backend service、worker、managed service のどこに属するかが矛盾なく説明できる

---

### User Story 3 - 正本更新箇所と deferred scope を明示する (Priority: P3)

レビュー担当者として、この deployment topology 変更をどの正本へ反映すべきか、何が今回の in-scope で何が deferred かを一覧で確認したい。そうすることで、ADR、stack、component、API、workflow 文書の更新順序を誤らずに進められるようにしたい。

**Why this priority**: topology 案だけがあっても、どの source-of-truth を更新するかが曖昧だと設計が再び分岐するため。

**Independent Test**: 第三者が成果物だけを読み、どの正本を更新するか、どの feature artifact を再同期するか、何を deferred に残すかを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** source-of-truth を確認する, **When** command/query 分離の反映先を見る, **Then** `docs/external/adr.md`、`docs/external/requirements.md`、関連 spec package の更新箇所が一覧化されている
2. **Given** transport binding や gateway 構成などの詳細論点を確認する, **When** scope 境界を見る, **Then** 今回固定する deployment topology と deferred に残す実装詳細が区別されている

### Edge Cases

- `Command Intake` と `Query Read` を別 deployment unit にしても、client からは単一 endpoint に見せたい場合に、どこまでを topology scope に含めるか
- command 受理直後に query を読むと projection lag がある場合に、user-visible に何を保証するか
- command service と query service の両方が auth/session handoff を使う場合に、token verification と actor normalization の責務が重複して見える場合
- workflow worker が query 向け read model を直接返したり、query service が workflow 起動を持ったりして deployment 境界を越境する場合
- subscription gate と usage allowance を query 側で返しつつ、verification workflow は別 worker に置く構成で、state source-of-truth と mirror の境界が誤読される場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None
- **Invariants / Terminology**: frequency、sophistication、proficiency、登録状態、explanation/image generation state、purchase state、subscription state、entitlement、usage allowance は deployment 分離によって統合してはならない。`Command Intake`、`Query Read`、`Async Generation`、`Async Subscription Reconciliation` の責務語彙は既存正本と整合させる
- **Async Lifecycle**: command service は受理と dispatch 起点のみを持ち、workflow worker は `pending` / `running` / `succeeded` / `failed` と retry / timeout / fallback を担う。query service は completed result と status-only read だけを返し、workflow 起動を持たない
- **User Visibility Rule**: deployment 分離後もユーザーに見せてよい生成物は completed result のみとし、pending / failed は状態表示のみに留める
- **Identifier Naming Rule**: identifier 型は `XxxIdentifier`、aggregate 自身の識別子は `identifier`、関連参照は概念名で表現し、transport / deployment 名称でも `id` / `xxxId` を新たな正本語彙として導入しない
- **External Ports / Adapters**: auth/session handoff、validation、generation provider、asset storage / access、pronunciation media、mobile storefront、purchase verification、store notification の配置先と caller-owned adapter 境界を整理対象とする

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、MVP 構成において `Command Intake` と `Query Read` を別 backend deployment unit として定義しなければならない
- **FR-002**: 成果物は、command 側 deployment unit の責務として command acceptance、idempotency、authorization 済み write 受理、workflow dispatch 起点を定義しなければならない
- **FR-003**: 成果物は、query 側 deployment unit の責務として completed result、status-only 情報、subscription read、entitlement mirror、usage allowance、feature gate result の返却を定義しなければならない
- **FR-004**: 成果物は、explanation workflow、image workflow、subscription reconciliation を command/query service とは独立した async worker deployment unit として整理しなければならない
- **FR-005**: 成果物は、client、auth/session boundary、backend service、worker、managed service の間で、どの component がどこへ配置されるかを一意に示さなければならない
- **FR-006**: 成果物は、command service から query service への反映が direct call ではなく durable state handoff を前提とすることを示し、`command-api` は accepted / status handle を返し、`query-api` は projection 反映までは status-only を返す visible guarantee を定義しなければならない
- **FR-007**: 成果物は、`command-api` と `query-api` の両方が backend で token 検証と actor handoff を行える前提で整理しつつ、Firebase token や provider credential を app core や query payload へ直接渡さない rule を維持しなければならない
- **FR-008**: 成果物は、`Entitlement Policy`、`Subscription Feature Gate`、`Usage Metering / Quota Gate` を独立 deployment unit とせず、backend service / worker 内部 policy として扱うかたちで配置を示さなければならない
- **FR-009**: 成果物は、物理 deployment topology と source-of-truth 更新箇所一覧を結びつけ、`docs/external/adr.md`、`docs/external/requirements.md`、関連 spec package のどこを更新すべきかを示さなければならない
- **FR-010**: 成果物は、client からは unified GraphQL endpoint を維持しつつ、内部 deployment では command/query を分離する前提を示さなければならない
- **FR-011**: 成果物は、client が呼ぶ unified GraphQL endpoint の実体を `graphql-gateway` という独立 deployment unit として定義し、`command-api` / `query-api` の前段 routing だけを担わせなければならない
- **FR-012**: 成果物は、今回 fixed とする deployment topology と、deferred scope に残す transport binding、service 内部 module 構成、運用細部を区別しなければならない

### Key Entities *(include if feature involves data)*

- **Deployment Unit**: client、backend command service、backend query service、workflow worker、managed service など、物理的に分離して配置・運用する単位
- **GraphQL Gateway**: client から見える unified GraphQL endpoint を提供し、内部で `command-api` / `query-api` へ routing する前段 deployment unit
- **Topology Allocation**: 各 architecture component をどの deployment unit へ配置するかを示す対応関係
- **Durable State Handoff**: command 側の authoritative write から query 側の read projection へ反映するための永続化ベースの受け渡し
- **Visibility Guarantee**: deployment 分離後も、completed result と status-only をどの service がどう返すかを固定する rule
- **Source-of-Truth Update Map**: deployment topology 変更を反映するために更新すべき正本文書と spec package の一覧

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が 10 分以内に、主要 component の 100% について client、command service、query service、worker、managed service のいずれへ配置されるか説明できる
- **SC-002**: `Command Intake` と `Query Read` の責務差分、および両者が別 deployment unit である理由を、第三者が 5 分以内に説明できる
- **SC-003**: explanation、image、subscription の 3 主要 async flow について、trigger、worker、durable state、user-visible read の流れを 10 分以内に追跡できる
- **SC-004**: source-of-truth 更新箇所一覧を使って、更新対象文書の漏れがレビュー時に 0 件になる

## Assumptions

- 現在の target stack では backend deployment unit は Cloud Run service または Cloud Run worker として実体化する
- `Command Intake` と `Query Read` は同じ repository や shared library を使ってよいが、MVP から同一 deployment service へ同居させない
- client から見た API endpoint は unified GraphQL endpoint を維持し、内部 deployment だけを command/query 分離する
- unified GraphQL endpoint の実体は `graphql-gateway` という独立 deployment unit とし、client は gateway のみを呼ぶ
- durable state handoff の具体製品や schema 詳細は既存の stack / persistence feature を前提とし、この feature では物理 topology と責務境界だけを扱う
- command 直後の read-after-write 強整合は MVP 必須にせず、projection 反映までは status-only を返す
- `command-api` と `query-api` はそれぞれ backend で token 検証と actor handoff を行い、auth/session の behavioral contract は shared module 相当で揃える
- auth/session の behavioral contract は `specs/008-auth-session-design/`、component taxonomy は `specs/009-component-boundaries/`、subscription authority は `specs/010-subscription-component-boundaries/`、command I/O は `specs/011-api-command-io-design/`、persistence / workflow runtime は `specs/012-persistence-workflow-design/` を正本参照とする
