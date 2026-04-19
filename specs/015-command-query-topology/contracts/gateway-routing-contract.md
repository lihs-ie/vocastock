# Contract: Gateway Routing

## Purpose

client から見える unified GraphQL endpoint と、内部 routing の規則を固定する。

## Gateway Role

`graphql-gateway` は client-facing endpoint を 1 つだけ提供し、operation kind に応じて
内部の `command-api` または `query-api` へ route する。

## Routing Matrix

| Client Operation | Gateway Target | Required Guarantee |
|------------------|----------------|--------------------|
| mutation | `command-api` | accepted / rejected / failed を返し、completed result を即返さない |
| query | `query-api` | completed result または status-only を返し、workflow 起動をしない |

## Auth Propagation

- gateway は auth header / request context を downstream へ伝播してよい
- gateway 自身は token verification の最終正本になってはならない
- backend 側の token verification と actor handoff は `command-api` / `query-api` がそれぞれ行う

## Non-Ownership Rules

- gateway は idempotency store を own してはならない
- gateway は read projection を own してはならない
- gateway は workflow dispatch や reconciliation を起動してはならない

## Deferred Scope

次はこの contract では固定しない。

- GraphQL schema detail
- resolver module 構成
- gateway 製品 / 実装方式
- gateway cache / rate limit policy
