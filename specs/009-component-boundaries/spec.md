# Feature Specification: 機能別コンポーネント定義

**Feature Branch**: `010-component-boundaries`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "機能ごとのコンポーネント定義を行う。現状は以下だが不足しているもの・コンテキストが正しく分割できていないものなどがないか議論したい"

## Clarifications

### Session 2026-04-17

- Q: `auth/session` 分離と生成系分離を含めて採用する主軸アーキテクチャは何か → A: オニオンアーキテクチャを主軸にし、`auth/session` を外側境界、`Explanation generation` / `Image generation` を非同期別コンポーネントとして分離する
- Q: オニオン主軸での top-level 責務分割はどうするか → A: `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` を top-level 責務として明示する
- Q: `Async Generation` 配下の分割粒度はどうするか → A: `Async Generation` を top-level に置き、その配下に `Explanation Generation Workflow` と `Image Generation Workflow` の 2 コンポーネントを置く
- Q: オニオン内側の `Domain` / `Application` の見せ方はどうするか → A: `Domain Core` と `Application Coordination` はアーキテクチャの内側として明示しつつ、top-level 責務一覧とは別枠で表現する

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 現行コンポーネント境界を棚卸しする (Priority: P1)

アーキテクチャレビュー担当者として、現行のコンポーネント一覧を見たときに、
どの責務が既に定義されていて、どの責務が欠けているか、どこが複数コンテキストを
またいで混ざっているかを説明したい。

**Why this priority**: 現行の責務境界が曖昧なままだと、後続実装で write / read / identity /
workflow の責務が混線し、議論の前提が揃わないため。

**Independent Test**: レビュー担当者が成果物だけを読み、現行コンポーネント一覧の不足項目、
責務重複、文脈混在を 5 分以内に指摘できれば成立する。

**Acceptance Scenarios**:

1. **Given** 現行のコンポーネント一覧がある, **When** レビュー担当者が責務の一覧を見る, **Then** 各コンポーネントの主責務と所属コンテキストが明示されている
2. **Given** 現行一覧に責務が抜けているまたは混ざっている箇所がある, **When** コンポーネント定義を確認する, **Then** 追加すべき項目または分割すべき項目が明示されている
3. **Given** 全体アーキテクチャの方針を確認する, **When** コンポーネント定義を見る, **Then** オニオンアーキテクチャを主軸に outer boundary と非同期コンポーネントの位置づけが示されている

---

### User Story 2 - コンテキストごとの責務を分離する (Priority: P2)

実装担当者として、UI、学習者解決、登録、解説生成、画像生成、読み取り、非同期実行、
外部アダプタの責務を混同せずに扱いたい。そうすることで、ある変更がどのコンポーネントへ
入るべきかを迷わず判断したい。

**Why this priority**: コンポーネントが「機能名」だけで定義されていると、command 受理、
workflow orchestration、provider 呼び出し、read-side 取得が 1 つの箱へ潰れてしまうため。

**Independent Test**: 第三者が成果物だけを読み、登録、解説閲覧、画像生成の各フローについて、
write-side、read-side、identity/session handoff、async execution の責務分離を説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 登録や生成要求のフローを確認する, **When** どこで受理し、どこで実行し、どこで結果を読むかを見る, **Then** command 受理、workflow 実行、結果取得の責務が分離されている
2. **Given** 学習者 identity と認証まわりの整理を確認する, **When** 外部 identity、session、actor handoff、`Learner` 解決を見る, **Then** auth/session の責務と domain 内の学習者解決が混同されていない
3. **Given** top-level の責務分割を確認する, **When** コンポーネント一覧を見る, **Then** `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` の責務差分が明示されている
4. **Given** 非同期生成の整理を確認する, **When** `Async Generation` 配下を見る, **Then** `Explanation Generation Workflow` と `Image Generation Workflow` が別コンポーネントとして定義されている
5. **Given** オニオンの内側構造を確認する, **When** コンポーネント定義を見る, **Then** `Domain Core` と `Application Coordination` が内側の基盤として別枠で説明されている

