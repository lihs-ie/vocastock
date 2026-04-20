# Feature Specification: Explanation Worker Implementation

**Feature Branch**: `021-explanation-worker-implementation`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: "4. explanation-workerの実装を設計書に従って実装する。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 登録済み語彙の解説生成を完了できる (Priority: P1)

学習者として、登録した英語表現に対する解説が非同期で生成され、完了した結果だけが現在の解説として採用されてほしい。そうすることで、登録後に状態を確認しながら、完成した解説だけを安心して閲覧できるようにしたい。

**Why this priority**: `explanation-worker` の最小価値は、accepted 済みの生成要求を completed explanation へ変換し、`currentExplanation` を正しく更新することにあるため。

**Independent Test**: 第三者が成果物だけを読み、accepted 済みの explanation generation 要求が `queued` から `succeeded` へ進み、完了時だけ `currentExplanation` が切り替わることを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** learner-owned `VocabularyExpression` に対する explanation generation 要求が accepted 済みである, **When** `explanation-worker` がその要求を成功裏に処理する, **Then** completed `Explanation` が保存され、対応する `VocabularyExpression.currentExplanation` が更新される
2. **Given** explanation generation 要求が `queued` または `running` である, **When** 利用者が read 側から状態を確認する, **Then** completed explanation 本文ではなく status-only だけが利用可能である
3. **Given** 既に completed `currentExplanation` が存在する, **When** 新しい explanation generation 試行が完了前に失敗する, **Then** 既存の `currentExplanation` は維持される

---

### User Story 2 - 失敗、再試行、重複要求を一貫して扱える (Priority: P2)

運用担当者として、`explanation-worker` が retryable failure、timeout、terminal failure、duplicate work を一貫して扱ってほしい。そうすることで、同じ業務要求で解説が二重生成されたり、未完了結果が completed 扱いになったりすることを防ぎたい。

**Why this priority**: explanation workflow は非同期処理であり、失敗分類と idempotent handling が曖昧だと 012 の state machine と 015 の worker allocation が崩れるため。

**Independent Test**: 第三者が成果物だけを読み、retryable / terminal / duplicate の各ケースで worker がどの状態へ遷移し、何を user-visible にしてはいけないかを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** explanation generation が retryable failure を返す, **When** `explanation-worker` が failure を処理する, **Then** completed explanation を保存せず `retry-scheduled` へ遷移する
2. **Given** explanation generation が timeout または retry exhaustion に達する, **When** `explanation-worker` が処理を終える, **Then** `failed-final` または `dead-lettered` へ遷移し、status-only failure として扱う
3. **Given** 同じ業務キーの explanation generation 要求が再送または重複到着する, **When** `explanation-worker` がそれを処理する, **Then** completed `Explanation` の重複保存や `currentExplanation` の二重切替を起こさない

---

### User Story 3 - worker 境界と runtime 検証を維持できる (Priority: P3)

backend 実装担当者として、`explanation-worker` が query 応答や public endpoint を持たない worker 境界を維持しつつ、validation 環境で success / failure の両経路を再現できてほしい。そうすることで、worker の責務を増やし過ぎずに継続的な検証を行えるようにしたい。

**Why this priority**: worker が user-facing response を持ち始めると 015 の topology と 016 の runtime boundary が崩れ、後続の image / billing worker との責務分離にも影響するため。

**Independent Test**: 第三者が成果物だけを読み、`explanation-worker` の owned responsibility、stable-run 条件、validation で再現すべき success / failure 経路を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** `explanation-worker` runtime が起動している, **When** worker 契約を確認する, **Then** long-running consumer として stable-run を維持し、completed explanation を直接 user-facing response として返さない
2. **Given** validation 環境で accepted 済みの explanation generation 要求を流す, **When** end-to-end 検証を行う, **Then** 少なくとも 1 つの success 経路と 1 つの non-success 経路を再現できる
3. **Given** worker allocation を確認する, **When** `explanation-worker` の責務をレビューする, **Then** explanation workflow だけを own し、query response、image workflow、billing reconciliation を own しない

### Edge Cases

