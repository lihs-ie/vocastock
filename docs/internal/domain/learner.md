# Learner ドメインモデル

## この文書の役割

- `Learner` を学習者本人の所有境界として定義する
- `VocabularyExpression` と `LearningState` の起点となる責務を固定する
- 認証そのものを domain 外へ留めつつ、外部 identity 境界を明確にする

## 関連文書

- [common.md](./common.md)
- [vocabulary-expression.md](./vocabulary-expression.md)
- [learning-state.md](./learning-state.md)
- [service.md](./service.md)

## 値オブジェクト

### LearnerIdentifier

- 学習者を一意に識別する値オブジェクト

### AuthenticationSubject

- 外部 identity を参照する安定した subject
- 認証方式や credential そのものではなく、外部責務と結びつく参照だけを持つ

不変条件:

- 同一 `AuthenticationSubject` は同一 `Learner` を指す
- credential、password、provider session を保持してはならない

## 集約

### Learner

- 学習者本人を表す独立集約
- 自身が所有する `VocabularyExpression` と `LearningState` の起点となる

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| identifier | LearnerIdentifier | 1 | 学習者識別子 |
| authenticationSubject | AuthenticationSubject | 1 | 外部 identity 参照 |
| timeline | Timeline | 1 | 作成・更新日時 |

不変条件:

- `authenticationSubject` は stable で一意でなければならない
- `Learner` は credential や session を保持しない

## 所有境界

- `Learner` は 0..n 件の `VocabularyExpression` を所有する
- `Learner` は 0..n 件の `LearningState` を持つ
- `VocabularyExpression` の重複判定は同一 `Learner` 境界の内側で行う
- `LearningState` は `Learner` と `VocabularyExpression` の関係上でのみ存在できる

## 外部 identity 境界

- 認証方式、provider 実装、session 管理は domain 外の責務である
- domain には `AuthenticationSubject` と `LearnerIdentityPort` の結果だけを持ち込む
- `Learner` は auth provider の種類に依存しない

## リポジトリ

### LearnerRepository

- `find(identifier)`
- `findByAuthenticationSubject(authenticationSubject)`
- `persist(learner)`
