# Implementation Plan: Flutter開発環境基盤整備

**Branch**: `002-flutter-dev-env` | **Date**: 2026-04-16 | **Spec**: [/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/spec.md](/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/002-flutter-dev-env/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

macOS を公式ローカル開発ホストとして、最新実機で検証済みの host baseline を正にした
iOS / Android / macOS 向け開発基盤へ更新する。ローカル host baseline は
macOS 26.4.1、Flutter stable 3.41.5、Xcode 26.4、Android Studio 2025.3、
CocoaPods 1.16.2、Docker Desktop 4.69.0 を基準にする。ローカルでは Docker 化した
Firebase エミュレーターを Node.js 24 LTS、Temurin JDK 21 LTS、Firebase CLI 15.2.1
で再現し、CI では `macos-15` と `ubuntu-24.04` を使い分けて静的検査、テスト、
ビルド smoke、脆弱性検査、保護ブランチ判定を一貫して適用する。

## Technical Context

**Language/Version**: Flutter 3.41.5 (stable), Dart SDK bundled with Flutter 3.41.5, shell scripts, YAML, GitHub Actions YAML  
**Primary Dependencies**: Flutter SDK 3.41.5, Xcode 26.4, Android Studio 2025.3, CocoaPods 1.16.2, Temurin JDK 21.0.10+7 LTS, Node.js 24.14.1 LTS, Firebase CLI 15.2.1, Docker Desktop 4.69.0, GitHub-hosted runners, Trivy Action 0.33.1  
**Storage**: Git-managed repository files, Docker volumes for emulator data, GitHub Actions artifacts for CI reports  
**Testing**: `flutter doctor --verbose`, `dart analyze`, `flutter test`, platform build smoke, Dockerized Firebase emulator healthcheck, Trivy filesystem scan, branch protection enforcement review  
**Target Platform**: macOS 26.4.1 local host baseline, iOS / Android / macOS app targets, GitHub Actions `macos-15` and `ubuntu-24.04`  
**Project Type**: mobile-app developer-platform / CI / infrastructure documentation  
**Performance Goals**: 新規開発者が 60 分以内に環境構築を完了できること、ローカル emulator stack が 5 分以内に ready になること、必須 CI が 30 分以内で収束すること  
**Constraints**: 公式ローカルホストは macOS のみ、Firebase 利用サービスはすべてローカル再現対象、`Critical` / `High` / `Medium` の脆弱性は統合前に遮断、正式 LTS がない製品は公式 stable 系統を採用、実機で確認済みの host baseline 更新は差分と理由を同じ変更単位で記録する、`FIREBASE_TOKEN` のような長期トークン依存を避ける  
**Scale/Scope**: 1 repository、3 protected branch patterns (`main` / `develop` / `release/*`)、3 target platforms、1 Dockerized Firebase emulator stack、3 contract documents、1 version approval catalog

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain change`. この feature は `docs/internal/domain/*.md`
      の語彙・集約・状態遷移を変更せず、開発基盤と CI 運用のみを対象にする。
- [x] Async generation の実装仕様は変更しない。既存の「完了結果のみユーザー表示」
      ルールは維持し、CI やローカル手順でも不完全な生成成果物をエンドユーザー向け
      成果物として扱わない。
- [x] Firebase CLI、Docker、GitHub Actions、Trivy などの外部依存は、スクリプト、
      コンテナ、workflow、設定契約の層に閉じ込めて扱い、導入面を `contracts/`
      で明示する。
- [x] ユーザーストーリーは、ローカル再現、CI 品質確認、バージョン採用根拠の説明に
      分離されており、それぞれ単独で検証可能である。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態といった
      学習概念には触れず、概念境界を変更しない。
- [x] 計画成果物内の識別子命名は憲章に従う。`id` / `xxxId` は使わず、型は
      `XxxIdentifier`、自己識別子は `identifier`、関連参照は概念名で表現する。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/version-approval-contract.md`, `contracts/local-stack-contract.md`,
and `contracts/ci-policy-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/002-flutter-dev-env/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
README.md
firebase.json
.firebaserc
.trivyignore

.github/
├── workflows/
└── trivy.yaml

docker/
└── firebase/
    ├── Dockerfile
    ├── compose.yaml
    └── env/

docs/
├── development/
│   ├── flutter-environment.md
│   ├── ci-policy.md
│   └── security-version-review.md
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/

scripts/
├── bootstrap/
├── ci/
├── firebase/
└── lib/

tooling/
└── versions/
    └── approved-components.md

specs/002-flutter-dev-env/
├── checklists/
│   └── requirements.md
├── contracts/
├── data-model.md
├── plan.md
├── quickstart.md
├── research.md
└── spec.md
```

**Structure Decision**: 実装はアプリ本体コードより先に、`firebase.json` /
`.firebaserc`、`docker/firebase/`、`.github/workflows/`、`scripts/`、
`docs/development/`、`tooling/versions/`、`README.md` を中心に整備する。
環境差分と CI 差分を product code から分離し、採用バージョンの証跡、実機 baseline
差分、local default / secret policy、ruleset 運用ルールを repository 直下で
追跡できる形にする。

## Complexity Tracking

> No constitution violations identified at planning time.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