- 同じ `VocabularyExpression` に対する explanation generation 要求が `queued` または `running` の間に再送される場合
- accepted 済み work item が処理開始時点で不在、所有者不整合、または無効な target を参照している場合
- generation adapter が `succeeded` 相当を返しても、completed explanation payload が不完全または不整合である場合
- completed `Explanation` の保存は成功したが、`VocabularyExpression.currentExplanation` の handoff が完了していない場合
- 既存 completed explanation を保持したまま regenerate 相当の試行が timeout した場合
- provider / adapter の詳細 failure reason が user-facing status にそのまま漏れそうな場合
- worker restart 中に `running` work が残り、再開時に duplicate completion を起こしそうな場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: `docs/internal/domain/explanation.md`、`docs/internal/domain/vocabulary-expression.md`、`docs/internal/domain/service.md`
- **Invariants / Terminology**: `Explanation` は `Sense`、`Frequency`、`Sophistication` を所有し、`VocabularyExpression.registrationStatus`、`VocabularyExpression.explanationGeneration`、`Explanation.imageGeneration`、subscription state と混同しない
- **Async Lifecycle**: explanation workflow は少なくとも `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を区別し、同一業務キーは idempotent に扱う
- **User Visibility Rule**: user-facing read は常に `query-api` 経由とし、completed `Explanation` だけを表示対象にする。`queued`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` では status-only だけを許可する
- **Identifier Naming Rule**: identifier type は `XxxIdentifier` を維持し、aggregate 自身の識別子は `identifier`、関連参照は `vocabularyExpression` や `sense` のような概念名を使う
- **External Ports / Adapters**: accepted command dispatch intake、`ExplanationGenerationPort`、workflow state persistence、`Explanation` persistence、`VocabularyExpression.currentExplanation` handoff

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、`explanation-worker` を explanation generation workflow 専用の worker deployment unit として定義しなければならない
- **FR-002**: 成果物は、learner-owned `VocabularyExpression` を対象とする accepted 済み explanation generation 要求を受け取り、workflow state を進行させなければならない
- **FR-003**: 成果物は、initial slice として explanation start が抑止されていない accepted registration 起点の explanation generation 要求を処理対象に含めなければならない
- **FR-004**: 成果物は、completed `Explanation` の保存と `VocabularyExpression.currentExplanation` の handoff が両方成立したときだけ success として扱わなければならない
- **FR-005**: 成果物は、`queued`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` のいずれでも、未完了 explanation 本文を completed 結果として扱ってはならない
- **FR-006**: 成果物は、新しい generation 試行が success 前に失敗した場合、既存の completed `currentExplanation` を維持しなければならない
- **FR-007**: 成果物は、少なくとも `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を explanation workflow の区別可能な状態として扱わなければならない
- **FR-008**: 成果物は、retryable failure、timeout、non-retryable failure を区別し、それぞれ retry scheduling または terminal failure へ写像しなければならない
- **FR-009**: 成果物は、同一業務キーの replay / duplicate work を idempotent に扱い、completed `Explanation` の重複保存や `currentExplanation` の重複切替を起こしてはならない
- **FR-010**: 成果物は、処理開始時に target 不在、所有者不整合、または前提不正が判明した work item を completed `Explanation` なしの failure outcome として扱わなければならない
- **FR-011**: 成果物は、user-facing には status-only で十分な failure summary を保持できるようにしつつ、provider / adapter の詳細内部情報を completed payload や公開応答へ漏らしてはならない
- **FR-012**: 成果物は、`explanation-worker` が query response、public GraphQL binding、image generation workflow、billing reconciliation を own してはならないことを明示しなければならない
- **FR-013**: 成果物は、validation 経路として success、retryable failure、terminal failure の少なくとも 3 系統を再現可能にしなければならない
- **FR-014**: 成果物は、この feature の scope を explanation generation workflow 実装に限定し、image generation、billing policy、provider 固有最適化、全文検索、public schema 拡張を deferred scope として明示しなければならない

### Key Entities *(include if feature involves data)*

- **ExplanationGenerationWorkItem**: accepted 済み explanation generation 要求を表す処理単位。target `VocabularyExpression`、業務キー、起点理由、現在の workflow state を持つ
- **ExplanationWorkflowState**: `queued` から terminal state までの lifecycle、attempt 回数、retry eligibility、timeout 判定を表す状態
- **CompletedExplanationRecord**: user-visible にしてよい completed `Explanation` の保存結果。`Sense`、`Frequency`、`Sophistication`、発音、語源、類似表現を含む
- **CurrentExplanationHandoff**: completed `Explanation` を `VocabularyExpression.currentExplanation` として採用するか、既存 current を維持するかの判断結果
- **ExplanationFailureSummary**: status-only 表示に使う failure 要約。retryable か terminal か、再試行余地があるかを示す

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が 10 分以内に、accepted 済み explanation generation 要求が completed `Explanation` と `currentExplanation` handoff へ到達する条件を説明できる
- **SC-002**: validation で、success 1 系統、retryable failure 1 系統、terminal failure 1 系統を再現しても、未完了 explanation 本文が user-visible completed と誤認されるケースが 0 件である
- **SC-003**: duplicate / replay work を含む検証で、同一業務要求に対する completed `Explanation` の重複作成または `currentExplanation` の重複切替が 0 件である
- **SC-004**: レビュー時に `explanation-worker`、`command-api`、`query-api`、`image-worker` の責務境界について判断不能ケースが 0 件である

## Assumptions

- initial slice は既存の accepted registration flow を再利用し、explanation start が抑止されていない要求を worker 実行対象にする
- standalone `requestExplanationGeneration` command の public intake は、upstream acceptance が未実装なら後続 slice で接続してよい
- explanation 本文の生成自体は completed-only / status-only 契約を満たす限り、stubbed source または本番向け adapter のいずれでもよい
- auth/session handoff、duplicate registration 判定、quota / entitlement gate は worker ではなく upstream boundary で処理済みである
- user-visible read は `query-api` が継続して担当し、worker は completed result を直接返さない
- image generation workflow、billing workflow、public GraphQL schema 全体の拡張はこの feature の主要対象外である
- deployment catalog と worker runtime 契約は `specs/015-command-query-topology/` および `specs/016-application-docker-env/` の正本を踏襲する
