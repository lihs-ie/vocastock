# Research: Billing Worker Implementation

## Decision 1: worker runtime は package-local Cabal package の Haskell 実装に固定する

- **Decision**: `billing-worker` は `applications/backend/billing-worker/` 配下の
  package-local Cabal package として実装し、worker-owned logic は Haskell module へ分割する。
- **Rationale**: 004 の正本で workflow boundary は Haskell、async execution baseline は
  `Pub/Sub + Cloud Run worker + Firestore state` と固定されている。既存の `explanation-worker`
  と `image-worker` がこのパターンで実装済みのため、同じ構造に揃えて CI / toolchain / Dockerfile
  multi-stage build の再利用を最大化する。
- **Alternatives considered**:
  - Rust で worker を実装する: 004 / 015 の runtime baseline に反する
  - shell-only stub のまま放置する: 憲章 III "非同期生成は完了結果のみ公開" を満たす workflow state machine が表現できない

## Decision 2: initial slice は submitted purchase artifact と normalized store notification に限定する

- **Decision**: worker intake は upstream accepted command dispatch から dispatch された purchase
  verification work item と、store から受信した normalized server notification work item の 2 系統に
  限定する。restore workflow は 012 に別経路があるため deferred scope とする。
- **Rationale**: 023 の最小価値は、012 の subscription workflow state machine のうち
  `Purchase Verification Workflow` と `Notification Reconciliation Workflow` を worker 側で
  実現し、purchase state / subscription state / entitlement snapshot を confirmed-only で反映
  することにある。restore workflow は purchase verification と同じ最終保存対象を更新する補正
  経路であり、同時に実装すると intake 責務境界が広がるため後続 slice に分離する。
- **Alternatives considered**:
  - restore workflow も同時実装する: intake と runtime の責務が両方広がり、023 の independent test 要件が崩れる
  - 非 store origin の notification 経路も含める: 010 / 014 で外部境界が `mobile storefront` / `purchase verification` / `store notification` に限定されており、逸脱になる

## Decision 3: success は「completed BillingRecord 保存」と「currentEntitlementSnapshot handoff 完了」の二段階確定にする

- **Decision**: worker は purchase verification adapter から `verified` 相当を受けても、
  completed `BillingRecord` (purchase state 更新 + entitlement snapshot) の保存と
  `Subscription.currentEntitlementSnapshot` handoff の両方が完了するまで `succeeded` としない。
  保存後に handoff が失敗した場合は candidate snapshot を workflow state に保持し、再検証ではなく
  handoff の再試行を優先する。
- **Rationale**: FR-004 と 012 の state machine contract では、completed entitlement snapshot が
  unlock 根拠になる条件は current handoff 完了まで含む。保存後 handoff 失敗を再検証へ戻すと
  duplicate BillingRecord を増やしやすく、current 切替の idempotency も崩れる。010 の
  authority rule も backend 側の authoritative state update を snapshot commit と同時に行う
  ことを要求している。
- **Alternatives considered**:
  - BillingRecord 保存成功時点で `succeeded` とする: confirmed-only visibility が崩れる
  - handoff failure 時に毎回再検証する: duplicate commit と余計な provider call を招く

## Decision 4: 不完全または不整合な「verified payload」は non-retryable failure として扱う

- **Decision**: verification adapter が `verified` 相当を返しても、`subscriptionStateName`、
  `entitlementBundleName`、`quotaProfileName`、`effectivePeriod` など completed
  `BillingRecord` / entitlement snapshot に必要な payload が欠けている場合は `failed-final` へ
  写像する。
- **Rationale**: 010 / 014 の contract は entitlement snapshot が完全な bundle / quota profile
  を含むことを要求しており、不完全 payload を partial success や retryable failure として扱うと
  confirmed-only visibility rule が壊れる。malformed payload は同じ adapter 実装を再試行しても
  改善しない可能性が高く、運用上は terminal failure として扱う方が安全である。
