# Contract: Query Read Scope Boundary

## Purpose

この feature が `query-api` の read-only 責務に閉じることを固定する。

## In Scope

- `VocabularyCatalogProjection` read endpoint
- completed summary / status-only の分離
- token verification / actor handoff 再利用
- in-memory / stub projection source

## Out of Scope

- `command-api` の変更
- worker の変更
- workflow 起動、retry dispatch、authoritative write
- GraphQL schema 全体の拡張
- Firestore 本実装

## Rules

- `query-api` は read projection の assembled response contract だけを own する
- `query-api` は workflow 起動や retry dispatch を own してはならない
- `query-api` は authoritative write を own してはならない
- read projection source は stub でよいが、visible guarantee は 012 / 013 / 015 の正本を維持しなければならない
