# ストーリー

## ユーザー

- ユーザーが自分の `VocabularyExpression` を登録する
  - `VocabularyExpression` は単語と連語を同一概念として扱う
  - 重複登録判定は同一学習者内の `NormalizedVocabularyExpressionText` で行う
- 未登録であれば、登録した `VocabularyExpression` に対して解説生成を行う
  - 時間がかかるため非同期で行う
- 完了済み `Explanation` は 1 件以上の `Sense` を持ち、多義語でも意味単位ごとに説明できる
  - 例文とコロケーションは explanation 全体ではなく対応する `Sense` に属する
- ユーザーは完了済み `Explanation` から視覚的イメージ画像を生成できる
  - 時間がかかるため非同期で行う
  - 生成された画像は何らかのストレージサービスに永続化される
  - 画像は explanation 全体を代表してもよく、必要に応じて特定の `Sense` に対応してもよい
- ユーザーには解説と画像の完全な生成結果のみを表示する
  - 生成中または失敗中は状態のみを表示し、中間生成結果は表示しない
- 画像が生成されている解説は単一の `currentImage` を表示に反映する

## 要件

- `Explanation` は生成時にネイティブスピーカーがよく使うかを `Frequency` としてレベル分けする
- `Explanation` は語彙の知的・語彙的な難度を `Sophistication` として管理する
- `Learner` は自分が所有する `VocabularyExpression` を管理できる
- 学習者ごとの定着度は `LearningState.proficiency` として管理する
  - `Frequency` や `Sophistication` とは異なる概念として扱う
- `RegistrationStatus`、`ExplanationGenerationStatus`、`ImageGenerationStatus` は別概念として管理する
- `Sense` は `Explanation` が所有する意味単位として管理し、`Meaning.values` を正本概念として再利用しない
- `VisualImage` は独立集約のまま維持しつつ、必要に応じてどの `Sense` を描写する画像かを示せる
- `Explanation.currentImage` は `Sense` の数にかかわらず単一参照のままとする

## Deferred Scope

- 認証、credential、session 管理は auth/session 設計で扱う
- command 受理、workflow orchestration、dispatch failure は backend command 設計で扱う
- query model、永続化実装、外部 vendor adapter 実装は別 feature とする
- 複数 current image の同時公開や meaning gallery は後続 feature で扱う

## 設計正本メモ

- コンポーネント境界、top-level responsibility、canonical component catalog の正本は `docs/external/adr.md` の「コンポーネント」節とする
- サブスクリプション境界、authoritative subscription state、purchase state、entitlement、feature gate、quota gate の正本は `docs/external/adr.md` の「サブスクリプションコンポーネント」節と `specs/010-subscription-component-boundaries/` とする
- domain terminology の正本は `docs/internal/domain/*.md` とし、component 定義はそれらの意味論を変更しない
- auth/session の責務境界と actor handoff の behavioral contract は `specs/008-auth-session-design/` を正本とする
- command 受理、retry / regenerate、dispatch rule の behavioral contract は `specs/007-backend-command-design/` を正本とする
- query model schema / persistence と vendor-specific adapter 実装は後続 feature の正本へ委ねる
- 課金状態の最終正本は backend authoritative subscription state とし、app core と UI は同期済み entitlement mirror のみを参照する
- purchase / restore の受付状態は `initiated`、`submitted`、`verifying`、`verified`、`rejected` の canonical purchase state model に従い、`verified` になるまで premium unlock の根拠にしない
- pricing catalog、tax、refund policy、vendor SDK detail は subscription component boundary の対象外とし、mobile storefront または後続実装を正本とする

## 開発基盤メモ

- 開発時の host baseline、CI runner 境界、version governance は `docs/development/*.md` と `tooling/versions/approved-components.md` を正とする
