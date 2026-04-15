# Pub/Sub Fallback

このディレクトリは Google Cloud Pub/Sub の local fallback 用 fixture を置く。

- source of truth: [message-envelope.example.json](/Users/lihs/workspace/vocastock/tooling/fallback/pubsub/message-envelope.example.json)
- smoke command: `bash scripts/fallback/smoke_pubsub_stub.sh`
- local mode: `stubbed`

local で確認するのは message contract、retry 前提、payload shape のみとし、delivery semantics や subscription 設定の変更は実クラウド確認へエスカレーションする。
