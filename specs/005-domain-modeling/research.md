# Research: ドメインモデリング

## Decision: `Sense` を `Explanation` 所有の内部エンティティとして導入する

**Rationale**: 多義語の「意味の数」と「画像の数」を直接結びつける前に、意味単位そのものを
明示する必要がある。`Sense` を `Explanation` 配下に置くと、語彙登録対象や学習状態の境界は
変えずに、意味、状況、ニュアンス、例文、コロケーションを意味単位で整理できる。
`Sense` を独立集約にすると、`Explanation` から切り離された更新順序や参照整合が必要になり、
現時点の domain complexity に対して過剰である。

**Alternatives considered**:

- `Meaning.values` のまま文字列一覧だけを維持する
- `Sense` を `Explanation` から独立した集約にする

## Decision: `Explanation.meaning` を coarse-grained な意味の塊ではなく、`Explanation.senses` へ置き換える

**Rationale**: 既存の `Meaning.values + situation + nuance` では、複数意味がある場合でも
状況やニュアンスが explanation 全体で 1 つに潰れてしまう。`Sense` に `label`、
`situation`、`nuance` を持たせると、意味ごとの差分を domain 上で保てる。
多義語に対して「どの例文がどの意味か」を説明しやすくなる。

**Alternatives considered**:

- `Meaning.values` に補足文字列を追記して疑似的に意味を増やす
- 画像だけ複数にして意味の構造化は行わない

## Decision: 例文とコロケーションは `Sense` に属させ、発音・語源・頻出度・知的度は `Explanation` に残す

**Rationale**: 例文とコロケーションは意味ごとの使われ方に強く依存する。一方で発音、語源、
頻出度、知的度は表現全体の説明として扱う方が自然であり、意味ごとに分割すると重複や
説明のばらつきが増える。これにより、説明全体の共通情報と意味別の局所情報を分離できる。

**Alternatives considered**:

- 例文、コロケーション、発音、語源をすべて `Sense` に移す
- 例文、コロケーションも explanation 全体の配列のままにする

## Decision: `VisualImage` は独立集約のまま維持し、必要に応じて `sense` 参照を持つ

**Rationale**: 画像は非同期生成、保存先参照、再生成履歴の責務を持つため、`Explanation` の
内部値へ戻すべきではない。ただし意味と画像の対応は domain 上で明示したいので、
`VisualImage` が `Explanation` と同時に `sense?` を持てるようにする。
これにより、「この画像はどの意味を描いているか」を示せる。

**Alternatives considered**:

- `VisualImage` を `Explanation` の子エンティティとして扱う
- 画像と意味の対応を持たず、画像説明テキストだけで補う

## Decision: この phase では `Explanation.currentImage` を単一 current 参照のまま維持する

**Rationale**: `Sense` の導入目的は、まず意味単位と画像単位の対応関係を明示することであり、
current image を複数 current image へ拡張することではない。単一 current 参照を維持すると、
既存の async visibility rule、retry / regenerate rule、UI 表示契約を壊さずに導入できる。
複数 current image は follow-on scope として、`Sense` の運用が固まってから判断する方が安全である。

**Alternatives considered**:

- `Explanation.currentImages` を直ちに複数化する
- 画像 current 参照を廃止し、履歴配列から都度選ぶ

## Decision: 画像枚数より意味対応の明確さを優先する

**Rationale**: 学習体験では画像数の多さより、「どの意味を補助する画像か」が明確であることが
重要である。`Sense` 導入により、画像を増やす前に meaning-image mapping を安定化できる。
これにより、意味と無関係な装飾画像や、複数意味を曖昧に代表する画像の乱用を避けられる。

**Alternatives considered**:

- 意味構造を持たずに画像だけ増やす
- 画像を 1 枚に固定したまま多義語の意味区別を model しない

## Decision: source-of-truth は `explanation.md` と `visual.md` を中心に `common.md` を更新して再編する

**Rationale**: `Sense` は `Explanation` の責務再編であり、既存の `Learner`、
`VocabularyExpression`、`LearningState` の ownership boundary を変えるものではない。
そのため正本の中心は `explanation.md` と `visual.md` であり、project-wide 用語差分は
`common.md` で吸収するのが最小変更である。必要な外部文書整合は `requirements.md` と
`adr.md` に限定できる。

**Alternatives considered**:

- `sense.md` を独立 source-of-truth として新設する
- 既存文書を変えず、spec artifacts だけで `Sense` を説明する
