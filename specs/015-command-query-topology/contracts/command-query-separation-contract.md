# Contract: Command Query Separation

## Purpose

`command-api` と `query-api` の責務差分、可視性保証、越境禁止ルールを固定する。

## Responsibility Matrix

| Concern | `command-api` | `query-api` |
|---------|---------------|-------------|
| token verification | yes | yes |
| actor handoff | yes | yes |
| command acceptance | yes | no |
| idempotency | yes | no |
| authoritative write | yes | no |
| workflow dispatch | yes | no |
| completed result read | no | yes |
| status-only read | no | yes |
| entitlement / quota / gate read | no | yes |

## Visibility Rules

- `command-api` は completed result payload を返してはならない
- `command-api` は accepted / rejected / failed と status handle を返してよい
- `query-api` は completed result が無い間は status-only を返してよい
- `query-api` は projection lag 中に provisional completed payload を返してはならない

## Non-Ownership Rules

- `command-api` は read projection の assembled response contract を own してはならない
- `query-api` は workflow 起動、retry dispatch、purchase verification 開始を own してはならない
- 両 service は shared auth/session contract を再利用してよいが、provider policy 自体を再定義してはならない

## Handoff Rule

`command-api` から `query-api` への情報伝播は direct call ではなく durable state handoff を
前提とする。query 側は projection refresh を eventual にしてよいが、authoritative write より
先に completed と見せてはならない。
