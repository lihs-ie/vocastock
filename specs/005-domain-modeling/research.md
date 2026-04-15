# Research: ドメインモデリング

## Decision: `Learner` を所有境界とし、`VocabularyExpression` は学習者が所有する登録対象として扱う

**Rationale**: 習熟度が学習者ごとに変わる以上、語彙登録の境界も学習者側に寄せる方が自然である。
`VocabularyExpression` を共有語彙にすると、重複登録判定、登録状態、生成状態、学習進捗の責務が
再び混ざる。`Learner` を独立集約とし、その配下に `VocabularyExpression` を置くことで、
語彙自体の概念と学習者の所有責務を同時に明確化できる。

**Alternatives considered**:

- `VocabularyExpression` を project-wide 共有語彙として扱う
- `Learner` を domain に持たず、外部 identity のみを参照する

## Decision: 英単語と連語は同一の `VocabularyExpression` 概念で扱う

**Rationale**: 登録、検証、解説生成、画像生成、学習進捗は単語と連語で大きく変わらない。
別概念に分けると、一意性判定、状態遷移、ポート契約、文書更新が二重化する。
`VocabularyExpression` に `VocabularyExpressionKind` を持たせる方が、学習者所有の登録対象として
一貫したルールを保ちやすい。

**Alternatives considered**:

- 単一英単語だけを対象にする
- 単語と連語を別々の集約として扱う

## Decision: `VocabularyExpression` の重複登録判定は同一学習者内の `NormalizedVocabularyExpressionText` で行う

**Rationale**: 学習者所有モデルでは、同じ英語表現でも別学習者なら独立して存在できる。
一方で同一学習者内の重複は登録状態や生成状態を分岐させるため避けたい。
`NormalizedVocabularyExpressionText` を一意キーに使うと、表記揺れを吸収しつつ学習者境界の
内側だけで重複を制御できる。

**Alternatives considered**:

- システム全体で英語表現を一意にする
- 同一学習者内でも重複登録を許可する

## Decision: `Proficiency` は `LearningState` に分離し、`Learner` と `VocabularyExpression` の関係上で扱う

**Rationale**: 頻出度と知的度は語彙や解説の属性であり、習熟度は学習者の状態である。
`Proficiency` を `VocabularyExpression` や `Explanation` に置くと、客観属性と主観進捗が混ざる。
`LearningState` を独立集約にすると、学習者所有の語彙であっても評価軸を分離できる。

**Alternatives considered**:

- `Proficiency` を `VocabularyExpression` の内部フィールドにする
- `Proficiency` を `Explanation` の属性として扱う

## Decision: `Explanation` は `VocabularyExpression` の current 参照を持つ知識集約とし、再生成中は直前の完了済み結果を保持する

**Rationale**: 解説生成は `VocabularyExpression` 単位で進むが、ユーザーへ見せるのは常に完了済み結果のみである。
そのため `VocabularyExpression.currentExplanation` を明示し、再生成開始時にこれを消さず、
新しい成功時だけ差し替える設計が一貫する。これにより中間結果を見せず、再生成失敗時も
最後の正常結果を維持できる。

**Alternatives considered**:

- 解説を常に最新ジョブ 1 件だけに上書きする
- 解説生成中は過去の完了済み解説も隠す

## Decision: `VisualImage` は `Explanation` から独立した集約とし、`currentImage` と履歴を分ける

**Rationale**: 画像は生成タイミング、保存先参照、再生成履歴が解説本文と異なる。`Explanation` が
`currentImage` を参照し、各 `VisualImage` が `previousImage` で同一解説内の履歴を辿れるようにすると、
現在表示中の画像と履歴画像の責務が分離される。再生成中も現在画像を維持し、新しい成功時だけ
参照を切り替えられる。

**Alternatives considered**:

- `Explanation` が画像 URL を直接持つ
- 画像を `Explanation` の子エンティティとして扱う
- 画像再生成時に過去画像を破棄する

## Decision: `Learner` は独立集約だが、認証そのものは外部責務として `AuthenticationSubject` 参照だけを持つ

**Rationale**: 学習者は domain 上の所有者として明示したいが、認証方式や credential まで domain に
持ち込むべきではない。`Learner` が外部 identity を表す `AuthenticationSubject` を保持し、
認証・セッション管理自体は外部ポートに委ねる方が architecture / tech stack と整合する。

**Alternatives considered**:

- `Learner` を auth provider の実装詳細ごと domain に持ち込む
- 学習者 identity を domain 外に完全に追い出し、所有境界も external に依存する

## Decision: external responsibility は learner identity を含む port catalog として整理する

**Rationale**: 単語存在確認、重複登録判定、学習者 identity 解決、解説生成、画像生成、アセット保存、
発音参照はすべて外部依存であり、project-wide domain に実装詳細を持ち込むべきではない。
ドメインでは入力、出力、保証事項だけを定義し、adapter 実装は後続 feature に委ねる。

**Alternatives considered**:

- auth provider や AI vendor 名をドメインサービスへ埋め込む
- ポート定義を作らず実装時に都度判断する

## Decision: source-of-truth は `learner.md`、`vocabulary-expression.md`、`learning-state.md` を追加して再編する

**Rationale**: 現行 `explanation.md` と `visual.md` だけでは、学習者所有、一意性境界、
習熟度分離、命名統一を表現しきれない。`Learner`、`VocabularyExpression`、`LearningState`
を独立した source-of-truth に切り出し、既存文書はそれらとの関係へ再配置する方が、
後続 feature の task と review 導線を明確にできる。

**Alternatives considered**:

- 既存 4 文書だけを追記して拡張する
- `Explanation` 文書内に `Learner` と `VocabularyExpression` と学習進捗を内包する
