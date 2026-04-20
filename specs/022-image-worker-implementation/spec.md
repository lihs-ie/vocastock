# Feature Specification: Image Worker Implementation

**Feature Branch**: `022-image-worker-implementation`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: "5. image-workerの実装を行う。"

## Clarifications

### Session 2026-04-20

- Q: `VisualImage` 保存成功後に `currentImage` handoff が失敗した場合の扱い → A: 保存済み `VisualImage` は保持し、non-current の completed 成果物として扱ったまま handoff だけを retryable failure として再試行する
- Q: 同じ `Explanation` に対する複数 accepted image request の current 採用優先順位 → A: 同じ `Explanation` に対してより新しく accepted された request が current 採用権を持ち、古い request が後から成功しても non-current completed として保持する
- Q: 前提不正系 failure の state mapping → A: target 不在、ownership mismatch、未完了 `Explanation`、`Sense` ownership mismatch は `failed-final` に写像し、`dead-lettered` は不明系や operator review 必須の異常だけに使う

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 完了済み解説から画像生成を完了できる (Priority: P1)

学習者として、完了済みの解説に対応する画像が非同期で生成され、完了した画像だけが現在画像として採用されてほしい。そうすることで、解説詳細では常に完成済みの画像だけを安全に閲覧できるようにしたい。

**Why this priority**: `image-worker` の最小価値は、accepted 済み image generation 要求を completed `VisualImage` へ変換し、`Explanation.currentImage` を正しく更新することにあるため。

**Independent Test**: 第三者が成果物だけを読み、accepted 済み image generation 要求が `queued` から `succeeded` へ進み、完了時だけ `currentImage` が切り替わることを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** learner-owned `VocabularyExpression` に紐づく completed `Explanation` があり、その explanation を対象に image generation 要求が accepted 済みである, **When** `image-worker` がその要求を成功裏に処理する, **Then** completed `VisualImage` が保存され、対応する `Explanation.currentImage` が更新される
2. **Given** image generation 要求が `queued` または `running` である, **When** 利用者が read 側から状態を確認する, **Then** completed image payload ではなく status-only だけが利用可能である
3. **Given** 既に completed `currentImage` が存在する, **When** 新しい image generation 試行が完了前に失敗する, **Then** 既存の `currentImage` は維持される
4. **Given** 新しい `VisualImage` の保存は成功したが `currentImage` handoff が未完了である, **When** worker が failure を処理する, **Then** 保存済み `VisualImage` は non-current の completed 成果物として保持され、handoff だけが再試行対象になる
5. **Given** 同じ `Explanation` に対してより新しい image generation request が accepted 済みである, **When** 古い request が後から成功する, **Then** その `VisualImage` は non-current completed として保持されても `currentImage` は上書きしない

---

### User Story 2 - 失敗、再試行、重複要求、前提不正を一貫して扱える (Priority: P2)

運用担当者として、`image-worker` が retryable failure、timeout、terminal failure、duplicate work、target 不在や ownership mismatch を一貫して扱ってほしい。そうすることで、同じ画像が二重生成されたり、未完了または無効な結果が current image として採用されたりすることを防ぎたい。

**Why this priority**: image workflow は completed `Explanation` を前提にした別 worker であり、失敗分類と idempotent handling が曖昧だと 012 の workflow rule と 015 の worker allocation が崩れるため。

**Independent Test**: 第三者が成果物だけを読み、retryable / timeout / terminal / duplicate / invalid target の各ケースで worker がどの状態へ遷移し、何を current image として採用してはいけないかを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** image generation adapter が retryable failure を返す, **When** `image-worker` が failure を処理する, **Then** completed `VisualImage` を保存せず `retry-scheduled` へ遷移する
2. **Given** image generation が timeout または retry exhaustion に達する, **When** `image-worker` が処理を終える, **Then** `failed-final` または `dead-lettered` へ遷移し、current image は切り替わらない
3. **Given** 同じ業務キーの image generation 要求が再送または重複到着する, **When** `image-worker` がそれを処理する, **Then** completed `VisualImage` の重複保存や `Explanation.currentImage` の二重切替を起こさない
4. **Given** accepted 済み work item が completed `Explanation` 不在、所有者不整合、または前提不正を参照している, **When** `image-worker` が処理を開始する, **Then** completed `VisualImage` なしの failure outcome として扱う

---

### User Story 3 - worker 境界と validation 経路を維持できる (Priority: P3)

