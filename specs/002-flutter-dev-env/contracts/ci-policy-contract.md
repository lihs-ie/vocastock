# Contract: CI Policy

## Purpose

保護対象ブランチと CI required checks の対応、ブロック条件、artifact 取り扱いを定義する。

## Required Checks

| Check | Runner | Blocking | Notes |
|-------|--------|----------|-------|
| `toolchain-validate` | `ubuntu-24.04` | yes | version catalog と lock/state の整合確認 |
| `flutter-static-checks` | `ubuntu-24.04` | yes | `flutter doctor`, `dart analyze` |
| `flutter-test` | `ubuntu-24.04` | yes | unit / widget / integration のうち存在するもの |
| `emulator-smoke` | `ubuntu-24.04` | yes | Dockerized Firebase emulator 起動確認 |
| `vulnerability-scan` | `ubuntu-24.04` | yes | `MEDIUM,HIGH,CRITICAL` で fail |
| `apple-build-smoke` | `macos-15` | yes | iOS / macOS build の最小確認 |
| `android-build-smoke` | `ubuntu-24.04` or `macos-15` | yes | Android build の最小確認 |

## Branch Policy Mapping

| Branch Pattern | Required Checks |
|----------------|-----------------|
| `main` | すべて |
| `develop` | すべて |
| `release/*` | すべて |

## Rules

- required check が 1 つでも失敗した PR は merge 不可
- vulnerability-scan は Medium 以上で fail する
- CI はエンドユーザー向け成果物を公開しない。保持するのは reviewer / maintainer 向け log と report のみ
- branch protection は GitHub の required status checks と review requirement を併用する
- 例外的に check を一時停止する場合は、理由、期限、代替統制を記録しなければならない
