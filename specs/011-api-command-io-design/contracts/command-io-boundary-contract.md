# Contract: Command I/O Boundary

## Purpose

011 が何を正本化し、どこから先を既存 feature または deferred scope へ委ねるかを固定する。

## Prerequisite Source Of Truth

| Concern | Source Of Truth | 011 で扱う範囲 |
|---------|-----------------|----------------|
| command semantics、duplicate reuse、dispatch consistency | [/Users/lihs/workspace/vocastock/specs/007-backend-command-design/](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/) | canonical I/O shape へ反映する |
| actor handoff、session completion | [/Users/lihs/workspace/vocastock/specs/008-auth-session-design/](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/) | completed handoff input の shape を受ける |
| command intake placement、async workflow boundary | [/Users/lihs/workspace/vocastock/specs/009-component-boundaries/](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/) | 011 が command intake contract であることを確認する |
| subscription / entitlement visibility | [/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/) | `pending-sync` visibility rule を反映する |

## Deferred Scope

| Concern | Source Of Truth | Why Deferred |
|---------|-----------------|-------------|
| HTTP / GraphQL / RPC request schema | future transport feature | 011 は transport 非依存 envelope だけを固定する |
| workflow payload schema | future workflow runtime design | worker 内部 payload は command I/O と別責務である |
| query response schema | future read-model / query design | command response と query response を混ぜない |
| provider-specific error payload | provider adapter design | client 可視 error は canonical `message` に限定する |
| persistence schema | future persistence design | idempotency / request log の物理 schema は 011 の対象外である |

## Boundary Rules

- 011 は command 入口の canonical shape を定義するが、authorization implementation detail は持たない
- 011 は accepted / rejected / failed の response contract を定義するが、query read model を定義しない
- 011 は `pending-sync` を状態表示してよいが、premium unlock 確定情報として返してはならない
- 011 は 007 / 008 / 009 / 010 の behavioral contract を上書きしてはならない