---

### User Story 3 - 後続 feature との境界を固定する (Priority: P3)

将来の変更担当者として、ある機能変更がこのコンポーネント定義の対象か、それとも
auth/session、backend command、query model、vendor adapter など別 feature に属するかを
一貫して判断したい。

**Why this priority**: コンポーネント定義と周辺設計の境界が曖昧だと、同じ責務を複数文書で
別名で持ち、後続 feature のスコープが崩れるため。

**Independent Test**: 将来の担当者が成果物だけを読み、任意の変更要求を 1 つ以上の
コンポーネントまたは deferred scope へ 5 分以内に割り当てられれば成立する。

**Acceptance Scenarios**:

1. **Given** 認証、session、workflow orchestration、query model の話題がある, **When** コンポーネント定義を見る, **Then** 何が今回の対象で何が周辺 feature の責務かが明示されている
2. **Given** 新しい機能変更を検討する, **When** 変更影響を確認する, **Then** どのコンポーネントを更新すべきか、またはどの deferred scope に属するかを判断できる

---

### Edge Cases

- 1 つのコンポーネントが UI と application service と external adapter を同時に担っているように見える場合
- `Learner identity resolution` が auth/session と `Learner` 解決を両方含んでしまう場合
- `Explanation generation` や `Image generation` が command 受理、workflow orchestration、provider invocation をまとめて表してしまう場合
- `Explanation reader` が query model、current result 取得、履歴取得、状態表示責務を曖昧にまとめてしまう場合
- `Asset storage` が保存責務だけでなく再取得、配信、URL 解決まで含むかが曖昧な場合
- 現状の一覧に存在しないが、end-to-end の説明には必要なコンポーネントが暗黙のまま残る場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None
- **Invariants / Terminology**: `Frequency`、`Sophistication`、`Proficiency`、登録状態、解説生成状態、画像生成状態の区別は維持し、コンポーネント定義によって domain 概念を統合しない
- **Async Lifecycle**: 非同期生成を扱うコンポーネントは、要求受理、状態管理、workflow 実行、完了結果取得を区別して説明しなければならない。`Async Generation` 配下では `Explanation Generation Workflow` と `Image Generation Workflow` を別コンポーネントとして扱う
- **User Visibility Rule**: どのコンポーネント分割を採用しても、ユーザーに見せてよい生成物は完了済み結果のみであり、生成中・失敗中は状態のみを表示対象とする
- **Identifier Naming Rule**: 既存の識別子命名規約を変更せず、新しいコンポーネント定義でも `XxxIdentifier`、`identifier`、概念名参照のルールを前提にする
- **External Ports / Adapters**: identity provider、validation、generation provider、asset storage、media access など外部依存は、コンポーネント定義の中でも domain 外責務として区別する
- **Architecture Style**: 主軸はオニオンアーキテクチャとし、内側の基盤として `Domain Core` と `Application Coordination` を別枠で示す。top-level 責務は `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` に整理し、`auth/session` は outer boundary、`Explanation generation` / `Image generation` は非同期コンポーネントとして扱う

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、現行のコンポーネント一覧を review し、各項目の主責務と所属コンテキストを定義しなければならない
- **FR-002**: 成果物は、1 つのコンポーネントが複数コンテキストをまたいで責務を持つ場合、その混在を指摘し、分割または境界明示の方針を示さなければならない
- **FR-003**: 成果物は、end-to-end の説明に必要だが現行一覧では暗黙になっているコンポーネントを追加候補として明示しなければならない
- **FR-004**: 成果物は、`Learner identity resolution` と auth/session 系責務の境界を定義し、`Learner` 解決、actor handoff、認証そのものを混同しないようにしなければならない
- **FR-005**: 成果物は、登録・解説生成・画像生成について、request acceptance、workflow orchestration、provider invocation、result reading の責務差分を明示しなければならない
- **FR-006**: 成果物は、read-side の責務として current result の取得、履歴取得、状態参照をどこで扱うかを明示しなければならない
- **FR-007**: 成果物は、asset storage、asset retrieval/access、pronunciation media access の責務を区別し、保存と取得が同一責務かどうかを明示しなければならない
- **FR-008**: 成果物は、各コンポーネントが product 内責務なのか、外部 adapter なのか、周辺 feature へ委ねる deferred scope なのかを示さなければならない
- **FR-009**: 成果物は、コンポーネント定義を既存の domain language、auth/session 設計、backend command 設計と矛盾しない言葉で整理しなければならない
- **FR-010**: 成果物は、ユーザーに完了済み結果だけを見せる rule を前提に、UI、read-side、async execution の責務分離を説明しなければならない
- **FR-011**: 成果物は、各主要ユーザーフローについて、どのコンポーネント群が関与するかを第三者が追跡できる粒度で示さなければならない
- **FR-012**: 成果物は、今回の見直し対象外である auth/session 実装詳細、query model 実装、workflow 実装、vendor 固有 adapter 実装を deferred scope として明示しなければならない
- **FR-013**: 成果物は、オニオンアーキテクチャを主軸として、内側の `Domain Core` / `Application Coordination`、外側の `auth/session` boundary、非同期生成コンポーネント、external adapter の配置関係を示さなければならない
- **FR-014**: 成果物は、top-level 責務として `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` を定義し、現行コンポーネントをいずれかへ割り当てなければならない
- **FR-015**: 成果物は、`Async Generation` の配下に少なくとも `Explanation Generation Workflow` と `Image Generation Workflow` を別コンポーネントとして定義し、それぞれの完了条件と依存関係の違いを説明しなければならない
- **FR-016**: 成果物は、`Domain Core` と `Application Coordination` を top-level 責務一覧へ混ぜずに、アーキテクチャの内側基盤として別枠で説明しなければならない

