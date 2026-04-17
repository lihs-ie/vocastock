# Contract: Auth Flow

## Purpose

会員登録、ログイン、ログアウトの受理条件、拒否条件、完了条件を、Flutter client、
Firebase Authentication、backend token verification を含めて固定する。

## Flow Rules

| Flow | Accept When | Reject When | Complete When | User-visible Result |
|------|-------------|-------------|---------------|---------------------|
| `registerAccount` | Flutter 側で初期対象または条件を満たした provider が利用可能で、重複会員規則に反しない | provider unavailable、重複会員を新規作成しようとする、必須入力不足、Firebase sign-in 失敗 | Firebase registration / sign-in 成功、backend の ID token 検証成功、会員作成または既存会員再利用、必要な session と actor reference が整う | `registered` / `reused-existing` / `rejected` / `failed` |
| `loginAccount` | 対象会員が存在し、Flutter で Firebase sign-in を開始でき、利用不能状態でない | account missing、disabled、provider unavailable、Firebase sign-in 失敗、backend token verification 失敗 | active session と resolved actor reference が両方成立する | `logged-in` / `rejected` / `failed` |
| `logoutAccount` | active Firebase current user または app-session の失効確認対象がある | session store 不達など、完了判定自体ができない | Flutter 側の Firebase sign-out と session invalidated または already-invalid が確定し、再認証要求が明示される | `logged-out` / `already-invalid` / `failed` |

## Duplicate Account Rule

- 同じメールアドレスまたは同じ Firebase provider subject で重複会員を新規作成してはならない
- 重複検知時は既存会員の再利用または既存会員案内へ切り替える
- 重複時の戻り値は新規会員作成成功ではなく `reused-existing` または `rejected` とする

## Partial Success Rule

- Flutter 側の Firebase sign-in 成功だけ、backend の token 検証成功だけ、session 発行成功だけを単独で利用可能状態として返してはならない
- actor reference の解決に失敗した場合は、アプリ本体利用開始を成功として見せてはならない
- logout は Firebase current user の破棄だけで成功とせず、session 側の失効確認まで必要とする
