# Contract: Subscription Authority

## Purpose

課金状態の最終正本、state model、app-facing mirror の関係を固定する。

## Authoritative Source Matrix

| Concern | Authoritative Owner | App-Facing Form | Not Authoritative |
|---------|---------------------|-----------------|-------------------|
| purchase 完了 artifact | `Purchase Result Intake` -> `Purchase Verification Workflow` | purchase pending / failed status | local storefront cache 単体 |
| subscription state | backend authoritative subscription state | `Subscription Status Reader` | paywall UI、local cache |
| entitlement | `Entitlement Policy` | `Entitlement Reader` の synced mirror | storefront callback 単体 |
| feature unlock | `Subscription Feature Gate` | `Subscription Feature Gate Reader` | UI local flag |
| usage allowance | `Usage Metering / Quota Gate` | `Usage Allowance Reader` | アプリの local counter |

## State Model

| State | Paid Entitlement | UI Status | Requires Additional Reconciliation |
|-------|------------------|-----------|------------------------------------|
| `active` | 維持する | 表示する | No |
| `grace` | 維持する | 表示する | Yes |
| `expired` | 維持しない | 表示する | No |
| `pending-sync` | 維持しない | 表示する | Yes |
| `revoked` | 維持しない | 表示する | No |

## Purchase State Model

| State | UI Status | Premium Unlock | Requires Adapter Retry |
|-------|-----------|----------------|------------------------|
| `initiated` | 表示する | No | No |
| `submitted` | 表示する | No | Yes |
| `verifying` | 表示する | No | Yes |
| `verified` | 表示する | Yes | No |
| `rejected` | 表示する | No | No |

## State Rules

1. `grace` は一時継続状態であり、通常の paid entitlement を維持しなければならない
2. `pending-sync` は UI に状態表示してよいが、premium unlock の根拠に使ってはならない
3. `revoked` は返金や強制失効を含み、paid entitlement を即時停止しなければならない
4. `expired` と `revoked` はどちらも non-paid だが、失効理由の意味は混同してはならない
5. `verified` だけが premium unlock の前提となりうる purchase state でなければならない
6. `submitted` と `verifying` は purchase progress を示すが、authoritative subscription state と同一視してはならない

## Mirror Rules

- app core と UI は authoritative backend source から同期済みの entitlement mirror だけを参照する
- mirror は read-only であり、ローカル UI 操作だけで entitlement を変更してはならない
- purchase 完了直後でも backend authoritative state への反映が未完了なら `pending-sync` として扱い、premium unlock を確定してはならない

## Failure / Drift Handling

- purchase 成功表示と authoritative state がずれた場合、unlock 判定は authoritative state を優先する
- cross-device で mirror がずれた場合、`Subscription Status Refresh Intake` または store notification reconciliation を経由して同期する
- `grace` から `expired` へ遷移した後は、paid entitlement を維持してはならない

## Adapter Resilience Rules

- `Mobile Storefront Adapter` の timeout では purchase state を `initiated` または `submitted` のまま保持し、paywall 側に retry 導線を出す
- `Purchase Verification Adapter` の timeout または一時障害では purchase state を `verifying` に留め、authoritative subscription state は `pending-sync` または既存状態を維持する
- `Store Notification Adapter` の障害では既存 mirror を維持してよいが、新しい paid entitlement を付与してはならない
