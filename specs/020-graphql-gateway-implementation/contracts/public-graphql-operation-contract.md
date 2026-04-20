# Contract: Public GraphQL Operation

## Purpose

`graphql-gateway` が client-facing `/graphql` endpoint で何を公開し、どの downstream service へ
relay するかを固定する。

## Public Transport

| Item | Value |
|------|-------|
| Path | `/graphql` |
| Method | `POST` |
| Body | JSON envelope with `query`, optional `operationName`, optional `variables` |

## Initial Slice Allowlist

| Public Operation | Kind | Downstream Service | Downstream Route | Required Guarantee |
|------------------|------|--------------------|------------------|--------------------|
| `registerVocabularyExpression` | mutation | `command-api` | `/commands/register-vocabulary-expression` | accepted / reused-existing / failed family |
| `vocabularyCatalog` | query | `query-api` | `/vocabulary-catalog` | completed summary / status-only |

## Public Response Shape

- success は `data.registerVocabularyExpression` または `data.vocabularyCatalog` 配下へ写像する
- failure は `errors[0].code` と `errors[0].message` を必須にした共通 shape を返す

## Validation Rules

- initial slice では 1 request に 1 operation だけを許可する
- allowlist 外 operation は downstream へ転送せず `unsupported-operation` を返す
- 複数 operation や operationName 未指定で routing 先が一意に決まらない document は
  `ambiguous-operation` を返す
- gateway は mutation を `command-api`、query を `query-api` へ route する

## Deferred Scope

- GraphQL schema 全体の field expansion
- subscription operation
- persisted query、batch request、GET query transport
