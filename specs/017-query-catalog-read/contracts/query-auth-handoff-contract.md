# Contract: Query Auth Handoff

## Purpose

catalog read が再利用する token verification / actor handoff の境界を固定する。

## Input

- `Authorization` 相当の bearer token から `shared-auth` の `TokenVerificationPort` を使って検証する
- app-facing read logic は `VerifiedActorContext` を受け取る

## Required Handoff Shape

| Field | Description |
|-------|-------------|
| `actor` | read projection の所有主体 |
| `authAccount` | auth account 参照 |
| `session` | session 参照 |
| `sessionState` | `active` または `reauth-required` |

## Rules

- raw token、provider credential、session secret を query payload に含めてはならない
- `sessionState = reauth-required` は catalog read 成功として扱ってはならない
- auth failure 時は read payload を返さず、internal auth detail と user-facing failure を分離する
- `query-api` は `shared-auth` の behavioral contract を再利用し、独自の actor handoff 型を正本化してはならない

## Non-Ownership

- `query-api` は provider-specific auth policy を再定義しない
- `query-api` は command 側 session issuance や token refresh を own しない
