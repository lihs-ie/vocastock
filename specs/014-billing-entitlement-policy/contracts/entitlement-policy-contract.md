# Contract: Entitlement Policy

## Purpose

plan code からどの entitlement bundle が適用されるかを固定する。

## Canonical Bundles

| Bundle Name | Included Feature Keys | Notes |
|-------------|-----------------------|-------|
| `free-basic` | `catalog-viewing`, `vocabulary-registration`, `explanation-generation`, `image-generation`, `completed-result-viewing`, `subscription-status-access`, `restore-access` | generation は quota 制御前提の limited access |
| `premium-generation` | `catalog-viewing`, `vocabulary-registration`, `explanation-generation`, `image-generation`, `completed-result-viewing`, `subscription-status-access`, `restore-access` | free と同じ feature key set を持つが、paid quota profile を適用できる |

## Plan To Bundle Mapping

| Plan Code | Bundle Name |
|-----------|-------------|
| `free` | `free-basic` |
| `standard-monthly` | `premium-generation` |
| `pro-monthly` | `premium-generation` |

## Policy Rules

- `standard-monthly` と `pro-monthly` は同一の premium entitlement bundle を共有する
- free と paid の初期差分は feature key set より quota profile に強く寄せる
- 将来 premium-only feature を追加する場合は bundle 差分として追加し、quota 差分と混同しない

## Invariants

- bundle と quota profile を同じ責務として潰してはならない
- `pending-sync` は bundle の新規昇格根拠にしてはならない
- `grace` は paid bundle を維持しなければならない
