# VisualImage ドメインモデル

## この文書の役割

- `VisualImage` を `Explanation` から独立した画像集約として定義する
- `VisualImage.sense` による meaning-to-image mapping を定義する
- `previousImage` による履歴保持と `currentImage` への handoff 条件を固定する

## 関連文書

- [common.md](./common.md)
- [explanation.md](./explanation.md)
- [service.md](./service.md)

## 値オブジェクト

### VisualImageIdentifier

- 画像を一意に識別する値オブジェクト

不変条件:

- 1 文字以上 255 文字以下

### StorageReference

- 画像アセットを再取得するための安定した参照

不変条件:

- 同一 `VisualImageIdentifier` は 1 つの `StorageReference` だけを指す
- 参照は再取得可能でなければならない

## 集約

### VisualImage

- `Explanation` に基づく視覚的表現画像
- 現在表示中画像と履歴画像の両方を表す独立集約

| フィールド名 | 種別 | 保持数 | 備考 |
|---|---|---:|---|
| identifier | VisualImageIdentifier | 1 | 画像識別子 |
| explanation | ExplanationIdentifier | 1 | 生成元解説 |
| sense | SenseIdentifier | 0..1 | 描写する意味単位 |
| previousImage | VisualImageIdentifier | 0..1 | 同一解説内の直前画像 |
| storageReference | StorageReference | 1 | 永続化先参照 |
| timeline | Timeline | 1 | 作成・更新日時 |

不変条件:

- `sense` を持つ場合、その `Sense` は同じ `Explanation` に属していなければならない
- `previousImage` を持つ場合、その画像は同じ `Explanation` に属していなければならない
- `previousImage` の循環参照を作ってはならない
- `previousImage` と現在画像の両方が `sense` を持つ場合、両者は同じ `Sense` を指していなければならない
- explanation 全体を代表する画像は `sense` を持たなくてよい
- `VisualImage` 自体は current か history かを持たず、current 判定は `Explanation.currentImage` 側の責務とする

## currentImage handoff

- 新しい `VisualImage` が `succeeded` 相当の完了状態として保存された時だけ `Explanation.currentImage` に採用できる
- regenerate 中は、直前の完了済み `VisualImage` を `Explanation.currentImage` のまま維持する
- 以前の画像は `previousImage` を通じて履歴として保持する
- `Explanation.currentImage` は `Sense` の数にかかわらず 0..1 件であり、複数 current image を同時に採用してはならない
- 特定 `Sense` の再生成では、`previousImage` は同じ `sense` を持つ履歴へ接続しなければならない
- explanation 全体の代表画像を再生成する場合は、`sense = null` のまま履歴を接続する

## リポジトリ

### VisualImageRepository

- `find(identifier)`
- `findCurrentByExplanation(explanation)`
- `listByExplanation(explanation)`
- `persist(image)`
