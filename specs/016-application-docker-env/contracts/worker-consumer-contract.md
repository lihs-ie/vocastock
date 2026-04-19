# Contract: Worker Consumer Runtime

## Purpose

worker container の canonical run mode と success signal を固定する。

## In Scope

- `explanation-worker`
- `image-worker`
- `billing-worker`

## Rules

- worker は `long-running consumer` を canonical run mode とする
- worker の success signal は queue / subscription 待受プロセスとしての安定稼働とする
- 外向き HTTP endpoint を必須にしてはならない
- one-shot debug execution は補助用途であり、canonical run contract の代替にしてはならない

## Output

worker について、stable-run ベースで成功可否を判定できること。
