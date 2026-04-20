# Research: Explanation Worker Implementation

## Decision 1: worker runtime は package-local Cabal package の Haskell 実装に固定する

- **Decision**: `explanation-worker` は `applications/backend/explanation-worker/` 配下の
  package-local Cabal package として実装し、worker-owned logic は Haskell module へ分割する。
- **Rationale**: 004 の正本で workflow boundary は Haskell、async execution baseline は
  `Pub/Sub + Cloud Run worker + Firestore state` と固定されている。repository にはまだ Haskell
  package skeleton が存在しないため、root 全体へ新しい multi-package manager を持ち込むより、
  app-local Cabal package を追加する方が影響を局所化できる。
- **Alternatives considered**:
  - Rust で worker を実装する: 004 / 015 の runtime baseline に反する
  - root へ Stack を導入する: repository-wide tooling 影響が大きく、initial slice の実装範囲を超える

## Decision 2: initial slice は accepted registration 起点かつ `startExplanation` 非抑止の work item だけを処理する

- **Decision**: worker intake は upstream accepted registration flow から dispatch された
  explanation generation work item に限定し、`startExplanation = false` 相当の抑止要求は worker
  対象に含めない。
- **Rationale**: 021 の最小価値は、既に 018 で受理された registration 起点の explanation start を
  completed explanation へ到達させることにある。standalone `requestExplanationGeneration` intake は
  upstream command acceptance 実装と結合するため、後続 slice に分離した方が責務境界が明確である。
- **Alternatives considered**:
  - standalone explanation request も同時に実装する: 021 の scope が intake と worker の両方へ広がる
  - `startExplanation = false` を worker 側で再判定する: suppression ownership が upstream から逸脱する

## Decision 3: success は「completed explanation 保存」と「currentExplanation handoff 完了」の二段階確定にする

- **Decision**: worker は generation adapter から completed payload を受けても、
  `Explanation` 保存と `VocabularyExpression.currentExplanation` handoff の両方が完了するまで
  `succeeded` としない。保存後に handoff が失敗した場合は candidate explanation を workflow
  state に保持し、再生成ではなく handoff の再試行を優先する。
- **Rationale**: FR-004 と 012 の state machine contract では、completed result が user-visible に
  なる条件は current handoff 完了まで含む。保存後 handoff 失敗を再生成へ戻すと duplicate
  explanation を増やしやすく、current 切替の idempotency も崩れる。
- **Alternatives considered**:
  - explanation 保存成功時点で `succeeded` とする: completed-only visibility が崩れる
  - handoff failure 時に毎回再生成する: duplicate result と余計な provider call を招く

## Decision 4: 不完全または不整合な「成功 payload」は non-retryable failure として扱う

- **Decision**: generation adapter が `succeeded` 相当を返しても、`Sense`、`Frequency`、
  `Sophistication`、`Pronunciation`、`Etymology`、`SimilarExpression` など completed
  `Explanation` に必要な payload が欠けている場合は `failed-final` へ写像する。
- **Rationale**: domain/service contract は completed 時だけ本文を返すと定義しており、不完全 payload
  を partial success や retryable failure として扱うと completed-only visibility rule が壊れる。
  malformed payload は同じ adapter 実装を再試行しても改善しない可能性が高く、運用上は terminal
  failure として扱う方が安全である。
- **Alternatives considered**:
  - partial explanation を保存して status-only で隠す: completed aggregate invariants を壊す
  - 無条件に retry-scheduled へ送る: 同じ malformed payload を繰り返すだけで収束しない

## Decision 5: duplicate / replay は business key と terminal outcome に基づいて idempotent に扱う

- **Decision**: work item は business key を持ち、同一 key の replay / duplicate arrival は
  existing workflow state を参照して no-op または completed candidate reuse として扱う。queued、
  running、retry-scheduled 中は重複生成を開始せず、succeeded 後は completed result を再利用し、
  `currentExplanation` の再切替を起こさない。
- **Rationale**: 012 の lifecycle と 015 の worker allocation では、worker が duplicate work に
  よって completed write や current switch を重複させないことが前提になっている。
- **Alternatives considered**:
  - message arrival ごとに再生成する: duplicate explanation write と current switch を招く
  - upstream duplicate 判定だけに依存する: worker restart / replay 時の自己防衛が弱い

## Decision 6: テストは Haskell unit mirror と Haskell Docker/Firebase feature suite を併用する

- **Decision**: worker-owned logic は `tests/unit/ExplanationWorker/*Spec.hs` で source module ごとに
  mirror した Haskell unit テストを用意し、feature path は Haskell suite から Docker
  container と Firebase emulator を起動して success / retryable / terminal path を検証する。
- **Rationale**: 現在の repo rule では feature test 実装言語は固定されておらず、worker 実装と同じ
  Haskell に寄せた方が Cabal component、coverage、editor support を一貫させやすい。Haskell unit
  だけでは runtime / container / emulator 経路を検証できず、逆に feature だけでは state machine
  の細部検証が弱い。
- **Alternatives considered**:
  - shell script で worker feature test を書く: typed fixture と coverage 連携が弱い
  - Haskell test だけで unit/E2E を兼用する: runtime / container / emulator と state machine の責務が混ざる

## Decision 7: HTTP runtime adapter が必要な場合は Servant 0.20.3.0 / servant-server 0.20.3.0 を使う

- **Decision**: `explanation-worker` が Pub/Sub push 受信、internal health/admin surface、dependency probe
  などの HTTP runtime adapter を持つ場合は、Servant `0.20.3.0` と `servant-server` `0.20.3.0` を採用する。
  ただし、これは non-public runtime boundary に限定し、query response や public GraphQL binding は
  引き続き scope 外とする。
- **Rationale**: Hackage 上の `servant` / `servant-server` の最新安定版 `0.20.3.0` は
  GHC `9.2.8` を tested-with に含んでおり、今回の toolchain 制約と両立する。Servant を使えば
  runtime HTTP surface の contract を型で固定しつつ、worker-owned business logic を既存 module
  から分離しやすい。
- **Alternatives considered**:
  - `wai` / `warp` だけで手書きする: route / payload contract が散りやすい
  - `scotty` など別 framework を使う: user 指定の Servant 採用方針と一致しない
