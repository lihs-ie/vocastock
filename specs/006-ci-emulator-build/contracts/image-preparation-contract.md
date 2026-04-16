# Contract: Image Preparation

## Purpose

prepared emulator image を解決、build、cache export、publish する operational unit の入出力を定義する。

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| baseline contract | yes | [emulator-image-baseline-contract.md](/Users/lihs/workspace/vocastock/specs/006-ci-emulator-build/contracts/emulator-image-baseline-contract.md) |
| GitHub Actions runner | yes | `ubuntu-24.04` |
| Buildx cache backend | yes | `type=gha` |
| package credentials | conditional | GHCR publish/pull に必要な `GITHUB_TOKEN` permission |
| workflow context | yes | push / pull_request / workflow_dispatch / workflow_call |

## Outputs

| Output | Description |
|--------|-------------|
| resolved image source | `existing-ghcr` / `rebuilt-and-published` / `rebuilt-and-artifacted` / `failed` |
| image reference | smoke job が参照する正規 image ref |
| optional artifact bundle | same-run reuse 用 image tarball |
| stage log | image-resolution、image-build、image-publish の記録 |

## Rules

- image preparation は `emulator-smoke` job の inline build として実装してはならない
- build が必要な場合は Buildx cache を利用して layer reuse を試みる
- trusted context では GHCR publish を優先し、publish 不可な context では same-run artifact reuse を許可する
- image が未解決または stale と判定された場合は、原因を stage log に記録して failure を返す
- reusable image が既に存在する場合、preparation unit は no-op success として image ref だけ返してよい
