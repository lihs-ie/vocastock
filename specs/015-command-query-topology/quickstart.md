# Quickstart: Command/Query Deployment Topology Review

## 1. Prerequisites

1. [spec.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md) を読み、MVP で `Command Intake` と `Query Read` を別 deployment unit にする前提を確認する
2. [spec.md](/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/spec.md) を読み、Rust command/query runtime、Haskell worker、Firebase baseline、Pub/Sub、Google Drive の stack 基線を確認する
3. [adr.md](/Users/lihs/workspace/vocastock/docs/external/adr.md) を読み、`Presentation`、`Command Intake`、`Query Read`、`Async Generation`、`Async Subscription Reconciliation` の責務分離を確認する

## 2. Review Order

1. [research.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/research.md) で、分離判断、gateway、auth verification、projection lag、policy placement の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/data-model.md) で、deployment unit、gateway route、durable state handoff、source-of-truth update の設計エンティティを確認する
3. [deployment-topology-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/deployment-topology-contract.md) で unit と component 配置を確認する
4. [command-query-separation-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/command-query-separation-contract.md) と [gateway-routing-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/gateway-routing-contract.md) で command/query 分離と unified endpoint の整合を確認する
5. [async-worker-allocation-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/async-worker-allocation-contract.md) で workflow / reconciliation worker の配置を確認する
6. [source-of-truth-update-contract.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/contracts/source-of-truth-update-contract.md) で更新対象文書一覧を確認する

## 3. Independent Review Checks

### User Story 1

- `command-api` と `query-api` が別 deployment unit であること
- `command-api` が acceptance / write / dispatch 起点だけを持つこと
- `query-api` が completed result / status-only / subscription read だけを持つこと

### User Story 2

- `graphql-gateway` が unified endpoint と routing だけを持つこと
- explanation / image / billing worker が command/query service とは独立していること
- auth/session verification が `command-api` / `query-api` の両方で backend 側にあること

### User Story 3

- `docs/external/adr.md` と `docs/external/requirements.md` が canonical sync 先であること
- 004 / 009 / 010 / 011 / 012 / 013 / 014 のうち、どこが resync 必須かを説明できること
- transport binding や service 内 module 構成が deferred であること

## 4. Expected Review Outcomes

- 主要 component の配置先を 10 分以内に説明できる
- projection lag 時に `accepted / status handle` と `status-only` がどう使われるかを説明できる
- `graphql-gateway` を置いても `command-api` / `query-api` の責務が崩れないことを説明できる
- 更新対象文書の漏れがないことを説明できる

## 5. Deferred Topics

次はこの feature では固定しない。

1. GraphQL schema の具体 shape
2. gateway 実装技術と内部 module 分割
3. Cloud Run service 間の細かな scaling / budget policy
4. observability dashboard や alert rule の詳細
