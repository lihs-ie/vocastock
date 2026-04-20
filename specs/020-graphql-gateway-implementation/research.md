# Research: GraphQL Gateway Implementation

## Decision 1: public transport は `POST /graphql` の JSON envelope に固定する

- **Decision**: initial slice の public GraphQL transport は `POST /graphql` に固定し、request
  body は `query`、任意の `operationName`、任意の `variables` を持つ JSON envelope とする。
- **Rationale**: unified GraphQL endpoint の最小実装として最も標準的で、mutation / query を 1 つの
  endpoint へ収めつつ、017 / 018 の既存 internal HTTP route と接続しやすい。
- **Alternatives considered**:
  - `GET /graphql` も同時サポートする: initial slice では検証点が増え、mutation の扱いも複雑になる
  - `/` を public GraphQL endpoint に兼用する: 既存の root message / readiness 周りの契約と衝突する

## Decision 2: initial slice は 2 operation allowlist と 1 request 1 operation validation に固定する

- **Decision**: public operation は `registerVocabularyExpression` mutation と
  `vocabularyCatalog` query の 2 件だけを allowlist し、1 request 1 operation を前提にする。
  複数 operation や operationName 未指定で曖昧な document は `ambiguous-operation`、allowlist 外は
  `unsupported-operation` とする。
- **Rationale**: 020 の scope を 017 / 018 の既存実装へ接続する最小スライスに保てる。未知の field を
  best-effort で downstream へ流さないため、visible guarantee と failure test が安定する。
- **Alternatives considered**:
  - mutation は全部 `command-api`、query は全部 `query-api` へ流す: scope 外 operation を誤公開しやすい
  - GraphQL schema 全体を先に広げる: 020 の最小 binding 実装を超える

## Decision 3: gateway は downstream HTTP relay adapter だけを持ち、domain ownership を持たない

- **Decision**: `graphql-gateway` は `command-api` の
  `POST /commands/register-vocabulary-expression` と `query-api` の `GET /vocabulary-catalog` を
 呼ぶ relay adapter を持ち、request/response mapping だけを行う。
- **Rationale**: 015 で gateway は routing と request correlation だけを担い、token verification、
  idempotency、read projection ownership、workflow dispatch を持たないと固定されている。
- **Alternatives considered**:
  - gateway が command/query の business logic を一部再実装する: topology と visible guarantee を壊す
  - gateway から downstream route を直接文字列連結だけで扱う: contract 追跡と failure shaping が弱い

## Decision 4: public failure は共通 envelope へ写像する

- **Decision**: unsupported / ambiguous / downstream unavailable / downstream auth failure は、
  `code` と `message` を必須にした共通 public failure envelope へ写像し、必要時のみ
  `retryable` を追加する。
- **Rationale**: client 側実装と feature test の観測点を統一でき、017 / 018 の `message` 必須方針とも
  整合する。downstream の internal route detail や secret を隠しやすい。
- **Alternatives considered**:
  - downstream error body をそのまま流す: internal detail が漏れやすい
  - failure category ごとに別 shape を作る: public contract の理解とテストが複雑になる

## Decision 5: auth header は透過伝播し、request correlation は欠落時だけ gateway が補完する

- **Decision**: auth header は client 受信値を再解釈せずそのまま downstream へ渡し、
  request correlation は client 提供値を優先し、無い場合のみ gateway が 1 つ採番して伝播する。
- **Rationale**: 008 と 015 で token verification / actor handoff の正本は downstream service 側にある。
  gateway は observability を補うだけに留めるのが boundary として自然である。
- **Alternatives considered**:
  - gateway が auth header を正規化し直す: token verification の ownership が曖昧になる
  - correlation を補完しない: local / CI の tracing と failure diagnosis が弱くなる

## Decision 6: feature テストは Rust integration test から gateway + downstream + Firebase emulator をまとめて起動する

- **Decision**: feature テストは Rust integration test から Docker compose と Firebase emulator を使い、
  `graphql-gateway`、`command-api`、`query-api` をまとめて起動して public GraphQL endpoint を検証する。
- **Rationale**: AGENTS の feature test ルールを満たしつつ、020 の価値である public binding を
  local / CI 双方で end-to-end に再現できる。
- **Alternatives considered**:
  - unit test だけで public binding を担保する: downstream relay と container runtime を検証できない
  - shell script で public GraphQL テストを行う: current test rule に反する
