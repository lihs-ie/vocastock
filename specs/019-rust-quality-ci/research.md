# Research: Rust Quality CI

## Decision 1: Rust quality job は常に定義し、path 非該当時は no-op success にする

- **Decision**: `.github/workflows/ci.yml` に `rust-quality` job を常設し、最初の change-detection step で Rust 関連 path の差分有無を判定する。差分が無い場合は required check 名を維持したまま軽量 success で終了する。
- **Rationale**: branch protection は check 名の安定性に依存するため、job 自体を消すより no-op success の方が運用が安定する。
- **Alternatives considered**:
  - job 自体を path 条件で生成しない: required check が欠落しやすく、branch protection と衝突しやすい
  - Rust 変更が無くても毎回 full 実行する: 不要な CI 時間と Docker/Firebase 起動コストが発生する

## Decision 2: Rust 変更検出は repo-local script で行う

- **Decision**: `scripts/ci/detect_rust_changes.sh` を追加し、GitHub Actions event の base/head から Rust 関連 path の差分を判定する。
- **Rationale**: local script にすると path catalog と no-op 判定ロジックを repository 内でレビュー・更新でき、外部 action 依存も増えない。
- **Alternatives considered**:
  - third-party `paths-filter` action を使う: 導入は容易だが、依存と挙動が workflow 外に散る
  - workflow YAML に diff 判定を直書きする: 可読性と再利用性が低い

## Decision 3: Rust quality 実行本体は単一の repo-local runner script に集約する

- **Decision**: `scripts/ci/run_rust_quality_checks.sh` を追加し、`cargo fmt --all -- --check`、`cargo clippy --workspace --all-targets -- -D warnings`、`query-api` / `command-api` の unit test、全 Rust アプリ向け feature test を順に実行する。
- **Rationale**: workflow に細かい shell を散らすより、ローカル再現・ログ整理・budget 計測を 1 箇所に寄せた方が保守しやすい。
- **Alternatives considered**:
  - 各 cargo command を workflow step に直接列挙する: ローカル再現の入口が増え、artifact 出力も分散する
  - static check / unit / feature を別 job に分ける: required check 数が増え、path gating と no-op 制御が複雑になる

## Decision 4: Docker/Firebase feature test は 1 回の emulator session を共有する

- **Decision**: Rust quality 実行では `scripts/firebase/start_emulators.sh` と `scripts/firebase/stop_emulators.sh` を用いて emulator session を 1 回だけ管理し、各 feature test には reuse 用の環境変数を渡す。
- **Rationale**: crate ごとに emulator を起動し直すより高速で、CI での flaky な起動待ちを減らせる。
- **Alternatives considered**:
  - 各 feature test が毎回 emulator を自己起動する: 実行時間が伸び、停止点が分散する
  - 既存 `application-container-smoke` を feature test の代わりに使う: crate 単位の Rust feature test 契約を満たせない

## Decision 5: 全 Rust アプリ対象の feature test を満たすため、`graphql-gateway` にも Rust feature test を追加する

- **Decision**: `query-api` と `command-api` に加えて `graphql-gateway` に Rust feature test harness を追加し、Rust quality job の feature segment で全 Rust アプリを実行対象にする。
- **Rationale**: clarifications で feature test の対象を全 Rust アプリに固定したため、`graphql-gateway` だけ除外すると spec と乖離する。
- **Alternatives considered**:
  - `graphql-gateway` だけ feature test 対象外にする: clarified scope と矛盾する
  - container smoke だけで gateway を代替する: Rust feature test の required gate にならない

## Decision 6: Rust quality のログと duration は `.artifacts/ci` へ集約して常時 upload する

- **Decision**: Rust quality の summary、segment log、failure stage、duration を `.artifacts/ci/logs` と `.artifacts/ci/durations` に書き出し、job 成否にかかわらず artifact upload する。
- **Rationale**: static / unit / feature のどこで止まったかを reviewer が 5 分以内に判断するには、統一された artifact 置き場が必要である。
- **Alternatives considered**:
  - GitHub Actions の raw log のみで追う: stage 境界と再現コマンドが散って判定しづらい
  - 成功時は artifact を出さない: passing run の基準値比較がしにくい
