# Research: ドメインモデル設計書の完成

## Decision: 登録対象は `VocabularyEntry` を基準概念として定義する

**Rationale**: ユーザーは英単語や連語を登録した時点では、まだ解説や画像を持たない。
登録状態を `Explanation` に内包すると、生成前の語彙を表現できず、登録状態と解説生成状態
が混同される。

**Alternatives considered**:

- `Explanation` を登録対象の中心集約にする
- 登録済み判定のみを暗黙の永続化ルールとして扱い、独立概念を置かない

## Decision: `Explanation` と `VisualImage` は別集約として扱う

**Rationale**: 解説本文と画像アセットは生成タイミングも更新契機も異なる。画像の識別子や
永続化先を `Explanation` の内部値として持つと、`VisualImage` 集約との責務が重複する。

**Alternatives considered**:

- `Explanation` が画像 URL を直接保持し、`VisualImage` を廃止する
- 画像を `Explanation` の子エンティティとして扱う

## Decision: 解説生成状態と画像生成状態は別概念のまま、同一の業務ライフサイクル語彙を共有する

**Rationale**: 両者は `pending`、`running`、`succeeded`、`failed` の共通語彙で扱えるが、
進行条件、再生成条件、ユーザー表示対象は異なる。共通語彙を使いつつ別状態として持つのが
最も明瞭である。

**Alternatives considered**:

- すべての生成を 1 つの汎用 `GenerationState` に統合する
- 状態を持たず、生成済みか否かのみで判定する

## Decision: 外部責務はポートとして定義し、ドメイン文書にベンダー固有の実装前提を持ち込まない

**Rationale**: 単語存在確認、解説生成、画像生成、画像保存、外部発音参照はドメインの外部
責務であり、設計書では入力、出力、保証事項に集中した方が差し替え可能性を保てる。

**Alternatives considered**:

- 外部サービス名をそのままドメインサービスへ埋め込む
- 外部責務の定義を行わず、実装時に個別判断する

## Decision: 習熟度は個人的な学習進捗として扱い、生成された解説内容とは分離する

**Rationale**: 頻出度と知的度は語彙自体の属性である一方、習熟度はユーザーの学習状態である。
同一の概念として管理すると、生成結果の品質評価と学習進捗評価が混ざる。

**Alternatives considered**:

- 習熟度を `Explanation` 集約の属性として保持する
- 習熟度を UI 上の一時的な表示状態としてのみ扱う

## Decision: 今回の計画では 2 つの契約文書を生成する

**Rationale**: この feature では、外部ポートの入出力契約と、ユーザーに見せてよい状態の契約
を明示できれば十分である。これによりドメイン責務と表示責務を分けて確認できる。

**Alternatives considered**:

- 契約文書を作らず、すべてを data-model.md に集約する
- ポートごとに細分化しすぎて、現時点では維持負荷の高い契約群を作る

## Decision: 識別子型は `XxxIdentifier`、関連識別子フィールドは概念名で統一する

**Rationale**: `Id` や `xxxIdentifier` をフィールド名に含めると、型名とフィールド名の
役割が重複し、集約自身の識別子と他概念参照の区別が読み取りにくくなる。

**Alternatives considered**:

- `VocabularyEntryId` や `entryId` のように `Id` を使う
- 関連識別子フィールドを `entryIdentifier` や `imageIdentifier` と命名する
