# Contract: Auth Boundary

## Purpose

Flutter client、Firebase Authentication、backend token verification、session 管理、
actor resolution、アプリ本体の責務分離を固定する。

## Boundary Catalog

| Boundary | Owns | Must Not Own | Depends On |
|----------|------|--------------|------------|
| Flutter Auth UI | 会員登録、ログイン、ログアウト画面、provider 開始、loading / error 表示、auth state 購読 | actor 解決、学習データ所有判断、provider token 検証 | Firebase Auth Client Adapter、Auth Handoff Endpoint |
| Firebase Auth Client Adapter | `Basic` / `Google` / `Apple` / `LINE` の sign-in 開始、Firebase client session の取得 | app core の保護操作判断、backend actor 解決 | Firebase Authentication |
| Backend Token Verifier | Flutter から受け取った Firebase ID token の検証、verified Firebase subject の正規化 | 語彙、解説、画像、学習状態の更新 | Firebase Authentication、auth account store |
| Session Manager | app-session 発行、失効、状態照会 | provider 固有本人確認、ドメイン概念の解釈 | auth account store、session store |
| Actor Resolver | 検証済み Firebase subject を actor / learner reference へ正規化 | provider token 保持、Firebase client session 永続化 | auth account store、identity link store |
| App Core Entry | 正規化済み actor reference に基づく保護操作の起点 | Firebase token 検証、provider credential 管理、auth account 作成 | Actor Resolver または auth handoff result |

## Dependency Rules

- Flutter Auth UI は raw `FirebaseUser` や provider 成功だけで app core を通してはならない
- Firebase Auth Client Adapter は語彙、解説、画像、学習状態を直接更新してはならない
- Backend Token Verifier は HTTPS 越しに受け取った Firebase ID token を検証し、検証済み subject を actor resolution 前提へ正規化しなければならない
- Session Manager は actor resolution を暗黙化してはならず、必要な handoff 条件を満たした後だけ利用可能状態を返す
- アプリ本体は Firebase ID token、refresh token、password、provider credential detail を直接扱ってはならない
