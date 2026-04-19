# Contract: Source Of Truth Update

## Purpose

015 の topology 変更をどの正本へ反映し、どの feature artifact を再同期するかを一覧化する。

## Canonical Sync Targets

| Target | Update Type | Why Required |
|--------|-------------|--------------|
| `docs/external/adr.md` | `canonical-sync` | product-wide component / topology 正本のため |
| `docs/external/requirements.md` | `canonical-sync` | deployment topology と source-of-truth 導線の正本のため |

## Artifact Resync Targets

| Target | Update Type | Change Theme |
|--------|-------------|--------------|
| `specs/004-tech-stack-definition/` | `artifact-resync` | boundary stack、interoperability、migration wave |
| `specs/009-component-boundaries/` | `artifact-resync` | `Command Intake` / `Query Read` の physical topology 反映 |
| `specs/010-subscription-component-boundaries/` | `artifact-resync` | subscription read / reconciliation の配置反映 |
| `specs/011-api-command-io-design/` | `artifact-resync` | unified gateway と command/query 前段の更新 |
| `specs/012-persistence-workflow-design/` | `artifact-resync` | durable state handoff と projection lag の topology 反映 |
| `specs/013-flutter-ui-state-design/` | `artifact-resync` | unified endpoint と mobile binding 反映 |
| `specs/014-billing-entitlement-policy/` | `artifact-resync` | policy が独立 deployment でないことの明確化 |

## Deferred References

| Concern | Update Type | Why Deferred |
|---------|-------------|-------------|
| transport schema detail | `deferred-reference` | query / API schema feature が正本 |
| gateway implementation detail | `deferred-reference` | topology では deployment unit だけ固定すればよい |
| service internal module layout | `deferred-reference` | implementation planning の責務 |
| scaling / budget / alert policy | `deferred-reference` | operational feature の責務 |

## Rule

- canonical sync target を更新する場合は、対応する artifact resync target の要否も同時に判定しなければならない
- topology 変更を `docs/external` に同期せず、015 配下だけで正本化してはならない
