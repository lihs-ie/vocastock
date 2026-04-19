# Feature Specification: Application Container Environments

**Feature Branch**: `016-application-docker-env`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "それぞれのアプリケーションのDocker環境を作らないといけないよ"

## Clarifications

### Session 2026-04-19

- Q: worker の canonical run mode は何か → A: `long-running consumer` を正本 run mode とし、queue / subscription を待ち受ける常駐プロセスとして扱う
- Q: local / CI の image 契約は何を共有するか → A: 同じ Dockerfile / target / entry contract を正本にし、image artifact 自体はそれぞれで build してよい
- Q: API service の canonical success signal は何か → A: `HTTP readiness endpoint` が応答して初めて起動成功とみなす
- Q: worker の canonical success signal は何か → A: queue / subscription を待ち受けるプロセスとして安定稼働できることを正本とし、外向き HTTP endpoint は必須にしない

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 各アプリの実行環境を独立して再現する (Priority: P1)

開発者として、各 deployable application を他のアプリと分離した状態で起動できる実行環境を持ちたい。そうすることで、`graphql-gateway`、`command-api`、`query-api`、各 worker の責務を混ぜずに実装と検証を進められるようにしたい。

**Why this priority**: 実行環境の単位が曖昧だと、設計で分けた deployment boundary が実装段階で崩れるため。

**Independent Test**: 第三者が成果物だけを読み、対象アプリごとの起動単位、必要入力、起動条件、成功条件を 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** backend service または worker のいずれかを確認する, **When** その実行環境定義を見る, **Then** そのアプリ単独で必要な runtime dependency、入力、起動契約が分かる
2. **Given** `command-api` と `query-api` の実行環境を比較する, **When** 境界責務を見る, **Then** command/query separation を崩さない別起動単位として整理されている

---

### User Story 2 - 共通要件とアプリ固有要件を分離する (Priority: P2)

実装担当者として、各アプリの実行環境で共通化できる dependency と、各アプリだけが必要とする dependency を分けて把握したい。そうすることで、余計な差分や設定漏れを避けながら保守できるようにしたい。

**Why this priority**: すべてのアプリに同じ実行条件を押し込むと、worker と API の差分や gateway 固有要件が埋もれるため。

**Independent Test**: 第三者が成果物だけを読み、共通 runtime baseline と app-specific requirement を 10 分以内に振り分けられれば成立する。

**Acceptance Scenarios**:

1. **Given** 任意の 2 つ以上のアプリを比較する, **When** runtime requirement を見る, **Then** 共通 dependency とアプリ固有 dependency が区別されている
2. **Given** worker を確認する, **When** 外向き listener の有無や完了条件を見る, **Then** API service と異なる起動・終了・監視条件が明示され、worker は `long-running consumer` として扱われている

---

### User Story 3 - ローカルと CI の検証契約を揃える (Priority: P3)

保守担当者として、各アプリの実行環境がローカル検証と CI 検証で同じ契約を共有していることを確認したい。そうすることで、手元で動くのに自動検証では動かない構成ずれを減らしたい。

**Why this priority**: 実行環境の定義がローカル専用になると、後続の build、smoke、deploy の基盤が再び分岐するため。

**Independent Test**: 第三者が成果物だけを読み、各アプリの build/run/health の契約がローカルと CI で共通であることを 10 分以内に説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** 任意のアプリの実行環境定義を確認する, **When** 検証用途を見る, **Then** ローカル起動と CI 検証で共有する Dockerfile / target / entry contract が定義されている
2. **Given** 起動失敗や設定不足が発生する, **When** failure contract を確認する, **Then** どの入力不足や依存不足で失敗したかを切り分ける導線がある

### Edge Cases

