# Feature Specification: バックエンド Command 設計

**Feature Branch**: `007-backend-command-design`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "バックエンドのCommandの実装を行うための設計書を作成する。"

## Clarifications

### Session 2026-04-17

- Q: 登録 command と解説生成開始 command の関係をどう扱うか → A: 登録 command は既定で解説生成を開始するが、明示的に開始しない登録も許可する
- Q: 同一学習者の重複登録時の受理方針をどうするか → A: 新規作成せず、既存 `VocabularyExpression` と現在状態を返す
- Q: command 受理後に workflow dispatch だけ失敗した場合の扱いをどうするか → A: command 全体を失敗として扱い、受付状態を確定しない
- Q: 重複登録時に生成を再開する条件をどうするか → A: 既存状態が `not-started` または `failed` で、かつ開始抑止がない場合だけ再開する

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Command の責務境界を定義する (Priority: P1)

設計担当者として、バックエンドの Command 境界が何を受け付け、どこまで責務を持つかを明確にしたい。これにより、登録、生成開始、再試行の処理を query や workflow と混同せずに実装判断できる。

**Why this priority**: Command 境界の責務が曖昧だと、後続実装で状態変更責務と表示責務が混線するため。

**Independent Test**: 第三者が設計書だけを読んで、各 command が「何を受け付け、何を返し、何を直接実行しないか」を説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 実装担当者が新しい状態変更処理の配置先を判断したい, **When** 設計書を読む, **Then** その処理が backend command 境界に属するかどうかを判断できる
2. **Given** レビュー担当者が責務分離を確認したい, **When** command と query / workflow の責務一覧を見る, **Then** command が長時間処理や表示整形を直接持たないことを確認できる

---

### User Story 2 - Command 契約と状態変更規則を整理する (Priority: P2)

実装担当者として、各 command の入力条件、受理条件、即時応答、状態変更、再試行時の扱いを明文化したい。これにより、登録や生成依頼を一貫した契約で実装できる。

**Why this priority**: 契約が曖昧なままだと、重複登録判定、生成依頼、再試行の挙動が実装ごとにぶれるため。

**Independent Test**: 第三者が設計書だけを読み、主要 command の受理条件、即時応答、状態遷移を説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 学習者が新しい英語表現を登録する, **When** command 契約を確認する, **Then** 重複判定、受付結果、後続生成開始条件を説明できる
2. **Given** 解説生成または画像生成の再試行を設計する, **When** command 規則を確認する, **Then** 同一業務キーでの受理条件と冪等な扱いを説明できる
3. **Given** 学習者が下書き登録だけを行いたい, **When** 登録 command 契約を確認する, **Then** 解説生成を開始しない明示的な受理パターンを説明できる

---

### User Story 3 - 実装前提と除外範囲を合意する (Priority: P3)

設計担当者として、backend command 実装の前提文書、依存境界、今回扱わない範囲を整理したい。これにより、後続の実装計画で scope を広げすぎずに進められる。

**Why this priority**: command 設計だけで解決しない論点まで混ぜると、実装着手条件と成果物の境界が曖昧になるため。

**Independent Test**: 第三者が設計書と既存文書を照合し、command 実装に必要な前提と今回の非対象領域を区別できれば成立する。

**Acceptance Scenarios**:

1. **Given** 開発者が command 実装前に参照すべき文書を確認したい, **When** 設計書を読む, **Then** 依存する要求、ドメイン、アーキテクチャ判断を特定できる
2. **Given** query 側や workflow 側の設計を別 feature で扱いたい, **When** 設計書の scope を確認する, **Then** 今回の対象外である論点を明確に説明できる

### Edge Cases

