# Quickstart: アーキテクチャ設計

## 1. 計画成果物を確認する

- `spec.md` で対象範囲が end-to-end 全体であること、成果物に段階移行方針を含むことを確認する
- `research.md` で採用した architecture style、workflow 分離、外部ポート方針、移行戦略を確認する
- `data-model.md` で boundary、runtime、async flow、visibility、migration phase の管理対象を確認する
- `contracts/` で責務境界、非同期表示、外部依存、移行フェーズの契約を確認する

## 2. 新しい要求を architecture へ割り当てる

- UI 表示や再試行導線の変更は `contracts/async-visibility-contract.md` を起点に確認する
- 登録、生成依頼、取得などの責務追加は `contracts/boundary-responsibility-contract.md` で owner boundary を決める
- 外部 AI、検証、保存先の追加や差し替えは `contracts/external-port-contract.md` で caller boundary とポート契約を確認する
- 実装をどの順で進めるか迷う場合は `contracts/migration-phase-contract.md` で現フェーズと次フェーズを選ぶ

## 3. 既存文書との整合を確認する

- `docs/internal/domain/explanation.md` と `docs/internal/domain/visual.md` で生成状態と集約関係が保たれているか確認する
- `docs/internal/domain/service.md` で外部責務がポートとして扱われているか確認する
- `docs/external/requirements.md` と `docs/external/adr.md` でコンポーネント責務と表示規則が矛盾していないか確認する

## 4. レビュー時に確認するポイント

- 各 core responsibility が 1 つの境界へ一意に割り当てられている
- 解説生成と画像生成で `pending` / `running` / `succeeded` / `failed` の扱いが説明できる
- ユーザーに見せる成果物が `succeeded` の完了結果に限定されている
- 外部依存への接続が caller-owned adapter として整理されている
- 実装対象がどの migration phase に属するかを説明できる
- 識別子命名が `XxxIdentifier`、`identifier`、概念名フィールドで統一されている
