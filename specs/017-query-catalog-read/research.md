# Research: Query Catalog Read

## Decision: initial slice は `query-api` 直下の HTTP GET endpoint として実装する

**Rationale**: 現在の `query-api` は plain HTTP skeleton を持ち、GraphQL schema 全体の拡張は
scope 外である。最小 read slice を internal service endpoint として切り出す方が、
015 の `query-api` read-only 責務と 016 の readiness/runtime 契約を崩さずに進められる。

**Alternatives considered**:

- 先に `graphql-gateway` 経由の GraphQL schema を拡張する
- endpoint を追加せず crate root 配下の関数差し替えだけで済ませる

## Decision: projection source は in-memory / stub abstraction を使い、Firestore 本実装は deferred にする

**Rationale**: 012 の read-model contract で必要なのは completed summary と status-only の
可視性保証であり、永続化製品そのものではない。initial slice では stub projection source を
使う方が、read-side contract とテストを先に固定しやすい。

**Alternatives considered**:

- 初回から Firestore read model 実装まで進める
- projection source abstraction を持たず `main.rs` に固定配列を埋め込む

## Decision: catalog response は `completed-summary` と `status-only` の 2 系統に固定する

**Rationale**: 012 は `VocabularyCatalogProjection` を `currentExplanation` の参照可否で
completed / status-only に分離し、013 は catalog が detail payload を含まないことを要求する。
response variant を 2 系統に絞ると、projection lag や failure 時の visible guarantee が
明確になる。

**Alternatives considered**:

- workflow runtime state をそのまま app-facing payload に露出する
- provisional completed payload を `succeeded but stale` のような中間 variant で返す

## Decision: auth/session は `shared-auth` の `TokenVerificationPort` と `VerifiedActorContext` を再利用する

**Rationale**: 015 で `command-api` / `query-api` はそれぞれ backend で token verification と
actor handoff を行う前提が固定されている。query-api 独自の actor context を作ると、service 間で
認証境界が分岐する。

**Alternatives considered**:

- query-api 独自の auth/session 型を追加する
- initial slice は認証無し endpoint にする

## Decision: 既存 readiness / Firebase dependency probe は維持し、catalog endpoint を追加しても runtime contract を壊さない

**Rationale**: 016 で API service の canonical success signal は `HTTP readiness endpoint` に
固定されている。catalog read 実装によって runtime validation を壊さないため、既存 endpoint は
維持し、catalog endpoint は追加のみとする。

**Alternatives considered**:

- `/` の既存 behavior を catalog endpoint に兼用させる
- runtime probe の設計を catalog endpoint 実装と同時に組み替える
