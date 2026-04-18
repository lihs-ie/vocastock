# Feature Specification: 永続化 / Read Model と非同期 Workflow 設計

**Feature Branch**: `012-persistence-workflow-design`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "2. 永続化 / Read Model 設計書 どの aggregate をどこに保存するかを固定する文書です 例: Learner、VocabularyExpression、LearningState、Explanation、VisualImage、subscription state、purchase state、entitlement の保存先 一意制約、index、ownership、read model の組み立て方もここで決めます 3. 非同期 Workflow / State Machine 設計書 explanation 生成、image 生成、purchase verification、restore、notification reconciliation の状態遷移表です pending/running/succeeded/failed だけでなく、retry 条件、timeout、fallback、dead-letter 相当の扱い、partial success 非許容を明記すべきです"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 集約と read model の保存責務を固定する (Priority: P1)

設計担当者として、どの aggregate と状態概念をどの保存境界へ置くかを固定したい。これにより、
後続実装で write-side と read-side の責務がぶれず、ownership、一意制約、index 設計を同じ前提で議論できる。

**Why this priority**: 保存責務が曖昧なままだと command 実装、query 実装、workflow 実装のすべてが不安定になるため。

**Independent Test**: 第三者が設計書だけを読み、`Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、`VisualImage`、authoritative subscription state、purchase state、entitlement の保存先、主 ownership、一意制約、主要 index を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 実装担当者が `VocabularyExpression` 登録と学習状態の保存責務を確認したい, **When** 設計書を読む, **Then** `Learner`、`VocabularyExpression`、`LearningState` の write-side 保存先、一意制約、ownership、主要 lookup 軸を説明できる
2. **Given** 実装担当者が解説・画像生成結果と課金状態の保存責務を確認したい, **When** 設計書を読む, **Then** `Explanation`、`VisualImage`、subscription state、purchase state、entitlement の authoritative store と read model 組み立て方を説明できる
3. **Given** reviewer が query read の前提を確認したい, **When** read model 節を読む, **Then** どの aggregate / state からどの app-facing projection を組み立てるかを説明できる

---

### User Story 2 - 非同期 workflow と状態遷移を固定する (Priority: P2)

設計担当者として、長時間処理と課金同期の状態遷移表を固定したい。これにより、retry、timeout、
fallback、dead-letter 相当、partial success 非許容の扱いが workflow ごとにぶれない。

**Why this priority**: state machine が曖昧だと explanation/image 生成と subscription 同期で失敗処理が実装ごとに分裂するため。

**Independent Test**: 第三者が設計書だけを読み、explanation 生成、image 生成、purchase verification、restore、notification reconciliation の各 workflow について、主要 state、遷移条件、retry 条件、timeout、fallback、exhaustion 後の扱いを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** explanation 生成または image 生成が失敗した, **When** state machine を読む, **Then** retry 可否、timeout 後の扱い、partial success を user-visible success にしない規則を説明できる
2. **Given** purchase verification または restore が遅延した, **When** workflow 契約を読む, **Then** purchase state と subscription state を混同せず、timeout / fallback / 再同期方針を説明できる
3. **Given** notification reconciliation が繰り返し失敗した, **When** recovery 規則を読む, **Then** dead-letter 相当の退避と mirror 保持方針を説明できる

---

### User Story 3 - read/write 境界と deferred scope を固定する (Priority: P3)

設計担当者として、保存設計と workflow 設計がどこまでを正本化し、どこから先を別 feature や後続実装へ委ねるかを整理したい。これにより、
007 / 008 / 009 / 010 / 011 と衝突せずに persistence / runtime 設計を進められる。

**Why this priority**: 保存責務と workflow runtime は既存 feature の behavioral contract と接続するため、境界を明示しないと責務の再定義が起きやすいため。

**Independent Test**: 第三者が設計書だけを読み、どの状態が authoritative write store に属し、どの情報が read projection で公開され、どの実装詳細が deferred scope なのかを 5 分以内に割り当てられれば成立する。

**Acceptance Scenarios**:

1. **Given** reviewer が command / auth / component / subscription 設計との接続点を確認したい, **When** source-of-truth 節を読む, **Then** 007 / 008 / 009 / 010 / 011 との責務分担を説明できる
2. **Given** reviewer が物理 DB、queue、vendor SDK detail の扱いを確認したい, **When** deferred scope を読む, **Then** この feature が固定する論点と後続 feature へ委ねる論点を区別できる

### Edge Cases

- 同一学習者内で同じ `NormalizedVocabularyExpressionText` が再登録される場合、write-side 一意制約と read model 再利用がどう整合するか
- `Explanation` が成功したが `VisualImage` 保存が失敗した場合、partial success を user-visible completed result として公開してはならないケース
- image 生成 request が `Sense` 指定付きで再送された場合、workflow attempt と current image 切替をどう扱うか
- purchase verification が timeout したが store notification が後から到着した場合、purchase state と authoritative subscription state のどちらを進めるか
- restore と notification reconciliation が同時に走る場合、どちらが authoritative write を行うか
- retry 上限を超えた workflow が再度失敗した場合、dead-letter 相当の退避先と operator review 導線をどう持つか
- `pending-sync` や `grace` を read model で表示しても、premium unlock 確定情報と混同してはならない場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: `docs/internal/domain/common.md`、`docs/internal/domain/learner.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/learning-state.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md` は terminology source として参照するが、aggregate semantics 自体は再定義しない
- **Invariants / Terminology**: `Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、`VisualImage`、subscription state、purchase state、entitlement、usage allowance、workflow attempt は別概念として維持し、registration / explanation / image / purchase / subscription の状態概念を混同しない
- **Async Lifecycle**: explanation 生成、image 生成、purchase verification、restore、notification reconciliation は少なくとも pending / running / succeeded / failed と、retry exhaustion、timeout、fallback、dead-letter 相当の終端を区別する
- **User Visibility Rule**: completed result だけを user-facing read model へ公開し、pending / failed / timed-out / dead-letter 状態では status のみを返す。partial success は completed として公開しない
- **Identifier Naming Rule**: 識別子型は `XxxIdentifier`、集約自身の識別子は `identifier`、関連参照は概念名で表現し、`id` / `xxxId` / `xxxIdentifier` を導入しない
- **External Ports / Adapters**: validation adapter、explanation/image provider adapter、asset storage adapter、mobile storefront adapter、purchase verification adapter、store notification adapter、auth/session boundary output を参照するが、vendor-specific implementation detail は持ち込まない

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、`Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、`VisualImage`、authoritative subscription state、purchase state、entitlement、idempotency record、workflow attempt record の canonical 保存境界を定義しなければならない
- **FR-002**: 成果物は、各保存対象について authoritative writer、ownership 軸、主 lookup key、一意制約、主要 index を定義しなければならない
- **FR-003**: 成果物は、同一学習者内重複登録、actor-owned target lookup、`Explanation.currentImage` 解決、`VisualImage.sense` 解決、subscription state lookup の read-side lookup ルールを定義しなければならない
- **FR-004**: 成果物は、app-facing read model として少なくとも vocabulary registration summary、explanation detail / status、image detail / status、subscription status、entitlement / allowance summary の組み立て方を定義しなければならない
- **FR-005**: 成果物は、read model がどの authoritative aggregate / state を参照して構成されるか、completed result と status-only 情報をどこで分離するかを定義しなければならない
- **FR-006**: 成果物は、explanation 生成と image 生成の workflow state machine について、主要 state、遷移条件、retry 条件、timeout、fallback、dead-letter 相当、partial success 非許容を定義しなければならない
- **FR-007**: 成果物は、purchase verification、restore、notification reconciliation の workflow state machine について、purchase state と authoritative subscription state の関係、retry 条件、timeout、fallback、dead-letter 相当を定義しなければならない
- **FR-008**: 成果物は、workflow attempt の保存と更新が authoritative aggregate 更新とどの順序で整合するかを定義しなければならない
- **FR-009**: 成果物は、retry exhaustion 後の operator review / dead-letter 相当の退避先と、user-facing read model への表示方針を定義しなければならない
- **FR-010**: 成果物は、timeout 後に authoritative state を進めない条件と、fallback として既存 completed result / mirror を維持してよい条件を定義しなければならない
- **FR-011**: 成果物は、partial success を completed read model として公開せず、どの保存対象が揃ったときだけ succeeded とみなすかを定義しなければならない
- **FR-012**: 成果物は、007 の command semantics、008 の actor handoff、009 の component boundary、010 の subscription boundary、011 の command I/O contract を前提に、persistence / workflow runtime が固定する責務だけを定義しなければならない
- **FR-013**: 成果物は、transport schema、provider payload detail、物理 DB / queue 製品選定、deployment topology、vendor SDK detail を deferred scope として明示しなければならない
- **FR-014**: 成果物は、`pending-sync`、`grace`、`expired`、`revoked` と purchase state を read model へどう反映するかを定義し、未確認 premium unlock を completed entitlement と混同してはならない
- **FR-015**: 成果物は、read model refresh と workflow state 更新の整合期待値を定義し、reviewer が stale read と authoritative write の責務差分を説明できるようにしなければならない
- **FR-016**: 成果物は、後続実装者が 10 分以内に保存先一覧、一意制約、主要 index、state machine、dead-letter / fallback 方針を追跡できる source-of-truth 導線を提供しなければならない

### Key Entities *(include if feature involves data)*

- **Persistence Allocation**: 各 aggregate / state / policy record をどの authoritative store に置くかを表す割当単位
- **Read Projection**: user-facing または app-facing 表示のために authoritative state から構成される要約単位
- **Workflow State Machine**: 非同期処理ごとの state、遷移条件、終端条件、retry / timeout / fallback を束ねる定義単位
- **Workflow Attempt Record**: 各 workflow 実行の最新状態、retry 回数、timeout / exhaustion 情報を保持する記録単位
- **Dead-Letter Review Unit**: 自動 retry を打ち切った後に operator review が必要な失敗単位
- **Subscription Runtime State**: authoritative subscription state、purchase state、entitlement、allowance の関係をまとめる保存 / read model 単位

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー参加者が 10 分以内に、主要 aggregate / state の保存先、ownership、一意制約、主要 index を 100% 対応付けられる
- **SC-002**: レビュー参加者が 10 分以内に、explanation / image / purchase / restore / notification の各 workflow について state 遷移、retry 条件、timeout、fallback、dead-letter 相当を一貫して説明できる
- **SC-003**: partial success、stale read、`pending-sync`、`grace` の扱いについて、レビュー時の解釈ぶれが 0 件になる
- **SC-004**: 007 / 008 / 009 / 010 / 011 との責務衝突がレビュー時に 0 件であり、後続実装者が 5 分以内に deferred scope を識別できる

## Assumptions

- この feature は product code 実装ではなく、永続化 / read model 設計と workflow runtime 設計の docs-first 成果物を対象とする
- 物理的な database、queue、cache、scheduler、vendor SDK の選定は後続実装または別 feature に委ねる
- authoritative write store は aggregate / runtime state ごとに明示するが、read model は app-facing projection として別責務で扱う
- `Explanation` と `VisualImage` は独立集約のまま維持し、completed result と generation status を分離して read model を組み立てる
- purchase verification、restore、notification reconciliation は subscription / purchase runtime を共有するが、premium unlock の最終正本は backend authoritative subscription state に置く
- dead-letter 相当の扱いは operator review が必要な終端状態として定義し、user-facing completed result ではない
