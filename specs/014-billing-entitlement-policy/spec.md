# Feature Specification: Billing Product And Entitlement Policy

**Feature Branch**: `014-billing-entitlement-policy`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "5. 課金 product / entitlement policy 設計書
    * subscription を実装するなら必須です
    * 例:
        * plan 一覧
        * product ID
        * free / premium の差分
        * quota table
        * grace / expired / revoked 時の挙動
        * どの機能がどの entitlement で unlock されるか
    * 010 は境界設計なので、商品設計と gate matrix は別紙にした方が実装しやすいです"

## Clarifications

### Session 2026-04-19

- Q: 初期プランの生成系差分はどうするか → A: `free` でも explanation / image の両方を少量使える。サブスクでは複数プランを用意し、プランごとに explanation / image の上限を変える
- Q: 初期の paid plan catalog の粒度はどうするか → A: `standard-monthly` と `pro-monthly` の 2 paid plan にする
- Q: explanation / image quota のリセット単位はどうするか → A: `free` も paid も月次リセットにする
- Q: `standard-monthly` と `pro-monthly` の差分はどう持たせるか → A: 2 つの paid plan は同じ feature entitlement を持ち、差分は explanation / image の quota だけにする
- Q: 月次 quota table の初期値はどうするか → A: `free` は explanation 10 / image 3、`standard-monthly` は explanation 100 / image 30、`pro-monthly` は explanation 300 / image 100

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 商品カタログの正本を固定する (Priority: P1)

プロダクト責任者として、free と premium の商品一覧、canonical plan code、
store product ID の対応を一つの正本で確認したい。そうすることで、paywall、
backend entitlement、store 設定が別々の命名でずれないようにしたい。

**Why this priority**: 商品一覧と product ID の正本が曖昧だと、課金導線、
restore、support 対応のすべてで参照ずれが起きるため。

**Independent Test**: 第三者が成果物だけを読んで、5 分以内に
「どの plan が存在し、どの product ID がどの plan を表すか」を説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 新しい paywall 文言や store 登録作業が必要である, **When** 商品設計書を確認する, **Then** `free`、`standard-monthly`、`pro-monthly` の canonical plan 一覧と product ID 対応が一意に分かる
2. **Given** free でも少量の explanation / image を提供する, **When** 商品設計書を確認する, **Then** `free` の月次 quota が explanation 10 / image 3 であり、各 paid plan の quota profile 差分が一意に分かる
3. **Given** backend が購入 artifact を plan へひも付けたい, **When** 商品設計書を参照する, **Then** store product ID から canonical plan code への対応が定義されている

---

### User Story 2 - entitlement と quota の差分を固定する (Priority: P2)

実装担当者として、free と premium の違いを subscription state ではなく、
entitlement bundle と quota policy で追跡したい。そうすることで、解説生成、
画像生成、閲覧、restore などの gate 判定を一貫した表で扱いたい。

**Why this priority**: `isPremium` のような単一フラグでは、機能解放と利用上限の
差分が潰れてしまい、010 の責務分離と矛盾するため。

**Independent Test**: 第三者が成果物だけを読んで、10 分以内に
plan ごとの entitlement と quota の差分、および各 feature gate の allow /
limited / deny を説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** free ユーザーが explanation generation を実行する, **When** gate matrix を確認する, **Then** free tier の quota と exhaustion 時の扱いが示されている
2. **Given** free ユーザーが image generation を実行する, **When** gate matrix を確認する, **Then** free tier の小さな image quota と exhaustion 時の扱いが示されている
3. **Given** paid ユーザーが image generation を実行する, **When** gate matrix を確認する, **Then** `standard-monthly` は explanation 100 / image 30、`pro-monthly` は explanation 300 / image 100 の月次 quota を持ち、同じ feature entitlement を共有することを説明できる

---

### User Story 3 - subscription state ごとの access policy を固定する (Priority: P3)

運用担当者として、`grace`、`pending-sync`、`expired`、`revoked` のときに、
どの entitlement と quota が有効で、どの画面や機能が止まるかを一貫して判断したい。
そうすることで、UI、support、restore、access restriction の解釈ずれを防ぎたい。

