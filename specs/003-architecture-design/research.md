# Research: アーキテクチャ設計

## Decision: target architecture は責務中心の layered architecture と runtime 分離を併用する

**Rationale**: 今回の対象は Flutter クライアントから非同期生成、保存、結果表示までの
end-to-end 全体である。責務を UI、同期 command、query、解説 workflow、画像 workflow、
adapter integration に分けておくと、どこが業務判断を持ち、どこが外部依存を吸収するかを
一意に説明しやすい。runtime は client、application、worker に分けるが、論理境界を
先に固定することで、物理分割は段階移行に合わせて行える。

**Alternatives considered**:

- クライアントが直接外部サービスや保存先へ接続する client-heavy 構成
- すべての責務を 1 つの backend runtime に集約する単一境界構成

## Decision: 同期 command と query は境界を分け、query 側がユーザー表示状態を組み立てる

**Rationale**: 登録、生成依頼、再試行は状態遷移を伴うため command 側が担うべきであり、
ユーザーへ見せる説明済み / 画像あり / 生成中などの表示状態は query 側で合成する方が、
完了結果のみ表示する規則を一貫して保ちやすい。これにより、workflow 側は業務状態の更新に
集中し、UI は read model を読むだけで済む。

**Alternatives considered**:

- command 側でそのまま表示用 payload も返す
- 各 workflow が UI 向け状態整形まで担う

## Decision: 解説生成と画像生成は別 workflow とし、状態語彙だけ共有する

**Rationale**: 解説生成と画像生成は同じ `pending`、`running`、`succeeded`、`failed`
を使えるが、開始条件、依存関係、再試行契機が異なる。とくに画像生成は解説完了を前提とし、
画像再生成も想定されるため、別 workflow owner を持たせる方が責務衝突を避けられる。

**Alternatives considered**:

- すべての生成を 1 つの generic workflow に統合する
- 状態を持たず、生成済みか否かだけで制御する

## Decision: 外部依存は caller-owned adapter として各 runtime に閉じ込める

**Rationale**: 単語検証、解説生成、画像生成、アセット保存、発音参照はすべて外部都合の
失敗や遅延を持つ。これらを domain model の責務に混ぜず、command / worker runtime が
自身のポートを通じて利用する構成にすると、タイムアウト、再試行、監視、差し替えの境界を
明確に保てる。

**Alternatives considered**:

- ベンダー固有 SDK を command / domain 層に直接持ち込む
- 1 つの汎用 adapter へ外部依存を雑に集約する

## Decision: 移行は「docs-first 現状」から 3 段階で行う

**Rationale**: 現在の repository はドメイン文書、要件、CI、開発基盤が先に整備されており、
product runtime はまだ固定されていない。そこで、まず architecture contract を確定し、
次に command/query と workflow の論理分離を実装し、最後に runtime 最適化と運用境界の
強化へ進む方が、過剰な先行分割を避けつつ設計の一貫性を保てる。

**Alternatives considered**:

- 最初から runtime を完全分割して実装を始める
- 現状整理だけで止め、target architecture を定義しない

## Decision: 現時点では repository 上の source of truth を `specs/003-architecture-design/` に集約する

**Rationale**: この feature 自体は architecture design artifact の整備であり、実装コードの
正しさではなく、後続 feature が参照すべき判断基準を固めることが目的である。plan、data model、
contracts、quickstart を 1 つの spec bundle に揃えることで、後続の `/speckit.tasks` と
implementation のトレーサビリティを保ちやすい。

**Alternatives considered**:

- `docs/internal/` へ直ちに architecture 文書を追加して source of truth を分散させる
- 研究内容だけを `research.md` に置き、契約文書を作らない