### Key Entities *(include if feature involves data)*

- **Component Definition**: 1 つのコンポーネントの名前、主責務、所属コンテキスト、扱う入出力、他コンポーネントとの境界を表す定義
- **Context Boundary**: UI、domain-adjacent application logic、async workflow、external adapter、deferred scope のどこに属するかを示す境界情報
- **Interaction Responsibility**: 登録、生成、閲覧、actor 解決、保存、取得の各フローで、どの責務をどのコンポーネントが担うかを示す整理単位
- **Deferred Scope Item**: 現時点では別 feature が正本を持つ責務領域を示す項目

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が、現行一覧の各コンポーネントについて主責務と所属コンテキストを 5 分以内に説明できる
- **SC-002**: 現行一覧に含まれる各項目について、責務混在または不足している境界の指摘漏れが 0 件になる
- **SC-003**: 第三者が、登録、解説閲覧、画像生成の 3 つの主要フローをコンポーネント単位で 5 分以内に追跡できる
- **SC-004**: auth/session、backend command、query model、vendor adapter への責務割り当てについて、文書横断の矛盾が 0 件になる

## Assumptions

- 現行のコンポーネント一覧は [adr.md](/Users/lihs/workspace/vocastock/docs/external/adr.md) の「コンポーネント」節を正本候補として見直す
- 既存の domain model、auth/session 設計、backend command 設計はすでに存在し、今回の feature はそれらを置き換えずに接続境界を整理する
- この feature は docs-first の議論整理であり、実装コードや vendor 選定は含まない
- query model、workflow 実装、storage 実装、認証実装の詳細は別 feature が正本を持つ前提とする
- 主軸アーキテクチャはオニオンアーキテクチャとし、`auth/session` は outer boundary、`Explanation generation` / `Image generation` は長時間処理を担う非同期別コンポーネントとして扱う
- top-level の整理は `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` を基準に行う
- `Async Generation` は 1 つの抽象カテゴリとして置くが、実際の workflow component は `Explanation Generation Workflow` と `Image Generation Workflow` に分ける
- `Domain Core` と `Application Coordination` はオニオンの内側基盤として明示するが、現行コンポーネントの割り当て表とは別レイヤ表現で扱う
