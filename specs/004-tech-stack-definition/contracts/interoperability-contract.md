# Contract: Interoperability

## Purpose

boundary 間の同期・非同期接続、auth 伝播、asset 参照、external adapter 形式を定義する。

## Synchronous Boundary Rules

| Producer | Consumer | Contract Style | Required Guarantees |
|----------|----------|----------------|---------------------|
| Client Experience | Vocabulary Command | GraphQL mutation over HTTPS | 認可済み command を受け付け、完了済み成果物を即返さず、accepted 状態または status handle を返す |
| Client Experience | Learning Query | GraphQL query over HTTPS | 表示用 read model を返し、未完了成果物を完成済みとして返さない |
| Vocabulary Command | Learning Query | Durable state handoff via Firestore projection | command 受理後の状態を query が整合的に読める |

## Async Workflow Rules

| Flow | Trigger | Message Transport | Durable State | Worker Contract | Visibility Guarantee |
|------|---------|-------------------|---------------|-----------------|----------------------|
| Explanation Generation | Vocabulary Command | Pub/Sub topic / subscription | Firestore-based workflow state | Haskell subscriber worker + idempotent execution | `succeeded` 以外の本文は表示しない |
| Image Generation | Vocabulary Command | Pub/Sub topic / subscription | Firestore-based workflow state + asset reference | Haskell subscriber worker + Google Drive save adapter + idempotent execution | `succeeded` 以外の画像は表示しない |

## External Adapter Rules

- AI provider 接続は HTTP/JSON adapter を通し、provider SDK を core domain や client stack に持ち込まない
- Google Drive への asset 保存は `AssetStoragePort` を通し、stable reference を返す契約で統一する
- 認証主体は Firebase Authentication を基準とし、GraphQL resolver と Pub/Sub message metadata の双方へ user context を安全に伝播する
- GraphQL request identifier と Pub/Sub correlation identifier を相互参照可能にし、boundary をまたいだ追跡を可能にする
- 失敗理由は内部では詳細を保持してよいが、ユーザー可視面では要約済み状態に変換する