- 同一学習者が同じ英語表現を再登録しようとした場合に、新規登録、拒否、既存状態の再利用のどれを command が返すか
- 同一学習者が同じ英語表現を再登録しようとした場合に、既存状態が `not-started` または `failed` で、かつ開始抑止がない場合だけ生成開始を再受理すること
- 解説未完了の状態で画像生成 command が要求された場合に、受付拒否と状態通知をどう分けるか
- すでに `pending` または `running` の生成依頼に対して同じ command が再送された場合に、重複実行を避けつつどう受理結果を返すか
- 外部検証や外部生成の失敗詳細を、command の即時応答にどこまで含めるか
- command 受理後に workflow dispatch だけ失敗した場合に、受理結果と状態整合をどう保つか
- command が状態変更を確定した後に dispatch 失敗が起きないよう、どの順で永続化と dispatch を扱うか

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: `docs/internal/domain/common.md`, `docs/internal/domain/service.md`, `docs/internal/domain/explanation.md`, `docs/internal/domain/visual.md`, 暫定 semantic source として参照する `specs/005-domain-modeling/spec.md`
- **Invariants / Terminology**: 学習者、英語表現、解説、画像、頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態は別概念として保ち、command はそれらの状態変更責務のみを扱う
- **Async Lifecycle**: command は登録、生成依頼、再試行、再生成の受付と初期状態設定を担い、長時間実行そのものは別境界へ委譲する。再送時は同一業務キーで冪等に扱う前提を維持する
- **User Visibility Rule**: command は完了済み成果物を即時応答で返す前提を持たず、未完了・失敗は状態のみ扱う
- **Identifier Naming Rule**: 識別子型は `XxxIdentifier`、集約自身の識別子は `identifier`、関連参照は概念名で表現し、`id` / `xxxId` / `xxxIdentifier` を使わない
- **External Ports / Adapters**: 英語表現検証、永続化、workflow dispatch、認証主体受け渡し、生成受付に必要な外部接続境界を整理対象とする
- **Temporary Semantic Source & Exit Condition**: `docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md` が未実体化の間は `specs/005-domain-modeling/spec.md` を learner ownership、一意性、非同期状態語彙の暫定 semantic source とする。exit 条件は、前記 3 文書が正本として materialize され、007 の command 設計がその文書参照へ切り替わることである

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 設計成果物は、backend command 境界が受け付ける状態変更要求の範囲を定義しなければならない
- **FR-002**: 設計成果物は、少なくとも英語表現登録、解説生成開始、画像生成開始、再試行または再生成に関する command を一覧化しなければならない
- **FR-002a**: 設計成果物は、英語表現登録 command が既定では解説生成開始を含む一体 command として振る舞うこと、ただし明示的に解説生成を開始しない登録パターンも許可することを定義しなければならない
- **FR-003**: 設計成果物は、各 command について入力、前提条件、重複判定、受理条件、即時応答、拒否条件を定義しなければならない
- **FR-003a**: 設計成果物は、同一学習者内の重複登録時に新規作成を行わず、既存 `VocabularyExpression` と現在状態を返す受理方針を定義しなければならない
- **FR-003b**: 設計成果物は、重複登録時の追加生成開始について、既存状態が `not-started` または `failed` で、かつ開始抑止がない場合だけ再受理する規則を定義しなければならない
- **FR-004**: 設計成果物は、command が直接担う状態変更と、別境界へ委譲する処理を区別して示さなければならない
- **FR-004a**: 設計成果物は、workflow dispatch が成立しなかった場合は command 全体を失敗として扱い、受付済み `pending` 状態を確定しない規則を定義しなければならない
- **FR-005**: 設計成果物は、登録済み判定、生成中判定、再試行受理など、同一業務キーに対する冪等な扱いを定義しなければならない
- **FR-006**: 設計成果物は、command 受理直後に利用者へ見せてよい情報を定義し、未完了成果物を完了済みとして返さない規則を含まなければならない
- **FR-007**: 設計成果物は、command が参照する外部依存と永続化責務をポート境界として整理しなければならない
- **FR-008**: 設計成果物は、query 境界、workflow 境界、client 境界との責務分離を明記しなければならない
- **FR-009**: 設計成果物は、認証済み主体と command 対象の所有者整合をどの時点で確認するかを定義しなければならない
- **FR-010**: 設計成果物は、失敗時に command が返す要約状態と、内部にのみ保持する失敗詳細を区別しなければならない
- **FR-011**: 設計成果物は、後続実装者が command 実装着手前に参照すべき既存文書とその依存関係を示し、`docs/internal/domain/*.md` 側の正本が未実体化な論点については暫定 semantic source と exit 条件を明記しなければならない
- **FR-012**: 設計成果物は、今回扱わない範囲を明示し、query 実装、workflow 実装、provider 個別実装などを別論点として切り分けなければならない

### Key Entities *(include if feature involves data)*

- **Command Definition**: どの要求を受け付け、何を検証し、何を返すかを表す command ごとの定義
- **Command Acceptance Result**: command 受理時に返す受付結果、状態要約、対象識別情報を表す
- **Duplicate Registration Result**: 重複登録時に既存対象の識別情報、現在状態、追加実行有無、およびその決定条件を返す受理結果
- **Command Ownership Rule**: command 境界が直接更新してよい状態と委譲すべき状態を表す責務規則
- **Dispatch Consistency Rule**: command の受付確定と workflow dispatch が不整合にならないための整合規則
- **Command Idempotency Key**: 重複登録や重複生成依頼を同一業務要求として扱うための識別単位

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー参加者が 10 分以内に、主要 command の 100% について受理対象、拒否条件、即時応答を対応付けられる
- **SC-002**: command と query / workflow の責務境界に関するレビュー上の曖昧さが 0 件になる
- **SC-003**: 重複登録、生成再送、失敗再試行の各ケースについて、第三者が一貫した受理ルールを説明できる
- **SC-004**: 既存要求、ドメイン文書、アーキテクチャ設計との矛盾がレビュー時に 0 件である

## Assumptions

- 今回の feature は backend command の実装そのものではなく、後続 implementation に使う設計成果物の整備を対象とする
- command 境界は既存アーキテクチャで定義済みの状態変更責務を引き継ぎ、長時間実行や表示整形は別境界が担う
- 学習者ごとに英語表現を所有し、同一学習者内で重複登録を判定する前提は維持される
- 英語表現登録 command は通常の利用では解説生成開始を同時に受け付けるが、明示的な入力によって生成開始を抑止できる
- 重複登録時は新規作成ではなく既存対象の再利用を返すことで、利用者は現在状態を再確認できる
- 重複登録時の生成再開は、既存状態が `not-started` または `failed` で、かつ開始抑止がない場合に限る
- workflow dispatch に失敗した場合は command 自体を不成立として扱い、利用者へは受付失敗を返し、`pending` 状態は保存しない
- 完了済み成果物のみを利用者へ見せる表示規則は不変であり、command はその規則を壊さない即時応答を返す
- `docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md` が正本として整備されるまでは、`specs/005-domain-modeling/spec.md` を learner ownership、一意性、非同期状態語彙の暫定 semantic source とする
- 上記の暫定参照は、3 つの domain docs が正本化され、007 の参照先が `docs/internal/domain/*.md` に切り替わった時点で終了する
- query 側の read model 詳細、workflow 側の実行詳細、外部 provider 個別仕様は今回の主要対象外とする
