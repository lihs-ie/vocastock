# コンポーネント

## 主軸アーキテクチャ

- 主軸はオニオンアーキテクチャとする
- `Domain Core` と `Application Coordination` は内側基盤として明示し、外から見える component catalog には混ぜない
- 外から見える top-level responsibility は `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` に固定する
- `auth/session` は outer boundary として分離し、009 では利用点だけを定義する
- `Explanation Generation Workflow` と `Image Generation Workflow` は `Async Generation` 配下の別 component とする
- ユーザーに公開してよい生成物は完了済み結果のみとし、生成中または失敗中は状態のみを表示する

## 内側基盤

### Domain Core

- `Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、`VisualImage`、`Sense` の用語と不変条件を保持する
- `LearningStateIdentifier` は `Learner` と `VocabularyExpression` の関係を表す複合識別子とし、`LearningState` 本体へ同じ参照を重複保持しない
- UI、auth/session detail、vendor API detail は持たない

### Application Coordination

- domain を使って actor handoff、command intake、query read、async workflow を接続する依存規則を保持する
- top-level responsibility の代替カテゴリとしては扱わない

## Top-Level Responsibilities

### Presentation

#### `UI`

- `VocabularyExpression` 登録入力を扱う
- 完了済み `Explanation` と完了済み `VisualImage` を表示する
- 生成中または失敗中は状態のみを表示する
- `Explanation.currentImage` の単一参照に従って表示する
- workflow 実行、vendor API 呼び出し、auth account lifecycle は扱わない

### Actor/Auth Boundary

#### `Learner Identity Resolution`

- 外部 identity から `Learner` 参照へ正規化する
- provider sign-in、session issuance、token verification は扱わない

#### `Actor Session Handoff`

- auth/session 境界の completed output を command / query 向け actor reference へ handoff する
- raw token、provider credential、domain aggregate mutation は扱わない

### Command Intake

#### `Vocabulary Expression Registration Intake`

- 登録要求受理の起点を担う
- completed result 読み取りと workflow 実行本体は扱わない

#### `Vocabulary Expression Validation Policy`

- `VocabularyExpressionText` の正規化と validation orchestration を担う
- vendor lexicon API への直接接続は扱わない

#### `Registration Lookup`

- 同一学習者内の duplicate registration check を担う
- auth/session detail と completed explanation / image の読み取りは扱わない

#### `Explanation Generation Request Intake`

- 解説生成要求の受理を担う
- provider 呼び出し本体は扱わない

#### `Image Generation Request Intake`

- 完了済み `Explanation` と optional `Sense` を前提に画像生成要求を受理する
- provider 呼び出し本体と asset 保存本体は扱わない

### Query Read

#### `Explanation Reader`

- completed `Explanation` と履歴取得を担う
- workflow 起動と provider 呼び出しは扱わない

#### `Visual Image Reader`

- completed `VisualImage` と `Explanation.currentImage` 解決を担う
- asset 永続化と workflow 起動は扱わない

#### `Generation Status Reader`

- explanation / image generation status の取得を担う
- incomplete payload の公開は行わない

#### `Pronunciation Media Reader`

- 発音サンプル参照の app-facing read を担う
- media source 直結と credential 管理は扱わない

### Async Generation

#### `Explanation Generation Workflow`

- `VocabularyExpression` から completed `Explanation` と `Sense` を生成する長時間処理を担う
- request acceptance、UI 表示、completed result の read API は扱わない

#### `Image Generation Workflow`

- completed `Explanation` と optional `Sense` から `VisualImage` を生成し、必要な storage handoff を行う長時間処理を担う
- request acceptance、UI 表示、asset access 解決は扱わない

### External Adapters

#### `Vocabulary Expression Validation Adapter`

- 英語表現存在確認の外部接続を担う
- validation policy の最終判断は持たない

#### `Explanation Generation Provider Adapter`

- explanation provider との接続を担う
- request acceptance と read-side 表示は扱わない

#### `Image Generation Provider Adapter`

- image provider との接続を担う
- request acceptance と completed image 表示は扱わない

#### `Asset Storage Adapter`

- 画像保存と stable asset reference 発行を担う
- user-facing image read は扱わない

#### `Asset Access Adapter`

- stored asset の再取得参照解決を担う
- asset 永続化判断と workflow 起動は扱わない

#### `Pronunciation Media Adapter`

- media source から音声参照を取得する
- reader の app-facing contract 定義は扱わない

## 主要フロー

### `VocabularyExpression` 登録

- `Actor Session Handoff`
- `Vocabulary Expression Registration Intake`
- `Vocabulary Expression Validation Policy`
- `Vocabulary Expression Validation Adapter`
- `Registration Lookup`
- `Generation Status Reader` または `Explanation Reader`

### 完了済み `Explanation` 閲覧

- `Actor Session Handoff`
- `Explanation Reader`
- `Generation Status Reader`
- `Pronunciation Media Reader`
- `Pronunciation Media Adapter`

### 画像生成

- `Actor Session Handoff`
- `Image Generation Request Intake`
- `Image Generation Workflow`
- `Image Generation Provider Adapter`
- `Asset Storage Adapter`
- `Visual Image Reader`
- `Asset Access Adapter`
- `Generation Status Reader`

## 依存方向ルール

- `Presentation` は `Async Generation` を直接起動してはならず、`Command Intake` または `Query Read` を経由する
- `Command Intake` は completed payload を返す reader を内包してはならない
- `Query Read` は workflow 起動や retry dispatch を own してはならない
- `Async Generation` は incomplete payload を user-facing contract として返してはならない
- `External Adapters` は最終的な受理判断や表示判断を持ってはならない

## Deferred Scope

- auth account lifecycle、provider sign-in、session invalidation detail は `specs/008-auth-session-design/` を正本とする
- command acceptance semantics、retry / regenerate、dispatch failure、workflow start rule は `specs/007-backend-command-design/` を正本とする
- query model schema / persistence implementation は後続 feature を正本とする
- vendor-specific adapter implementation は後続実装で具体化する
- multiple current image / meaning gallery は follow-on scope とし、現時点では単一 `Explanation.currentImage` 前提を維持する

## サブスクリプションコンポーネント

### Top-Level Responsibilities

#### `Presentation`

- `Subscription Paywall UI` は購入導線、upsell、purchase pending の状態表示を担う
- `Subscription Status UI` は subscription state、entitlement、usage allowance の表示を担う
- `Presentation` は authoritative subscription state を保持せず、同期済み mirror だけを参照する

#### `Actor/Auth Boundary`

- `Actor Session Handoff` は auth/session 境界の completed output を subscription 判定用 actor reference へ handoff する
- auth lifecycle、token verification、session invalidation detail は 008 の正本を再定義しない

#### `Command Intake`

- `Purchase Result Intake` は storefront 完了後の purchase artifact 提出受付を担う
- `Restore Purchase Intake` は restore 要求の受理を担う
- `Subscription Status Refresh Intake` は manual refresh と cross-device 再同期の起点を担う
- `Command Intake` は premium unlock の最終確定を持たない

#### `Query Read`

- `Subscription Status Reader` は authoritative subscription state の app-facing read を担う
- `Entitlement Reader` は synced entitlement mirror を返す
- `Usage Allowance Reader` は quota 状態を返す
- `Subscription Feature Gate Reader` は feature gate result を返す

#### `Async Subscription Reconciliation`

- `Purchase Verification Workflow` は purchase artifact の照合と state 更新を担う
- `Store Notification Reconciliation Workflow` は store notification による state / entitlement 再計算を担う
- reconciliation workflow は UI 表示責務を持たない

#### `External Adapters`

- `Mobile Storefront Adapter` は App Store / Google Play などの購入接続を担う
- `Purchase Verification Adapter` は receipt / token 検証接続を担う
- `Store Notification Adapter` は store notification の受信と正規化を担う
- `External Adapters` は entitlement policy や unlock 判定を最終決定してはならない

### Inner Policy Components

- `Entitlement Policy` は authoritative subscription state と plan から entitlement を導出する
- `Subscription Feature Gate` は entitlement と feature key から allow / limited / deny を決定する
- `Usage Metering / Quota Gate` は利用回数、無料枠、期間上限を評価する
- entitlement の付与と quota 消費判定は同じ責務へ潰してはならない

### Authority And State Rules

- 課金状態の最終正本は backend authoritative subscription state が持つ
- app core と UI は authoritative backend source から同期済みの entitlement mirror だけを参照する
- authoritative subscription state は `active`、`grace`、`expired`、`pending-sync`、`revoked` を区別する
- `grace` は通常の paid entitlement を維持する
- `pending-sync` は状態表示してよいが premium unlock の根拠にしてはならない
- purchase state は `initiated`、`submitted`、`verifying`、`verified`、`rejected` を区別し、subscription state と混同しない
- `verified` 以前の purchase state は premium unlock の根拠にしてはならない

### Reconciliation And Resilience Rules

- purchase / restore / refresh は command intake を起点とし、verification / notification 反映は async reconciliation で扱う
- `Mobile Storefront Adapter` の timeout では purchase state を `initiated` または `submitted` のまま保持し、retry 導線だけを返す
- `Purchase Verification Adapter` の timeout では purchase state を `verifying` に留め、authoritative subscription state を新規 paid へ進めない
- `Store Notification Adapter` の障害では既存 mirror を維持してよいが、新しい paid entitlement を付与してはならない

### Deferred Scope

- pricing catalog、tax、refund policy、store-specific dashboard setup は mobile storefront / business policy / operational policy を正本とする
- vendor SDK detail は後続実装で具体化する
- protected feature の command semantics は `specs/007-backend-command-design/` を正本とする
- auth / account / session lifecycle は `specs/008-auth-session-design/` を正本とする

## コマンド I/O 契約

### Canonical Command Set

- canonical command は `registerVocabularyExpression`、`requestExplanationGeneration`、`requestImageGeneration`、`retryGeneration` の 4 つに固定する
- 011 は 007 の command semantics を transport 非依存の canonical I/O contract へ落とし込む境界であり、command catalog 自体を置き換えない

### Request Envelope Rules

- すべての command request は `command`、`actor`、`idempotencyKey`、`body` を共有する
- `actor` は completed actor handoff input とし、少なくとも `actor`、`authAccount`、`session`、`sessionState` を含む
- request は Firebase ID token、refresh token、provider credential、password、session secret を含めてはならない
- `idempotencyKey` は actor 単位で一意に扱う
- `registerVocabularyExpression` だけが `startExplanation = false` を許可する
- `requestImageGeneration` は `Explanation` を主 target とし、必要時だけ `Sense` を補助参照で受ける
- `retryGeneration` は `targetKind`、`target`、`mode` を必須とし、`mode` は `retry` と `regenerate` を明示的に区別する

### Success Response Rules

- success response は `acceptance`、`target`、`state`、必須 `message`、`replayedByIdempotency`、必要時の `duplicateReuse` を返す
- duplicate registration は error ではなく `reused-existing` response として返す
- success response は未完了解説本文、未完了画像 payload、asset URL、provider detail、dispatch detail を返してはならない

### Error And Replay Rules

- canonical error は `validation-failed`、`ownership-mismatch`、`target-missing`、`target-not-ready`、`idempotency-conflict`、`dispatch-failed`、`internal-failure` を区別する
- error response も success response と同様に必須の user-facing `message` を返す
- same-request replay では新しい dispatch を行ってはならない
- 同じ actor に対して同じ `idempotencyKey` で正規化 request が異なる場合は `idempotency-conflict` を返す
- `dispatch-failed` は success envelope と両立してはならず、見かけ上の `pending` 確定を返してはならない

### Boundary And Deferred Scope

- 007 は command semantics、008 は actor handoff、009 は command intake placement、010 は subscription / entitlement visibility の正本とする
- command response は `pending-sync` を状態表示してよいが、premium unlock 確定情報として返してはならない
- HTTP / GraphQL / RPC schema、workflow payload schema、query response schema、provider 固有 error payload、persistence schema は deferred scope とする

## 永続化 / Read Model と非同期 Workflow

### Authoritative Persistence Allocation

- write-side の正本は `Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、`VisualImage`、authoritative subscription state、purchase state、entitlement snapshot、usage allowance、idempotency record、workflow attempt、dead-letter review に分割する
- `VocabularyExpression.currentExplanation` と `Explanation.currentImage` だけが current pointer を持ち、projection は独自に current 判定してはならない
- ownership、一意制約、主要 index、ordering rule の正本は `specs/012-persistence-workflow-design/` の allocation / data model / contracts とする