backend 実装担当者として、`image-worker` が query 応答や public endpoint を持たない worker 境界を維持しつつ、validation 環境で success / retryable / terminal の各経路を再現できてほしい。そうすることで、worker の責務を増やし過ぎずに継続的な検証を行えるようにしたい。

**Why this priority**: worker が image detail の read や public GraphQL binding を持ち始めると 015 の topology と 016 の runtime boundary が崩れ、`query-api` / `graphql-gateway` / `billing-worker` との責務分離にも影響するため。

**Independent Test**: 第三者が成果物だけを読み、`image-worker` の owned responsibility、stable-run 条件、validation で再現すべき success / retryable / terminal 経路を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** `image-worker` runtime が起動している, **When** worker 契約を確認する, **Then** long-running consumer として stable-run を維持し、completed image を直接 user-facing response として返さない
2. **Given** validation 環境で accepted 済み image generation 要求を流す, **When** end-to-end 検証を行う, **Then** 少なくとも 1 つの success 経路、1 つの retryable failure 経路、1 つの terminal failure 経路を再現できる
3. **Given** worker allocation を確認する, **When** `image-worker` の責務をレビューする, **Then** image workflow だけを own し、query response、public GraphQL binding、billing reconciliation を own しない

### Edge Cases

- same explanation / same business key の image generation 要求が `queued` または `running` の間に再送される場合
- accepted 済み work item が completed `Explanation` 不在、他 learner 所有の explanation、または未完了 explanation を参照している場合
- image generation adapter が `succeeded` 相当を返しても、image payload、asset reference、または `sense` 参照が不完全である場合
- completed `VisualImage` の保存は成功したが、`Explanation.currentImage` の handoff が完了していない場合
- 既存 completed image を保持したまま regenerate 相当の試行が timeout した場合
- `VisualImage.sense` が対象 explanation に属さない `Sense` を指している場合
- provider / adapter の詳細 failure reason が user-facing status にそのまま漏れそうな場合
- worker restart 中に `running` work が残り、再開時に duplicate completion を起こしそうな場合
- 同じ `Explanation` に対して古い request と新しい request が並行し、古い request の成功が遅れて到着する場合
- target 不在、ownership mismatch、未完了 `Explanation`、`Sense` ownership mismatch のような deterministic な前提不正が処理開始時に判明する場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: `docs/internal/domain/visual.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/service.md`
- **Invariants / Terminology**: `VisualImage` は独立 aggregate を維持し、`Explanation.currentImage` は単一 current 参照を維持する。`Explanation` 完了状態、`VisualImage` 完了状態、subscription state、registration state を混同しない。`VisualImage.sense` は optional だが、指定される場合は対象 explanation 配下の `Sense` に限定する
- **Application Ownership Rule**: `image-worker` が image generation workflow とその domain rule を所有し、shared package は logging、monitoring、auth/session handoff、request correlation のような sidecar concern に限定する
- **Inner Layer Package Plan**: design では `image-worker` 配下に image work item intake、workflow state machine、image persistence / current handoff coordination、generation port adapter を表す inner layer module を定義し、outer runtime から内側へだけ依存させる
- **Async Lifecycle**: image workflow は少なくとも `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を区別し、同一業務キーは idempotent に扱う
- **User Visibility Rule**: user-facing read は常に `query-api` 経由とし、completed `VisualImage` だけを表示対象にする。`queued`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` では status-only だけを許可する
- **Identifier Naming Rule**: identifier type は `XxxIdentifier` を維持し、aggregate 自身の識別子は `identifier`、関連参照は `explanation`、`sense`、`vocabularyExpression` のような概念名を使う
- **External Ports / Adapters**: accepted command dispatch intake、`VisualImage` asset generation adapter、workflow state persistence、`VisualImage` persistence、`Explanation.currentImage` handoff、asset storage handoff

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、`image-worker` を image generation workflow 専用の worker deployment unit として定義しなければならない
- **FR-002**: 成果物は、learner-owned `VocabularyExpression` に紐づく completed `Explanation` を対象とする accepted 済み image generation 要求を受け取り、workflow state を進行させなければならない
- **FR-003**: 成果物は、initial slice として image start が抑止されていない accepted image generation 要求を処理対象に含めなければならない
- **FR-004**: 成果物は、completed `VisualImage` の保存と `Explanation.currentImage` の handoff が両方成立したときだけ success として扱わなければならない
- **FR-004a**: 成果物は、completed `VisualImage` の保存に成功したが `Explanation.currentImage` handoff が未完了のケースでは、保存済み `VisualImage` を non-current の completed 成果物として保持しつつ、handoff だけを retryable failure として扱わなければならない
- **FR-005**: 成果物は、`queued`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` のいずれでも、未完了 image payload を completed 結果として扱ってはならない
- **FR-006**: 成果物は、新しい generation 試行が success 前に失敗した場合、既存の completed `currentImage` を維持しなければならない
- **FR-007**: 成果物は、少なくとも `queued`、`running`、`retry-scheduled`、`timed-out`、`succeeded`、`failed-final`、`dead-lettered` を image workflow の区別可能な状態として扱わなければならない
- **FR-008**: 成果物は、retryable failure、timeout、non-retryable failure を区別し、それぞれ retry scheduling または terminal failure へ写像しなければならない
- **FR-009**: 成果物は、同一業務キーの replay / duplicate work を idempotent に扱い、completed `VisualImage` の重複保存や `Explanation.currentImage` の重複切替を起こしてはならない
- **FR-009a**: 成果物は、同じ `Explanation` に対する複数 accepted image generation request のうち、より新しく accepted された request だけに `currentImage` 採用権を与え、古い request が後から成功しても non-current completed として保持しなければならない
- **FR-010**: 成果物は、処理開始時に target 不在、所有者不整合、前提不正、または `Sense` ownership mismatch が判明した work item を completed `VisualImage` なしの failure outcome として扱わなければならない
- **FR-010a**: 成果物は、target 不在、ownership mismatch、未完了 `Explanation`、`Sense` ownership mismatch のような deterministic な前提不正を `failed-final` に写像し、`dead-lettered` は不明系または operator review 必須の異常に限定しなければならない
- **FR-011**: 成果物は、user-facing には status-only で十分な failure summary を保持できるようにしつつ、provider / adapter の詳細内部情報を completed payload や公開応答へ漏らしてはならない
- **FR-012**: 成果物は、`image-worker` が query response、public GraphQL binding、explanation generation workflow、billing reconciliation を own してはならないことを明示しなければならない
- **FR-013**: 成果物は、validation 経路として success、retryable failure、terminal failure の少なくとも 3 系統を再現可能にしなければならない
- **FR-014**: 成果物は、この feature の scope を image generation workflow 実装に限定し、multiple current image / meaning gallery、billing policy、provider 固有最適化、public schema 拡張、image search UX を deferred scope として明示しなければならない

### Key Entities *(include if feature involves data)*

- **ImageGenerationWorkItem**: accepted 済み image generation 要求を表す処理単位。target `Explanation`、業務キー、起点理由、optional `Sense`、現在の workflow state を持つ
- **ImageWorkflowState**: `queued` から terminal state までの lifecycle、attempt 回数、retry eligibility、timeout 判定を表す状態
- **CompletedVisualImageRecord**: user-visible にしてよい completed `VisualImage` の保存結果。asset reference、対象 explanation、optional `sense`、表示可能メタデータを持つ
- **CurrentImageHandoff**: completed `VisualImage` を `Explanation.currentImage` として採用するか、既存 current を維持するかの判断結果
- **ImageFailureSummary**: status-only 表示に使う failure 要約。retryable か terminal か、再試行余地があるかを示す

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が 10 分以内に、accepted 済み image generation 要求が completed `VisualImage` と `currentImage` handoff へ到達する条件を説明できる
- **SC-002**: validation で、success 1 系統、retryable failure 1 系統、terminal failure 1 系統を再現しても、未完了 image payload が user-visible completed と誤認されるケースが 0 件である
- **SC-003**: duplicate / replay work を含む検証で、同一業務要求に対する completed `VisualImage` の重複作成または `Explanation.currentImage` の重複切替が 0 件である
- **SC-004**: レビュー時に `image-worker`、`query-api`、`graphql-gateway`、`billing-worker` の責務境界について判断不能ケースが 0 件である

## Assumptions

- initial slice は既存の accepted image generation flow を再利用し、completed `Explanation` を前提とする要求を worker 実行対象にする
- standalone image generation intake の public binding が未実装でも、upstream acceptance が完了している work item から worker 実装を始めてよい
- image asset 生成自体は completed-only / status-only 契約を満たす限り、stubbed source または本番向け adapter のいずれでもよい
- auth/session handoff、duplicate request 判定、quota / entitlement gate は worker ではなく upstream boundary で処理済みである
- user-visible read は `query-api` が継続して担当し、worker は completed result を直接返さない
- explanation generation workflow、billing workflow、public GraphQL schema 全体の拡張はこの feature の主要対象外である
- deployment catalog と worker runtime 契約は `specs/015-command-query-topology/` および `specs/016-application-docker-env/` の正本を踏襲する
