# Quickstart: バックエンド Command 設計

## 1. 前提文書を確認する

1. [requirements.md](/Users/lihs/workspace/vocastock/docs/external/requirements.md) を読み、登録、解説生成、画像生成の業務要求を確認する
2. [boundary-responsibility-contract.md](/Users/lihs/workspace/vocastock/specs/003-architecture-design/contracts/boundary-responsibility-contract.md) と [async-visibility-contract.md](/Users/lihs/workspace/vocastock/specs/003-architecture-design/contracts/async-visibility-contract.md) を読み、Vocabulary Command の責務と可視性規則を確認する
3. [spec.md](/Users/lihs/workspace/vocastock/specs/004-tech-stack-definition/spec.md) を読み、`Command/Query = Rust`、`GraphQL`、`Pub/Sub + Firestore state` の前提を確認する
4. [spec.md](/Users/lihs/workspace/vocastock/specs/005-domain-modeling/spec.md) を読み、学習者所有、一意性、非同期状態語彙の前提を確認する。`docs/internal/domain/learner.md` などの正本が未実体化なため、ここでは 005 spec を暫定 semantic source として扱う。exit 条件は `learner.md`、`vocabulary-expression.md`、`learning-state.md` の正本化と 007 参照の切り替えであり、その handoff は 005-domain-modeling 側の文書整備作業が担う

## 2. 007 の設計成果物を読む

1. [research.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/research.md) で command 設計上の判断理由を確認する
2. [data-model.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/data-model.md) で command definition、acceptance result、dispatch consistency rule を確認する
3. [contracts/command-catalog-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-catalog-contract.md) と [contracts/command-acceptance-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-acceptance-contract.md) で command 一覧と受理条件を確認する
4. [contracts/command-dispatch-consistency-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-dispatch-consistency-contract.md) と [contracts/command-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/007-backend-command-design/contracts/command-boundary-contract.md) で dispatch 整合と責務分離を確認する

## 3. 実装前レビューで確認すること

1. 登録 command が既定で解説生成開始を含みつつ、開始抑止パターンを持てること
2. 重複登録時に新規作成せず、既存 `VocabularyExpression` と現在状態を返すこと
3. 重複登録時の生成再開は、既存状態が `not-started` または `failed` で、かつ開始抑止がない場合だけ許可されること
4. 画像生成 command が完了済み `Explanation` を前提条件にすること
5. dispatch failure では `pending` を確定せず command 全体を失敗として扱うこと
6. 即時応答が未完了成果物本文や画像本体を返さないこと
7. 暫定 semantic source は恒久運用ではなく、3 つの domain docs 正本化後に `docs/internal/domain/*.md` 参照へ切り替えること

## 4. この feature で扱わないこと

1. query 側の read model 詳細
2. workflow 側の長時間実行ロジック
3. provider 固有 adapter の request / response 詳細
4. Rust コードの module 構成や GraphQL schema 実装詳細
