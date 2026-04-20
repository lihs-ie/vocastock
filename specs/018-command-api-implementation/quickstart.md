# Quickstart: Command API Implementation

## Goal

`command-api` の `registerVocabularyExpression` 実装が、011 / 015 の契約どおりに
`accepted / reused-existing / dispatch-failed` を返し、completed payload を返さないことを確認する。

## Review Flow

1. [research.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/research.md) を読み、internal route、crate root 分割、stub port、feature test 方針の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/data-model.md) で request、accepted result、idempotency decision、dispatch plan を確認する
3. [register-vocabulary-command-contract.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/register-vocabulary-command-contract.md) と [command-auth-idempotency-contract.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/command-auth-idempotency-contract.md) で request / response / replay / conflict を確認する
4. [command-dispatch-visibility-contract.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/command-dispatch-visibility-contract.md) と [command-runtime-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/018-command-api-implementation/contracts/command-runtime-boundary-contract.md) で accepted visible guarantee、dispatch-failed、readiness、scope 外を確認する

## Implementation Verification

1. `cargo test -p command-api --test unit`
2. `cargo test -p command-api --test feature -- --nocapture`
3. `cargo llvm-cov -p command-api --tests --summary-only`

## What Must Be True

1. `registerVocabularyExpression` request が completed actor handoff、`idempotencyKey`、`text`、任意 `startExplanation` を受け、`startExplanation` omitted 時は `true` として扱うこと
2. accepted 応答が `acceptance`、target 参照、状態要約、`statusHandle`、必須 `message` を持つこと
3. same-request replay と duplicate reuse が別概念として扱われること
4. same key + different normalized request が `idempotency-conflict` になること
5. `startExplanation = false` が登録 command にのみ許可されること
6. dispatch failure 時に accepted を返さず、registration write も確定させないこと
7. completed explanation payload、image payload、query projection payload を返さないこと
8. feature テストが Rust コードから Docker container と Firebase emulator を使って動くこと
9. unit / feature 共通で coverage 90% 以上を達成すること
