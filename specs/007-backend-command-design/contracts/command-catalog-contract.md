# Contract: Command Catalog

## Purpose

backend command 境界が受け付ける主要 command と、その意図、対象、即時応答の輪郭を固定する。

## Command Catalog

| Command | Primary Intent | Target | Default Behavior | Immediate Response |
|--------|-----------------|--------|------------------|--------------------|
| `registerVocabularyExpression` | 新規登録 | learner-owned `VocabularyExpression` | 既定では解説生成開始まで受け付ける。明示的に開始抑止もできる。重複登録時は既存状態が `not-started` または `failed` で、かつ開始抑止がない場合だけ再開する | 受付結果、対象参照、状態要約 |
| `requestExplanationGeneration` | 解説生成開始 / 再生成 | `VocabularyExpression` | 対象が所有者整合を満たす場合のみ受け付ける | 受付結果、対象参照、状態要約 |
| `requestImageGeneration` | 画像生成開始 / 再生成 | `Explanation` | 対応する解説が完了済みの場合のみ受け付ける | 受付結果、対象参照、状態要約 |
| `retryGeneration` | 失敗済み生成の再試行 | failed explanation or image generation | 同一業務キーまたは明示的 retry reason に基づいて受け付ける | 受付結果、対象参照、状態要約 |

## Rules

- command は長時間生成そのものを実行しない
- command は完了済み成果物本文や画像本体を即時応答に含めない
- command 名は意図を表す正規名称として扱い、query 名や workflow 名と混同してはならない
- command catalog にない状態変更要求は backend command 境界の外とみなす
