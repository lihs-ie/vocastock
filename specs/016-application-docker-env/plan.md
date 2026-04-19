# Implementation Plan: Application Container Environments

**Branch**: `016-application-docker-env` | **Date**: 2026-04-19 | **Spec**: [/Users/lihs/workspace/vocastock/specs/016-application-docker-env/spec.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/016-application-docker-env/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

各 deployable application の Docker 実行環境を docs-first で固定する。対象は
`graphql-gateway`、`command-api`、`query-api`、`explanation-worker`、
`image-worker`、`billing-worker` であり、`docker/applications/<application>/` 配下の Docker assets、
local / CI 共通の Dockerfile / target / entry contract、API 向け `HTTP readiness endpoint`、
worker 向け `long-running consumer` success signal、repository-wide shared dependency stack
との境界、required / optional の環境入力を整理する。`docker/firebase/` は既存の shared
dependency stack として再利用し、アプリ個別の container profile とは分離する。
最終同期先は `docs/external/adr.md` と `docs/external/requirements.md` とする。

## Technical Context

**Language/Version**: Dockerfile syntax 1.x、Docker Compose specification、Bash、Rust 2021 workspace manifests、Markdown 1.x documentation artifacts  
**Primary Dependencies**: Docker-compatible runtime、Docker Compose、Cargo workspace (`/Users/lihs/workspace/vocastock/Cargo.toml`)、`/Users/lihs/workspace/vocastock/applications/backend/*`、`/Users/lihs/workspace/vocastock/packages/rust/shared-auth`、`/Users/lihs/workspace/vocastock/docker/firebase/`、`/Users/lihs/workspace/vocastock/docs/external/requirements.md`、`/Users/lihs/workspace/vocastock/docs/external/adr.md`、`/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/`、`/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/`、`/Users/lihs/workspace/vocastock/specs/012-persistence-workflow-design/`、`/Users/lihs/workspace/vocastock/specs/015-command-query-topology/`  
**Storage**: Git-managed repository files、container image layers、local compose network、application env files、existing repository-wide local dependency stack  
**Testing**: docs-first independent review、`cargo test` for Rust application baseline、`docker compose config` review、per-application container build review、API readiness smoke review、worker stable-run review  
**Target Platform**: local Docker-compatible developer host、CI Linux container path、Cloud Run-aligned service / worker deployment units  
**Project Type**: infrastructure / backend containerization design  
**Performance Goals**: レビュー担当者が 10 分以内に 6 application の起動契約を説明できること、開発者が 15 分以内に任意の 1 application の build/run contract を再現できること、API container は readiness 判定まで一貫した成功条件を持ち、worker container は stable-run 判定まで一貫した成功条件を持つこと  
**Constraints**: Flutter client は scope 外、`graphql-gateway` / `command-api` / `query-api` / worker の deployment separation を維持する、local / CI は同じ Dockerfile / target / entry contract を共有する、API service は `HTTP readiness endpoint` を canonical success signal とする、worker は `long-running consumer` を canonical run mode とし外向き HTTP endpoint を必須にしない、`docker/firebase/` は application-specific profile に統合しない、auth/session と workflow runtime の behavioral contract は既存正本を再利用する  
**Scale/Scope**: 6 application runtime profile、2 success-signal family (API / worker)、1 shared dependency stack boundary、5 contract documents、1 source-of-truth sync map

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is explicitly `no domain change`. この feature は `docs/internal/domain/*.md`
      の aggregate、value object、repository contract を変更せず、アプリごとの container
      実行契約だけを対象にする。
- [x] Async generation の lifecycle rule は 012 の正本を再利用し、不完全な生成結果を
      ユーザーへ見せない前提を維持する。worker container は runtime contract を定義するが、
      user-visible payload rule は変更しない。
- [x] External dependencies remain behind ports/adapters. identity boundary、state store
      boundary、async messaging boundary、asset storage boundary、billing verification /
      notification boundary は既存の port / adapter 設計を前提にし、container feature で
      vendor API 直結を導入しない。
- [x] User stories remain independently implementable and reviewable. application profile、
      shared / app-specific requirement、local / CI contract は別 artifact として確認できる。
- [x] 頻出度、知的度、習熟度、登録状態、解説生成状態、画像生成状態、purchase state、
      subscription state、entitlement を混同しない。今回の feature は runtime unit と
      execution contract を扱い、学習概念を変更しない。
- [x] Identifier naming follows the constitution. container-related entity と contract でも
      `id` / `xxxId` を導入せず、既存 identifier naming rule を維持する。

Post-design re-check: PASS. Verified against `/Users/lihs/workspace/vocastock/specs/016-application-docker-env/research.md`,
`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/data-model.md`,
`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/application-runtime-profile-contract.md`,
`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/local-ci-container-contract.md`,
`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/api-readiness-contract.md`,
`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/worker-consumer-contract.md`, and
`/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/environment-input-boundary-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/016-application-docker-env/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── api-readiness-contract.md
│   ├── application-runtime-profile-contract.md
│   ├── environment-input-boundary-contract.md
│   ├── local-ci-container-contract.md
│   └── worker-consumer-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
Cargo.toml
README.md
.gitignore
.dockerignore

.github/
└── workflows/
    └── ci.yml

applications/
└── backend/
    ├── README.md
    ├── graphql-gateway/
    │   ├── Cargo.toml
    │   └── src/
    │       └── main.rs
    ├── command-api/
    │   ├── Cargo.toml
    │   └── src/
    │       └── main.rs
    ├── query-api/
    │   ├── Cargo.toml
    │   └── src/
    │       └── main.rs

packages/
└── rust/
    └── shared-auth/

docker/
├── firebase/
│   ├── Dockerfile
│   ├── compose.yaml
│   └── env/
└── applications/
    ├── graphql-gateway/
    │   └── Dockerfile
    ├── command-api/
    │   └── Dockerfile
    ├── query-api/
    │   └── Dockerfile
    ├── explanation-worker/
    │   ├── Dockerfile
    │   └── entrypoint.sh
    ├── image-worker/
    │   ├── Dockerfile
    │   └── entrypoint.sh
    ├── billing-worker/
    │   ├── Dockerfile
    │   └── entrypoint.sh
    ├── compose.yaml
    └── env/
        └── .env.example

docs/
├── development/
│   └── backend-container-environment.md
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/

scripts/
├── bootstrap/
│   ├── validate_application_containers.sh
│   └── validate_local_stack.sh
├── ci/
│   ├── check_ci_runtime_budget.sh
│   ├── run_application_container_smoke.sh
│   └── run_local_stack_smoke.sh
└── lib/
    └── vocastock_env.sh

specs/
├── 011-api-command-io-design/
├── 012-persistence-workflow-design/
├── 015-command-query-topology/
└── 016-application-docker-env/
```

**Structure Decision**: container 定義は `docker/applications/<application>/` 配下へ集約し、
各アプリの `Dockerfile` と worker `entrypoint.sh` を code directory から分離する。
複数 application を束ねる local orchestration と shared env defaults も `docker/applications/`
に集約し、
既存の `docker/firebase/` は repository-wide shared dependency stack として分離する。
`graphql-gateway`、`command-api`、`query-api` の Rust workspace は既存 skeleton を再利用しつつ
`src/main.rs` に最小の HTTP readiness endpoint を持つ long-running process を追加する。
worker 群は 016 の scope で `docker/applications/<worker>/Dockerfile` と `entrypoint.sh` を持ち、
queue / subscription を待ち受ける `long-running consumer` 契約を固定する。business logic と
deployment publication detail は後続実装へ委ねる。

## Complexity Tracking

> No constitution violations requiring justification were identified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
