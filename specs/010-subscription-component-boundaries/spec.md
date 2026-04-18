# Feature Specification: Subscription Component Boundaries

**Feature Branch**: `010-component-boundaries`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: User description: "PR6のままサブスク用のアーキテクチャコンポーネント定義をする"

## Clarifications

### Session 2026-04-18

- Q: 機能解放の最終判定をどこで行うか → A: backend が最終正本を持ち、アプリは同期済み entitlement mirror で UI 制御する
- Q: authoritative subscription state の最小粒度 → A: `active` / `grace` / `expired` / `pending-sync` / `revoked` の 5 状態にする
- Q: 利用上限の消費判定をどこで持つか → A: `Entitlement Policy` は解放権限だけを持ち、利用上限の消費判定は別の `Usage Metering / Quota Gate` component として分ける
- Q: `grace` 状態での機能解放方針 → A: `grace` 中は通常の有料 entitlement を維持する

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 課金責務の正本を整理する (Priority: P1)

アーキテクチャレビュー担当者として、サブスクに関わる責務がどこで管理されるかを
一目で把握したい。そうすることで、課金有無の判定、機能解放、購入 UI が同じ箱に
混ざらない状態を先に固定したい。

**Why this priority**: 課金まわりは purchase、subscription state、entitlement、
feature gate を混同しやすく、最初に責務境界を固定しないと後続設計が崩れるため。

**Independent Test**: 成果物だけを読めば、第三者が 5 分以内に
「誰が課金状態の正本を持ち、誰が機能解放を判定し、誰が UI を担うか」を説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** サブスク導入前の component catalog がある, **When** レビュー担当者が subscription 関連責務を確認する, **Then** mobile purchase、subscription state、entitlement、feature gate、UI の責務差分が明示されている
2. **Given** 課金有無の判定をどこで持つかを確認する, **When** component definition を読む, **Then** mobile storefront、backend authoritative state、app-facing gate の境界が区別されている

---

### User Story 2 - 課金状態と機能解放の流れを分離する (Priority: P2)

実装担当者として、購入受付、購入状態照合、subscription 状態保持、entitlement 判定、
feature unlock の流れを混同せずに扱いたい。そうすることで、有料機能の開放条件と
制限条件を一貫して定義したい。

**Why this priority**: `isPremium` のような単一フラグへ潰すと、購入済みだが未反映、
期限切れ、猶予中、復元待ちなどの状態を適切に扱えないため。

**Independent Test**: 第三者が成果物だけを読んで、購入確認から entitlement 反映、
feature gate 判定までを component 単位で追跡できれば成立する。

**Acceptance Scenarios**:

1. **Given** ユーザーが有料プランを購入する, **When** subscription flow を確認する, **Then** purchase interaction、authoritative subscription state、entitlement evaluation、feature gate が別責務として示されている
2. **Given** 課金により画像生成や解説生成の利用制限が変わる, **When** component definition を確認する, **Then** 制限条件と解放条件が entitlement と feature gate で表現されている
3. **Given** 課金処理が pending または照合中である, **When** UI の責務を見る, **Then** 状態は表示できるが backend で confirmed された entitlement ではない限り unlock しないことが明示されている
4. **Given** 月次上限や無料枠の消費判定を確認する, **When** component definition を読む, **Then** entitlement と usage metering / quota gate が別責務として示されている

---

### User Story 3 - 課金境界と deferred scope を固定する (Priority: P3)

将来の変更担当者として、価格設定、税務、ストア固有設定、返金通知、利用制限変更の
どれが今回の対象で、どれが別 feature や外部境界の責務かを判断したい。

**Why this priority**: billing は store policy、backend verification、product policy が
絡むため、対象外領域を明示しないと文書間で責務が二重化しやすいため。

**Independent Test**: 任意のサブスク関連変更要求を見たときに、第三者が
in-scope component か deferred scope かを 5 分以内に割り当てられれば成立する。

**Acceptance Scenarios**:

