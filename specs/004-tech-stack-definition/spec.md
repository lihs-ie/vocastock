# Feature Specification: 技術スタック定義

**Feature Branch**: `[004-tech-stack-definition]`  
**Created**: 2026-04-15  
**Status**: Ready for Planning  
**Input**: User description: "技術スタックを定義する"

## Clarifications

### Session 2026-04-15

- Q: 非同期 workflow の実行基盤は何を標準にするか → A: Pub/Sub + Cloud Run worker + Firestore state
- Q: バックエンドの標準 runtime 言語は何にするか → A: Command/Query は Rust、Workflow は Haskell
- Q: 永続化と配信の managed service 基盤は何を標準にするか → A: Firebase Authentication + Firestore + Firebase Hosting を標準にし、画像アセットはコスト理由で Google Drive を使う
- Q: Client と Command/Query 境界の同期契約は何を標準にするか → A: GraphQL
- Q: Flutter client の GraphQL client ライブラリは何を標準にするか → A: graphql_flutter

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 境界ごとの採用スタックを確定する (Priority: P1)

設計担当者として、プロダクト全体の各責務境界に対して採用する技術スタックを一意に定義したい。これにより、新規実装や設計レビューのたびに土台技術を再議論せずに進められる。

**Why this priority**: アーキテクチャ設計の次に、どの境界でどの技術を使うかが曖昧なままだと、実装判断とレビュー基準が揺れるため。

**Independent Test**: 第三者が stack 定義書だけを読み、クライアント、アプリケーション、非同期 workflow、永続化、外部接続の各境界に対して採用技術を説明できれば独立に価値を確認できる。

**Acceptance Scenarios**:

1. **Given** 開発者が新しい機能をどの技術で実装すべきか判断したい, **When** 技術スタック定義書を読む, **Then** 対応する境界の採用技術と非推奨技術を判断できる
2. **Given** レビュー担当者が実装方針を確認している, **When** 境界ごとの stack 定義を見る, **Then** 採用済み方針との一致・逸脱を判定できる

---

### User Story 2 - 選定基準と互換条件を共有する (Priority: P2)

設計担当者として、なぜその技術を採用するのか、どの技術同士が互換前提なのかを文書化したい。これにより、将来の差し替えや追加提案を同じ基準で評価できる。

**Why this priority**: 技術名だけを並べても、採用理由や互換制約がないと継続運用や見直し判断に使えないため。

**Independent Test**: 第三者が 1 つの新しい技術提案を与えられたとき、既存 stack 定義と比較して採用可否または例外扱いを判断できれば独立に価値を確認できる。

**Acceptance Scenarios**:

1. **Given** 新しい技術候補が提案される, **When** 選定基準と互換条件を確認する, **Then** 採用済み stack へ与える影響を説明できる
2. **Given** 既存技術の見直しが必要になる, **When** support 方針と再評価条件を確認する, **Then** 再評価の起点と判断責任を説明できる

---

### User Story 3 - 移行と例外運用を定義する (Priority: P3)

実装担当者として、現状から採用 stack へどの順で寄せるか、例外をどう扱うかを把握したい。これにより、移行途中でも一貫した判断で実装を進められる。

**Why this priority**: 現状の repository は docs-first であり、target stack を定義するだけでは着手順序や例外処理が曖昧に残るため。

**Independent Test**: 第三者が現状の設計成果物と stack 定義書を比較し、どこが即採用対象で、どこが移行対象かを説明できれば独立に価値を確認できる。

**Acceptance Scenarios**:

1. **Given** 既存の実装または設計成果物が新しい stack 方針と完全には一致しない, **When** 移行方針を参照する, **Then** 次に合わせるべき境界と順序を判断できる
2. **Given** 一時的に未承認技術を使う必要が生じる, **When** 例外運用ルールを確認する, **Then** 承認条件、期限、見直し責任を説明できる

### Edge Cases

