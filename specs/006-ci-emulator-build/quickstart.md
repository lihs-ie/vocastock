# Quickstart: CI Emulator Build Optimization

## 1. 現状の起点を確認する

1. [ci.yml](/Users/lihs/workspace/vocastock/.github/workflows/ci.yml) の `emulator-smoke` job と
   [run_emulator_smoke.sh](/Users/lihs/workspace/vocastock/scripts/ci/run_emulator_smoke.sh) を確認する
2. [start_emulators.sh](/Users/lihs/workspace/vocastock/scripts/firebase/start_emulators.sh) で
   `docker compose up -d --build` が CI path に入っていることを確認する
3. [compose.yaml](/Users/lihs/workspace/vocastock/docker/firebase/compose.yaml) と
   [Dockerfile](/Users/lihs/workspace/vocastock/docker/firebase/Dockerfile) を baseline source-of-truth として確認する

## 2. planning artifact の想定変更点を確認する

1. `emulator-smoke` は required check 名を維持したまま、prepared image の解決と ready 判定だけを担当する
2. image build / publish は dedicated workflow or job に分離する
3. reusable image ref は baseline hash から計算し、GHCR を正規配布先にする
4. stage logs は `image-resolution`、`image-build or pull`、`container-start`、`readiness-wait` を必須化する

## 3. 実装後のローカル検証

1. workflow 定義を lint する

   ```bash
   actrun lint .github/workflows/ci.yml
   actrun lint .github/workflows/emulator-image-prepare.yml
   ```

2. image preparation path を単独で確認する

   ```bash
   VOCAS_IMAGE_PREPARE_ALLOW_PUBLISH=0 \
   VOCAS_IMAGE_PREPARE_EXPORT_ARTIFACT=1 \
   bash scripts/ci/prepare_emulator_image.sh
   ```

3. local developer path が build 維持で壊れていないことを確認する

   ```bash
   bash scripts/firebase/start_emulators.sh
   bash scripts/firebase/smoke_local_stack.sh
   bash scripts/firebase/stop_emulators.sh
   ```

4. reusable CI path を actrun で確認する

   ```bash
   actrun workflow run .github/workflows/ci.yml --local --include-dirty --trust
   ```

## 4. 実装後の GitHub 検証

1. `emulator-image-prepare` workflow を default branch で 1 回成功させる
2. その後の PR / push で `prepare-emulator-image` が `existing-ghcr` または same-run artifact を返し、`emulator-smoke` が inline build なしに成功することを確認する
3. failure 時は `.artifacts/ci/logs/*.stages.tsv`、`*.compose-ps.txt`、`*.container-tail.log` だけで停止点を説明できることを確認する
