# コンポーネント

## 主軸アーキテクチャ

- 主軸はオニオンアーキテクチャとする
- `Domain Core` と `Application Coordination` は内側基盤として明示し、外から見える component catalog には混ぜない
- 外から見える top-level responsibility は `Presentation`、`Actor/Auth Boundary`、`Command Intake`、`Query Read`、`Async Generation`、`External Adapters` に固定する
- `auth/session` は outer boundary として分離し、009 では利用点だけを定義する
- `Explanation Generation Workflow` と `Image Generation Workflow` は `Async Generation` 配下の別 component とする
- ユーザーに公開してよい生成物は完了済み結果のみとし、生成中または失敗中は状態のみを表示する

## 内側基盤

### Domain Core

- `Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、`VisualImage`、`Sense` の用語と不変条件を保持する
- UI、auth/session detail、vendor API detail は持たない

### Application Coordination

- domain を使って actor handoff、command intake、query read、async workflow を接続する依存規則を保持する
- top-level responsibility の代替カテゴリとしては扱わない

## Top-Level Responsibilities

### Presentation

#### `UI`

- `VocabularyExpression` 登録入力を扱う
- 完了済み `Explanation` と完了済み `VisualImage` を表示する
- 生成中または失敗中は状態のみを表示する
- `Explanation.currentImage` の単一参照に従って表示する
- workflow 実行、vendor API 呼び出し、auth account lifecycle は扱わない

### Actor/Auth Boundary

#### `Learner Identity Resolution`

- 外部 identity から `Learner` 参照へ正規化する
- provider sign-in、session issuance、token verification は扱わない

#### `Actor Session Handoff`

- auth/session 境界の completed output を command / query 向け actor reference へ handoff する
- raw token、provider credential、domain aggregate mutation は扱わない

### Command Intake

#### `Vocabulary Expression Registration Intake`

- 登録要求受理の起点を担う
- completed result 読み取りと workflow 実行本体は扱わない

#### `Vocabulary Expression Validation Policy`

- `VocabularyExpressionText` の正規化と validation orchestration を担う
- vendor lexicon API への直接接続は扱わない

#### `Registration Lookup`

- 同一学習者内の duplicate registration check を担う
- auth/session detail と completed explanation / image の読み取りは扱わない

#### `Explanation Generation Request Intake`

- 解説生成要求の受理を担う
- provider 呼び出し本体は扱わない

#### `Image Generation Request Intake`

- 完了済み `Explanation` と optional `Sense` を前提に画像生成要求を受理する
- provider 呼び出し本体と asset 保存本体は扱わない

### Query Read

#### `Explanation Reader`

- completed `Explanation` と履歴取得を担う
- workflow 起動と provider 呼び出しは扱わない

#### `Visual Image Reader`

- completed `VisualImage` と `Explanation.currentImage` 解決を担う
- asset 永続化と workflow 起動は扱わない

#### `Generation Status Reader`

- explanation / image generation status の取得を担う
- incomplete payload の公開は行わない

#### `Pronunciation Media Reader`

- 発音サンプル参照の app-facing read を担う
- media source 直結と credential 管理は扱わない

### Async Generation

#### `Explanation Generation Workflow`

- `VocabularyExpression` から completed `Explanation` と `Sense` を生成する長時間処理を担う
- request acceptance、UI 表示、completed result の read API は扱わない

#### `Image Generation Workflow`

- completed `Explanation` と optional `Sense` から `VisualImage` を生成し、必要な storage handoff を行う長時間処理を担う
- request acceptance、UI 表示、asset access 解決は扱わない

### External Adapters

#### `Vocabulary Expression Validation Adapter`

- 英語表現存在確認の外部接続を担う
- validation policy の最終判断は持たない

#### `Explanation Generation Provider Adapter`

- explanation provider との接続を担う
- request acceptance と read-side 表示は扱わない

#### `Image Generation Provider Adapter`

- image provider との接続を担う
- request acceptance と completed image 表示は扱わない

#### `Asset Storage Adapter`

- 画像保存と stable asset reference 発行を担う
- user-facing image read は扱わない

#### `Asset Access Adapter`

- stored asset の再取得参照解決を担う
- asset 永続化判断と workflow 起動は扱わない

#### `Pronunciation Media Adapter`

- media source から音声参照を取得する
- reader の app-facing contract 定義は扱わない

## 主要フロー

### `VocabularyExpression` 登録

- `Actor Session Handoff`
- `Vocabulary Expression Registration Intake`
- `Vocabulary Expression Validation Policy`
- `Vocabulary Expression Validation Adapter`
- `Registration Lookup`
- `Generation Status Reader` または `Explanation Reader`

### 完了済み `Explanation` 閲覧

- `Actor Session Handoff`
- `Explanation Reader`
- `Generation Status Reader`
- `Pronunciation Media Reader`
- `Pronunciation Media Adapter`

### 画像生成

- `Actor Session Handoff`
- `Image Generation Request Intake`
- `Image Generation Workflow`
- `Image Generation Provider Adapter`
- `Asset Storage Adapter`
- `Visual Image Reader`
- `Asset Access Adapter`
- `Generation Status Reader`

## 依存方向ルール

- `Presentation` は `Async Generation` を直接起動してはならず、`Command Intake` または `Query Read` を経由する
- `Command Intake` は completed payload を返す reader を内包してはならない
- `Query Read` は workflow 起動や retry dispatch を own してはならない
- `Async Generation` は incomplete payload を user-facing contract として返してはならない
- `External Adapters` は最終的な受理判断や表示判断を持ってはならない

## Deferred Scope

- auth account lifecycle、provider sign-in、session invalidation detail は `specs/008-auth-session-design/` を正本とする
- command acceptance semantics、retry / regenerate、dispatch failure、workflow start rule は `specs/007-backend-command-design/` を正本とする
- query model schema / persistence implementation は後続 feature を正本とする
- vendor-specific adapter implementation は後続実装で具体化する
- multiple current image / meaning gallery は follow-on scope とし、現時点では単一 `Explanation.currentImage` 前提を維持する
