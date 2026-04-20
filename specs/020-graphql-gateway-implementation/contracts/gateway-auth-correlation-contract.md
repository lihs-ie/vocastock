# Contract: Gateway Auth And Correlation

## Purpose

`graphql-gateway` が auth header と request correlation をどう扱うかを固定する。

## Auth Propagation

- auth header は client 受信値を再解釈せず、そのまま downstream へ伝播してよい
- gateway 自身は token verification の最終正本になってはならない
- backend 側の token verification / actor handoff は `command-api` と `query-api` がそれぞれ行う

## Request Correlation

- client が correlation 値を提供した場合はそれを優先する
- client が提供しない場合だけ、gateway が 1 つ採番して downstream へ渡す
- gateway は correlation 情報を transport metadata として扱い、business state と混ぜてはならない

## Non-Ownership Rules

- gateway は session store を own してはならない
- gateway は idempotency store を own してはならない
- gateway は read projection を own してはならない
- gateway は workflow dispatch や reconciliation を起動してはならない
