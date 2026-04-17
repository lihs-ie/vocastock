# Contract: Command Acceptance

## Purpose

command ごとの受理条件、拒否条件、重複時の扱い、利用者向け即時応答を固定する。

## Acceptance Rules

| Command | Accept When | Reject When | Reuse Existing When | User-visible Response |
|--------|-------------|-------------|---------------------|----------------------|
| `registerVocabularyExpression` | 同一学習者内で未登録、または明示条件を満たす登録のみ | 所有者不整合、入力不正、抑止不能な前提違反 | 同一学習者内で同じ正規化表現が既に存在する | `accepted` または `reused-existing` と対象状態要約 |
| `requestExplanationGeneration` | 対象登録表現が存在し、所有者整合を満たす | 対象不在、所有者不整合、前提状態不正 | 同一業務キーで `pending` / `running` が既に存在する | 状態要約のみ。解説本文は返さない |
| `requestImageGeneration` | 対象解説が完了済みで、所有者整合を満たす | 解説未完了、対象不在、所有者不整合 | 同一業務キーで `pending` / `running` が既に存在する | 状態要約のみ。画像本体は返さない |
| `retryGeneration` | 対象生成が `failed` | 対象が `failed` でない、所有者不整合 | 同一 retry 要求が既に受理済みである | retry 受付結果と状態要約 |

## Duplicate Registration Rule

- 同一学習者内の重複登録は新規作成しない
- 既存 `VocabularyExpression` と現在状態を返す
- 既存状態が `not-started` または `failed` で、かつ開始抑止がない場合だけ追加の生成開始を再受理する
- 既存状態が `pending`、`running`、`succeeded`、または開始抑止がある場合は追加の生成開始を行わない
- 重複登録時の即時応答は既存対象参照と現在状態を返し、再開有無は状態要約または次アクションで示す

## Visibility Rule

- `accepted`、`reused-existing`、`rejected`、`failed` のいずれでも、未完了成果物本体は返してはならない
- 利用者へ返すのは状態要約、対象参照、次アクションだけである
