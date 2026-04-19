# Contract: Async Worker Allocation

## Purpose

workflow / reconciliation 系 component をどの worker deployment unit に配置するかを固定する。

## Worker Allocation Matrix

| Component | Deployment Unit | Trigger | Durable State | Must Not Own |
|-----------|-----------------|---------|---------------|--------------|
| `Explanation Generation Workflow` | `explanation-worker` | command dispatch | workflow state + explanation write | query response |
| `Image Generation Workflow` | `image-worker` | command dispatch | workflow state + image write + asset reference | query response |
| `Purchase Verification Workflow` | `billing-worker` | purchase artifact intake | purchase state + authoritative subscription state | paywall rendering |
| `Store Notification Reconciliation Workflow` | `billing-worker` | store notification ingest | authoritative subscription state + entitlement recalculation | query response |

## Adapter Placement Rule

- validation / generation / storage / storefront / verification / notification adapter は caller-owned とする
- `explanation-worker` / `image-worker` / `billing-worker` は必要な adapter を使ってよいが、adapter 自体を独立 deployment unit としては扱わない

## Visibility Rule

- worker は completed result を user-facing contract として直接返してはならない
- user-visible read は常に `query-api` を経由しなければならない

## Failure Rule

- timeout、retry、fallback、dead-letter 相当は worker 側に保持してよい
- worker 障害中も `query-api` は status-only を返してよいが、未完了結果を completed として返してはならない
