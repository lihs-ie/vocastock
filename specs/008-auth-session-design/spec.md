# Feature Specification: 会員登録・ログイン・ログアウト設計

**Feature Branch**: `008-auth-session-design`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "会員登録・ログイン・ログアウトに関する設計書を作成する"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 主要な会員導線を定義する (Priority: P1)

利用者として、会員登録、ログイン、ログアウトの基本導線を明確に知りたい。これにより、サービス利用開始と再訪時の入口が一貫する。

**Why this priority**: 会員導線が曖昧だと、利用開始前に離脱しやすく、後続機能の利用条件も定義できないため。

**Independent Test**: 第三者が設計書だけを読み、`Basic` と `Google` の会員登録、ログイン、ログアウトが、Flutter 側の認証 UI と provider 開始から Firebase Authentication、backend の検証と利用主体解決を経て完了する流れとして説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 未登録の利用者が利用開始したい, **When** 会員登録導線を確認する, **Then** Flutter 側で `Basic` または `Google` の登録を開始し、Firebase Authentication による本人確認と backend の利用主体解決が完了した後に利用可能状態へ遷移する流れを説明できる
2. **Given** 既存会員が再訪した, **When** ログイン導線を確認する, **Then** Flutter 側で利用可能な手段を開始し、Firebase Authentication と backend 検証の両方を通過してから利用可能状態へ入る流れを説明できる
3. **Given** ログイン中の利用者が利用を終えたい, **When** ログアウト導線を確認する, **Then** 現在の利用状態を終了し、再度認証が必要な状態へ戻ることを説明できる

---

### User Story 2 - 認証をアプリのコアドメイン外として切り分ける (Priority: P2)

設計担当者として、認証そのものを vocastock のコアドメインに混ぜず、会員状態と学習データの所有者解決だけを接続したい。これにより、語彙学習ドメインの複雑さを増やさずに認証基盤を差し替えやすくできる。

**Why this priority**: 認証をドメインモデルに取り込むと、学習概念と外部 identity の責務が混線するため。

**Independent Test**: 第三者が設計書だけを読み、Flutter が認証 UI と provider 開始を担い、Firebase Authentication が本人確認基盤となり、backend が Firebase ID token を検証して actor / learner を解決し、アプリ本体は正規化済みの利用主体だけを受け取ることを説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 実装担当者が会員登録責務の配置先を確認したい, **When** 設計書を読む, **Then** Flutter 認証 UI、Firebase Authentication、backend token 検証、session 管理、利用主体解決の責務分離を説明できる
2. **Given** 学習データへのアクセス制御を設計したい, **When** 設計書を読む, **Then** backend 検証後にアプリへ渡す利用主体情報と、アプリが保持しない Firebase token や provider 資格情報を区別できる

---

### User Story 3 - 条件付き provider 採用方針を定義する (Priority: P3)

運用担当者として、`Apple ID` と `LINE` を追加候補として評価しつつ、追加コストが発生する場合は初期導入から除外したい。これにより、認証手段の拡張余地を残しながら初期運用コストを抑えられる。

**Why this priority**: provider ごとの採用条件が曖昧だと、設計上は対応していても実運用で有効化できない手段が混ざるため。

**Independent Test**: 第三者が設計書だけを読み、`Basic` / `Google` が Firebase Authentication を前提とした初期対象であり、`Apple ID` / `LINE` は追加コストなしで Firebase Authentication または承認済み同等経路に載せられる場合の後続有効化候補であることを説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 認証手段の採用可否を判断したい, **When** provider 一覧を確認する, **Then** 初期対象と条件付き対象を区別できる
2. **Given** `Apple ID` または `LINE` に追加コストが発生する、または Firebase Authentication もしくは承認済み同等経路に載せられない, **When** 採用条件を確認する, **Then** 初期リリースでは無効のまま扱うことを説明できる

### Edge Cases