**Why this priority**: subscription state の扱いが曖昧だと、013 の画面遷移設計、
010 の subscription boundary、012 の workflow state machine と食い違いやすいため。

**Independent Test**: 第三者が成果物だけを読んで、10 分以内に
各 subscription state が entitlement、quota、feature gate、UI access へ与える
影響を追跡できれば成立する。

**Acceptance Scenarios**:

1. **Given** subscription state が `grace` である, **When** policy を確認する, **Then** paid entitlement と paid quota profile を維持することが分かる
2. **Given** subscription state が `expired` である, **When** policy を確認する, **Then** free tier へ戻り、completed result 閲覧は維持しつつ premium 操作は deny されることが分かる
3. **Given** subscription state が `revoked` である, **When** policy を確認する, **Then** hard-stop policy と `Restricted` への誘導が必要だと分かる
4. **Given** subscription state が `pending-sync` である, **When** policy を確認する, **Then** 状態表示はできても未確認 premium unlock の根拠にはならず、`free-monthly` への safe fallback を使うことが分かる

### Edge Cases

- 複数 paid plan が存在しても、feature entitlement と quota profile の境界を二重定義しない必要がある場合
- 同じ actor が `standard-monthly` から `pro-monthly` へ変更し、feature entitlement は同じまま quota だけが変わる場合
- purchase は `verified` だが notification reconciliation が遅れ、mirror 更新だけが未完了の場合
- `grace` 中は paid entitlement を維持する一方で、quota exhaustion は通常どおり発生する場合
- `expired` へ落ちた瞬間に free quota へ戻す必要があるが、既存の completed result は失わせたくない場合
- `revoked` により paywall ではなく `Restricted` を出すべき actor と、単なる `expired` actor を UI で区別する必要がある場合
- premium product ID が将来増えても、既存 plan code と feature gate key の意味を壊したくない場合
- pricing change、tax、intro offer、coupon、family plan のような商用施策を、今回の正本に含めず deferred にしたい場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None
- **Invariants / Terminology**: subscription state、purchase state、entitlement、quota、feature gate decision は別概念として維持し、`Frequency`、`Sophistication`、`Proficiency`、登録状態、生成状態とは統合しない
- **Async Lifecycle**: purchase verification、restore、notification reconciliation の runtime state は 012 の state machine に従い、本 feature はそれらが最終的にどの product policy / entitlement policy へ反映されるかだけを定義する
- **User Visibility Rule**: ユーザーへは課金状態や反映待ち状態を表示してよいが、premium unlock は confirmed entitlement に限る
- **Identifier Naming Rule**: 識別子命名は既存の `XxxIdentifier`、`identifier`、概念名参照の規約を変更しない
- **External Ports / Adapters**: mobile storefront、purchase verification、store notification は 010 の外部境界を前提とし、本 feature は product catalog と policy decision の正本だけを追加する

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、canonical plan catalog として `free`、`standard-monthly`、`pro-monthly` を定義しなければならない
- **FR-002**: 成果物は、各 paid plan について canonical plan code と store product ID の対応を定義しなければならない
- **FR-003**: 成果物は、`free` でも explanation / image の両方を少量利用できることを定義しなければならない
- **FR-004**: 成果物は、free と premium の差分を feature entitlement と usage quota の両面で説明しなければならない
- **FR-005**: 成果物は、quota policy を entitlement flag と別表で定義し、explanation generation と image generation の利用上限、消費単位、月次リセット、上限到達時の挙動を plan ごとに示さなければならない
- **FR-005a**: 成果物は、初期月次 quota table として `free` を explanation 10 / image 3、`standard-monthly` を explanation 100 / image 30、`pro-monthly` を explanation 300 / image 100 と定義しなければならない
- **FR-006**: 成果物は、少なくとも `catalog viewing`、`vocabulary registration`、`explanation generation`、`image generation`、`completed result viewing`、`subscription status / restore access` の feature gate matrix を定義しなければならない
- **FR-007**: 成果物は、各 feature gate に対して free、paid active、paid grace、pending-sync、expired、revoked の allow / limited / deny 方針を定義しなければならない
- **FR-008**: 成果物は、`grace` では paid entitlement と paid quota profile を維持し、`expired` では free tier へ戻し、`revoked` では hard-stop とする方針を明示しなければならない
- **FR-009**: 成果物は、`pending-sync` を状態表示可能としつつ、未確認 premium unlock の根拠にせず、`free-monthly` への safe fallback を使う方針を明示しなければならない
- **FR-010**: 成果物は、free tier exhaustion 時と paid tier exhaustion 時の user-facing fallback を定義しなければならない
- **FR-011**: 成果物は、product policy の変更先が `product catalog`、`entitlement policy`、`quota policy`、`feature gate matrix` のどれかを第三者が判別できるようにしなければならない
- **FR-012**: 成果物は、010 の subscription boundary、011 の command I/O、012 の workflow state machine、013 の UI access policy と矛盾しない source-of-truth 導線を明示しなければならない
- **FR-013**: 成果物は、pricing amount、tax、refund policy、coupon、intro offer、family plan、store SDK detail を deferred scope または外部境界として明示しなければならない
- **FR-014**: 成果物は、support や運用担当者が state ごとの access 方針を判断できるよう、`grace`、`pending-sync`、`expired`、`revoked` の挙動を一覧化しなければならない
- **FR-015**: 成果物は、複数 paid plan の差分が主に explanation / image の quota 差分であることを示し、plan ごとにどの上限が変わるかを一覧化しなければならない
- **FR-016**: 成果物は、`standard-monthly` と `pro-monthly` が同じ feature entitlement bundle を共有し、paid plan 間の違いは quota profile のみであることを明示しなければならない

