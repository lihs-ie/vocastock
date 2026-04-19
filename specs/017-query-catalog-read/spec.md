# Feature Specification: Query Catalog Read

**Feature Branch**: `017-query-catalog-read`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "query-api の VocabularyCatalogProjection read 実装"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 語彙カタログを read できる (Priority: P1)

アプリ実装担当者として、`query-api` から `VocabularyCatalogProjection` を読めるようにしたい。そうすることで、通常利用画面の catalog が completed summary と status-only を混同せずに表示できるようにしたい。

**Why this priority**: catalog read は `query-api` の最小価値であり、これが無いと UI と read-side contract の接続確認が進まないため。

**Independent Test**: 第三者が成果物だけを読み、catalog read endpoint を呼んだときに completed summary を返す条件と status-only に倒す条件を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** `currentExplanation` を参照できる `VocabularyExpression` が projection に存在する, **When** catalog read を行う, **Then** その項目は completed summary を持つ catalog item として返る
2. **Given** `currentExplanation` が無い、または最新 workflow 状態が未完了 / 失敗である項目が存在する, **When** catalog read を行う, **Then** その項目は status-only catalog item として返り、provisional completed payload を含まない
3. **Given** 語彙項目が 0 件である, **When** catalog read を行う, **Then** endpoint は失敗せず空の catalog を返す

---

### User Story 2 - auth/session 境界を再利用して安全に読む (Priority: P2)

backend 実装担当者として、`query-api` の read が既存の token verification / actor handoff 契約を再利用して動いてほしい。そうすることで、read 側だけ別の認証解釈や actor 解決を持たずに済むようにしたい。

**Why this priority**: `query-api` は `command-api` と別 deployment unit であるため、auth/session の再利用契約を早めに固定しないと service 間で挙動差が出るため。

**Independent Test**: 第三者が成果物だけを読み、read endpoint が actor handoff を前提に動き、raw credential を response や app-facing payload へ流さないことを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** token verification と actor handoff が成功している, **When** catalog read を行う, **Then** `query-api` はその actor に紐づく read projection だけを返す
2. **Given** token verification、session 解決、または actor 解決に失敗する, **When** catalog read を行う, **Then** `query-api` は read payload を返さず、provider 固有 credential detail を露出しない失敗として扱う
3. **Given** catalog read endpoint の責務を確認する, **When** command/query separation を見る, **Then** write、workflow 起動、retry dispatch を持たないことを説明できる

---

### User Story 3 - UI 可視性ルールと projection lag を守る (Priority: P3)

モバイル実装担当者として、catalog read の response shape が `AppShell` と `VocabularyExpressionDetail` の境界に整合していてほしい。そうすることで、stale read や projection lag があっても completed と status-only の意味を壊さずに画面実装できるようにしたい。

**Why this priority**: `query-api` が UI 可視性ルールを破ると、後続の detail 画面や paywall 導線まで provisional payload を前提にしてしまうため。

**Independent Test**: 第三者が成果物だけを読み、catalog 項目が detail 本文ではなく summary / status を返すこと、および projection lag 中は status-only を維持することを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** command side write は完了したが read projection refresh が遅れている, **When** catalog read を行う, **Then** `query-api` は status-only を返してよく、completed と誤認させる provisional payload を返さない
2. **Given** `VocabularyExpressionDetail` が後続画面として存在する, **When** catalog read の payload を確認する, **Then** catalog では completed summary と status だけを返し、explanation detail 本文や image detail payload を含まない
3. **Given** 最新 workflow が `timed-out`、`failed-final`、または `dead-lettered` である, **When** catalog read を行う, **Then** 既存 completed result を維持できない限り status-only failure として扱う

### Edge Cases

