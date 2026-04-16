# Research: CI Emulator Build Optimization

## Decision: reusable emulator image の正規配布先は GHCR にし、tag は baseline hash で固定する

**Rationale**: GitHub workflow artifact は同一 workflow run 内の job 間共有には向くが、
run をまたいだ再利用には向かない。一方、GHCR は OCI image を repository に関連付けて
保持でき、GitHub Actions workflow から `GITHUB_TOKEN` で publish / pull できる。
baseline hash を tag に含めれば、`docker/firebase/Dockerfile`、`compose.yaml`、
`firebase.json`、approved runtime version に変化がない run は同じ image ref を
参照できる。

**Alternatives considered**:

- workflow artifact だけで image tar を渡す
- Docker Hub など外部 registry を使う
- 毎 run `docker compose build` を継続する

## Decision: image preparation path では Docker Buildx + GitHub Actions cache を使い、build path だけを高速化する

**Rationale**: Docker Docs では GitHub Actions 上の build cache として `type=gha` を
推奨している。Buildx を dedicated preparation unit に閉じ込めることで、smoke job 側は
`--no-build` に固定できる。cache は stale になり得るため、最終的な reusable image の
正規参照は GHCR tag とし、cache は build path の短縮専用にする。

**Alternatives considered**:

- `actions/cache` で buildx ローカルディレクトリを直接管理する
- Buildx cache を使わず毎回フルビルドする
- smoke job 自体で build cache を解決する

## Decision: `emulator-smoke` required check 名は維持し、smoke path は image 解決専用にする

**Rationale**: 既存 ruleset と required status check 名を変えると、保護ブランチ運用と
既存 CI policy の整合が崩れる。したがって required check 名は `emulator-smoke` のまま
維持し、job の責務だけを「image を解決して起動する path」に縮める。image build や publish
は別 job / 別 workflow に分離する。

**Alternatives considered**:

- `emulator-smoke-build` と `emulator-smoke-run` に required checks を分ける
- 既存 `emulator-smoke` を削除して別名へ置き換える

## Decision: smoke path の image 解決順は「same-run artifact -> GHCR baseline tag -> deterministic failure」とする

**Rationale**: baseline 変更直後の trusted run では、preparation path が build した image を
同一 run artifact として downstream に渡せる。baseline 未変更 run では GHCR baseline tag
pull が最短であり、clean runner でも再利用できる。どちらも使えない場合に local build へ
黙って戻すと、今回の改善対象である inline rebuild が再発するため、CI では fail-fast にする。

**Alternatives considered**:

- GHCR miss 時に CI 内で自動 `--build` へ戻す
- GHCR miss でも待機を続け、ready timeout に委ねる
- same-run artifact を使わず GHCR のみを信頼する

## Decision: local developer path は build を維持し、CI と local を mode で切り替える

**Rationale**: FR-007 により local path は reusable CI image がなくても利用可能である必要が
ある。`start_emulators.sh` と `compose.yaml` に CI / local mode を持たせれば、local では
`--build`、CI では `--no-build` と `image` pull/load を使い分けられる。これにより
local 再現性を壊さず CI だけ最適化できる。

**Alternatives considered**:

- local でも build を禁止して GHCR image のみを使う
- local / CI で別 compose file を完全分離する

## Decision: diagnostic log は stage marker と duration file を `.artifacts/ci` へ集約する

**Rationale**: 現状の `emulators.log` だけでは、image resolution、build/pull、container
start、readiness wait のどこで止まったかが読み取りづらい。`start_emulators.sh` と
`run_emulator_smoke.sh` に stage marker、epoch、duration、`docker compose ps`、
container log tail を追加し、failure 時も maintainer が artifact だけで停止点を判定できる
ようにする。

**Alternatives considered**:

- Firebase emulator の標準ログだけに依存する
- GitHub Actions の step 名だけで切り分ける
- 成功時の詳細ログを出さず、失敗時だけ追加出力する

## Decision: preparation unit は reusable workflow と standalone trigger の両方に対応させる

**Rationale**: 同じ preparation logic を `ci.yml` の trusted path と、manual refresh /
default-branch warm-up の両方で共有したい。GitHub Docs の reusable workflow を使えば、
同じ build/publish logic を 1 か所にまとめたまま `workflow_call` と `workflow_dispatch`
を両立できる。

**Alternatives considered**:

- すべてを `ci.yml` 内の単発 job に閉じ込める
- default branch warm-up 用と PR 用で別々の build script を持つ

## Sources Reviewed

- GitHub-hosted runners overview: [docs.github.com/.../about-github-hosted-runners](https://docs.github.com/en/actions/how-tos/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners)
- GitHub dependency caching reference: [docs.github.com/.../dependency-caching](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching)
- GitHub workflow artifacts: [docs.github.com/.../workflow-artifacts](https://docs.github.com/en/actions/concepts/workflows-and-actions/workflow-artifacts)
- GitHub reusable workflows: [docs.github.com/.../reusing-workflow-configurations](https://docs.github.com/en/actions/concepts/workflows-and-actions/reusing-workflow-configurations)
- GitHub workflow triggers / `workflow_run`: [docs.github.com/.../events-that-trigger-workflows](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows?apiVersion=2022-11-28)
- GitHub Container registry: [docs.github.com/.../working-with-the-container-registry](https://docs.github.com/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- GitHub Packages permissions: [docs.github.com/.../about-permissions-for-github-packages](https://docs.github.com/en/packages/learn-github-packages/about-permissions-for-github-packages)
- Docker Buildx GitHub Actions cache backend: [docs.docker.com/build/cache/backends/gha/](https://docs.docker.com/build/cache/backends/gha/)
- Docker cache management with GitHub Actions: [docs.docker.com/build/ci/github-actions/cache/](https://docs.docker.com/build/ci/github-actions/cache/)
- Docker GitHub Actions overview: [docs.docker.com/build/ci/github-actions/](https://docs.docker.com/build/ci/github-actions/)
