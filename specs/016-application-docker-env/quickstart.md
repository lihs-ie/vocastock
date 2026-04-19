# Quickstart: Application Container Environments

## 1. Scope Confirmation

1. [spec.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/spec.md) を開き、in-scope application が `graphql-gateway`、`command-api`、`query-api`、`explanation-worker`、`image-worker`、`billing-worker` の 6 つであることを確認する
2. Flutter client が scope 外であり、`docker/firebase/` が repository-wide shared dependency stack として別管理であることを確認する

## 2. Runtime Contract Review

1. [data-model.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/data-model.md) の `ApplicationRuntimeProfile` と `SharedRuntimeBaseline` を読む
2. API service の canonical success signal が `HTTP readiness endpoint` であることを確認する
3. worker の canonical success signal が `stable long-running consumer` であり、外向き HTTP endpoint を必須にしないことを確認する

## 3. Contract Review

1. [application-runtime-profile-contract.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/application-runtime-profile-contract.md) で `docker/applications/<application>/` 配下の配置規則を確認する
2. [local-ci-container-contract.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/local-ci-container-contract.md) で local / CI が同じ Dockerfile / target / entry contract を共有することを確認する
3. [api-readiness-contract.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/api-readiness-contract.md) と [worker-consumer-contract.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/worker-consumer-contract.md) で success signal の差を確認する
4. [environment-input-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/016-application-docker-env/contracts/environment-input-boundary-contract.md) で required / optional input と secret boundary を確認する

## 4. Source-of-Truth Sync Review

1. `docs/external/adr.md` と `docs/external/requirements.md` が最終同期先であることを確認する
2. 011、012、015 の正本と矛盾しないことを確認する

## 5. Planning Exit Check

- application ごとの Docker asset ownership が説明できる
- local / CI 共通 contract と image artifact 非共有方針が説明できる
- API / worker の success signal の違いが説明できる
- `docker/firebase/` が application profile の一部ではないことを説明できる