- command 受理後に projection refresh が遅れ、authoritative write は進んでいるが catalog にはまだ completed summary を出せない場合
- `currentExplanation` が無いまま workflow 状態だけが `queued`、`running`、`retry-scheduled` に進んでいる場合
- latest workflow が `timed-out`、`failed-final`、`dead-lettered` のいずれかで、completed summary を新たに構成できない場合
- actor は解決できたが、その actor に対応する learner / catalog projection がまだ存在しない場合
- `pending-sync` の subscription / entitlement mirror が存在しても、catalog read が未確認 premium unlock を completed 情報として見せてしまいそうな場合
- catalog 項目は completed でも、detail 画面でしか見せてはいけない explanation 本文や image payload を catalog response に含めてしまいそうな場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None。`docs/internal/domain/*.md` の aggregate semantics 自体は変更しない
- **Invariants / Terminology**: `VocabularyCatalogProjection`、completed result、status-only、stale read、`currentExplanation`、actor handoff、token verification の語彙を既存正本に揃え、command/write の責務と混同しない
- **Async Lifecycle**: `query-api` は workflow を起動せず、latest workflow 状態と current pointer を読んで completed summary か status-only を返す。projection refresh は eventual でよいが、authoritative write より先に completed と見せてはならない
- **User Visibility Rule**: app-facing に返してよいのは catalog summary と status のみであり、未完了解説、intermediate payload、provisional completed payload を返してはならない
- **Identifier Naming Rule**: 既存の `XxxIdentifier`、`identifier`、関連概念名ベースの命名規則を維持し、transport 向けに `id` / `xxxId` を新たな正本語彙として導入しない
- **External Ports / Adapters**: token verification / actor handoff は `shared-auth::VerifiedActorContext` を completed auth/session context として再利用し、read projection source、subscription / entitlement mirror 読み取りを利用対象とする。worker、provider、write-side adapter は変更対象にしない

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、`query-api` に `VocabularyCatalogProjection` を返す read endpoint を定義しなければならない
- **FR-002**: 成果物は、catalog read の各項目について completed summary と status-only を区別し、`currentExplanation` が参照可能なときだけ completed summary を返さなければならない
- **FR-003**: 成果物は、`currentExplanation` が無い、または latest workflow が `queued`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` の場合に status-only を返さなければならない
- **FR-004**: 成果物は、projection lag 中に provisional completed payload を返してはならず、refresh 完了までは status-only を維持しなければならない
- **FR-005**: 成果物は、catalog response に explanation detail 本文、未完了 image payload、intermediate payload を含めてはならない
- **FR-006**: 成果物は、`query-api` が workflow 起動、retry dispatch、authoritative write を own しないことを endpoint 契約と scope で明示しなければならない
- **FR-007**: 成果物は、catalog read が既存の token verification / actor handoff 契約を再利用し、`shared-auth::VerifiedActorContext` を read 対象 actor の確定済み context として扱い、raw token、provider credential、session secret を app-facing payload に含めないことを定義しなければならない
- **FR-008**: 成果物は、token verification、session 解決、actor 解決の失敗時に read payload を返さず、internal auth detail と user-facing failure を分離しなければならない
- **FR-009**: 成果物は、catalog 項目が 0 件のときに失敗ではなく空の collection を返す規則を定義しなければならない
- **FR-010**: 成果物は、catalog read の response shape が `AppShell` の catalog 一覧と `VocabularyExpressionDetail` への遷移前提に整合し、detail 専用 payload を事前公開しないことを定義しなければならない
- **FR-011**: 成果物は、`pending-sync` など未確認の subscription / entitlement 情報を catalog read の completed 情報として扱ってはならないことを明示しなければならない
- **FR-012**: 成果物は、initial slice において read projection source を in-memory / stub で代替してよい一方、completed / status-only の visibility contract 自体は正本通りに維持しなければならない
- **FR-013**: 成果物は、015 / 012 / 013 / 008 / 016 のどの rule を再利用しているかを後続実装者が追跡できるよう、依存正本を明示しなければならない

### Key Entities *(include if feature involves data)*

- **VocabularyCatalogProjection**: `VocabularyExpression` の catalog 一覧を app-facing に返す projection
- **CatalogItemSummary**: catalog 一覧で返してよい completed summary または status-only summary を表す単位
- **CompletedCatalogItem**: `currentExplanation` 参照が成立したときだけ返せる completed summary 項目
- **StatusOnlyCatalogItem**: workflow 未完了、失敗、stale read、projection lag の間に返す status-only 項目
- **VerifiedActorContext**: token verification 後に `query-api` が read の対象 actor を確定するための completed auth/session context であり、017 では `shared-auth` の既存型をそのまま再利用する
- **ProjectionFreshness Rule**: authoritative write と read projection refresh の差分があるときに provisional completed payload を禁止する可視性ルール

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が 10 分以内に、catalog endpoint が completed summary を返す条件と status-only を返す条件を 100% 対応付けられる
- **SC-002**: projection lag、workflow failure、current pointer 不在の 3 系統について、completed と status-only の解釈ぶれがレビュー時に 0 件になる
- **SC-003**: 第三者が 5 分以内に、`query-api` が read のみを担い write / dispatch を持たないことを説明できる
- **SC-004**: 第三者が 10 分以内に、015 / 012 / 013 / 008 / 016 のどの rule が catalog read 実装へ反映されるかを追跡できる

## Assumptions

- 今回の feature は `query-api` の最小 read slice に限定し、`VocabularyCatalogProjection` 以外の projection は follow-on とする
- client からは既存の unified endpoint 越しに到達しうるが、この feature で実装・検証対象とする `/vocabulary-catalog` は `query-api` 内部の service route とし、gateway での公開 mapping は deferred とする
- initial slice では Firestore 実装まで必須にせず、in-memory / stub の read projection source を許可する
- `command-api`、worker、GraphQL schema 全体、write-side persistence schema は今回の対象外とする
- token verification / actor handoff の behavioral contract は `specs/008-auth-session-design/` を正本参照とする
- command/query separation と deployment topology は `specs/015-command-query-topology/` を正本参照とする
- completed / status-only の read model 条件は `specs/012-persistence-workflow-design/` を正本参照とする
- UI 可視性と `AppShell` / `VocabularyExpressionDetail` の境界は `specs/013-flutter-ui-state-design/` を正本参照とする
- runtime / readiness / container scope は `specs/016-application-docker-env/` を正本参照とする
