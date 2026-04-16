# vocastock Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-16

## Active Technologies
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/development/*.md` (003-architecture-design)
- Git-managed repository files、設計上で参照する抽象的な永続化ストアとアセットストア (003-architecture-design)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/` (005-domain-modeling)
- Git-managed repository files、設計上で参照する抽象的な explanation storage と image asset storage (005-domain-modeling)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/` (005-domain-modeling)
- Git-managed repository files、設計上で参照する抽象的な learner store、explanation store、image asset store (005-domain-modeling)
- Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/` (005-domain-modeling)
- Flutter 3.41.5 (stable), Dart SDK bundled with Flutter 3.41.5, shell scripts, YAML, GitHub Actions YAML + Flutter SDK 3.41.5, Xcode 26.4, Android Studio 2025.3, CocoaPods 1.16.2, Temurin JDK 21.0.10+7 LTS, Node.js 24.14.1 LTS, Firebase CLI 15.2.1, Docker Desktop 4.69.0, GitHub-hosted runners, Trivy Action 0.33.1 (005-domain-modeling)
- Git-managed repository files, Docker volumes for emulator data, GitHub Actions artifacts for CI reports (005-domain-modeling)

- Markdown 1.x, YAML, JSON + Spec Kit workflow, existing domain documents, requirements memo, ADR memo (001-complete-domain-model)

## Project Structure

```text
docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/
        ├── common.md
        ├── explanation.md
        ├── service.md
        └── visual.md

specs/
└── 001-complete-domain-model/
    ├── contracts/
    ├── data-model.md
    ├── plan.md
    ├── quickstart.md
    ├── research.md
    └── spec.md
```

## Commands

- Inspect current feature spec: `sed -n '1,220p' specs/001-complete-domain-model/spec.md`
- Inspect current implementation plan: `sed -n '1,260p' specs/001-complete-domain-model/plan.md`
- Search domain terminology across docs: `rg -n "VocabularyEntry|Explanation|VisualImage|Identifier|Proficiency|Generation" docs specs`

## Code Style

Markdown 1.x, YAML, JSON: Keep terminology consistent across `docs/internal/domain/`,
`docs/external/`, and `specs/`. When a domain boundary changes, update the affected
domain docs in the same change set. Identifier types must use `XxxIdentifier`,
an aggregate's own identifier field must be `identifier`, and related identifier
fields must use concept names such as `bank`, `entry`, or `image`.

## Recent Changes
- 005-domain-modeling: Added Flutter 3.41.5 (stable), Dart SDK bundled with Flutter 3.41.5, shell scripts, YAML, GitHub Actions YAML + Flutter SDK 3.41.5, Xcode 26.4, Android Studio 2025.3, CocoaPods 1.16.2, Temurin JDK 21.0.10+7 LTS, Node.js 24.14.1 LTS, Firebase CLI 15.2.1, Docker Desktop 4.69.0, GitHub-hosted runners, Trivy Action 0.33.1
- 005-domain-modeling: Added Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`
- 005-domain-modeling: Added Markdown 1.x, YAML/JSON reference documents + 憲章、`docs/internal/domain/*.md`、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/001-complete-domain-model/`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`


<!-- MANUAL ADDITIONS START -->
- 002-flutter-dev-env: ローカル host baseline は `macOS 26.4.1 / Flutter 3.41.5 / Xcode 26.4 / Android Studio 2025.3 / Docker Desktop 4.69.0`
- 002-flutter-dev-env: 検証コマンドは `bash scripts/bootstrap/verify_macos_toolchain.sh`、`bash scripts/bootstrap/validate_local_setup.sh`、`bash scripts/firebase/measure_emulator_ready_time.sh`
<!-- MANUAL ADDITIONS END -->
