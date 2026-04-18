# Contract: Purchase Reconciliation

## Purpose

購入完了、復元、状態再同期、store notification による authoritative update の流れを固定する。

## Flow 1: Complete Purchase

1. `Subscription Paywall UI` が `Mobile Storefront Adapter` を通じて購入開始を要求し、purchase state を `initiated` にする
2. storefront 完了後、`Purchase Result Intake` が purchase artifact を受け付け、purchase state を `submitted` にする
3. `Purchase Verification Workflow` が `Purchase Verification Adapter` を使って artifact を検証し、purchase state を `verifying` にする
4. 検証成功時に purchase state を `verified` にし、authoritative subscription state を更新し、`Entitlement Policy` を再計算する
5. 検証失敗時は purchase state を `rejected` にし、paid entitlement を付与しない
6. `Subscription Status Reader`、`Entitlement Reader`、`Subscription Feature Gate Reader` が app-facing 結果を返す

## Flow 2: Restore Purchase

1. `Restore Purchase Intake` が restore 要求を受け付け、purchase state を `initiated` にする
2. `Mobile Storefront Adapter` が storefront 側の restore を実行し、artifact 取得後に purchase state を `submitted` にする
3. `Purchase Verification Workflow` が復元対象の artifact を検証し、purchase state を `verifying` にする
4. 成功時は purchase state を `verified` にし、authoritative subscription state と entitlement を再計算する
5. app は synced mirror を通じて更新結果を受け取る

## Flow 3: Refresh And Cross-Device Reconciliation

1. `Subscription Status Refresh Intake` が明示 refresh または起動時同期を受け付ける
2. `Store Notification Reconciliation Workflow` が `Store Notification Adapter` 経由の通知や未処理イベントを照合する
3. authoritative subscription state と entitlement mirror を再計算する
4. `Subscription Status Reader` と `Entitlement Reader` が最新状態を返す

## Adapter Resilience Matrix

| Adapter | Timeout | Retry | Fallback |
|---------|---------|-------|----------|
| `Mobile Storefront Adapter` | purchase state を `initiated` または `submitted` のままにする | user-driven retry または restore 再試行 | paywall に再試行導線を出し、unlock は止める |
| `Purchase Verification Adapter` | purchase state を `verifying` に留める | workflow retry または refresh 再実行 | authoritative state を新規 paid にしないまま status 表示を継続する |
| `Store Notification Adapter` | 未反映イベントを保留する | reconciliation workflow が再取得する | 既存 mirror を維持し manual refresh を許可する |

## Partial Success Rules

- storefront 側の完了だけでは premium unlock を確定してはならない
- verification が未完了なら `pending-sync` を返し、premium unlock を行ってはならない
- verification 失敗時は paid entitlement を付与してはならない
- purchase state が `verified` になる前に premium unlock を行ってはならない

## Read Visibility Rules

- app は pending / failed / revoked などの状態を表示してよい
- app は incomplete purchase payload、raw receipt、provider token を表示または保持してはならない
- protected feature 実行前の最終 gate は authoritative state と synced mirror に基づかなければならない
