# Contract: Boundary Stack

## Purpose

責務境界ごとの採用 stack と、持ってよい責務・持ってはならない責務を定義する。

## Boundary Stack Catalog

| Boundary | Adopted Stack | Purpose | Must Not Own |
|----------|---------------|---------|--------------|
| Client Experience | Flutter 3.41.5 / Dart + `graphql_flutter` + Firebase Authentication client integration | iOS / Android / macOS で入力、状態表示、完了済み解説/画像の描画、GraphQL query/mutation 実行を担う | AI provider への直接接続、workflow state の直接更新、Firestore や Google Drive 業務データの直接取得 |
| Vocabulary Command | Rust application runtime on Cloud Run + GraphQL mutation boundary | 単語登録、生成開始 command、重複確認、認可済み command 受理を担う | 長時間生成実行、UI 向け描画ロジック |
| Learning Query | Rust application runtime on Cloud Run + GraphQL query boundary | 表示用 read model の合成と取得契約を担う | 生成状態の直接変更、external provider 呼び出し |
| Explanation Workflow | Haskell worker runtime on Cloud Run + Pub/Sub subscriber + Firestore state | 解説生成、状態遷移、冪等再試行、失敗確定を担う | UI 向け整形、画像生成そのもの |
| Image Workflow | Haskell worker runtime on Cloud Run + Pub/Sub subscriber + Firestore state + Google Drive asset adapter | 画像生成、保存、再生成、失敗確定を担う | 解説本文生成、client 向け描画、Google Drive API の直接露出 |
| Persistence / Identity Baseline | Firebase Authentication, Cloud Firestore, Firebase Hosting | 認証、業務状態、workflow state、静的エントリポイントを担う | ドメイン判断や provider 特有の retry 制御 |
| Integration Adapter | Caller-owned Rust/Haskell adapters + AI provider HTTP/JSON + Google Drive API | provider / storage との変換、タイムアウト、再試行、stable reference 化を担う | ドメイン状態の所有、ユーザー表示判断 |
| Operations / Observability | Cloud Logging, Cloud Monitoring, Error Reporting, correlation identifier propagation | 構造化ログ、メトリクス、エラー集約、GraphQL / Pub/Sub 相関を担う | ドメイン mutation、API 契約の公開責務 |

## Rules

- Client Experience は Rust command/query runtime の GraphQL contract 以外へ直接依存してはならない
- Workflow runtime は AI provider と Google Drive asset storage を port/adapter 越しにのみ利用する
- Persistence / Identity Baseline は state source of truth になりうるが、業務判断そのものは持ってはならない
- Integration Adapter は caller boundary ごとに所有し、Drive や provider の固有 API を user-visible contract へ漏らしてはならない
- Operations / Observability は correlation identifier を GraphQL request と Pub/Sub message の双方に付与できなければならない
- stack を boundary 単位で変更する場合は、この契約と exception record を同時に更新する
