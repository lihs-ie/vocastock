# CI ポリシー

## Required Checks

| Check | Workflow | Runner | Purpose |
|-------|----------|--------|---------|
| `toolchain-validate` | [ci.yml](/Users/lihs/workspace/vocastock/.github/workflows/ci.yml) | `ubuntu-24.04` | version catalog と CI toolchain の整合確認 |
| `flutter-static-checks` | [ci.yml](/Users/lihs/workspace/vocastock/.github/workflows/ci.yml) | `ubuntu-24.04` | `flutter doctor`、`dart analyze`、`flutter test` |
| `emulator-smoke` | [ci.yml](/Users/lihs/workspace/vocastock/.github/workflows/ci.yml) | `ubuntu-24.04` | Dockerized Firebase emulator の起動確認 |
| `android-build-smoke` | [ci.yml](/Users/lihs/workspace/vocastock/.github/workflows/ci.yml) | `ubuntu-24.04` | Android build の最小確認 |
| `vulnerability-scan` | [ci.yml](/Users/lihs/workspace/vocastock/.github/workflows/ci.yml) | `ubuntu-24.04` | `MEDIUM/HIGH/CRITICAL` 脆弱性 block |
| `ci-runtime-budget` | [ci.yml](/Users/lihs/workspace/vocastock/.github/workflows/ci.yml) | `ubuntu-24.04` | Linux CI aggregate が `30 分` 以内か検証 |
| `apple-build-smoke` | [apple-build.yml](/Users/lihs/workspace/vocastock/.github/workflows/apple-build.yml) | `macos-15` | iOS / macOS build の最小確認 |

## 保護ブランチ

| Branch Pattern | Enforcement |
|----------------|-------------|
| `main` | すべての required checks と 1 review を必須化 |
| `develop` | すべての required checks と 1 review を必須化 |
| `release/*` | すべての required checks と 1 review を必須化 |

## Ruleset Rollout

1. `gh auth status` で repository admin 権限を確認する
2. payload を確認する: [github_ruleset_payload.json](/Users/lihs/workspace/vocastock/scripts/ci/github_ruleset_payload.json)
3. 適用する:
   `bash scripts/ci/apply_github_ruleset.sh owner/repo`
4. 既存 ruleset を上書きする場合:
   `bash scripts/ci/apply_github_ruleset.sh owner/repo <ruleset_identifier>`
5. GitHub UI または `gh api repos/<owner>/<repo>/rulesets` で反映結果を確認する

## Rerun ポリシー

- required check が失敗した PR は merge しない
- flaky ではなく環境差分による失敗と判断した場合のみ rerun する
- rerun 前に `.artifacts/ci/logs/` の内容を確認する
- ruleset 変更時は、`main` へ入る前に `develop` 上で required checks 名が一致することを確認する

## actrun ローカル検証

- `ci.yml`:
  `actrun workflow run .github/workflows/ci.yml --local --include-dirty`
- `apple-build.yml`:
  `actrun workflow run .github/workflows/apple-build.yml --local --include-dirty`
- workflow は Node setup 以外を shell script 側へ寄せ、actrun でも同じ定義を解釈できるようにする

## Runtime Budget

- Linux 側の aggregate budget は `30 分`
- Apple build workflow も個別に `30 分` を超えないこと
- 予算計測は [check_ci_runtime_budget.sh](/Users/lihs/workspace/vocastock/scripts/ci/check_ci_runtime_budget.sh) が行う
- budget 超過時は build を green にせず、依存更新・job 分割・cache 戦略見直しを次変更で行う

## Artifact Handling

- CI が保持してよいのは maintainer 向けの log、duration、scan report のみ
- エンドユーザー向け成果物は CI artifact として公開しない
- Trivy 結果は `.artifacts/ci/logs/trivy-results.txt` に集約する
- duration 記録は `.artifacts/ci/durations/*.seconds` に統一する