### Read Projection Rules

- app-facing projection は `VocabularyCatalogProjection`、`ExplanationDetailProjection`、`ImageDetailProjection`、`SubscriptionStatusProjection`、`UsageAllowanceProjection` に分ける
- completed payload は authoritative current pointer または同期済み snapshot が確定した後にのみ公開する
- `pending`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` は status-only として扱い、未完了生成物や未確認 premium unlock を completed projection として返してはならない
- projection refresh は eventual でよいが、authoritative write より先に completed と見せてはならない

### Workflow Runtime Rules

- explanation generation、image generation、purchase verification、restore、notification reconciliation は runtime state machine を持ち、少なくとも `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を区別する
- timeout は成功確定ではなく、既存 completed result または mirror を fallback として維持できても、新しい completed result を合成してはならない
- partial success は completed とみなしてはならない。特に image asset 保存失敗や verification 未完了は status-only のまま扱う
- retry exhaustion 後は `DeadLetterReviewUnit` を作り、operator review 用終端として扱う
- purchase state と authoritative subscription state は別 state model とし、`verified` 以前の purchase state を premium unlock の根拠にしてはならない

### Deferred Scope

- 物理 DB / queue / cache 製品、deployment topology、wire schema、provider payload detail、vendor SDK detail、operator tooling UI はこの ADR 節では固定しない
- これらの詳細実装は後続 feature または実装設計へ委ね、logical allocation / projection / runtime rule の正本は `specs/012-persistence-workflow-design/` とする

