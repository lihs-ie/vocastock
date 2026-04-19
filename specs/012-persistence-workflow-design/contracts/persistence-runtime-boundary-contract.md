# Contract: Persistence And Runtime Boundary

## Purpose

012 が固定する責務、既存 feature から受け継ぐ責務、後続 feature へ委ねる責務を整理する。

## Source Of Truth Matrix

| Concern | Source Of Truth | 012 で扱う範囲 |
|---------|-----------------|----------------|
| command acceptance / duplicate reuse / dispatch semantics | `specs/007-backend-command-design/` | command 後にどの persistence / workflow state を更新するかだけを扱う |
| actor handoff / session completion | `specs/008-auth-session-design/` | persistence owner と lookup 軸への影響だけを扱う |
| component placement / read vs write split | `specs/009-component-boundaries/` | persistence allocation と projection assembly に反映する |
| subscription authority / purchase state / entitlement | `specs/010-subscription-component-boundaries/` | 保存先、projection、runtime state machine に反映する |
| command request / response / idempotency contract | `specs/011-api-command-io-design/` | `IdempotencyRecord` と state summary の persistence expectation に反映する |

## Deferred Scope

| Concern | Source Of Truth | Why Deferred |
|---------|-----------------|-------------|
| physical database / queue / cache 製品選定 | future implementation / infra feature | 012 は logical allocation を固定するだけでよい |
| transport-specific query schema | future query design | projection の存在だけを定義し、wire format は持たない |
| provider payload schema / SDK detail | adapter implementation feature | runtime expectation と persistence だけを定義する |
| deployment topology / scaling policy | future operational design | runtime state machine と別責務である |
| operator tooling UI | future operational tooling feature | dead-letter review unit の存在だけを定義する |

## Boundary Rules

- 012 は logical store / projection / runtime state machine を定義するが、vendor-specific implementation は定義しない
- 012 は user-facing completed visibility rule を保持し、未完了成果物を completed projection にしない
- 012 は runtime state を豊かに持てるが、domain-facing status 概念を再定義してはならない
- 012 は read projection refresh を eventual にしてよいが、authoritative write より先に completed と見せてはならない
