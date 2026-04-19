# Quickstart: Query Catalog Read

## 1. Scope Confirmation

1. [spec.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/spec.md) を開き、対象が `query-api` の `VocabularyCatalogProjection` read slice に限定されていることを確認する
2. `command-api`、worker、GraphQL schema 全体、Firestore 本実装が scope 外であることを確認する

## 2. Read Contract Review

1. [data-model.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/data-model.md) の `VocabularyCatalogItem`、`CatalogVisibilityVariant`、`CatalogReadResponse` を読む
2. `currentExplanation` が参照可能なときだけ completed summary を返すことを確認する
3. projection lag や workflow failure の間は `status-only` を返し、provisional completed payload を返さないことを確認する

## 3. Contract Review

1. [vocabulary-catalog-read-contract.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/vocabulary-catalog-read-contract.md) で endpoint と response shape を確認する
2. [query-auth-handoff-contract.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/query-auth-handoff-contract.md) で token verification / actor handoff が `shared-auth::VerifiedActorContext` 再利用であることを確認する
3. [catalog-visibility-contract.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/catalog-visibility-contract.md) で completed / status-only の visible guarantee を確認する
4. [query-read-scope-boundary-contract.md](/Users/lihs/workspace/vocastock/specs/017-query-catalog-read/contracts/query-read-scope-boundary-contract.md) で write / dispatch を持たないことを確認する

## 4. Source-of-Truth Trace

1. `specs/015-command-query-topology/` が `query-api` の read-only 責務の正本であることを確認する
2. `specs/012-persistence-workflow-design/` が completed / status-only 判定の正本であることを確認する
3. `specs/013-flutter-ui-state-design/` が catalog と detail の visibility 境界の正本であることを確認する
4. `specs/008-auth-session-design/` が token verification / actor handoff の正本であることを確認する
5. `specs/016-application-docker-env/` が runtime / readiness の正本であることを確認する

## 5. Planning Exit Check

- catalog endpoint の completed summary 条件と status-only 条件が説明できる
- `/vocabulary-catalog` が `query-api` の internal route であり、gateway 公開 mapping は deferred だと説明できる
- projection lag 中に provisional completed payload を返さない理由が説明できる
- actor handoff 再利用と raw credential 非露出の境界が説明できる
- `query-api` が write / workflow dispatch を持たないことが説明できる
