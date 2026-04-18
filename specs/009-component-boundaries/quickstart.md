# Quickstart: 機能別コンポーネント定義

## 1. アーキテクチャの主軸を確認する

最初に [architecture-topology-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/architecture-topology-contract.md) を読み、オニオンアーキテクチャの内側基盤と、外から見える top-level 責務 6 分類を確認する。

確認ポイント:

- `Domain Core` と `Application Coordination` が top-level 一覧に混ざっていないこと
- `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` の依存方向が明示されていること

## 2. 現行一覧を canonical component へ割り当てる

次に [component-allocation-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/component-allocation-contract.md) を読み、現行のフラット一覧を keep / rename / split / add のいずれかへ割り当てる。

確認ポイント:

- `Explanation generation` と `Image generation` が request intake / workflow / adapter に分割されていること
- `Asset storage` と `Pronunciation media` が read-side と adapter-side に分離されていること
- `Actor Session Handoff`、`Visual Image Reader`、`Generation Status Reader` が追加 component として定義されていること

## 3. auth/session 境界を照合する

[actor-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/actor-boundary-contract.md) を読み、`Actor/Auth Boundary` が `specs/008-auth-session-design/` と矛盾しないことを確認する。

確認ポイント:

- `Learner Identity Resolution` が auth/session 実装詳細を持っていないこと
- `Actor Session Handoff` が app core へ raw token や provider credential を渡さないこと

## 4. 非同期生成フローを確認する

[async-generation-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/async-generation-boundary-contract.md) を読み、Explanation と Image の workflow が別 component であり、completed result の read-side が独立していることを確認する。

確認ポイント:

- `Explanation Generation Workflow` と `Image Generation Workflow` の依存 adapter が異なること
- `Generation Status Reader` が incomplete payload を返さず、status のみを返すこと

## 5. deferred scope を確認する

最後に [deferred-scope-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/deferred-scope-contract.md) を読み、どこまでが本 feature の ownership で、どこから先が 007 / 008 など別 feature の正本かを確認する。

確認ポイント:

- auth/session 実装詳細は 008、command semantics は 007 を参照すること
- query model 実装、vendor adapter 実装、multiple current image は 009 の対象外であること

## Review Sequence

1. [spec.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/spec.md)
2. [plan.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/plan.md)
3. [data-model.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/data-model.md)
4. [architecture-topology-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/architecture-topology-contract.md)
5. [component-allocation-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/component-allocation-contract.md)
6. [actor-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/actor-boundary-contract.md)
7. [async-generation-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/async-generation-boundary-contract.md)
8. [deferred-scope-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/deferred-scope-contract.md)
