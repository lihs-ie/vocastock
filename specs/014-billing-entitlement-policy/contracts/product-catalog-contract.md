# Contract: Product Catalog

## Purpose

billing product の canonical plan catalog と product ID 対応を固定する。

## Canonical Plan Catalog

| Plan Code | Tier | Billing Cadence | Store Product Reference | Entitlement Bundle | Quota Profile |
|-----------|------|-----------------|-------------------------|--------------------|---------------|
| `free` | `free` | `none` | none | `free-basic` | `free-monthly` |
| `standard-monthly` | `premium` | `monthly` | `vocastock.standard.monthly` | `premium-generation` | `standard-monthly` |
| `pro-monthly` | `premium` | `monthly` | `vocastock.pro.monthly` | `premium-generation` | `pro-monthly` |

## Mapping Rules

- purchase artifact は必ず 1 つの paid `Store Product Reference` から 1 つの canonical `Plan Code` へ写像される
- `free` は store product を持たず、product purchase ではなく baseline policy として扱う
- plan code は paywall、support、quota policy、feature gate の共通 key として使う

## Invariants

- paid plan の `Store Product Reference` を再利用してはならない
- `standard-monthly` と `pro-monthly` の違いは quota profile のみであり、plan code の意味を途中で入れ替えてはならない
- annual、family、coupon 由来 catalog はこの contract へ追加しない
