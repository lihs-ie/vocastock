# Contract: Local Stack

## Purpose

日常開発で利用する local core stack、managed service fallback、完了条件を定義する。

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `docs/development/flutter-environment.md` | yes | local stack 手順と制約の正本 |
| `tooling/versions/approved-components.md` | yes | exact toolchain 承認記録 |
| `firebase.json` | yes | Firebase emulator 対象サービスの source of truth |
| `docker/firebase/compose.yaml` | yes | Firebase core stack |
| `docker/firebase/env/.env.example` | yes | local defaults |
| `scripts/bootstrap/*` | yes | host bootstrap / verify path |
| `scripts/firebase/*` | yes | emulator core smoke path |
| `tooling/fallback/*` | yes | Pub/Sub / Google Drive fixture、sample payload、stub input |
| `scripts/fallback/*` | yes | Pub/Sub / Google Drive local fallback smoke |

## Coverage Matrix

| Concern | Local Mode | Required Outcome |
|---------|------------|------------------|
| Firebase Authentication / Firestore / Hosting | `emulated` | shared cloud なしで日常開発を進められる |
| Firebase Storage | `mixed` | generated image の primary path と混同しない |
| Pub/Sub | `stubbed` または `mixed` | message contract と retry 前提を local で確認できる |
| Google Drive asset storage | `stubbed` または `manual-check` | asset reference と port boundary を local で確認できる |
| Rust / Haskell runtime presence | `host-toolchain` | local host と CI で toolchain availability を確認できる |

## Outputs

| Output | Description |
|--------|-------------|
| core ready signal | Firebase emulator core が利用可能であること |
| fallback ready signal | non-emulated service の local fallback が利用可能であること |
| endpoint catalog | emulator core の接続先一覧 |
| limitation register | local で省略または stub 化している点 |
| smoke logs | 切り分けに必要なログ |

## Rules

- shared cloud 依存なしで日常開発を進められる範囲を明示しなければならない
- local parity がない service は、代替確認手段と実クラウド確認が必要になる条件を必ず記録する
- Node.js、Temurin JDK、Firebase CLI は emulator / tooling 用 runtime として扱い、application runtime と混同してはならない
- generated image の primary path を Firebase Storage emulator に戻してはならない
- fallback profile でも port/adapter 前提と user visibility rule を崩してはならない
