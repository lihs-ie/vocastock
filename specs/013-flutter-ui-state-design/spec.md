# Feature Specification: モバイル画面遷移 / UI 状態設計

**Feature Branch**: `013-flutter-ui-state-design`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "4. Flutter 画面遷移 / UI 状態設計書 mobile 実装に入るなら必須です 例: login、paywall、単語登録、生成中、失敗、完了、restore、grace、revoked どの画面がどの reader / gate を参照するかを固定します"

## Clarifications

### Session 2026-04-19

- Q: 画面遷移の最上位構造はどうするか → A: `Auth / Paywall / Restricted` は full-screen の別ルート群に置き、ログイン後の通常利用は `AppShell` 配下で扱う。tab は `AppShell` 内部の deferred implementation choice とする
- Q: 通常利用 shell 内の詳細画面の分割粒度はどうするか → A: `VocabularyExpression Detail` を状態集約画面にし、completed explanation と completed image には専用 detail 画面を持つ
- Q: `expired` と `revoked` の画面アクセス方針はどうするか → A: `expired` は通常 shell で completed result の閲覧を許可し、生成や有料操作だけ paywall へ戻す。`revoked` は full-screen の `Restricted` に送る
- Q: `subscription status` / `restore` 画面の配置はどうするか → A: 通常利用 shell から到達できる canonical な `subscription status` 画面を置き、paywall / `Restricted` からはその回復セクションへ導く

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 利用開始と利用制限の入口画面を固定する (Priority: P1)

設計担当者として、利用者がアプリを開いた直後にどの画面へ入るかを一貫して定義したい。これにより、
未ログイン、ログイン完了直後、課金制限中、利用停止中の入口が実装ごとにぶれない。

**Why this priority**: 入口画面が曖昧だと、auth/session、subscription、feature gate の境界が UI 上で崩れ、後続実装の前提が揃わないため。

**Independent Test**: 第三者が設計書だけを読み、未ログイン、session 解決中、利用可能、paywall 必要、`grace`、`expired`、`revoked` の入口画面と遷移条件を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 利用者が未ログインでアプリを開いた, **When** 入口導線を確認する, **Then** login 画面へ入り、認証成功後に actor handoff 完了を待ってから利用可能画面へ進む流れを説明できる
2. **Given** 利用者が有料機能の条件を満たしていない, **When** 制限導線を確認する, **Then** paywall 画面へ遷移し、機能解放判定は gate 読み取り結果だけを根拠にすることを説明できる
3. **Given** subscription state が `grace`、`expired`、または `revoked` である, **When** 入口状態を確認する, **Then** `grace` は継続利用画面、`expired` は通常 shell の completed result 閲覧を維持しつつ paywall へ戻す導線、`revoked` は利用停止または再認証 / 再購読導線へ入ることを説明できる

---

### User Story 2 - 単語登録から生成結果閲覧までの画面状態を固定する (Priority: P2)

実装担当者として、単語登録、解説生成、画像生成、完了結果閲覧の画面状態を一貫して定義したい。これにより、
pending / running / failed / completed の扱いと、どの reader を使って状態や結果を表示するかがぶれない。

**Why this priority**: 学習体験の中心は登録、解説閲覧、画像閲覧であり、ここで未完了生成物を見せたり reader 責務が混ざると仕様破綻を起こすため。

**Independent Test**: 第三者が設計書だけを読み、単語登録、解説状態表示、画像状態表示、完了済み result 閲覧を 10 分以内に screen / state / reader 単位で追跡できれば成立する。

**Acceptance Scenarios**:

1. **Given** 利用者が新しい `VocabularyExpression` を登録する, **When** 登録画面とその後の遷移を確認する, **Then** 登録入力、duplicate reuse、解説生成状態表示、完了済み解説表示の流れを説明できる
2. **Given** 解説生成または画像生成が進行中または失敗中である, **When** 詳細画面を確認する, **Then** status-only 表示に留め、未完了 payload を表示しないことを説明できる
3. **Given** 完了済み `Explanation` と `VisualImage` が存在する, **When** 閲覧画面を確認する, **Then** explanation detail、`Explanation.currentImage`、発音参照、画像 detail をどの reader で取得するかを説明できる

---

### User Story 3 - 課金回復と状態差分の画面を固定する (Priority: P3)

運用担当者として、paywall、restore、`pending-sync`、`grace`、`expired`、`revoked` の画面状態と回復導線を固定したい。これにより、
課金状態の揺れが起きても、何を表示し、どこまで操作を許可するかを一貫して説明できる。

**Why this priority**: 課金状態は purchase state、subscription state、entitlement、quota が絡み、回復導線が曖昧だと unlock 判定と UI 表示が崩れやすいため。

