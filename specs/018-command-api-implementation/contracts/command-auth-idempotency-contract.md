# Contract: Command Auth & Idempotency

## Purpose

`command-api` が再利用する auth/session handoff と actor-scoped idempotency rule を固定する。

## Auth / Session Rules

| Stage | Rule |
|-------|------|
| Token verification | `shared-auth` の behavioral contract を再利用する |
| Completed handoff | `VerifiedActorContext` を command actor の completed context として受ける |
| Failure path | missing / invalid / reauth-required は write を行わず失敗応答へ写像する |
| Visibility | raw token、provider credential、session secret を response に含めない |

## Idempotency Rules

| Situation | Outcome |
|-----------|---------|
| same actor + same key + same normalized text + same `startExplanation` | 既知の accepted / reused-existing 結果を replay する |
| same actor + same key + different normalized request | `idempotency-conflict` を返す |
| same actor + different key + same normalized text on existing registration | `reused-existing` を返す |
| different actor + same key | replay とみなしてはならない |

## Rules

- same-request replay では新しい dispatch を行ってはならない
- duplicate registration reuse と same-request replay は別概念として保持する
- `startExplanation = false` の duplicate request では explanation 再開を行ってはならない
