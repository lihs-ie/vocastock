# Research: 機能別コンポーネント定義

## Decision: 主軸はオニオンアーキテクチャとし、`Domain Core` と `Application Coordination` を top-level 責務一覧と分離する

**Rationale**: この feature は単なる機能一覧ではなく、依存方向と責務境界をレビュー可能な
形で固定する必要がある。オニオンアーキテクチャを主軸にすると、domain language を内側に
保ちつつ、外側の UI、auth/session、command、query、workflow、adapter を明示的に
配置できる。`Domain Core` と `Application Coordination` を top-level 責務一覧へ混ぜると、
「外から見える component catalog」と「内側基盤」が混線するため、別枠で表現する。

**Alternatives considered**:

- 単純なレイヤードアーキテクチャとして UI / Application / Infrastructure の 3 層だけで整理する
- feature ごとのフラットな component 一覧を維持し、不足項目だけ追加する

## Decision: 外から見える top-level 責務は `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` に固定する

**Rationale**: 現行一覧は「機能名」と「責務層」が混在しており、`Explanation generation` の
ような長時間処理と `Explanation reader` のような read-side が同じ粒度で並んでいる。
top-level 責務を固定すると、どの component が user-facing、boundary-facing、
write-side、read-side、workflow-facing、adapter-facing なのかを一目で判定できる。

**Alternatives considered**:

- `UI`、`generation`、`storage` のような粒度の異なるカテゴリを継続利用する
- `Presentation`、`Application`、`Infrastructure` の 3 層だけを top-level とし、細分化は各自に委ねる

## Decision: `auth/session` は outer boundary として分離し、product 内では `Learner Identity Resolution` と `Actor Session Handoff` のみを扱う

**Rationale**: 認証そのものは `specs/008-auth-session-design/` で設計済みであり、今回の
feature が再定義すると責務が二重化する。product component として必要なのは、auth/session
実装そのものではなく、外部 identity から `Learner` を解決し、正規化済み actor reference を
command/query へ渡す境界だけである。そのため `Actor/Auth Boundary` には
`Learner Identity Resolution` と `Actor Session Handoff` を置き、auth account lifecycle や
token verification は deferred scope に留める。

**Alternatives considered**:

- `Learner identity resolution` を domain core 側へ寄せる
- auth/session 実装詳細も current component catalog に含める

## Decision: write-side、read-side、async workflow は同じ機能名の中に押し込まず分離する

**Rationale**: `Explanation generation` と `Image generation` は要求受理、実行、結果取得が
異なるタイミングで起こる。これを 1 つの component として定義すると、command acceptance、
workflow orchestration、provider invocation、completed result read が混線する。登録系も
同様に、validation や duplicate lookup は command intake 側、completed result の取得は
query read 側として切り分ける方が、`specs/007-backend-command-design/` と整合する。

**Alternatives considered**:

- `Explanation generation` / `Image generation` を 1 component のまま扱う
- `Explanation reader` を query read と status read の両方を含む曖昧な component として残す

## Decision: `Async Generation` 配下は `Explanation Generation Workflow` と `Image Generation Workflow` の 2 component に分ける

**Rationale**: 両者はどちらも長時間処理だが、入力、完了条件、依存 adapter、履歴の扱いが
異なる。`Image generation` は completed `Explanation` と optional `Sense` を前提にし、
さらに `AssetStoragePort` を介した保存が必要である。一方 `Explanation generation` は
`VocabularyExpression` から `Explanation` / `Sense` を生成する。親カテゴリは共有しつつ、
workflow component は分けた方が責務と follow-on scope を明確にできる。

**Alternatives considered**:

- `Async Generation` を 1 つの共通 workflow component として扱う
- `Explanation generation` と `Image generation` を top-level 責務へ昇格させる

## Decision: `Asset storage` と `asset access/retrieval` は別 adapter として定義し、read-side には `Visual Image Reader` と `Pronunciation Media Reader` を置く

**Rationale**: 現行一覧では `Asset storage` が保存責務だけでなく、再取得参照の解決まで
暗黙に背負っている。保存と取得を分離しないと、storage metadata の責務と user-facing read
path の責務が混ざる。同じ問題は `Pronunciation media` にもあり、アプリから見える reader と、
外部 media source へ接続する adapter は分離した方が、query read と external adapter の
境界が明確になる。

**Alternatives considered**:

- `Asset storage` が保存と取得の両方を持つ
- `Pronunciation media` を単一 component として残し、reader と adapter を分けない
