# Contract: Navigation Topology

## Purpose

Flutter client の route group、主要 screen、入口 / 出口条件を固定する。

## Route Group Matrix

| Route Group | Presentation | Entry Condition | Exit Target |
|-------------|--------------|-----------------|-------------|
| `Auth` | full-screen | 未ログイン、logout 後、actor handoff 未完了 | `SessionResolving` または `VocabularyCatalog` |
| `AppShell` | shell-contained | login 完了かつ actor handoff completed | shell 内 screen または `Paywall` |
| `Paywall` | full-screen | premium action deny、`expired`、quota deny による upsell | `SubscriptionStatus` recovery section、purchase success 後の shell 復帰 |
| `Restricted` | full-screen | `revoked`、re-auth required、hard stop | `Login` または `SubscriptionStatus` recovery section |

## Canonical Screen Flow

| From | Trigger / Guard | To |
|------|------------------|----|
| `Login` | 認証成功 | `SessionResolving` |
| `SessionResolving` | actor handoff completed | `VocabularyCatalog` |
| `SessionResolving` | handoff failure or logout | `Login` |
| `VocabularyCatalog` | 語彙を選択 | `VocabularyExpressionDetail` |
| `VocabularyCatalog` | 新規登録導線 | `VocabularyRegistration` |
| `VocabularyRegistration` | `registerVocabularyExpression` accepted | `VocabularyExpressionDetail` |
| `VocabularyExpressionDetail` | completed explanation を開く | `ExplanationDetail` |
| `VocabularyExpressionDetail` | completed current image を開く | `ImageDetail` |
| `VocabularyExpressionDetail` | premium action deny | `Paywall` |
| `Paywall` | restore / status 確認 | `SubscriptionStatus` |
| `RestrictedAccess` | recovery action | `SubscriptionStatus` または `Login` |

## Topology Rules

- `Auth`、`Paywall`、`Restricted` は通常利用 shell の stack に混在してはならない
- `VocabularyExpressionDetail` は result payload 本体ではなく generation status の集約を担う
- `SubscriptionStatus` は `AppShell` 内の canonical screen とし、paywall / restricted はその回復セクションへの入口を持つ
- `expired` は shell へ残るが、premium 操作は paywall へ戻す
- `revoked` は shell に残してはならない
