# Implementation Plan: CI Emulator Build Optimization

**Branch**: `006-ci-emulator-build` | **Date**: 2026-04-17 | **Spec**: [/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/spec.md](/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`emulator-smoke` required check から inline Docker build を外し、baseline hash 付きの
prepared emulator image を再利用する。image preparation は dedicated workflow / job
へ分離し、Docker Buildx と GitHub Actions cache で build path を短縮する。smoke path
は GHCR または同一 run artifact から image を解決して `--no-build` で起動し、
`start_emulators.sh` と関連スクリプトに stage ごとの詳細ログと duration 記録を追加する。

## Technical Context

**Language/Version**: GitHub Actions YAML, Bash, Docker Compose, Docker Buildx/BuildKit, Firebase CLI 15.2.1, Node.js 24.14.1, Temurin JDK 21  
**Primary Dependencies**: GitHub Actions (`actions/checkout`, `actions/upload-artifact`, `actions/download-artifact`), official Docker GitHub Actions (`docker/setup-buildx-action`, `docker/login-action`, `docker/build-push-action`) pinned by commit SHA, GHCR, Dockerized Firebase emulator stack  
**Storage**: Git-managed repository files, GHCR container image storage, GitHub Actions cache, GitHub Actions artifacts, `.artifacts/ci` and `.artifacts/firebase` logs  
**Testing**: `actrun lint`, `actrun workflow run`, `bash scripts/ci/run_emulator_smoke.sh`, `bash scripts/firebase/start_emulators.sh`, `bash scripts/firebase/smoke_local_stack.sh`, GitHub Actions required checks review  
**Target Platform**: GitHub Actions `ubuntu-24.04`, local Docker developer path on macOS 26.4.1 host baseline  
**Project Type**: CI / infrastructure automation for a mobile-app repository  
**Performance Goals**: baseline 変更がない run の 95% 以上で inline rebuild なし、reusable-image run の ready 判定 5 分以内、full required checks の 95% が既存 aggregate budget 30 分以内  
**Constraints**: existing required-check names を維持する、clean GitHub-hosted runner で動作する、image 未解決時は deterministic に fail する、local developer path は引き続き build 可能である、stage logs だけで停止点を判定できる  
**Scale/Scope**: 1 repository、1 Dockerized Firebase emulator image、2 operational paths (preparation / smoke)、1 protected required check (`emulator-smoke`)、3 contract documents、1 new workflow file と既存 `ci.yml` の更新

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain change`. 今回の feature は
      `docs/internal/domain/*.md` の集約、値オブジェクト、状態遷移を変更せず、CI と
      Dockerized emulator path のみを対象にする。
- [x] Async lifecycle は image preparation と smoke execution の operational state
      として定義し、`pending/running/succeeded/failed`、retry-safe、completed checks
      のみ merge 判断へ使うルールを維持する。
- [x] GHCR、GitHub Actions cache、artifact、Docker compose 起動は workflow と
      shell script の adapter 層へ閉じ込め、`contracts/` で入出力と失敗条件を固定する。
- [x] User stories は image reuse、preparation 分離、diagnostic logging に分かれており、
      baseline reuse、separate prep path、log-only diagnosis をそれぞれ独立に検証できる。
- [x] 学習概念には触れず、頻出度、知的度、習熟度、登録状態、生成状態の境界は不変である。
- [x] 新しい domain identifier type は追加しない。operational record でも `id` /
      `xxxId` を使わず、必要なら `identifier` と概念名で表す。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/emulator-image-baseline-contract.md`,
`contracts/image-preparation-contract.md`, and
`contracts/ci-diagnostic-log-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/006-ci-emulator-build/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code (repository root)

```text
.github/
└── workflows/
    ├── ci.yml
    ├── apple-build.yml
    └── emulator-image-prepare.yml

docker/
└── firebase/
    ├── Dockerfile
    ├── compose.yaml
    └── env/
        └── .env.example

docs/
└── development/
    ├── ci-policy.md
    ├── flutter-environment.md
    └── security-version-review.md

scripts/
├── ci/
│   ├── prepare_emulator_image.sh
│   ├── resolve_emulator_image_ref.sh
│   ├── run_emulator_smoke.sh
│   └── check_ci_runtime_budget.sh
├── firebase/
│   ├── start_emulators.sh
│   ├── smoke_local_stack.sh
│   ├── stop_emulators.sh
│   └── measure_emulator_ready_time.sh
└── lib/
    └── vocastock_env.sh

specs/006-ci-emulator-build/
├── checklists/
│   └── requirements.md
├── contracts/
├── data-model.md
├── plan.md
├── quickstart.md
├── research.md
└── spec.md
```

**Structure Decision**: 実装の中心は `.github/workflows/ci.yml` に残る required check
`emulator-smoke` と、新設する `emulator-image-prepare.yml`、および `scripts/ci/` /
`scripts/firebase/` の operational adapter 群である。baseline source-of-truth は
`docker/firebase/Dockerfile`、`docker/firebase/compose.yaml`、`firebase.json`、
`scripts/lib/vocastock_env.sh` に置き、運用文書は
`docs/development/ci-policy.md`、`docs/development/flutter-environment.md`、
`docs/development/security-version-review.md` で追跡する。

## Complexity Tracking

> No constitution violations identified at planning time.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