- API service には外向き listener と `HTTP readiness endpoint` が必要だが、worker には不要な場合に、同じ成功条件で誤って扱ってしまうケース
- あるアプリだけ追加の system dependency や credential boundary を必要とする場合に、共通 baseline へ誤って混ぜてしまうケース
- 起動に必要な環境変数が不足しているが、build 自体は成功してしまうケース
- ローカルでは単独起動できるが、CI では依存先への接続条件が不足して挙動差が出るケース
- command/query/worker を一つの実行環境へまとめてしまい、015 の deployment topology と矛盾するケース
- worker に外向き HTTP endpoint がなくても正常だが、待受プロセスとして安定稼働している状態を失敗と誤判定してしまうケース

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None
- **Invariants / Terminology**: `graphql-gateway`、`command-api`、`query-api`、`explanation-worker`、`image-worker`、`billing-worker` の deployment boundary は維持し、`Command Intake`、`Query Read`、`Async Generation`、`Async Subscription Reconciliation` を同じ runtime unit へ再統合してはならない
- **Async Lifecycle**: worker 側の `pending` / `running` / `succeeded` / `failed`、retry、timeout、dead-letter 相当の設計は 012 の正本を再利用し、今回の feature では各 lifecycle を実行できる container runtime contract を整理する
- **User Visibility Rule**: 実行環境の整理後も、ユーザーに見せてよい生成物は completed result のみとし、pending / failed は status-only のまま維持する
- **Identifier Naming Rule**: 既存の `XxxIdentifier`、`identifier`、関連参照の命名規則を変えない
- **External Ports / Adapters**: identity boundary、state store boundary、async messaging boundary、asset storage boundary、billing verification / notification boundary、local dependency stack 接続など、各アプリが必要とする外部接続境界を整理対象に含める

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、in-scope の各 deployable application について、独立した containerized runtime environment を定義しなければならない
- **FR-002**: 成果物は、in-scope application を少なくとも `graphql-gateway`、`command-api`、`query-api`、`explanation-worker`、`image-worker`、`billing-worker` として整理しなければならない
- **FR-003**: 成果物は、各 application ごとに build/run entry contract、必要入力、依存サービス、成功条件を定義しなければならない
- **FR-004**: 成果物は、shared runtime baseline と app-specific runtime requirement を区別しなければならない
- **FR-005**: 成果物は、各 application ごとに required / optional の環境入力を区別し、secret boundary と local default boundary を示さなければならない
- **FR-006**: 成果物は、listener を持つ application と持たない application を区別し、health / readiness / completion の判定契約を分けて定義しなければならない。worker は `long-running consumer` を canonical run mode として扱わなければならず、API service は `HTTP readiness endpoint` が応答して初めて起動成功とみなさなければならない。worker は queue / subscription を待ち受けるプロセスとして安定稼働できることを canonical success signal とし、外向き HTTP endpoint を必須にしてはならない
- **FR-007**: 成果物は、各 application の runtime environment が local verification と CI verification で共有する Dockerfile / target / entry contract を持つことを定義しなければならない。image artifact 自体は local / CI で別 build を許可しなければならない
- **FR-008**: 成果物は、015 で固定した `graphql-gateway`、`command-api`、`query-api`、worker の deployment separation を実行環境側でも維持しなければならない
- **FR-009**: 成果物は、既存の local dependency stack を repository-wide shared dependency として扱いつつ、各 application の実行環境定義と混同しないよう境界を示さなければならない
- **FR-010**: 成果物は、Flutter client を今回の containerized application scope から外し、backend / worker application の実行環境に限定しなければならない
- **FR-011**: 成果物は、起動失敗、設定不足、依存先未接続などの典型 failure mode に対して、切り分け可能な troubleshooting contract を定義しなければならない
- **FR-012**: 成果物は、どの source-of-truth を更新するかを示し、`docs/external/adr.md`、`docs/external/requirements.md`、関連 topology / command / workflow / stack spec との同期箇所を定義しなければならない

### Key Entities *(include if feature involves data)*

- **Application Runtime Profile**: 各 application の起動単位、runtime dependency、entry contract、成功条件を表す定義
- **Shared Runtime Baseline**: 複数 application で共有する base dependency、共通入力、共通運用 rule の集合
- **Application-Specific Requirement**: 特定 application のみに必要な dependency、input、接続条件、監視条件
- **Environment Input Catalog**: required / optional の runtime input、secret boundary、local default boundary を表す一覧
- **Execution Contract**: build、起動、終了、health / readiness / completion の判定方法を表す契約
- **Source-of-Truth Update Map**: 実行環境 feature を反映する正本文書と関連 spec package の更新先一覧

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー担当者が 10 分以内に、in-scope application の 100% について起動単位、必要入力、成功条件を説明できる
- **SC-002**: 開発者が任意の 1 application を選び、その実行環境の build/run 契約を 15 分以内に再現できる
- **SC-003**: in-scope application の 100% について、shared requirement と app-specific requirement の区別が記録される
- **SC-004**: in-scope application の 100% について、health / readiness / completion のいずれか適切な判定契約と failure troubleshooting 導線が定義される

## Assumptions

- 今回の対象は backend / worker の deployable application とし、Flutter client は含めない
- container runtime は local / CI の両方で再利用できる path を前提とするが、feature 本文では実行契約と境界定義を正本とする
- 既存の repository-wide local dependency stack は再利用し、各 application 個別の実行環境 feature とは分けて扱う
- `graphql-gateway`、`command-api`、`query-api`、`explanation-worker`、`image-worker`、`billing-worker` の application catalog は topology 正本を引き継ぐ
- worker は `long-running consumer` を canonical run mode とし、補助的な debug invocation は正本 run contract の代替にしない
- local / CI は同じ Dockerfile / target / entry contract を使うが、生成済み image artifact の共有までは必須にしない
- API service の canonical success signal は `HTTP readiness endpoint` の応答とし、process 起動のみを成功条件にしない
- worker の canonical success signal は queue / subscription を待ち受けるプロセスとしての安定稼働とし、外向き HTTP endpoint を必須にしない
- image publication target や deployment pipeline 詳細は follow-on implementation で具体化する
- auth/session behavior は 008、command/query separation は 015、command I/O は 011、workflow runtime は 012、billing policy は 014 を正本参照とする
