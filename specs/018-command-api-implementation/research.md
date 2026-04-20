# Research: Command API Implementation

## Decision: internal command route は `POST /commands/register-vocabulary-expression` に固定する

**Rationale**:
- 015 では gateway 公開 binding が deferred であり、018 では `command-api` 内部 route だけを実装対象にすればよい
- command 名と route を 1 対 1 にすると、011 の `registerVocabularyExpression` contract と対応づけやすい
- query-api の internal route 方針と同じく、service 内部 transport を明示できる

**Alternatives considered**:
- `POST /commands`
  - envelope の `command` だけで分岐できるが、initial slice では観測点が増えすぎる
- GraphQL mutation を直接 `command-api` に実装する
  - 015 の gateway 分離方針と衝突し、018 の scope を超える

## Decision: `command-api` は `src/register_command_api/` を crate root にし、`lib.rs` を廃止する

**Rationale**:
- AGENTS の Rust File Rules で抽象的な `lib.rs` が禁止されている
- 018 では request / response / acceptance / runtime を分割するため、責務名付き crate root の方が自然
- query-api で採用済みの責務別ディレクトリ構成と揃えられる

**Alternatives considered**:
- `src/lib.rs` を維持して中身だけ分割する
  - 現行ルールに反し、今後の `tests/unit` mirror も崩れる
- `src/command_api.rs` 単一ファイルへ集約する
  - request / response / runtime / http の責務分離が弱い

## Decision: authoritative write、idempotency、dispatch は command-api 内の stub port で実装する

**Rationale**:
- 012 は authoritative write / idempotency / dispatch ordering の正本だが、018 は Firestore 本実装を要求していない
- それでも受理規則、duplicate reuse、same-request replay、`dispatch-failed` を実コードで検証するには port が必要
- stub port にすれば、後続で Firestore / Pub/Sub 実装へ差し替えても command-side rule を保ちやすい

**Alternatives considered**:
- 直接 in-memory map を HTTP handler へ書く
  - port / adapter 分離が失われ、憲章 III と衝突する
- Firestore / Pub/Sub 本実装まで同時に入れる
  - 018 の MVP scope を超え、失敗原因の切り分けが難しい

## Decision: same-request replay と duplicate reuse を別判定として保持する

**Rationale**:
- 011 の idempotency contract は `same key + same normalized request` と `different key + same normalized text` を別概念として扱う
- 007 では duplicate registration 時に `reused-existing` を返しうる
- command-api 実装でもこの 2 つを混ぜると、replay なのか business reuse なのかが不明になる

**Alternatives considered**:
- duplicate reuse も replay として 1 種類に統合する
  - `idempotencyKey` の意味が弱くなり、011 契約とずれる
- duplicate registration を全件 rejection にする
  - 007 の reuse 方針と矛盾する

## Decision: feature テストは Rust integration test から Docker container と Firebase emulator を起動・再利用する

**Rationale**:
- AGENTS の Test Rules で feature テストは Rust コードから Docker / Firebase emulator を使うことが必須
- 016 ですでに `command-api` container と emulator の接続経路が整備済み
- query-api と同じ test style に寄せると、repository 全体で検証パターンを揃えられる

**Alternatives considered**:
- shell script で feature テストを行う
  - AGENTS の current rule に反する
- process 内 integration test だけで済ませる
  - container runtime 契約と emulator 接続を検証できない
