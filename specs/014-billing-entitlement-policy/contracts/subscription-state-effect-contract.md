# Contract: Subscription State Effect

## Purpose

`active`、`grace`、`pending-sync`、`expired`、`revoked` が entitlement、quota、UI access、
recovery にどう影響するかを固定する。

## State Effect Matrix

| State | Entitlement Effect | Quota Effect | UI Access Effect | Recovery Effect |
|-------|--------------------|--------------|------------------|-----------------|
| `active` | paid plan bundle を適用 | paid quota profile を適用 | 通常利用継続 | 通常の subscription status |
| `grace` | paid plan bundle を維持 | paid quota profile を維持 | 通常利用継続 | grace 説明と更新導線 |
| `pending-sync` | premium bundle の新規昇格を保留 | `free-monthly` へ safe fallback | 状態表示は許可、premium 断定は不可 | refresh / restore 導線 |
| `expired` | `free-basic` へ戻す | `free-monthly` へ戻す | completed result は許可、premium upsell を表示 | paywall / restore 導線 |
| `revoked` | normal bundle access を停止 | generation を停止 | `Restricted` へ送る | recovery section のみ許可 |

## Alignment Rules

- `grace` の paid 維持は 010 の authority rule に従う
- `pending-sync` の premium unlock 禁止は 010 と 011 に従う
- `expired` / `revoked` の UI access は 013 の `Paywall` / `Restricted` に整合しなければならない
- purchase verification や notification reconciliation の state progression は 012 を正本参照する

## Invariants

- `grace` を free fallback に落としてはならない
- `pending-sync` を paid active と同等に扱ってはならない
- `revoked` を単なる `expired` として扱ってはならない
