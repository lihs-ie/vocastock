# Feature Specification: Rust Quality CI

**Feature Branch**: `019-rust-quality-ci`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: ".github/workflows/ci.yml に Rust quality job を追加して、cargo fmt --all -- --check、cargo clippy --workspace --all-targets -- -D warnings、cargo test -p query-api --test unit、cargo test -p command-api --test unit、Docker/Firebase を使う feature test"

## Clarifications

### Session 2026-04-20

- Q: CI で実行する Docker/Firebase feature test の範囲はどこまで含めるか → A: すべての Rust アプリケーションを対象として実行する
- Q: Rust quality job をいつ実行するか → A: Rust 関連 path に変更があるときだけ実行する
- Q: Rust 関連 path に変更が無いときの required check はどう扱うか → A: Rust quality job 自体は常に存在させ、Rust path 変更が無いときは no-op success として完了させる

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rust の静的品質ゲートを CI に追加する (Priority: P1)

CI 管理者として、Rust 実装の formatting 崩れや warning を pull request の required check で検出したい。そうすることで、レビュー前に repository 全体の Rust 品質基準を自動で守れるようにしたい。

**Why this priority**: formatting と clippy を CI に載せない限り、Rust 実装の品質基準がローカル依存のままになり、レビュー時の差し戻しが減らないため。

**Independent Test**: 第三者が workflow 定義と実行結果だけを見て、Rust quality job が formatting と clippy の両方を required gate として扱い、どちらで失敗したかを説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** Rust コードに formatting 崩れがある, **When** CI が走る, **Then** Rust quality job は formatting check の失敗として停止する
2. **Given** Rust コードに clippy warning がある, **When** CI が走る, **Then** Rust quality job は warning 許容ではなく失敗として停止する

---

### User Story 2 - command/query の unit test を required check にする (Priority: P2)

backend 実装担当者として、`command-api` と `query-api` の unit test を毎回 CI で確認したい。そうすることで、read/write の最小スライスに対する回帰を review 前に検出できるようにしたい。

**Why this priority**: 既にローカルでは unit test を実行しているため、CI に乗らないと reviewer と author の前提がずれたままになるため。

**Independent Test**: 第三者が workflow 定義と job log だけを見て、`query-api` と `command-api` の unit test が両方 required gate に含まれていることを説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** `query-api` の unit test が失敗する変更が入る, **When** CI が走る, **Then** Rust quality job は `query-api` unit test の失敗として merge を止める
2. **Given** `command-api` の unit test が失敗する変更が入る, **When** CI が走る, **Then** Rust quality job は `command-api` unit test の失敗として merge を止める
3. **Given** 両 unit test が通る, **When** Rust quality job が進む, **Then** unit test 区間は成功として記録される

---

### User Story 3 - Docker/Firebase を使う Rust feature test を CI で再現する (Priority: P3)

backend 実装担当者として、Docker コンテナと Firebase エミュレータを使う Rust feature test を GitHub Actions 上でも再現したい。そうすることで、ローカルでは通るが CI では壊れる container/emulator integration の差分を早期に検出できるようにしたい。

**Why this priority**: この repository では feature test の正本が Docker/Firebase 前提であり、ここが CI に無いと最も重い回帰が required check から漏れるため。

**Independent Test**: 第三者が workflow 定義、job log、生成 artifact だけを見て、Rust quality job が Docker/Firebase 依存の feature test を起動し、その成功または失敗理由を説明できれば成立する。

**Acceptance Scenarios**:

1. **Given** Docker と Firebase エミュレータが利用可能な runner である, **When** Rust quality job が走る, **Then** Docker/Firebase 前提の Rust feature test がすべての Rust アプリケーションを対象に CI 上で実行される
2. **Given** Firebase エミュレータ起動または container 接続に失敗する, **When** feature test 区間が失敗する, **Then** Rust quality job は失敗し、停止点を job log または artifact から追跡できる
3. **Given** Rust 関連 path に変更が無い, **When** CI が走る, **Then** Rust quality job は required check 名を維持したまま no-op success として完了する

### Edge Cases

