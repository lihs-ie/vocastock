# 視覚的表現画像

## 値オブジェクト

### 視覚的表現画像識別子（VisualImageIdentifier）

- 文字列

#### 不変条件

- 1文字以上255文字以下

## 集約

### 視覚的表現画像（VisualImage）

- 英単語を視覚的に表現した画像

|フィールド名 |種別 |保持数 | 備考|
|-|-|-|-|
| identifier | 識別子 | 1 | |
| explanation | 解説識別子 | 1 | | 
| timeline | タイムライン | 1 | |

#### リポジトリ

- 識別子で集約を単一取得する（find）
- 解説識別子で集約を単一取得する（findByExplanation）
- 識別子を指定して集約を破棄する（terminate）
- 集約を永続化する（persist）
