# Contract: Actor Handoff For Command I/O

## Purpose

008 の completed auth/session output を、011 の command request へどう受けるかを固定する。

## Accepted Handoff Input

| Field | Required | Description |
|-------|----------|-------------|
| `actor` | Yes | normalized actor reference |
| `authAccount` | Yes | upstream auth account 参照 |
| `session` | Yes | upstream session 参照 |
| `sessionState` | Yes | `active` または `rechecked-active` |

## Handoff Rules

| Stage | Required Condition | Must Not Happen | Command-side Interpretation |
|-------|--------------------|-----------------|-----------------------------|
| Protected Operation Intake | 008 の protected operation start 条件を満たし、normalized actor reference が available | raw token や provider credential を request に渡す | `ActorHandoffInput` として受理できる |
| Ownership Check | command target の owner と actor が整合する | auth/session detail 自体を ownership error と混同する | `ownership-mismatch` だけを返す |
| Session Recheck Path | upstream が active session を再確認済み | expired / invalidated session を completed handoff として流す | `sessionState = rechecked-active` を受ける |

## Visibility Rules

- command request は Firebase ID token、refresh token、provider token、password、external credential detail を含めてはならない
- completed actor handoff の最小 shape は `actor`、`authAccount`、`session`、`sessionState` である
- command response は actor handoff の内部検証経路を返してはならない
- actor handoff の behavioral contract 自体は [session-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/session-handoff-contract.md) を正本とする
