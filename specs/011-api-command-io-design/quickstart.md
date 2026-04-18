# Quickstart: API / Command I/O 設計

## 1. 前提文書を確認する

1. [requirements.md](/Users/lihs/workspace/vocastock/docs/external/requirements.md) と [adr.md](/Users/lihs/workspace/vocastock/docs/external/adr.md) を読み、command intake と actor handoff の全体方針を確認する
2. [spec.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/spec.md) と [contracts/command-catalog-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-catalog-contract.md) を読み、4 command の semantics を確認する
3. [session-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/contracts/session-handoff-contract.md) を読み、completed actor handoff の条件を確認する
4. [architecture-topology-contract.md](/Users/lihs/workspace/vocastock/specs/009-component-boundaries/contracts/architecture-topology-contract.md) を読み、command intake が置かれる boundary を確認する
5. [subscription-authority-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/subscription-authority-contract.md) と [entitlement-gate-contract.md](/Users/lihs/workspace/vocastock/specs/010-subscription-component-boundaries/contracts/entitlement-gate-contract.md) を読み、`pending-sync` visibility rule を確認する

## 2. 011 の設計成果物を読む

1. [research.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/research.md) で envelope、error、idempotency、boundary の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/data-model.md) で request / response / error の canonical entity を確認する
3. [command-request-envelope-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-request-envelope-contract.md) と [command-response-envelope-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-response-envelope-contract.md) で 4 command の I/O shape を確認する
4. [command-error-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-error-contract.md) と [command-idempotency-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-idempotency-contract.md) で error / replay / conflict を確認する
5. [actor-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/actor-handoff-contract.md) と [command-io-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/011-api-command-io-design/contracts/command-io-boundary-contract.md) で completed handoff と deferred scope を確認する

## 3. 実装前レビューで確認すること

1. 4 command すべてが共通 envelope を持ち、actor handoff が `actor reference`、`session reference`、`auth account reference` を含み、idempotency key が必須であること
2. `registerVocabularyExpression` だけが `startExplanation = false` を許可すること
3. duplicate registration が error ではなく `reused-existing` response を返すこと
4. `requestImageGeneration` が `Explanation` を主 target とし、必要時のみ `Sense` を受けること
5. `retryGeneration` が `mode = retry` / `regenerate` を明示的に区別すること
6. same-request replay と `idempotency-conflict` が区別されること
7. dispatch failure が success envelope を返さず、`pending` を見かけ上確定しないこと
8. success / error の両方で必須 `message` を返すこと
9. `pending-sync` は表示できても premium unlock 確定情報として返さないこと

## 4. この feature で扱わないこと

1. HTTP / GraphQL / RPC の具体 schema
2. workflow worker payload と internal dispatch message
3. provider 固有 error payload や vendor SDK detail
4. query response shape と read model
5. persistence schema と command handler の module 構成
