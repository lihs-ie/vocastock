# Contract: Migration Phase

## Purpose

現状の docs-first repository から target architecture へ進む段階移行方針を定義する。

## Phase Catalog

| Phase | Goal | Runtime Shape | Main Changes | Exit Criteria |
|-------|------|---------------|--------------|---------------|
| `current-state` | 現状整理 | documentation first | ドメイン文書、要件、ADR、開発基盤 docs が存在し、architecture contract は未固定 | 本 spec bundle が完成し、責務境界と移行順序が合意されている |
| `phase-1-foundation` | architecture 契約の実装土台を作る | Flutter Client Runtime + Application Runtime | command/query 契約、repository 契約、visibility contract を実装側へ反映する | 登録、取得、状態表示の owner boundary がコード上で説明できる |
| `phase-2-workflow-isolation` | 非同期 workflow を論理的に分離する | Flutter Client Runtime + Application Runtime + Explanation Worker Runtime + Image Worker Runtime | 解説生成と画像生成の workflow owner、冪等 retry、完了結果のみ表示を end-to-end で成立させる | explanation/image の `pending/running/succeeded/failed` が一貫して扱われる |
| `phase-3-runtime-optimization` | 運用境界とスケーリング方針を最適化する | target runtime shape maintained | adapter の監視、失敗分離、必要に応じた runtime 独立 deploy を強化する | provider 差し替えや運用変更の影響範囲を runtime ごとに説明できる |

## Rules

- フェーズを進める前に、前段フェーズの exit criteria を満たさなければならない
- どのフェーズでも未完了成果物をユーザーへ表示してはならない
- command/query を同一 runtime に同居させてもよいが、契約上の責務分離は崩してはならない
- workflow の物理分離を遅らせる場合でも、状態所有者、retry owner、visibility rule は先に固定する
- フェーズ進行中にドメイン境界を変更する場合は、`docs/internal/domain/*.md` を同じ変更セットで更新する
