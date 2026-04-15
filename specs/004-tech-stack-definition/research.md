# Research: 技術スタック定義

## Decision: client boundary は Flutter 3.41.5 / Dart と `graphql_flutter` を中核 stack とし、client-side Firebase integration は認証用途に限定する

**Rationale**: 対象プラットフォームは iOS、Android、macOS であり、feature 002 でも
Flutter 3.41.5 を承認済み toolchain としている。GraphQL を同期契約に採る前提では、
Flutter client 側の query / mutation、認証ヘッダ伝播、キャッシュ制御を
`graphql_flutter` で一元化するのが最も整合的である。一方、業務状態や画像アセットの
直接取得責務は client に持たせず、Firebase Authentication は認証主体に限定する。

**Alternatives considered**:

- Swift / Kotlin / AppKit の個別 native stack
- Flutter client で自前 GraphQL client を持つ構成

## Decision: command/query boundary は Rust runtime on Cloud Run を中核 stack とし、GraphQL schema を外向け同期契約にする

**Rationale**: user clarification で backend の command/query 系は Rust を標準にすると
確定しており、Cloud Run 上の Rust runtime は単一バイナリ運用、型安全、低い実行コスト、
起動性能の観点で相性がよい。さらに、client との同期契約を GraphQL に固定すると、
query と command を同一 schema 上で扱いながら、mobile client 側の呼び出し体験と
境界定義を揃えやすい。

**Alternatives considered**:

- TypeScript on Node.js を継続する
- REST/gRPC を command/query の primary 契約にする

## Decision: workflow boundary は Haskell runtime on Cloud Run を中核 stack とし、`Pub/Sub + Firestore state` で実行する

**Rationale**: user clarification で workflow 系 backend は Haskell と確定しており、
画像生成・解説生成の長時間処理、状態遷移、冪等再試行を純粋関数寄りに整理しやすい。
`Pub/Sub` を実行トリガー、`Cloud Run` を worker 実行、`Firestore` を durable state と
する構成により、`pending / running / succeeded / failed` の明示状態と retry owner を
説明しやすい。

**Alternatives considered**:

- workflow も Rust へ統一する
- Cloud Tasks や polling worker を標準 execution baseline にする

## Decision: managed data/delivery baseline は Firebase Authentication、Cloud Firestore、Firebase Hosting とし、画像アセットは Google Drive を `AssetStoragePort` 配下で扱う

**Rationale**: feature 002 の開発環境基盤は Firebase family を前提に整備されており、
認証、業務状態、workflow state、配信エントリポイントはそのまま整合させるのが最も
運用負荷が低い。一方、画像アセットは user clarification によりコスト観点で
Google Drive を選ぶため、domain や user-visible contract からは Drive 固有 API を
隠し、`AssetStoragePort` を介して stable reference を返す構成に固定する。

**Alternatives considered**:

- Cloud Storage for Firebase を画像アセットの primary storage にする
- PostgreSQL と独立 object storage へ置き換える

## Decision: client と command/query 境界の同期契約は GraphQL over HTTPS を標準とする

**Rationale**: user clarification で同期契約は GraphQL と確定している。Flutter client、
Rust command/query runtime、複数 read model を前提とした end-to-end service では、
取得 shape を client 都合で制御しやすく、query と mutation を同一の契約体系で扱える
GraphQL が最も整合的である。

**Alternatives considered**:

- HTTPS + JSON REST
- gRPC

## Decision: external adapter は AI provider HTTP/JSON と Google Drive API を caller-owned adapter として扱い、provider SDK を core stack にしない

**Rationale**: 憲章では外部依存をポート越しに接続することが必須であり、AI provider や
Google Drive API の固有 SDK を domain 近傍へ持ち込むと差し替え性が下がる。
caller-owned adapter に限定すると、タイムアウト、再試行、失敗時の扱い、stable
reference 化を runtime 側へ閉じ込めやすい。

**Alternatives considered**:

- provider / storage SDK を core runtime の共通基盤として採用する
- client が provider API や Drive API を直接呼び出す

## Decision: operations / observability boundary は Cloud Logging、Cloud Monitoring、Error Reporting を基準とし、GraphQL request と Pub/Sub message の相関を必須とする

**Rationale**: Rust command/query runtime、Haskell workflow runtime、Pub/Sub、
GraphQL をまたぐ構成では、boundary をまたいだ相関識別子なしに障害調査が難しい。
Cloud Run / Pub/Sub と自然に接続できる Google Cloud 系 observability を基準にすると、
構造化ログ、メトリクス、エラー集約を最小の追加運用で揃えられる。

**Alternatives considered**:

- runtime ごとに個別 logging 方針を持つ
- observability は implementation phase まで先送りする

## Decision: stack governance は「exact toolchain version + managed service family + implementation-wave package pinning」の三層で管理する

**Rationale**: 既存 repository には approved-components に exact version を残す運用が
あり、Flutter / Rust / Haskell / Docker / Firebase CLI の toolchain は exact version
で統制できる。一方、Firebase family、Pub/Sub、Google Drive API のような managed
service は family / contract 基準で統制し、`graphql_flutter` や Rust/Haskell の
application library は implementation wave で exact pin する三層運用が最も現実的である。

**Alternatives considered**:

- すべてを exact version で先に固定する
- package/version の記録を実装時の判断へ全面委任する

## Decision: 例外導入は期限付き例外記録を必須にし、migration wave に紐付けて扱う

**Rationale**: docs-first repository から target stack へ移行する途中では、一時的な
非標準技術や既存資産の持ち込みが発生しうる。Rust/Haskell の分離、GraphQL 採用、
Google Drive asset storage のように構成が明確になった分、例外を記録なしで許すと
stack definition 自体が機能しなくなるため、期限、代替統制、見直し責任を持つ
exception record を必須とする。

**Alternatives considered**:

- 例外を認めず、現状との差分をすべて即時解消前提にする
- 例外を口頭合意に委ねる