**Independent Test**: 第三者が設計書だけを読み、paywall、restore、`pending-sync`、`grace`、`expired`、`revoked` の表示差分と reader / gate 参照先を 5 分以内に割り当てられれば成立する。

**Acceptance Scenarios**:

1. **Given** 利用者が restore を実行したい, **When** paywall または `Restricted` 画面を確認する, **Then** canonical な `subscription status` 画面の回復セクションへ遷移し、restore 開始、照合中表示、成功時復帰、失敗時再試行導線を説明できる
2. **Given** subscription state が `pending-sync` である, **When** subscription 状態画面を確認する, **Then** 状態表示はできても premium unlock 確定とは扱わないことを説明できる
3. **Given** subscription state が `expired` または `revoked` である, **When** 利用制限画面を確認する, **Then** 継続閲覧、再購読導線、強制停止のどこまでを許可するかを説明できる

### Edge Cases

- login 成功直後に actor handoff が未完了で、利用可能画面へまだ進めない場合
- paywall 画面では purchase が `submitted` または `verifying` のままで、状態表示だけを継続する必要がある場合
- `pending-sync` は表示できるが、有料機能の unlock 根拠にはできない場合
- `grace` は通常の有料 entitlement を維持する一方、`expired` や `revoked` では一部または全部の機能を止める必要がある場合
- 単語登録 command は受理済みでも、read projection refresh が遅れて登録一覧にまだ反映されていない場合
- `Explanation` が完了しているが `VisualImage` は未生成または失敗中で、片方だけ completed 表示になる場合
- image 生成が `Sense` 指定で再試行されても、画面は `currentImage` の単一表示規則を維持する必要がある場合
- restore と notification reconciliation が進行中で、paywall と subscription 状態画面の文言を分ける必要がある場合
- `UsageAllowance` が尽きていて gate は deny だが、subscription state 自体は `active` の場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None。`docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md` は terminology source として参照し、aggregate semantics 自体は変更しない
- **Invariants / Terminology**: login 状態、actor handoff 完了状態、registration 状態、explanation generation 状態、image generation 状態、purchase state、subscription state、entitlement、usage allowance は別概念として維持し、1 つの UI state へ潰して表現しない
- **Async Lifecycle**: explanation / image generation、purchase verification、restore、notification reconciliation の runtime state は status 表示へ反映してよいが、completed result 公開条件は 012 の正本に従う
- **User Visibility Rule**: completed `Explanation` と completed `VisualImage` だけを本文 / 画像として表示し、pending / failed / timed-out / dead-letter 状態では status のみを表示する。未確認 premium unlock も completed entitlement として見せない
- **Identifier Naming Rule**: 画面設計でも識別子命名規約は変えず、`XxxIdentifier`、`identifier`、概念名参照の前提を維持する
- **External Ports / Adapters**: auth/session boundary output、command intake、`Explanation Reader`、`Visual Image Reader`、`Generation Status Reader`、`Subscription Status Reader`、`Entitlement Reader`、`Usage Allowance Reader`、`Subscription Feature Gate Reader`

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、少なくとも login、session resolving、home / catalog、vocabulary registration、`VocabularyExpression Detail`、completed explanation detail、completed image detail、paywall、subscription status、`SubscriptionStatus` 内の restore progress state、restricted access の画面または画面状態を定義しなければならない
- **FR-002**: 成果物は、未ログイン、actor handoff 完了待ち、利用可能、課金制限中、利用停止中の入口遷移条件を定義し、`Auth`、`Paywall`、`Restricted` を full-screen の別ルート群として通常利用 `AppShell` と分離しなければならない
- **FR-003**: 成果物は、各画面が参照する reader または gate を定義し、少なくとも actor/session handoff、generation status、explanation detail、image detail、subscription status、entitlement、usage allowance の参照先を明示しなければならない
- **FR-004**: 成果物は、画面が `Async Generation` や reconciliation workflow を直接起動するのではなく、command intake を経由して状態更新は reader 側で受ける前提を定義しなければならない
- **FR-005**: 成果物は、login 画面と logout 後の遷移について、008 の actor handoff 完了前に利用可能画面へ進めない規則を定義しなければならない
- **FR-006**: 成果物は、paywall 画面について purchase 開始、canonical な `subscription status` 画面の回復セクションへの導線、照合中、成功、失敗、再試行の状態を区別して定義しなければならない
- **FR-007**: 成果物は、`pending-sync` を状態表示してよいが premium unlock の根拠にしてはならない規則を paywall または subscription 状態画面へ反映しなければならない
- **FR-008**: 成果物は、`grace`、`expired`、`revoked` の UI 差分を定義し、`grace` は通常の有料 entitlement 維持、`expired` は通常利用 shell 内で completed result 閲覧を維持しつつ有料操作を paywall へ戻し、`revoked` は full-screen の `Restricted` へ送ることを示さなければならない
- **FR-009**: 成果物は、vocabulary registration 画面について、新規登録、duplicate reuse、登録後に `VocabularyExpression Detail` へ遷移して解説 / 画像の status を集約表示し、completed result 閲覧へ分岐する流れを定義しなければならない
- **FR-010**: 成果物は、`VocabularyExpression Detail` を generation status 集約画面として定義し、completed explanation 本文は専用 explanation detail 画面でのみ表示し、未完了 explanation payload を表示してはならない
- **FR-011**: 成果物は、completed image の閲覧を専用 image detail 画面でのみ扱い、`VocabularyExpression Detail` では `Explanation.currentImage` に従う status と current image 参照導線だけを示し、未完了 image payload や複数 current image を表示してはならない
- **FR-012**: 成果物は、通常利用 shell から到達できる canonical な `subscription status` 画面を定義し、paywall と `Restricted` からはその回復セクションへ遷移できる前提で、subscription state、entitlement、usage allowance、gate result を別概念として表示できるようにしなければならない
- **FR-013**: 成果物は、stale read が起きても authoritative write より先に completed と見せない規則と、その間の loading / status 表示方針を定義しなければならない
- **FR-014**: 成果物は、画面遷移設計の対象外として、widget、通知、アニメーション曲線、視覚スタイル詳細、ネイティブ OS 固有実装差分を deferred scope として明示しなければならない
- **FR-015**: 成果物は、009 の component boundary、010 の subscription boundary、011 の command I/O、012 の persistence / workflow 正本と矛盾しない画面責務と言葉で整理しなければならない
- **FR-016**: 成果物は、後続実装者が 10 分以内に「どの画面がどの reader / gate / command intake を参照するか」を追跡できる screen-to-source-of-truth 導線を提供しなければならない

