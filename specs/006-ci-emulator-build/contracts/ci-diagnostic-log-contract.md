# Contract: CI Diagnostic Log

## Purpose

emulator image preparation と smoke execution の停止点を maintainer が artifact だけで判定できるよう、必須ログ項目を定義する。

## Required Stages

| Stage | Required | Notes |
|-------|----------|-------|
| `image-resolution` | yes | baseline hash、resolved image source、cache/registry miss reason |
| `image-build` | conditional | build が走った場合のみ |
| `image-publish` | conditional | GHCR publish が走った場合のみ |
| `image-pull` | conditional | smoke path が registry pull した場合のみ |
| `artifact-load` | conditional | same-run artifact を読み込んだ場合のみ |
| `container-start` | yes | `docker compose up` 実行開始と完了 |
| `readiness-wait` | yes | ready 判定開始、timeout、成功 |
| `cleanup` | conditional | stop / down / failure cleanup |

## Required Log Fields

| Field | Required | Description |
|-------|----------|-------------|
| `stage` | yes | stage 名 |
| `startedAt` | yes | 開始時刻 |
| `completedAt` | conditional | 完了時刻 |
| `durationSeconds` | conditional | 経過秒 |
| `result` | yes | `succeeded` / `failed` / `skipped` |
| `details` | yes | source ref、cache scope、container 名、timeout reason など |

## Failure Diagnostics

- readiness timeout 時は `docker compose ps` と container log tail を残す
- container が ready 前に落ちた場合は timeout と区別できる message を残す
- image miss 時は baseline hash、期待 image ref、どの source が不在だったかを残す
- log path は `.artifacts/ci/logs/` または `.artifacts/firebase/logs/` に集約する

## Rules

- stage logs は成功時も失敗時も同じ順序で出力する
- `emulator-smoke` required check は recorded log だけで停止点を説明できなければ green と見なしてはならない
- log bundle は maintainer 向けのみであり、エンドユーザー向け成果物として公開してはならない
