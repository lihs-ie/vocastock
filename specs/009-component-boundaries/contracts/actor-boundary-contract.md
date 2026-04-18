# Contract: Actor Boundary

## Purpose

`Actor/Auth Boundary` の component を定義し、auth/session 設計と product 内 component catalog の接続点を固定する。

## Boundary Components

| Component | Owns | Must Not Own | Source of Truth |
|-----------|------|--------------|-----------------|
| `Learner Identity Resolution` | verified actor / identity から `Learner` 参照へ解決する | provider sign-in、session issuance、token verification | 009 component taxonomy + `docs/internal/domain/learner.md` |
| `Actor Session Handoff` | auth/session 境界の completed output を command/query 向け actor reference へ handoff する | raw token 保持、provider credential 管理、domain aggregate mutation | 009 component taxonomy + `specs/008-auth-session-design/` |

## Boundary Rules

- `Learner Identity Resolution` は auth/session の内部状態を再実装してはならない
- `Actor Session Handoff` が app core 側へ渡してよいのは、正規化済み actor reference と最小限の利用可否状態だけである
- `Presentation`、`Command Intake`、`Query Read`、`Async Generation` は Firebase token、provider token、password、session store detail を直接受け取ってはならない
- auth/session implementation detail は `specs/008-auth-session-design/` を正本とし、009 では boundary placement だけを記述する

## Handoff Relationships

| Upstream | Boundary Component | Downstream |
|----------|--------------------|------------|
| auth/session completed result | `Actor Session Handoff` | `Command Intake`, `Query Read` |
| verified actor / identity reference | `Learner Identity Resolution` | `Command Intake`, `Query Read`, `Async Generation` |

## Deferred Areas

- provider availability policy
- account registration / login / logout contract
- session invalidation semantics
- Firebase Authentication specific verification rules

These areas are deferred to `specs/008-auth-session-design/`.
