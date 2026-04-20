# Research: Image Worker Implementation

## Decision 1: worker runtime は package-local Cabal package の Haskell 実装に固定する

- **Decision**: `image-worker` は `applications/backend/image-worker/` 配下の package-local
  Cabal package として実装し、worker-owned logic は Haskell module へ分割する。
- **Rationale**: 004 の正本で workflow boundary は Haskell、async execution baseline は
  `Pub/Sub + Cloud Run worker + Firestore state + asset adapter` と固定されている。repository
  にはまだ `image-worker` package skeleton が存在しないため、root 全体へ別の package manager
  を導入するより、app-local Cabal package を追加する方が影響を局所化できる。
- **Alternatives considered**:
  - Rust で worker を実装する: 004 / 015 の runtime baseline に反する
  - root へ Stack を導入する: repository-wide tooling 影響が大きく、initial slice の範囲を超える

## Decision 2: initial slice は accepted 済み `requestImageGeneration` work item だけを処理する

- **Decision**: worker intake は upstream accepted `requestImageGeneration` flow から dispatch
  された image generation work item に限定し、completed `Explanation` を持つ target だけを処理する。
- **Rationale**: 022 の最小価値は、011 で正本化された canonical image command を completed
  `VisualImage` と `currentImage` handoff へ到達させることにある。request acceptance 自体を同時に
  実装すると、worker と command boundary の責務が混ざる。
- **Alternatives considered**:
  - public intake も同時に実装する: 022 の scope が worker と command intake の両方へ広がる
  - completed `Explanation` 前提を worker 外へ押し戻す: worker restart / replay 時の自己防衛が弱くなる

## Decision 3: generation port と asset storage port を分離し、success は asset reference 確定後にだけ判定する

- **Decision**: 画像生成 provider と asset storage handoff は別 port として扱う。worker は
  generation port で renderable payload を受け、asset storage port で stable asset reference を
  確定し、その後に `VisualImage` 保存へ進む。
- **Rationale**: 004 の boundary stack contract は image workflow が Google Drive 相当の asset
  adapter を含むことを明示しており、provider generation と asset 保存は failure mode が異なる。
  port を分離した方が retryable / terminal mapping と contract test の設計が明確になる。
- **Alternatives considered**:
  - provider が final asset reference まで返す前提にする: asset adapter の差し替え余地を狭める
  - asset storage を persistence の一部に埋め込む: retry point と failure visibility が曖昧になる

## Decision 4: 保存済み `VisualImage` は handoff failure 時に non-current completed として保持する

- **Decision**: asset reference 確定済みの completed `VisualImage` を保存した後に
  `Explanation.currentImage` handoff が失敗した場合、保存済み画像は破棄せず non-current completed
  として保持し、handoff だけを retryable failure として再試行する。
- **Rationale**: clarification で確定したとおり、画像生成自体は成功しているため、再生成より handoff
  再試行の方が duplicate image と余計な provider call を防げる。completed-only visibility も
  `currentImage` 未切替の間は current payload に出さないことで維持できる。
- **Alternatives considered**:
  - handoff failure 時に画像を破棄して再生成する: duplicate 生成とコスト増を招く
  - 毎回 `dead-lettered` に送る: recoverable handoff failure まで operator review に寄ってしまう

## Decision 5: `currentImage` の採用権はより新しい accepted request に固定する

- **Decision**: 同じ `Explanation` に対する複数 accepted image request では、より新しく accepted
  された request だけに `currentImage` 採用権を与える。古い request が後から成功しても、
  その `VisualImage` は non-current completed として保持する。
- **Rationale**: single-current rule の下で最も危険なのは、遅延した古い成功結果が新しい利用者意図を
  上書きすることにある。accepted ordering を current adoption priority に使えば stale success を
  安全に吸収できる。
- **Alternatives considered**:
  - 最後に `succeeded` した request を current にする: race により新しい意図を失う
  - concurrent request を全面禁止する: regenerate / retry と後続機能の余地を不必要に狭める

## Decision 6: deterministic な前提不正は `failed-final` に写像する

- **Decision**: target 不在、ownership mismatch、未完了 `Explanation`、`Sense` ownership mismatch の
  ような deterministic な前提不正は `failed-final` とし、`dead-lettered` は不明系または operator
  review 必須の異常に限定する。
- **Rationale**: clarification で確定したとおり、再試行で改善しない failure を `dead-lettered` に
  混ぜると state machine の意味が弱くなる。`failed-final` を deterministic invalid target 用に
  固定した方が validation と運用判断が単純になる。
- **Alternatives considered**:
  - 前提不正をすべて `dead-lettered` にする: operator review 負荷が不必要に増える
  - failure family を実装ごとに任せる: acceptance test と observability がぶれる

## Decision 7: initial slice では dedicated HTTP runtime adapter を持たず、stable-run consumer に集中する

- **Decision**: `image-worker` 初期実装では dedicated な HTTP runtime adapter を持たず、queue /
  subscription 待受の stable-run consumer と container-level dependency probe に集中する。
- **Rationale**: 022 の scope は image workflow 実装であり、public / operator HTTP surface は必須
  ではない。runtime HTTP を入れない方が、image workflow と query/public API の責務境界を崩さずに済む。
- **Alternatives considered**:
  - health/admin endpoint を app 内に追加する: initial slice の scope 外であり、worker 境界も広がる
  - public endpoint を worker に持たせる: 015 / 016 の topology に反する

## Decision 8: テストは Haskell unit mirror と Haskell Docker/Firebase feature suite を併用する

- **Decision**: worker-owned logic は `tests/unit/ImageWorker/*Spec.hs` で source module ごとに
  mirror した Haskell unit テストを用意し、feature path は Haskell suite から Docker
  container と Firebase emulator を起動して success / retryable / terminal path を検証する。
- **Rationale**: 現在の repo rule では feature test の実装言語は固定されておらず、worker 実装と
  同じ Haskell に寄せた方が Cabal component、coverage、editor support を一貫させやすい。unit だけ
  では runtime / container / emulator 経路を検証できず、feature だけでは stale-success や handoff
  rule の細部検証が弱い。
- **Alternatives considered**:
  - shell script で worker feature test を書く: typed fixture と coverage 連携が弱い
  - Haskell test だけで unit/E2E を兼用する: runtime / container / emulator と state machine の責務が混ざる
