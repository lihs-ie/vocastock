# Contract: Gateway Failure Envelope

## Purpose

public GraphQL endpoint が失敗時に返す最小 shape と category を固定する。

## Envelope

top-level response は GraphQL-style の `errors` 配列を持つ。

| Field | Required | Notes |
|-------|----------|-------|
| `errors` | Yes | failure envelope object を 1 件以上含む array |

## Error Object

| Field | Required | Notes |
|-------|----------|-------|
| `code` | Yes | failure category |
| `message` | Yes | user-facing explanation |
| `retryable` | No | optional retry hint |

## Required Categories

- `unsupported-operation`
- `ambiguous-operation`
- `downstream-unavailable`
- `downstream-auth-failed`
- `downstream-invalid-response`

## Exposure Rules

- raw token、provider credential、internal route URL、secret detail を含めてはならない
- downstream service 固有の internal-only message はそのまま public に露出してはならない
- mutation / query どちらでも同じ `errors[0]` object shape を使う
