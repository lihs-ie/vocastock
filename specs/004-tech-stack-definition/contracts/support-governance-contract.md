# Contract: Support Governance

## Purpose

stack decision ごとの support 方針、version strategy、見直し契機を定義する。

## Governance Tiers

| Tier | Scope | Version Strategy | Source of Truth |
|------|-------|------------------|-----------------|
| Toolchain | Flutter SDK, Rust toolchain, GHC toolchain, Docker, Firebase CLI, Xcode など | `exact` | `tooling/versions/approved-components.md` |
| Managed Service Family | Firebase Authentication, Cloud Firestore, Firebase Hosting, Cloud Run, Google Cloud Pub/Sub, Google Drive API | `family` | stack contract と vendor support policy |
| Application Libraries | `graphql_flutter`、Rust GraphQL/runtime library 群、Haskell worker library 群 | `implementation-wave-pin` | 実装 feature で導入する lockfile / catalog |

## Rules

- `exact` tier は approved-components に exact version、reviewedAt、reviewCadence を持たなければならない
- `family` tier は service family と contract compatibility を source of truth とし、未承認の vendor-specific coupling を導入してはならない
- `implementation-wave-pin` tier は package 導入時に exact pin と review record を追加しなければならない
- vendor support の逸脱、`MEDIUM` 以上の未解決 finding、contract break、または Drive / Pub/Sub adapter の互換破壊が見つかった場合は再評価を必須とする

## Initial Baseline

- Flutter SDK 3.41.5
- Rust toolchain family
- GHC toolchain family
- `graphql_flutter`
- Firebase Authentication family
- Cloud Firestore family
- Firebase Hosting family
- Cloud Run family
- Google Cloud Pub/Sub family
- Google Drive API family
