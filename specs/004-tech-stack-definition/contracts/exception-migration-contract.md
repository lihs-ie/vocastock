# Contract: Exception and Migration

## Purpose

例外技術の扱いと、現状から target stack へ到達する移行波を定義する。

## Exception Rules

| Situation | Required Action | Approval Condition |
|-----------|-----------------|-------------------|
| 採用済み stack に存在しない技術を使いたい | `StackExceptionRecord` を起票する | 期限、代替統制、owner、対象 boundary が明記されている |
| 既存資産のため一時的に REST や単一 backend 言語を残す | migration wave に紐付ける | 次 wave での解消条件がある |
| provider 要件で SDK 直結や Drive 固有契約を持ち込みたい | port/adapter 代替案と比較する | core stack へ侵入しないことを証明できる |

## Migration Waves

| Wave | Goal | Main Adoption |
|------|------|---------------|
| `current-state` | docs-first 現状 | architecture と environment の文書のみ整備済み |
| `wave-1-foundation` | client / contract foundation | Flutter client、GraphQL contract、Firebase baseline、Google Drive asset adapter の契約を実装側へ反映する |
| `wave-2-service-runtime` | command/query runtime 導入 | Rust command/query runtime on Cloud Run を導入する |
| `wave-3-workflow-hardening` | workflow 分離と運用強化 | Haskell workflow runtime、Pub/Sub、Firestore state、observability hardening を完成させる |

## Rules

- 各 wave は前 wave の exit criteria を満たしてから進める
- どの wave でも未完了成果物をユーザーへ表示してはならない
- local / CI 基盤に新しい managed service や runtime を追加する場合は、feature 002 系の source of truth も同じ変更セットで更新する
- 例外が残ったまま次 wave へ進む場合は、期限と解消責任を明示しなければならない
- Google Drive asset adapter や Pub/Sub worker を導入できない環境では、代替検証手段を例外記録なしに常設してはならない
