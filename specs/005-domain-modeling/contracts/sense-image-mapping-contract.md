# Contract: Sense Image Mapping

## Sense Ownership

| Concept | Rule |
|--------|------|
| `Sense` | `Explanation` が所有する内部エンティティである |
| `VisualImage.sense` | 指定する場合は、同じ `Explanation` に属する `Sense` だけを参照できる |
| `Explanation.currentImage` | 常に完了済み `VisualImage` を 0..1 件だけ参照する |

## Meaning-to-Image Mapping

| Case | Allowed | Notes |
|------|---------|-------|
| `VisualImage.sense = null` | Yes | explanation 全体を代表する画像として扱える |
| `VisualImage.sense = SenseIdentifier` | Yes | 特定の意味単位を描写する画像として扱える |
| `VisualImage.sense` が他 explanation の `Sense` を指す | No | ownership boundary を壊すため禁止 |
| 1 explanation に意味対応なしの裸画像を複数 current として並べる | No | この phase の scope 外 |

## Example and Collocation Ownership

| Artifact | Owner |
|---------|-------|
| `ExampleSentence` | `Sense` |
| `Collocation` | `Sense` |
| `Pronunciation` | `Explanation` |
| `Frequency` | `Explanation` |
| `Sophistication` | `Explanation` |

## Guarantees

- 画像枚数より先に意味単位と画像単位の対応関係を明示する
- `Sense` を導入しても `Explanation.currentImage` の単一 current 参照は維持する
- 多義語の画像化は、少なくとも domain 上では「どの意味の画像か」を説明できる
