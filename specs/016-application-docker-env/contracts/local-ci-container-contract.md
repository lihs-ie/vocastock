# Contract: Local / CI Container Contract

## Purpose

local verification と CI verification が共有する container build/run 契約を固定する。

## Shared Contract

| Item | Required | Rule |
|------|----------|------|
| Dockerfile | yes | local / CI で同じ定義を使う |
| Build target | yes | local / CI で同じ target 名を使う |
| Entry contract | yes | local / CI で同じ entrypoint / command 契約を使う |
| Image artifact reuse | no | local / CI で別 build を許可する |

## Rules

- local / CI で別 Docker 定義を持ってはならない
- image artifact の事前共有を成功条件にしてはならない
- `docker/applications/compose.yaml` は local orchestration の正本とする

## Output

任意の application について、local と CI が同じ Dockerfile / target / entry contract を使うこと。
