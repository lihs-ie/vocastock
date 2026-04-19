# Contract: API Readiness

## Purpose

API service container の canonical success signal を固定する。

## In Scope

- `graphql-gateway`
- `command-api`
- `query-api`

## Rules

- API service は外向き listener を持つ
- 起動成功は `HTTP readiness endpoint` が応答して初めて成立する
- process 起動のみを success signal にしてはならない
- readiness failure は smoke / health review で観測可能でなければならない

## Output

API service について、readiness endpoint ベースで成功可否を判定できること。