## モバイル画面遷移 / UI 状態

### Route Topology

- mobile client の top-level route group は `Auth`、`AppShell`、`Paywall`、`Restricted` に固定する
- `Auth`、`Paywall`、`Restricted` は full-screen route group とし、通常利用は `AppShell` 配下で扱う
- `AppShell` へは login 完了かつ actor handoff completed 後にのみ入れる
- tab 構成は `AppShell` 内部の deferred implementation choice とし、この ADR 節では固定しない

### Screen Roles And Visibility

- `VocabularyExpressionDetail` は generation status 集約画面とし、未完了 explanation / image payload を表示してはならない
- completed explanation 本文は `ExplanationDetail`、completed current image は `ImageDetail` でのみ表示する
- `SubscriptionStatus` は通常利用側の canonical 状態画面とし、subscription state、entitlement、usage allowance、gate result、restore progress state を表示する
- `pending-sync` は状態表示してよいが premium unlock の根拠にしてはならない
- stale read 中は loading または status-only に倒してよいが、authoritative write より先に completed と見せてはならない

### Subscription Access And Recovery

- `grace` は paid entitlement を維持し、通常利用を継続できる
- `expired` は completed result 閲覧を維持するが、premium 操作や生成系操作は `Paywall` へ戻す
- `revoked` は hard stop とし、通常利用 shell ではなく `Restricted` へ送る
- paywall と restricted access は recovery 導線を持てるが、restore と状態説明の canonical surface は `SubscriptionStatus` に集約する

