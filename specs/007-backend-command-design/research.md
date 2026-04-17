# Research: バックエンド Command 設計

## Decision: 登録 command を command catalog の中心に置き、既定では解説生成開始を含める

**Rationale**: 既存要件では「未登録なら解説生成を行う」が主経路であり、登録と解説生成開始を
別 command に完全分離すると通常フローが二段階化する。一方で、下書き登録や管理操作のために
生成開始を抑止する余地も必要である。そこで `registerVocabularyExpression` は既定では
解説生成開始を伴うが、明示フラグで開始を抑止できる command として定義する。

**Alternatives considered**:

- 登録 command を常に解説生成開始まで固定する
- 登録と解説生成開始を必ず別 command に分離する

## Decision: 重複登録時は新規作成せず、既存 `VocabularyExpression` と現在状態を返す

**Rationale**: 同一学習者内一意性を維持する以上、重複登録で新規項目を作るべきではない。
単純エラーにすると、既に何が登録済みで、現在どの状態にあるかが利用者にも実装者にも見えにくい。
既存対象と現在状態を返す contract にすると、冪等性と利用者フィードバックを両立できる。

**Alternatives considered**:

- 重複として常に拒否し、エラーだけ返す
- 既存項目を更新扱いにして再登録を受け付ける

## Decision: 重複登録時の生成再開は `not-started` または `failed` で、かつ開始抑止がない場合に限る

**Rationale**: 重複登録で常に生成を再開すると、すでに `pending`、`running`、`succeeded`
の対象まで再度動かしてしまい、冪等性と利用者期待が崩れる。一方で `not-started` や
`failed` のままなら、通常登録フローの再要求として再開余地を残した方が自然である。
そのため既存対象を再利用しつつ、再開条件だけを限定する。

**Alternatives considered**:

- 重複登録では生成を再開せず、常に既存状態だけ返す
- `pending` / `running` 以外なら常に再開する
- 明示的な `restartOnDuplicate` 指定がある場合だけ再開する

## Decision: command は `pending` の作成前に dispatch 成功を確認し、失敗時は command 全体を不成立にする

**Rationale**: command が受付済み状態だけを先に保存し、dispatch が失敗すると、
「受け付けたのに動かない」半端な状態が生じる。backend command の整合責務を明確にするため、
dispatch 成功を伴わない受付は不成立とし、利用者へは受付失敗を返す設計とする。

**Alternatives considered**:

- `pending` を保存したうえで後続補正ジョブへ委ねる
- `dispatch_failed` のような中間状態を command 側で持つ
- command 自体は成功として返し、自動再送を前提にする

## Decision: command catalog は command definition、acceptance result、idempotency key を分けて扱う

**Rationale**: 「何を受け付けるか」「どう返すか」「重複をどう畳むか」は別の判断軸である。
これらを 1 つの表に混ぜると、後続実装で validation、result mapping、deduplication rule が
分離しにくい。command ごとの定義を中心にしつつ、acceptance result と idempotency key を
横断規則として持つ方が review と実装分解に向く。

**Alternatives considered**:

- command ごとの文章説明だけで整理する
- すべてを 1 つの巨大な matrix で表現する

## Decision: 所有者整合は command 受理の前提条件として扱う

**Rationale**: `VocabularyExpression` は学習者所有であり、他者の登録対象へ command を
通すと責務境界が崩れる。認証主体と対象所有者の整合は command 実行途中ではなく、受理前の
前提条件として扱う方が、拒否条件と state mutation の境界が明確になる。

**Alternatives considered**:

- workflow 側で所有者整合を再確認する
- query 側で見え方だけを制御し、command では受理する

## Decision: command は user-facing summary と internal failure detail を分離する

**Rationale**: 利用者へは状態要約だけを返し、詳細な provider / dispatch failure は内部ログや
内部状態へ留めるという既存方針を維持する必要がある。これにより、command contract は安定し、
失敗の内部調査性は別の運用文脈で担保できる。

**Alternatives considered**:

- command 即時応答に provider 由来の詳細をそのまま含める
- 失敗要約すら返さず、汎用エラーだけを返す

## Decision: 今回の設計対象から query、workflow 実行本体、provider 個別仕様を除外する

**Rationale**: 007 の目的は backend command 実装のための設計書であり、read model、worker の
実行詳細、プロバイダ別 adapter まで同時に扱うと scope が崩れる。command が何を受け付け、
どこまで責務を持つかに集中するため、非対象範囲を明示して分離する。

**Alternatives considered**:

- query と command を同時に設計する
- workflow state machine と adapter 契約まで 1 feature に含める

## Decision: 005 の domain docs 実装完了までは `specs/005-domain-modeling/` を暫定 semantic source とする

**Rationale**: 007 は learner-owned `VocabularyExpression` と一意性前提に依存するが、
その正本候補である `docs/internal/domain/learner.md`、
`docs/internal/domain/vocabulary-expression.md`、
`docs/internal/domain/learning-state.md` はまだ materialize されていない。現在の
`docs/internal/domain/*.md` を無理に再定義すると 005 と二重管理になるため、007 は 005 の
設計成果物を暫定 semantic source として参照し、再定義を避ける。

**Alternatives considered**:

- 007 の中で learner-owned vocabulary semantics を独自に再定義する
- 005 の文書実装完了まで 007 の planning を止める

## Decision: 暫定 semantic source の exit は 3 つの domain docs 正本化と 007 参照切替で判定し、その handoff は 005-domain-modeling 側が担う

**Rationale**: 暫定参照だけを記録すると、「いつ終わるか」と「誰が終わらせるか」が曖昧なまま残る。
憲章例外として扱う以上、終了条件と follow-on owner を同時に明記する必要がある。007 は
command design package であり domain docs 本体の materialization は直接の対象外なので、
`docs/internal/domain/learner.md`、`vocabulary-expression.md`、`learning-state.md` の
正本化と 007 の参照切替を exit 条件とし、その handoff を 005-domain-modeling 側の
source-of-truth 整備作業へ置く。

**Alternatives considered**:

- 007 の中で domain docs materialization まで ownership を引き取る
- exit 条件だけを書き、follow-on owner を曖昧なまま残す
