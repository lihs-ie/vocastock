# Research: Command/Query Deployment Topology

## Decision: `Command Intake` と `Query Read` は MVP から別 Cloud Run service にする

**Rationale**: 009 の top-level responsibility 分離と 012 の authoritative write / read
projection 分離を、物理 topology にもそのまま写像できる。MVP から分けることで、write 側の
acceptance / idempotency と read 側の completed visibility / projection lag handling を
責務として混ぜずに済む。

**Alternatives considered**:
- 1 つの Rust service に同居させる
- 同一 binary の別 route group としてだけ分離する

## Decision: client から見える endpoint は unified GraphQL のまま維持し、前段に `graphql-gateway` を置く

**Rationale**: client experience と screen binding は 013 で unified contract を前提に整理されており、
MVP で endpoint を分裂させると mobile 実装と review 導線の変更量が大きい。一方で gateway を
独立 deployment unit にすれば、client-visible 契約を保ちつつ backend の command/query 分離を
崩さずに済む。

**Alternatives considered**:
- client から `command` / `query` endpoint を明示的に使い分ける
- `command-api` か `query-api` のどちらかが unified endpoint を兼務する

## Decision: auth/session の token verification と actor handoff は `command-api` と `query-api` の両方で行う

**Rationale**: 008 の正本は backend 側で token を検証し、actor reference を handoff する形で
固定されている。新しい auth gateway を追加せず、各 service が shared module 相当の同一契約で
検証 / 正規化を行う方が、既存設計と最も整合する。

**Alternatives considered**:
- auth 専用 gateway を別 deployment にする
- API gateway だけが token を検証し backend は forwarded actor を信頼する

## Decision: command 直後の visible guarantee は accepted / status handle + status-only read にする

**Rationale**: 012 は read projection refresh を eventual にしてよいが、authoritative write より
先に completed と見せてはならないとしている。したがって command 後に strong read-after-write を
要求せず、projection 反映までは `query-api` が status-only を返す方が、visibility rule と
deployment 分離を両立できる。

**Alternatives considered**:
- command 成功まで projection 反映を待つ
- provisional payload を command response で返す
- command 側が query projection を同期更新する

## Decision: `Entitlement Policy` / `Subscription Feature Gate` / `Usage Metering / Quota Gate` は独立 deployment にしない

**Rationale**: 010 はこれらを inner policy component として定義しており、deployment unit ではない。
独立 service にすると topology が過分割になり、MVP で必要な責務分離を超えて運用複雑性だけが増える。

**Alternatives considered**:
- billing 専用 policy service を追加する
- query-api 外部に gate decision service を設ける

## Decision: source-of-truth 更新は `docs/external` を最終同期先とし、関連 spec package は再同期対象一覧で管理する

**Rationale**: 009 以降の設計 package は review 導線として有効だが、最終的な product-wide 正本は
`docs/external/adr.md` と `docs/external/requirements.md` に寄せる必要がある。015 では
どの package を再同期するかを update map として先に固定しておく。

**Alternatives considered**:
- 015 だけに topology 正本を閉じる
- 既存 package の個別判断に委ね、更新対象一覧を持たない