### Key Entities *(include if feature involves data)*

- **Screen Definition**: 画面名、目的、入口条件、出口条件、主要状態、参照先を束ねた定義単位
- **Navigation State**: 未ログイン、解決中、利用可能、制限中、停止中などの画面遷移条件を表す状態単位
- **UI State Variant**: loading、status-only、completed、retryable failure、hard stop のような表示差分を表す単位
- **Reader Binding**: 各画面がどの reader、status source、gate を参照するかを示す対応単位
- **Gate Decision View**: entitlement と usage allowance の結果から、allow / limited / deny を UI に反映する表示判断単位
- **Recovery Flow**: restore、re-login、retry、re-subscribe などの回復導線を表す単位

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー参加者が 10 分以内に、主要画面とその入口条件、出口条件、参照する reader / gate を 100% 対応付けられる
- **SC-002**: login、単語登録から解説閲覧、paywall / restore の 3 つの主要フローを、第三者が 10 分以内に画面遷移として追跡できる
- **SC-003**: `pending-sync`、`grace`、`revoked`、generation failure、stale read の表示方針について、レビュー時の解釈ぶれが 0 件になる
- **SC-004**: 未完了生成物や未確認 premium unlock を completed として見せる画面が 0 件である

## Assumptions

- この feature は product code 実装ではなく、モバイル client の画面遷移と UI 状態を docs-first で定義する成果物を対象とする
- 画面の責務は 009 の `Presentation`、`Command Intake`、`Query Read`、`Actor/Auth Boundary`、subscription component の分離を前提に整理する
- 最上位の画面遷移は `Auth`、`Paywall`、`Restricted` を full-screen の別ルート群とし、ログイン後の通常利用は `AppShell` 配下で扱う。tab は `AppShell` 内部の deferred implementation choice とする
- login / logout / actor handoff の behavioral contract は 008 を正本とし、この feature では画面遷移への反映だけを扱う
- command request / response の shape は 011 を正本とし、この feature では command acceptance 後の画面状態と message 表示だけを扱う
- completed result と status-only の公開条件、stale read、workflow runtime state の意味は 012 を正本とする
- 課金状態の最終正本は backend authoritative subscription state であり、画面は subscription status、entitlement mirror、usage allowance、gate result を読むだけとする
- paywall からの purchase / restore 開始は許可してよいが、unlock 判定そのものは backend 正本に委ねる
- 通常利用 shell では `VocabularyExpression Detail` が status 集約画面となり、completed explanation と completed image の閲覧だけを専用 detail 画面へ分ける
- `expired` は通常利用 shell の completed result 閲覧を許可するが、premium 操作や生成再開は paywall 経由に戻し、`revoked` は full-screen の `Restricted` で扱う
- `subscription status` は通常利用 shell から到達できる canonical 画面とし、paywall と `Restricted` はその回復セクションへの full-screen 導線を持つ
- `restore progress` は独立画面ではなく `SubscriptionStatus` 内の明示 state として扱う
- widget、push notification、詳細な visual style token、animation spec、platform-native 分岐実装はこの feature の主要対象外とする
