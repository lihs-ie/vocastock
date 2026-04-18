# Research: API / Command I/O 設計

## Decision: command I/O は transport 非依存の envelope contract として定義する

**Rationale**: 現時点で必要なのは、HTTP、GraphQL、RPC のどれを使っても揺れない
canonical request / response shape である。binding まで同じ文書に含めると、transport の
選択が変わるたびに command contract 自体が揺れる。したがって 011 では envelope と
意味論だけを固定し、transport schema は deferred に置く。

**Alternatives considered**:

- GraphQL mutation payload をそのまま canonical contract にする
- HTTP JSON schema を正本にし、他 transport は後から合わせる

## Decision: すべての command request は `command`、`actor`、`idempotencyKey`、`body` を共有する

**Rationale**: 実装時に command ごとに envelope の形が違うと、middleware、audit、dedupe、
review 観点が分裂する。共通 envelope を持たせれば、actor handoff、idempotency、
request normalization を 1 箇所の責務として説明できる。

**Alternatives considered**:

- command ごとに完全に別の request shape を持つ
- idempotency key を command 固有 body の中へ埋め込む

## Decision: actor handoff input は 008 の completed output だけを受ける

**Rationale**: command I/O 側が token 検証や provider credential を扱い始めると、
auth/session の正本と競合する。011 では actor handoff input を「すでに completed な
auth/session 出力」として定義し、最小 shape を `actor reference`、
`session reference`、`auth account reference` に固定する。raw token、
provider credential、password、refresh token は request へ入れない。

**Alternatives considered**:

- command request に Firebase ID token を直接含める
- provider credential を command boundary で再検証する

## Decision: success response は target 参照、状態要約、user-facing message だけを返す

**Rationale**: command は state change intake であり、完了済み成果物 query ではない。
未完了 payload や provider detail を返すと、憲章の「完了結果のみ公開」と矛盾する。
そのため success response は accepted / reused-existing の結果、target 参照、要約状態、
必要最小限の message に限定する。

**Alternatives considered**:

- command success response に explanation payload や image URL を含める
- message を持たず、target 参照だけ返す

## Decision: error response でも user-facing `message` を必須にする

**Rationale**: UI と client adapter が error code だけで文言責務を持つと、画面側ごとの解釈差が
生まれやすい。canonical contract 自体に必須 `message` を持たせれば、success / error で
同じ response discipline を保てる。

**Alternatives considered**:

- success response だけ `message` を持たせる
- error は code のみ返し、message を downstream に委ねる

## Decision: duplicate registration は error ではなく `reused-existing` response として返す

**Rationale**: 同一学習者内の重複登録は business 的には異常ではなく、既存対象再利用である。
error 扱いにすると idempotent UX と reviewer の理解がぶれるため、既存
`VocabularyExpression` 参照、現在状態、再開有無を含む success response として固定する。

**Alternatives considered**:

- 常に `validation-failed` として返す
- 既存対象を暗黙再利用し、duplicate だったことを response に出さない

## Decision: idempotency key の replay と conflict を明示的に分ける

**Rationale**: 同じ key でも、同じ要求の再送と異なる本文の再送は扱いが違う。これを曖昧にすると
dedupe 実装とエラー設計が破綻する。011 では「同じ key + 同じ正規化要求」は replay、
「同じ key + 異なる正規化要求」は `idempotency-conflict` として固定する。key の
一意性スコープは actor 単位に揃える。

**Alternatives considered**:

- 同じ key なら本文差分を無視して常に replay とみなす
- key ではなく target 参照だけで dedupe する

## Decision: dispatch failure は success envelope を返さず command failure に倒す

**Rationale**: 007 ですでに「dispatch failure では `pending` を確定しない」と決めている。
I/O contract でも同じ整合を保つため、dispatch failure は accepted response ではなく
`dispatch-failed` error を返し、見かけ上の受付成功を禁止する。

**Alternatives considered**:

- accepted response を返したうえで後から status 補正する
- `pending-but-unconfirmed` のような中間 outcome を success envelope に追加する

## Decision: `requestImageGeneration` は `Explanation` を主 target とし、必要時のみ `Sense` を補助参照で受ける

**Rationale**: 009 と 005 の現在設計では `Explanation.currentImage` は単一 current であり、
`VisualImage.sense` は optional refinement である。したがって image request の主 target は
`Explanation` に置きつつ、特定意味を描写したい場合だけ `sense` を optional field とする。

**Alternatives considered**:

- image request を常に `Sense` 必須にする
- image request target を completed `VisualImage` 自体にする

## Decision: `retryGeneration` は 1 command のまま retry / regenerate を明示 mode で区別する

**Rationale**: 007 の command catalog は 4 command 前提であり、retry と regenerate を別 command に
分けると既存設計とズレる。一方で reason だけでは client / backend 両方で機械判定が弱いので、
011 では `mode` を必須にして意図を固定する。

**Alternatives considered**:

- retry と regenerate を別 command に分ける
- `reason` だけで retry / regenerate を暗黙判定する

## Decision: command I/O に subscription state を載せても `pending-sync` を unlock 根拠にしない

**Rationale**: 010 の正本では `pending-sync` は status 表示可能だが premium unlock の根拠に
使ってはならない。011 でも同じ visibility rule を守るため、state summary に subscription
status を含める場合でも confirmed unlock を一緒に示してはならない。

**Alternatives considered**:

- `pending-sync` でも premium unlocked とみなして返す
- subscription / entitlement 関連情報を一切返さない

## Decision: workflow payload、query schema、provider error detail は 011 から除外する

**Rationale**: 011 の価値は実装入口の canonical I/O を決めることであり、内部 payload や
query schema まで抱えると scope が崩れる。後続 feature と責務を切り分けるため、deferred
scope を明示する。

**Alternatives considered**:

- worker payload schema まで同時に決める
- query response shape と command response shape を同じ feature で固定する
