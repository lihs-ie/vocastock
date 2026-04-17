# Quickstart: 会員登録・ログイン・ログアウト設計

## 1. 前提文書を確認する

1. [requirements.md](/Users/lihs/workspace/vocastock/docs/external/requirements.md) を読み、利用開始前提と保護操作の要求を確認する
2. [boundary-responsibility-contract.md](/Users/lihs/workspace/vocastock/specs/003-architecture-design/contracts/boundary-responsibility-contract.md) を読み、アプリ本体と外部境界の責務分離を確認する
3. [spec.md](/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/spec.md) を読み、Firebase Authentication を含む managed service baseline と provider adapter 前提を確認する
4. [common.md](/Users/lihs/workspace/vocastock/docs/internal/domain/common.md) と [service.md](/Users/lihs/workspace/vocastock/docs/internal/domain/service.md) を読み、auth をコアドメインへ混ぜない前提を確認する

## 2. 008 の設計成果物を読む

1. [research.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/research.md) で Flutter auth UI、Firebase Authentication、backend token verification、actor resolution の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/data-model.md) で auth account、external identity、verified Firebase identity、session、actor handoff を確認する
3. [contracts/auth-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/auth-boundary-contract.md) と [contracts/auth-flow-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/auth-flow-contract.md) で Flutter / Firebase / backend の責務と完了条件を確認する
4. [contracts/session-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/session-handoff-contract.md) と [contracts/provider-availability-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/provider-availability-contract.md) で actor handoff 条件と provider tier を確認する

## 3. 実装前レビューで確認すること

1. `Basic` と `Google` が初期対象として成立していること
2. `Apple ID` と `LINE` は追加コストなし条件を満たす場合のみ候補であること
3. Flutter client が認証 UI と provider 開始だけを担っていること
4. Firebase Authentication を本人確認基盤として使っていること
5. backend が Firebase ID token を検証してから actor / learner を解決していること
6. 認証成功後にアプリ本体へ渡すのが actor reference だけであること
7. 重複会員を新規作成しないこと
8. 部分的に成立した認証状態を利用可能状態として返さないこと
9. logout 後は保護操作に再認証が必要になること

## 4. この feature で扱わないこと

1. パスワード再設定
2. メール確認や電話番号確認の詳細フロー
3. プロフィール編集
4. 外部 identity の高度なアカウント統合
5. 課金や subscription と会員状態の統合