1. **Given** ストア固有の購入設定や価格変更の相談がある, **When** component definition を確認する, **Then** 外部境界または deferred scope として扱うべき理由が示されている
2. **Given** 課金による機能 unlock 条件を変更したい, **When** component definition を確認する, **Then** 変更先が entitlement policy か feature gate かを判断できる

---

### Edge Cases

- ユーザー端末では購入成功に見えるが、authoritative subscription state への反映がまだ完了していない場合
- purchase state が `submitted` または `verifying` のまま、purchase verification adapter のタイムアウトや一時障害で長引く場合
- subscription が失効、猶予中、復元待ちのいずれかで、即時に unlock / lock を切り替えてよいか曖昧な場合
- subscription state が `grace` または `revoked` のとき、UI 表示と機能 unlock の扱いがずれる場合
- 同じ actor が複数端末を使い、端末ごとの local purchase cache と backend state がずれる場合
- 購入済みでも entitlement が plan 変更で縮小され、機能ごとの制限値だけが変わる場合
- サブスク状態は有効だが、特定機能だけ別 entitlement として制御したい場合
- entitlement は有効でも usage quota が尽きており、unlock と実行可否の判定が分かれる場合
- `grace` 中は有料機能を維持する一方、`expired` または `revoked` では停止する境界を明確にする必要がある場合
- mobile storefront または store notification adapter が一時利用不能で、再試行中は状態表示だけを継続しつつ unlock は止める必要がある場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None
- **Invariants / Terminology**: purchase state、subscription state、entitlement、feature gate decision、usage limit は別概念として維持し、`Frequency`、`Sophistication`、`Proficiency`、登録状態、生成状態とは統合しない
- **Quota Rule**: entitlement の付与と usage limit の消費判定は別責務として扱い、quota 消費は独立した gate で評価する
- **Async Lifecycle**: 課金確認と state reconciliation は pending / running / succeeded / failed を区別して説明し、未確定状態のまま unlock 判定へ進めない
- **Purchase State Rule**: canonical purchase state は少なくとも `initiated`、`submitted`、`verifying`、`verified`、`rejected` を区別し、authoritative subscription state とは別概念として扱う
- **Subscription State Rule**: authoritative subscription state は少なくとも `active`、`grace`、`expired`、`pending-sync`、`revoked` を区別して扱う
- **Grace Rule**: `grace` は一時的な継続状態として扱い、通常の有料 entitlement を維持する
- **User Visibility Rule**: ユーザーへは購入状態や反映待ち状態を表示してよいが、機能 unlock は confirmed entitlement に限る
- **Identifier Naming Rule**: 既存の識別子命名規約を変更せず、新しい component 定義でも `XxxIdentifier`、`identifier`、概念名参照のルールを前提にする
- **External Ports / Adapters**: mobile storefront、purchase verification、server notification、subscription synchronization は external boundary として区別する
- **Adapter Resilience Rule**: mobile storefront、purchase verification、store notification adapter は timeout、retry、fallback を明示し、一時障害時も未確認 entitlement を unlock 根拠にしない

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、サブスク関連の current component 候補を review し、purchase、subscription state、entitlement、feature gate、UI の主責務を定義しなければならない
- **FR-002**: 成果物は、mobile purchase interaction と backend authoritative subscription state を別責務として定義しなければならない
- **FR-002a**: 成果物は、authoritative subscription state として `active`、`grace`、`expired`、`pending-sync`、`revoked` を区別し、それぞれが unlock 判定へ与える影響を説明しなければならない
- **FR-002b**: 成果物は、`grace` 状態では通常の有料 entitlement を維持し、`expired` と `revoked` とは異なる unlock 方針を明示しなければならない
- **FR-002c**: 成果物は、purchase state の canonical model として `initiated`、`submitted`、`verifying`、`verified`、`rejected` を定義し、authoritative subscription state と別責務であることを明示しなければならない
- **FR-003**: 成果物は、subscription 状態から機能解放条件を導く entitlement policy component を定義しなければならない
- **FR-004**: 成果物は、entitlement に基づいて app core と UI の利用可否を判定する feature gate component を定義しなければならない
- **FR-004a**: 成果物は、機能解放の最終正本を backend 側の entitlement 判定に置き、アプリ側は同期済み entitlement mirror を用いた UI 制御だけを行うよう定義しなければならない
- **FR-004b**: 成果物は、entitlement の付与と usage limit の消費判定を別責務として定義し、`Usage Metering / Quota Gate` component を明示しなければならない
- **FR-005**: 成果物は、purchase state、subscription state、entitlement、feature gate decision、usage limit を混同しないように定義しなければならない
- **FR-006**: 成果物は、confirmed ではない purchase / subscription 状態では有料機能を unlock しない rule を示さなければならない
- **FR-007**: 成果物は、restore purchase、status refresh、cross-device reconciliation がどの責務で扱われるかを示さなければならない
- **FR-007a**: 成果物は、mobile storefront、purchase verification、store notification adapter ごとに timeout、retry、障害時 fallback の扱いを示さなければならない
- **FR-008**: 成果物は、課金による機能制限と解放を subscription そのものではなく entitlement と feature gate の組み合わせで説明しなければならない
- **FR-009**: 成果物は、課金状態の正本、機能 unlock の正本、UI 表示責務を別の component として定義しなければならない
- **FR-010**: 成果物は、auth/session、component boundaries、backend command の既存設計と矛盾しない言葉で subscription component を整理しなければならない
- **FR-011**: 成果物は、store-specific configuration、pricing catalog、tax、refund policy、vendor SDK detail を deferred scope または外部境界として明示しなければならない
- **FR-012**: 成果物は、サブスク有無の判定と機能解放の判定を、第三者が end-to-end で追跡できる粒度で示さなければならない