- `Basic` 登録済みメールアドレスで再登録を試みた場合に、新規会員作成ではなく既存会員案内へ切り替えるか
- `Google` で取得した外部 identity と既存会員が競合する場合に、重複会員を作らずどう案内するか
- ログイン成功直後に利用主体解決ができない場合に、認証成功とアプリ利用開始をどう分離するか
- ログアウト要求時に session が既に無効な場合に、利用者へどう結果を返すか
- `Apple ID` または `LINE` がコスト条件や運用条件を満たさない場合に、UI 上でどう非表示または無効扱いにするか

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None。認証コンテキストは vocastock のコアドメイン外として扱い、`docs/internal/domain/*.md` は参照専用とする
- **Invariants / Terminology**: Flutter は認証 UI と provider 開始だけを担い、Firebase Authentication は本人確認基盤、backend は Firebase ID token 検証と actor / learner 解決、app core は正規化済み利用主体参照のみを受け取る。会員アカウント、外部 identity、検証済み Firebase identity、session、利用主体解決、学習者所有は別概念として扱い、認証情報を語彙・解説・画像のドメイン概念へ混在させない
- **Async Lifecycle**: 会員登録、ログイン、ログアウトは、Flutter 側の開始、Firebase Authentication、backend 検証、利用主体解決を内部で含んでも、利用者から見て即時完了または失敗として扱い、`pending` / `running` の長時間状態は公開しない
- **User Visibility Rule**: Flutter 側での Firebase sign-in 成功だけでは「利用可能状態」と見せてはならず、backend 検証と actor / learner 解決が完了した後にのみ利用可能状態へ遷移できる。ログアウト完了後は認証が必要な状態へ戻ったことだけを示す
- **Identifier Naming Rule**: 認証境界からアプリ本体へ受け渡す利用主体参照が存在する場合でも、識別子命名は憲章に従い `XxxIdentifier`、`identifier`、概念名参照を維持する
- **External Ports / Adapters**: Flutter 認証 UI、provider 開始、Firebase Authentication、Firebase ID token 検証、Google identity 検証、Apple identity 検証、LINE identity 検証、session 発行、session 失効、利用主体解決

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 設計成果物は、会員登録、ログイン、ログアウトを vocastock のコアドメイン外にある認証境界として定義しなければならない
- **FR-002**: 設計成果物は、初期対象の会員登録・ログイン手段として少なくとも `Basic` と `Google` を定義し、Flutter 側で開始して Firebase Authentication を本人確認基盤として使う流れを明記しなければならない
- **FR-003**: 設計成果物は、`Apple ID` と `LINE` を追加コストが発生せず、Firebase Authentication または承認済み同等経路で提供できる場合の条件付き候補として定義し、その有効化条件を明記しなければならない
- **FR-004**: 設計成果物は、Flutter 側の認証 UI と provider 開始、Firebase Authentication による本人確認、backend による Firebase ID token 検証、会員登録、ログイン、ログアウト、session 有効化、session 終了、利用主体解決を別責務として整理しなければならない
- **FR-005**: 設計成果物は、認証成功後にアプリ本体へ渡す actor reference と、アプリ本体が保持しない Firebase ID token、refresh token、provider 資格情報、Firebase user 情報を区別して定義しなければならない
- **FR-006**: 設計成果物は、既存メールアドレスまたは既存外部 identity との重複時に、重複会員を新規作成しない規則を定義しなければならない
- **FR-007**: 設計成果物は、会員登録済み利用者のログイン条件として、Flutter 側での開始後に Firebase Authentication の本人確認と backend の Firebase ID token 検証、actor / learner 解決が完了することを定義し、利用不能状態で拒否する条件も定義しなければならない
- **FR-008**: 設計成果物は、ログアウト時に Flutter 側の Firebase sign-out と backend 側の利用状態終了を完了させ、その後の保護操作が再認証を要求する規則を定義しなければならない
- **FR-009**: 設計成果物は、会員登録、ログイン、ログアウトのいずれでも、Flutter 側の Firebase sign-in 成功だけ、または backend 側の部分完了だけの状態を利用者へ成功として見せない規則を定義しなければならない
- **FR-010**: 設計成果物は、認証境界とアプリ本体の接続点として、backend が検証済み Firebase subject から解決した正規化済み利用主体参照の受け渡し方法を定義しなければならない
- **FR-011**: 設計成果物は、provider ごとの利用可否が変わった場合の案内方針を定義し、Firebase Authentication または承認済み同等経路への搭載可否も利用可否判断へ含めなければならない
- **FR-012**: 設計成果物は、今回扱わない範囲を明示し、パスワード再設定、プロフィール管理、課金連携、外部 identity の高度な統合は別論点として切り分けなければならない

### Key Entities *(include if feature involves data)*

- **Auth Account**: 会員登録済みの利用単位を表し、どの認証手段で利用可能かを示す
- **External Identity**: `Google`、`Apple ID`、`LINE` など外部 provider 側の本人識別情報を表し、Firebase Authentication または承認済み同等経路へ接続される対象を示す
- **Verified Firebase Identity**: backend が Firebase ID token を検証した後に得る、Firebase subject と検証結果を束ねた認証境界内の確認済み本人情報を表す
- **Session State**: 現在の利用可能状態、無効状態、終了状態を表す
- **Resolved Actor Reference**: 認証境界からアプリ本体へ受け渡す正規化済み利用主体参照を表す
- **Provider Availability Policy**: 各 provider が初期対象か条件付き対象か、利用不可時にどう扱うかを表す

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー参加者が 10 分以内に、`Basic` と `Google` の会員登録、ログイン、ログアウト導線を 100% 対応付けられる
- **SC-002**: 第三者が 5 分以内に、認証境界と vocastock コアドメインの責務分離を説明できる
- **SC-003**: `Apple ID` と `LINE` の採用条件について、レビュー時の解釈ぶれが 0 件になる
- **SC-004**: 重複会員作成、部分ログイン成功、ログアウト後の保護操作に関する矛盾がレビュー時に 0 件である

## Assumptions

- `Basic` はメールアドレスと秘密情報による一般的な会員登録・ログイン手段を指し、Flutter 側で開始して Firebase Authentication に委譲する
- Flutter が認証 UI と provider 開始を担い、Firebase Authentication を本人確認基盤とし、backend が Firebase ID token を検証して uid から actor / learner を解決する
- 初期リリースでは `Basic` と `Google` を主対象とし、`Apple ID` と `LINE` は追加コストがなく、Firebase Authentication または承認済み同等経路に載せられる場合のみ後続有効化候補とする
- 認証そのものは vocastock のコアドメインモデルに含めず、app core は backend 検証後の正規化済み actor reference だけを受け取る
- 会員登録、ログイン、ログアウトは利用者から見て同期的に完了または失敗し、長時間処理状態は公開しない
- パスワード再設定、メール確認、プロフィール編集、外部 identity の高度なアカウント統合はこの feature の主要対象外とする
