# Contract: Deployment Topology

## Purpose

MVP の physical deployment unit と、主要 component の配置先を固定する。

## Canonical Deployment Units

| Deployment Unit | Kind | Owns | Must Not Own |
|----------------|------|------|--------------|
| `mobile-client` | client | UI、screen state、GraphQL 呼び出し | workflow 起動、authoritative write、provider 直結 |
| `graphql-gateway` | gateway | unified GraphQL endpoint、routing、request correlation | domain write、projection read ownership、workflow 実行 |
| `command-api` | service | `Command Intake`、idempotency、write、workflow dispatch 起点 | completed result read、query projection ownership |
| `query-api` | service | `Query Read`、completed result、status-only、subscription read | command acceptance、workflow dispatch |
| `explanation-worker` | worker | explanation workflow 実行 | query response |
| `image-worker` | worker | image workflow 実行、asset save handoff | query response |
| `billing-worker` | worker | purchase verification / notification reconciliation | paywall UI、query response |
| `firebase-auth` | managed | identity baseline | app core handoff logic |
| `firestore-state` | managed | authoritative write / projection persistence | business decision |
| `pubsub-runtime` | managed | async trigger transport | user-visible read |
| `drive-asset-store` | managed | stable image asset storage | domain state ownership |

## Allocation Rules

1. `Command Intake` は `command-api` に primary allocation しなければならない
2. `Query Read` は `query-api` に primary allocation しなければならない
3. `graphql-gateway` は client-facing だが、acceptance や read ownership を持ってはならない
4. worker 系 unit は completed result を直接返してはならず、durable state 更新までに留める
5. inner policy component は `query-api` または `billing-worker` 内部に配置してよいが、独立 service として定義してはならない

## Invariants

- `command-api` と `query-api` は MVP から別 deployment unit でなければならない
- client から見える endpoint は `graphql-gateway` 1 つに統一してよい
- managed service は state source-of-truth になりうるが、受理判断や表示判断を持ってはならない
