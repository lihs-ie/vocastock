# Contract: Screen Source Binding

## Purpose

各 screen がどの reader、gate、command intake を参照するかを固定する。

## Binding Matrix

| Screen | Readers / Gates | Commands / Actions | Purpose |
|--------|-----------------|--------------------|---------|
| `Login` | auth session boundary state | login action | 認証開始 |
| `SessionResolving` | actor handoff status reader | logout action | actor handoff 完了待ち |
| `VocabularyCatalog` | vocabulary catalog reader、learning state reader | navigate to registration / detail | 語彙一覧閲覧 |
| `VocabularyRegistration` | vocabulary validation state、duplicate registration hint | `registerVocabularyExpression` | 新規登録 |
| `VocabularyExpressionDetail` | generation status reader、explanation summary reader、image summary reader、pronunciation reader、subscription feature gate、usage allowance reader | `requestExplanationGeneration`、`requestImageGeneration`、`retryGeneration` | status 集約と completed detail への分岐 |
| `ExplanationDetail` | explanation detail reader | navigate back | completed explanation 本文 |
| `ImageDetail` | visual image detail reader | `retryGeneration`、navigate back | completed current image |
| `SubscriptionStatus` | subscription status reader、entitlement reader、usage allowance reader、subscription feature gate | restore action、manage subscription action | 課金状態表示と recovery |
| `Paywall` | subscription feature gate、usage allowance reader、purchase state status | purchase start、navigate to `SubscriptionStatus` | upsell と purchase 開始 |
| `RestrictedAccess` | actor/session restriction reason、subscription status summary | re-login、navigate to `SubscriptionStatus` | hard stop と recovery |

## Binding Rules

- screen は workflow runtime store や provider SDK を直接参照してはならない
- command acceptance 後の表示更新は command response の `message` を使ってよいが、状態本体は reader 再取得で反映しなければならない
- gate は allow / limited / deny を返せるが、payload 本文の代替には使ってはならない
- `SubscriptionStatus` は `subscription state`、`entitlement`、`usage allowance`、`gate result` を別概念として描画しなければならない