- 1 つの責務境界に対して複数の有力技術候補があり、採用基準が競合する場合
- 主要技術が憲章の「完了結果のみ表示」やポート分離方針を満たしにくい場合
- 外部 provider の要件上、例外的に boundary 固有の stack を追加せざるを得ない場合
- 既存の開発環境基盤で承認済みの toolchain と、今回定義する application stack が不整合を起こす場合

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: 直接更新対象はなし。`docs/internal/domain/common.md`、`docs/internal/domain/explanation.md`、`docs/internal/domain/visual.md`、`docs/internal/domain/service.md` は stack 定義時の制約参照として扱う
- **Invariants / Terminology**: frequency、sophistication、proficiency、登録状態、解説生成状態、画像生成状態は stack 定義によって統合または曖昧化してはならない
- **Async Lifecycle**: 採用 stack は explanation と visual image の `pending` / `running` / `succeeded` / `failed` を表現でき、再試行を冪等に扱える前提を満たさなければならない
- **Async Execution Baseline**: 非同期 workflow の標準実行基盤は `Pub/Sub + Cloud Run worker + Firestore state` とし、状態永続化は Firestore、実行トリガーは Pub/Sub、worker 実行は Cloud Run に統一する
- **Backend Runtime Baseline**: backend の標準 runtime 言語は、`Vocabulary Command` と `Learning Query` を Rust、`Explanation Workflow` と `Image Workflow` を Haskell とする分離構成を前提にする
- **Persistence Baseline**: 認証は Firebase Authentication、業務状態と workflow state は Firestore、配信エントリポイントは Firebase Hosting を標準とし、画像アセット永続化はコスト最適化のため Google Drive を `AssetStoragePort` 配下で利用する
- **Synchronous Contract Baseline**: Client Experience と Command/Query 境界の同期契約は GraphQL を標準とし、Command と Query を同一 schema 上で区別して扱う
- **Client Library Baseline**: Flutter client の GraphQL client ライブラリは `graphql_flutter` を標準とし、認証ヘッダ伝播、query/mutation 実行、キャッシュ制御を同一ライブラリで扱う
- **User Visibility Rule**: どの stack decision でも、ユーザーへ表示してよい生成結果は完了済み成果物のみとし、未完了や失敗時は状態表示のみに留める
- **Identifier Naming Rule**: stack 定義に従って今後追加される契約やコードでも、識別子型は `XxxIdentifier`、集約自身の識別子は `identifier`、関連参照は概念名で表現し、`id` / `xxxId` / `xxxIdentifier` を使わない
- **External Ports / Adapters**: 単語検証、解説生成、画像生成、画像永続化、発音参照、結果取得、必要な運用補助境界はすべてポート/アダプタ越しに接続する前提で stack を定義する

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 技術スタック定義は、クライアント境界、アプリケーション境界、非同期 workflow 境界、永続化境界、外部接続境界、運用/観測境界を含む end-to-end 全体を対象としなければならない
- **FR-002**: 技術スタック定義は、各責務境界ごとに採用する主要技術と、その技術を選ぶ理由を一意に示さなければならない
- **FR-003**: 技術スタック定義は、境界間で整合しなければならない互換条件と依存条件を示さなければならない
- **FR-004**: 技術スタック定義は、各採用技術について support 方針、見直し契機、継続利用条件を示さなければならない
- **FR-005**: 技術スタック定義は、非同期生成の明示的状態管理、冪等再試行、完了済み結果のみ表示という憲章要件を満たす前提を示さなければならない
- **FR-005a**: 非同期 workflow 境界の標準実行基盤は `Pub/Sub + Cloud Run worker + Firestore state` とし、他の実行方式を採る場合は例外申請対象として扱わなければならない
- **FR-005b**: backend runtime の標準は `Command/Query = Rust`、`Workflow = Haskell` とし、同一責務境界で別言語を採る場合は理由と例外条件を明示しなければならない
- **FR-006a**: managed service 基盤の標準は `Firebase Authentication + Firestore + Firebase Hosting` とし、画像アセット永続化は `AssetStoragePort` を介した Google Drive を標準構成として扱わなければならない
- **FR-006b**: Client Experience と Command/Query 境界の標準同期契約は GraphQL とし、REST や gRPC を採る場合は互換理由と例外条件を明示しなければならない
- **FR-006c**: Flutter client の標準 GraphQL client は `graphql_flutter` とし、別 client を採る場合はキャッシュ戦略、認証伝播、エラー処理の互換条件を明示しなければならない
- **FR-006**: 技術スタック定義は、外部 AI、検証、メディア参照、アセット保存などの依存を domain 直結ではなくポート/アダプタ越しに扱う前提を含まなければならない
- **FR-007**: 技術スタック定義は、共有標準として全境界で従う事項と、特定境界だけに適用する事項を区別して示さなければならない
- **FR-008**: 技術スタック定義は、新しい技術候補を採用済み/非推奨/例外申請対象のいずれに分類するかを判定できる基準を含まなければならない
- **FR-009**: 技術スタック定義は、現状の docs-first 状態から採用 stack へ寄せる段階移行方針を示さなければならない
- **FR-010**: 技術スタック定義は、既存の開発環境基盤、CI 方針、アーキテクチャ設計との整合を保たなければならない

### Key Entities *(include if feature involves data)*

- **Stack Decision**: どの責務境界でどの技術を主要採用とするか、理由と制約を含めた判断記録
- **Boundary Stack Mapping**: アーキテクチャ境界と採用 stack の対応関係
- **Support Policy**: support 状況、見直し契機、再評価責任を表す定義
- **Exception Rule**: 未承認技術を一時的に扱う際の承認条件、期限、責任者を表す規則

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: レビュー参加者が 10 分以内に、主要な責務境界の 100% について採用 stack を対応付けられる
- **SC-002**: 新しい技術提案を 1 件与えたとき、5 分以内に採用済み/非推奨/例外申請対象のいずれかへ分類できる
- **SC-003**: stack 定義対象の全境界について、採用理由と互換条件を 100% 説明できる
- **SC-004**: 憲章、アーキテクチャ設計、開発環境基盤との矛盾がレビュー時に 0 件である

## Assumptions

- 今回の feature は product code の実装ではなく、後続 plan と implementation に使う stack decision 文書の整備を主対象とする
- `specs/003-architecture-design/` で定義した責務境界と runtime 方針が、今回の stack 定義の前提となる
- `specs/002-flutter-dev-env/` で定義した開発環境と CI 基盤は有効であり、今回は application stack 側の承認方針を補完する
- backend runtime は command/query 系と workflow 系で異なる言語を採用してよく、相互接続契約の明示を必須とする
- 画像アセット保存は Google Drive を使うが、ユーザー可視面や domain からは Google 固有 API を直接見せず `AssetStoragePort` 経由で扱う
- client と backend の同期通信は GraphQL を標準とし、mobile client の状態取得と command 実行を同一の API 契約体系で扱う
- Flutter client の GraphQL 実装は `graphql_flutter` を前提とし、client library の比較検討は例外申請がある場合に限る
- プロダクトは引き続き英単語登録、解説生成、画像生成、結果表示を中心とする end-to-end サービスである
