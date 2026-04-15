# Google Drive Fallback

このディレクトリは Google Drive asset storage の local fallback 用 fixture を置く。

- source of truth: [asset-reference.example.json](/Users/lihs/workspace/vocastock/tooling/fallback/drive/asset-reference.example.json)
- smoke command: `bash scripts/fallback/smoke_drive_stub.sh`
- local mode: `stubbed`

local で確認するのは asset reference、保存先 path、port boundary のみとし、permission / sharing / scope 変更は実クラウド確認へエスカレーションする。
