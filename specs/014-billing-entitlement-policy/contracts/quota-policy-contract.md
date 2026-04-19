# Contract: Quota Policy

## Purpose

plan ごとの explanation / image の月次 quota と、上限到達時の扱いを固定する。

## Monthly Quota Table

| Quota Profile | Explanation Per Month | Image Per Month | Reset Window | Exhaustion Behavior |
|---------------|-----------------------|-----------------|--------------|---------------------|
| `free-monthly` | 10 | 3 | monthly | paywall / upsell 導線付き `limited` |
| `standard-monthly` | 100 | 30 | monthly | status 表示付き `limited` |
| `pro-monthly` | 300 | 100 | monthly | status 表示付き `limited` |

## Plan Mapping

| Plan Code | Quota Profile |
|-----------|---------------|
| `free` | `free-monthly` |
| `standard-monthly` | `standard-monthly` |
| `pro-monthly` | `pro-monthly` |

## Quota Rules

- explanation と image は別カウンタで消費する
- すべての quota は月次でリセットする
- `grace` は paid plan の quota profile を維持する
- `pending-sync` と `expired` は `free-monthly` へ safe fallback する
- `revoked` は execution 不可とし、quota の残量に関わらず generation を許可しない

## Invariants

- `pro-monthly` の quota は `standard-monthly` 未満になってはならない
- `standard-monthly` の quota は `free-monthly` 未満になってはならない
- 画像 quota は explanation quota と同じ値に自動追従させず、独立に管理する
