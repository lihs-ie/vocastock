# Contract: Emulator Image Baseline

## Purpose

reusable emulator image の正規参照、invalidations、ownership を定義する。

## Source of Truth Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `docker/firebase/Dockerfile` | yes | emulator image build 定義 |
| `docker/firebase/compose.yaml` | yes | service 名、image/build 構成、port 公開 |
| `firebase.json` | yes | emulator service inventory |
| `scripts/lib/vocastock_env.sh` | yes | approved runtime versions と ready budget |
| `docs/development/ci-policy.md` | yes | required check と ownership の正本 |

## Output Schema

| Field | Required | Description |
|-------|----------|-------------|
| `baselineHash` | yes | source-of-truth 入力から計算した hash |
| `imageReference` | yes | `ghcr.io/<owner>/<repo>/firebase-emulators:<baselineHash>` |
| `distributionChannel` | yes | `ghcr` を primary、`workflow-artifact` を same-run fallback とする |
| `invalidatedBy` | yes | baseline を更新する入力一覧 |
| `owner` | yes | build/publish を担当する workflow または maintainer |

## Rules

- `baselineHash` は `Dockerfile`、`compose.yaml`、`firebase.json`、approved runtime version のいずれかが変わったら更新しなければならない
- reusable smoke path の正規参照は `imageReference` であり、cache key 単独を source of truth にしてはならない
- `distributionChannel = workflow-artifact` は same-run の downstream reuse に限定する
- local developer path は baseline image がなくても成立してよいが、CI smoke path は baseline image 未解決時に fail-fast しなければならない