### Key Entities *(include if feature involves data)*

- **Subscription Component Definition**: subscription 関連 component の名前、主責務、ownership、非責務を表す定義
- **Purchase State**: 購入要求や復元要求の進行状況を表す状態
- **Purchase State Model**: `initiated`、`submitted`、`verifying`、`verified`、`rejected` の canonical progression を持ち、authoritative subscription state より手前の受付・照合状態を表すモデル
- **Subscription State**: actor に紐づく契約状態の正本として扱う状態であり、少なくとも `active`、`grace`、`expired`、`pending-sync`、`revoked` を区別する
- **Entitlement**: 契約に基づいて解放される機能・上限・権限の集合
- **Feature Gate Decision**: 特定機能を許可、制限、拒否する判定結果
- **Usage Metering / Quota Gate**: entitlement とは別に、利用回数、期間上限、無料枠消費を評価して実行可否を返す component

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が、課金状態の正本、機能 unlock の正本、UI 表示責務を 5 分以内に説明できる
- **SC-002**: 第三者が、購入確認から entitlement 反映、feature gate 判定までの流れを 10 分以内に追跡できる
- **SC-003**: purchase state、subscription state、entitlement、feature gate decision の責務混同に関する指摘漏れが 0 件になる
- **SC-004**: サブスク関連の変更要求を in-scope component または deferred scope へ割り当てる文書横断の矛盾が 0 件になる

## Assumptions

- mobile storefront が実際の課金処理を担い、product 内 component はその結果の利用点だけを定義する
- backend が actor に紐づく authoritative subscription state と entitlement の正本を持つ
- purchase と restore の受付は canonical purchase state model に従い、`verified` になるまで premium unlock の根拠にしない
- authoritative subscription state の最小粒度は `active`、`grace`、`expired`、`pending-sync`、`revoked` とする
- `grace` は短期的な継続状態として扱い、通常の有料 entitlement を維持する
- app core は purchase detail や store credential ではなく、backend と同期済みの entitlement と feature gate decision だけを受け取る
- 有料機能は explanation generation、image generation、利用上限など複数の feature gate へ展開されうる
- 利用回数や期間上限の消費判定は backend 側の `Usage Metering / Quota Gate` が正本を持つ
- mobile storefront、purchase verification、store notification adapter は timeout、retry、fallback を定義し、一時障害中は状態表示のみを継続して unlock は保留する
- pricing catalog、税務、返金、store policy detail、vendor SDK 選定はこの feature では扱わない