### Key Entities *(include if feature involves data)*

- **SubscriptionPlanDefinition**: canonical plan code、plan tier、billing cadence、store product ID、対象 entitlement bundle、quota profile を表す定義
- **EntitlementBundleDefinition**: 特定 plan が解放する feature set を表す定義であり、`standard-monthly` と `pro-monthly` は同一 bundle を共有する
- **QuotaPolicyDefinition**: 特定 plan または tier に対して、何をどれだけ利用できるか、月次でどうリセットされるかを表す定義。初期値は `free` explanation 10 / image 3、`standard-monthly` explanation 100 / image 30、`pro-monthly` explanation 300 / image 100 を持つ
- **FeatureGateRule**: feature key ごとに、plan tier と subscription state に応じた allow / limited / deny を表す定義
- **SubscriptionStateEffect**: `active`、`grace`、`pending-sync`、`expired`、`revoked` が entitlement、quota、UI access に与える影響を表す定義

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が、5 分以内に canonical plan catalog と各 paid product ID の対応を説明できる
- **SC-002**: 第三者が、10 分以内に free と premium の entitlement / quota 差分を feature gate 単位で追跡できる
- **SC-003**: `grace`、`pending-sync`、`expired`、`revoked` の access policy 解釈に関する文書間の矛盾が 0 件になる
- **SC-004**: 商品設計変更要求を `product catalog`、`entitlement policy`、`quota policy`、`feature gate matrix`、または deferred scope に割り当てるレビューで判断不能ケースが 0 件になる

## Assumptions

- free tier は paywall 導線と completed result 閲覧を持ち、explanation / image の両方を少量だけ利用できる
- 初期リリースの paid offer は `standard-monthly` と `pro-monthly` の 2 種類とし、plan ごとに explanation / image の quota が変わる
- `standard-monthly` と `pro-monthly` の差分は quota のみで、追加 feature entitlement は設けない
- 初期月次 quota は `free` explanation 10 / image 3、`standard-monthly` explanation 100 / image 30、`pro-monthly` explanation 300 / image 100 とする
- explanation generation と image generation は quota 対象であり、quota 消費判定の正本は backend 側にある
- explanation generation と image generation の quota は `free` / paid とも月次でリセットする
- `grace` は paid entitlement 維持、`expired` は free tier fallback、`revoked` は hard-stop という既存方針を踏襲する
- `pending-sync` は mirror 反映待ちまたは確認中を含む補助状態であり、新しい premium unlock を確定しない
- product ID は store ごとに異なってよいが、canonical plan code への対応は一意でなければならない
- pricing amount、currency、tax、refund、discount campaign はこの feature の正本では扱わない
