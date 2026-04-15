# Contract: Boundary Responsibility

## Purpose

主要な責務境界、主責務、依存方向、runtime 配置を定義する。

## Boundary Catalog

| Boundary | Primary Runtime | Owns | Must Not Own | Depends On |
|----------|-----------------|------|--------------|------------|
| Client Experience | Flutter Client Runtime | ユーザー入力、状態表示、完了済み解説/画像の描画、再試行導線の起動 | 外部 provider への直接接続、生成状態の永続化、ドメイン判断 | Vocabulary Command、Learning Query |
| Vocabulary Command | Application Runtime | 単語登録、重複確認、解説生成開始 command、画像生成開始 command の受理 | 長時間生成処理の実行、表示用整形、外部 SDK 直結 | WordValidationPort、各 repository、workflow dispatch |
| Learning Query | Application Runtime | 登録済み単語、解説、画像、状態をユーザー表示用に合成した read model | 生成状態の直接変更、外部 provider 呼び出し | ExplanationRepository、VisualImageRepository、projection store |
| Explanation Workflow | Explanation Worker Runtime | 解説生成状態遷移、冪等再試行、解説完了/失敗の確定 | UI 向け整形、画像生成の直接実行 | ExplanationGenerationPort、PronunciationMediaPort、ExplanationRepository |
| Image Workflow | Image Worker Runtime | 画像生成状態遷移、再生成、画像完了/失敗の確定 | 解説本文生成、UI 描画、単語登録判断 | ImageGenerationPort、AssetStoragePort、VisualImageRepository |
| Integration Adapter | Caller-owned in each runtime | provider / storage / validation との変換、タイムアウト、リトライ、監視情報付与 | ドメイン状態の所有、ユーザー表示判断 | 外部サービス、ストレージ、監視基盤 |

## Runtime Catalog

| Runtime Unit | Hosted Boundaries | Notes |
|--------------|-------------------|-------|
| Flutter Client Runtime | Client Experience | iOS / Android / macOS で同一の責務境界を共有する |
| Application Runtime | Vocabulary Command, Learning Query | 初期段階では同期 command と query を同居させてよいが、契約は分離する |
| Explanation Worker Runtime | Explanation Workflow | queue-driven に動作し、解説生成の冪等性を担保する |
| Image Worker Runtime | Image Workflow | 画像生成と保存を担い、解説完了を前提条件にする |

## Dependency Rules

- Client Experience は Application Runtime の command/query 契約以外へ直接依存してはならない
- Workflow 境界は repository と external port を通じて状態を更新し、相手 workflow の内部状態を直接変更してはならない
- Integration Adapter は caller boundary ごとに所有し、shared utility としても domain 判断を持ってはならない
- Query 側は内部状態を要約してよいが、未完了成果物を完成済みとして見せてはならない
