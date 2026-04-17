# Contract: Session Handoff

## Purpose

認証境界からアプリ本体へ利用可能状態を handoff する条件を、Flutter client、
Firebase Authentication、backend actor resolution を含めて固定する。

## Handoff Rules

| Stage | Required Condition | Must Not Happen | Handoff Output |
|-------|--------------------|-----------------|----------------|
| Registration Completion | Flutter で Firebase sign-in が成功し、backend で ID token 検証、会員 account 確定、必要な session と actor reference が揃う | actor reference 未解決のまま利用可能状態を返す | `RegisterFlowResult` |
| Login Completion | backend で検証済み Firebase subject、active session、resolved actor reference が揃う | Firebase sign-in 成功だけで app core を通す | `LoginFlowResult` |
| Protected Operation Start | actor reference が有効で、session が active、または同等の handoff 条件が backend で再確認されている | expired / invalidated session を有効扱いする | normalized actor reference |
| Logout Completion | Flutter 側の Firebase current user が解除され、session invalidated または already-invalid が確定し、再認証要求が明示される | logout 後も保護操作を通す | `LogoutFlowResult` |

## Visibility Rules

- handoff 結果には Firebase ID token、refresh token、provider token、password、外部 credential detail を含めてはならない
- app core が受け取るのは actor reference と利用可否判断に必要な最小状態だけである
- logout 後は保護操作で再認証が必要なことを user-visible に示す
