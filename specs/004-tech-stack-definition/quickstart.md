# Quickstart: 技術スタック定義

## 1. 計画成果物を確認する

- `spec.md` で stack 定義の対象範囲、clarification で確定した技術選定、例外運用の目的を確認する
- `research.md` で Flutter + GraphQL client、Rust command/query、Haskell workflow、Firebase baseline、Google Drive asset adapter、observability の採用判断を確認する
- `data-model.md` で boundary stack profile、compatibility constraint、support policy、exception、migration wave の管理対象を確認する
- `contracts/` で boundary ごとの stack、GraphQL / Pub/Sub 接続、support 見直し、例外 / 移行の規則を確認する

## 2. 境界ごとに採用 stack を参照する

- Client Experience に変更を入れる場合は `contracts/boundary-stack-contract.md` で Flutter + `graphql_flutter` profile を確認する
- Vocabulary Command と Learning Query に変更を入れる場合は、Rust command/query runtime と GraphQL contract を確認する
- Explanation Workflow と Image Workflow に変更を入れる場合は、Haskell worker runtime、Pub/Sub trigger、Firestore state、Google Drive asset adapter の扱いを確認する
- 外部 AI や asset storage を追加・変更する場合は `contracts/interoperability-contract.md` を起点に caller boundary と port/adapter 契約を確認する

## 3. support と例外運用を確認する

- exact version を持つ toolchain は `tooling/versions/approved-components.md` と `contracts/support-governance-contract.md` を合わせて確認する
- Firebase / Pub/Sub / Google Drive API のような managed service family は `versionStrategy = family` として確認する
- `graphql_flutter`、Rust library、Haskell library は implementation wave で exact pin する前提として扱う
- 非標準技術を提案する場合は `contracts/exception-migration-contract.md` に沿って期限付き例外として扱う

## 4. 実装前に確認するポイント

- 採用 stack が `specs/003-architecture-design/` の boundary と矛盾していない
- client / backend 同期契約が GraphQL に統一され、client library が `graphql_flutter` に固定されている
- 非同期生成の `pending` / `running` / `succeeded` / `failed` と完了済み結果のみ表示の rule を `Pub/Sub + Cloud Run worker + Firestore state` で表現できる
- external dependency と画像 asset storage が port/adapter 越しに接続され、Google Drive 固有 API を user-visible contract に漏らさない
- GraphQL request と Pub/Sub workflow の相関を observability で追跡できる
- 新しい技術候補が採用済み / 非推奨 / 例外申請対象のいずれかに分類できる
- 現在の実装対象がどの migration wave に属するか説明できる