### Source Of Truth And Deferred Scope

- 画面責務、route group、reader / gate / command binding、state variant の正本は `specs/013-flutter-ui-state-design/` とする
- auth/session の behavioral contract は `specs/008-auth-session-design/`、subscription authority は `specs/010-subscription-component-boundaries/`、command acceptance と message は `specs/011-api-command-io-design/`、completed visibility と stale read は `specs/012-persistence-workflow-design/` を正本とする
- router package 選定、widget tree、state management library、animation curve、visual token、tablet / foldable 最適化、push notification entry point はこの ADR 節では固定しない

## 課金 Product / Entitlement Policy

### Canonical Catalog

- canonical plan catalog は `free`、`standard-monthly`、`pro-monthly` の 3 つに固定する
- store product reference は `standard-monthly` が `vocastock.standard.monthly`、`pro-monthly` が `vocastock.pro.monthly` を使う
- `free` は store product reference を持たない

### Bundle And Quota Policy

- `free` は `free-basic` bundle と `free-monthly` quota profile を使う
- `standard-monthly` と `pro-monthly` は同じ `premium-generation` bundle を共有する
- paid plan 間の差分は feature entitlement ではなく quota profile のみとする
- 月次 quota は `free-monthly` が explanation 10 / image 3、`standard-monthly` が explanation 100 / image 30、`pro-monthly` が explanation 300 / image 100 とする
- feature gate key は `catalog-viewing`、`vocabulary-registration`、`explanation-generation`、`image-generation`、`completed-result-viewing`、`subscription-status-access`、`restore-access` に固定する

### State Effect Rules

- `active` は plan に紐づく bundle と quota profile を適用する
- `grace` は paid bundle と paid quota profile を維持する
- `pending-sync` は状態表示してよいが premium unlock の根拠にせず、`free-monthly` へ safe fallback する
- `expired` は `free-basic` と `free-monthly` へ戻し、completed result 閲覧は維持しつつ premium 操作は upsell / restore 導線へ戻す
- `revoked` は hard-stop とし、通常利用を止めて recovery section のみ許可する

### Deferred Scope

- pricing amount、currency、tax、refund policy、coupon、intro offer、family plan、store dashboard setup は business / operational policy を正本とする
- vendor SDK detail と runtime workflow ordering は 010 / 012 の boundary と state machine を正本とする
- product catalog、entitlement bundle、quota profile、feature gate matrix、subscription state effect の詳細 contract は `specs/014-billing-entitlement-policy/` を正本とする