- **Alternatives considered**:
  - 不完全 payload を status-only で隠す: entitlement snapshot の invariants を壊す
  - 無条件に retry-scheduled へ送る: 同じ malformed payload を繰り返すだけで収束しない

## Decision 5: duplicate / replay は business key と terminal outcome に基づいて idempotent に扱う

- **Decision**: work item は business key (例: `actor + subscription + trigger + artifactReference`)
  を持ち、同一 key の replay / duplicate arrival は existing workflow state を参照して no-op
  または completed candidate reuse として扱う。queued、running、retry-scheduled 中は重複
  verification を開始せず、succeeded 後は completed snapshot を再利用し、
  `currentEntitlementSnapshot` の再切替を起こさない。
- **Rationale**: 012 の lifecycle と 015 の worker allocation では、worker が duplicate work に
  よって authoritative subscription state や entitlement snapshot を重複切替しないことが
  前提になっている。`verified → active → revoked` のような順序が破綻すると 014 の state effect
  が再現できない。
- **Alternatives considered**:
  - message arrival ごとに再検証する: duplicate commit と current switch を招く
  - upstream duplicate 判定だけに依存する: worker restart / replay 時の自己防衛が弱い

## Decision 6: notification reconciliation は subscription state 補正のみに限定し、新規 paid entitlement を付与しない

- **Decision**: store notification は subscription state の補正経路であり、`grace` → `expired` →
  `revoked` や `active` → `grace` のような既存 authority state の更新だけを行う。notification
  単独で未確認 actor に新規 paid entitlement を付与してはならない。
- **Rationale**: 012 の notification reconciliation workflow contract は "retry / timeout /
  failure 中に新規 paid entitlement を付与しない" と規定している。notification は store が
  source-of-truth を補正するための後追い signal であり、purchase verification が終わって
  いない actor へ先回りして unlock を与えると confirmed-only visibility rule が崩れる。
- **Alternatives considered**:
  - notification から paid entitlement を推論する: verification 経路を迂回し、confirmed-only rule に反する
  - notification を無視する: `grace` / `expired` / `revoked` 補正が機能せず、010 / 014 の state effect が実装できない

## Decision 7: テストは Haskell unit mirror と Haskell Docker/Firebase feature suite を併用する

- **Decision**: worker-owned logic は `tests/unit/BillingWorker/*Spec.hs` で source module ごとに
  mirror した Haskell unit テストを用意し、feature path は Haskell suite から Docker container と
  Firebase emulator を起動して success / retryable / terminal / notification-reconciled path を
  検証する。
- **Rationale**: `explanation-worker` で同じ pattern が既に確立しており、Cabal component、
  coverage、editor support を一貫させやすい。Haskell unit だけでは runtime / container /
  emulator 経路を検証できず、逆に feature だけでは state machine の細部検証が弱い。
- **Alternatives considered**:
  - shell script で worker feature test を書く: typed fixture と coverage 連携が弱い
  - Haskell test だけで unit/E2E を兼用する: runtime / container / emulator と state machine の責務が混ざる

## Decision 8: HTTP runtime adapter は持たず stable-run long-running consumer のみを canonical success signal とする

- **Decision**: `billing-worker` は Servant による internal HTTP surface を **持たない**。
  `explanation-worker` は Pub/Sub push 受信や internal health/admin surface 用に Servant を採用
  しているが、billing-worker は pull-based consumer として stable-run だけを success signal とし、
  HTTP 層は導入しない。
- **Rationale**: 016 の container contract では worker の canonical success signal は
  `long-running consumer` の stable-run であり、HTTP endpoint は必須ではない。billing-worker は
  payment provider や store server notification を pull ベースで扱えば十分で、追加の HTTP surface は
  責務を広げるだけになる。image-worker も HTTP を持たない同じ pattern を採用している。
- **Alternatives considered**:
  - Servant internal HTTP surface を追加する: canonical success signal は stable-run で足り、追加 HTTP は overkill
  - HTTP-push 専用 consumer にする: pull-based stable-run に比べ canonical success signal の単純さが失われる