- Rust 以外の変更でも CI 全体は走るが、Rust quality job が repository 内のすべての Rust アプリケーションを見失わないこと
- Rust 関連 path に変更が無い run では、Rust quality job を不要に起動しない一方で required check 運用と矛盾しないこと
- Rust 関連 path に変更が無い run でも、branch protection が期待する check 名が欠落しないこと
- formatting と clippy のどちらも失敗しうる場合でも、失敗した区間を reviewer が区別できること
- unit test は通るが Docker/Firebase feature test だけが失敗する場合でも、integration failure として切り分けられること
- GitHub-hosted runner 上で Docker は使えるが Firebase 起動が遅い場合に、無言の hang ではなく失敗区間が読めること
- 既存の `toolchain-validate` や container smoke と重複する準備があっても、Rust quality job の責務が不明瞭にならないこと

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None
- **Invariants / Terminology**: `rust-quality`、static check、unit test、feature test、Docker/Firebase integration、required check、artifact log を別概念として扱い、既存の `application-container-smoke` や `emulator-smoke` と混同しない
- **Async Lifecycle**: Rust quality job は `pending` / `running` / `succeeded` / `failed` の CI lifecycle を持ち、feature test 区間では Docker container と Firebase emulator の起動・待機・終了を含む。部分成功でも job 全体は completed success 扱いにしてはならない
- **User Visibility Rule**: merge 判定には completed success の required check のみを使い、進行中や失敗中は状態とログのみを示す
- **Identifier Naming Rule**: 新しい domain identifier type は追加しない
- **External Ports / Adapters**: GitHub Actions workflow、Rust toolchain bootstrap、Docker engine、Firebase emulator startup scripts、Rust feature test runtime

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 成果物は、`.github/workflows/ci.yml` に Rust quality を担う独立 job を定義しなければならない
- **FR-001a**: Rust quality job は Rust 関連 path に変更がある場合にのみ実行対象としなければならない
- **FR-001b**: Rust 関連 path に変更が無い場合でも、Rust quality job は required check 名を維持した no-op success として完了しなければならない
- **FR-002**: Rust quality job は repository 全体に対する formatting check を required gate として実行しなければならない
- **FR-003**: Rust quality job は workspace 全体に対する clippy warning 拒否を required gate として実行しなければならない
- **FR-004**: Rust quality job は `query-api` の unit test を required gate として実行しなければならない
- **FR-005**: Rust quality job は `command-api` の unit test を required gate として実行しなければならない
- **FR-006**: Rust quality job は Docker コンテナと Firebase エミュレータを使う Rust feature test を、対象となるすべての Rust アプリケーションについて CI 上で実行しなければならない
- **FR-007**: Rust quality job は static check、unit test、feature test のどの区間で失敗したかを job log から判別できるようにしなければならない
- **FR-008**: Rust quality job は GitHub-hosted runner 上で再現可能な prerequisite のみを前提にし、ローカル専用の手動準備へ依存してはならない
- **FR-009**: Rust quality job は既存の `toolchain-validate` と整合し、必要な toolchain / Docker / Firebase dependency を CI 上で再利用または準備できなければならない
- **FR-010**: Rust quality job は既存の required check 群と共存し、Flutter、Android、vulnerability、container smoke など既存 job の責務を上書きしてはならない
- **FR-010a**: Rust 関連 path に変更が無い場合の CI 挙動は、不要な Rust quality 実行を避けつつ、branch protection と required check 運用の整合を保たなければならない
- **FR-011**: Rust quality job は成功・失敗のいずれでも、feature test の停止点を追跡できる log または artifact の取り扱いを定義しなければならない
- **FR-012**: 成果物は、今回の CI feature が repository 内のどの Rust application / test suite を対象とし、すべての Rust アプリケーションを feature test 対象に含める一方で何を scope 外に置くかを明示しなければならない

### Key Entities *(include if feature involves data)*

- **Rust Quality Job**: Rust 向けの formatting、lint、test、integration check をまとめて実行する CI required check
- **Rust Static Gate**: formatting check と clippy warning 拒否の組み合わせ
- **Rust Unit Test Suite**: `query-api` と `command-api` の unit test 群
- **Rust Feature Test Suite**: Docker コンテナと Firebase エミュレータを使って動作し、すべての Rust アプリケーションを対象に実行する Rust integration / feature test 群
- **CI Diagnostic Artifact Bundle**: Rust quality job の成功 / 失敗時に停止点や経過を追跡するための log / artifact 出力

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Rust を含む pull request の 100% で、Rust quality job が自動実行される
- **SC-002**: Rust quality job の失敗時に、reviewer が 5 分以内に static check、unit test、feature test のどこで止まったかを判定できる
- **SC-003**: `query-api` と `command-api` の unit test 回帰は、review 開始前の CI 実行で 100% 検出される
- **SC-004**: Docker/Firebase 前提の Rust feature test 回帰は、すべての Rust アプリケーションに対して local 再現前に CI 上で検出される required check として扱われる

## Assumptions

- 今回の Rust quality job は既存の Rust backend application のうち、少なくとも `query-api` と `command-api` を対象にする
- Rust feature test の対象は `query-api` と `command-api` に限定せず、repository 内のすべての Rust アプリケーションへ広げる
- Docker/Firebase を使う Rust feature test では、既存の `query-api` / `command-api` の契約を再利用しつつ、`graphql-gateway` の harness はこの feature で追加する
- GitHub-hosted Linux runner で Docker を利用できる前提を維持する
- Rust quality job は Rust 関連 path 変更時のみ実行する path-based gating を採用する
- Rust path 変更が無い run では、同じ job 名の no-op success を返す形で branch protection と整合させる
- 既存の toolchain bootstrap script と Firebase emulator script は引き続き正本として再利用する
- `graphql-gateway` など他の Rust package 向け unit test 追加は、この feature の primary scope 外とする
- 既存の Flutter / Android / vulnerability / smoke 系 job は削除せず、Rust quality job を追加する形で整合させる
