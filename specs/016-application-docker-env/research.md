# Research: Application Container Environments

## Decision: 各 application の Docker assets は `docker/applications/<application>/` に置く

**Rationale**: `graphql-gateway`、`command-api`、`query-api`、worker は deployment
boundary が異なる。Docker 定義を `docker/applications/` 配下の application ごとの
directory に集約すると、code directory と Docker ownership を分離しながら、
entrypoint、dependency、health contract の責務を一箇所に寄せられる。

**Alternatives considered**:

- 1 つの monolithic Dockerfile を build arg で切り替える
- `applications/backend/<application>/` に Dockerfile を同居させる

## Decision: local orchestration は `docker/applications/compose.yaml` に集約する

**Rationale**: 各 application が個別 Docker assets を持っても、local smoke と CI
contract では束ねて扱う場面がある。compose 定義を `docker/applications/` にまとめると、
application-scoped Docker assets と repository-wide orchestration を同じ Docker root に
置きつつ、shared dependency stack とは分離できる。

**Alternatives considered**:

- 各 application に独自 compose file を置く
- compose を持たず、すべて `docker run` 手順だけで扱う

## Decision: local / CI は同じ Dockerfile / target / entry contract を共有し、image artifact は共有必須にしない

**Rationale**: 再現性の正本を Dockerfile / target / entry contract に置くことで、
ローカル開発を registry や事前配布 image に依存させずに済む。CI でも同じ build
definition を使えるため、実装と検証の乖離を抑えられる。

**Alternatives considered**:

- local / CI で同じ生成済み image artifact を必須にする
- local / CI で別々の Docker 定義を許可する

## Decision: API service の canonical success signal は `HTTP readiness endpoint` とする

**Rationale**: `graphql-gateway`、`command-api`、`query-api` は外向き listener を持つ。
process 起動だけでは request 受付可否が分からないため、readiness endpoint を canonical
signal にする方が smoke test と運用監視が一貫する。

**Alternatives considered**:

- process 起動だけで成功とみなす
- service ごとに異なる success signal を許可する

## Decision: worker は `long-running consumer` を canonical run mode とし、success signal は stable-run とする

**Rationale**: worker は request/response service ではなく queue / subscription 待受の
常駐処理である。外向き HTTP endpoint を必須にせず、待受プロセスとしての安定稼働を
正本にした方が 012 の workflow runtime と整合する。

**Alternatives considered**:

- worker にも HTTP readiness endpoint を必須にする
- one-shot execution を canonical run mode にする

## Decision: `docker/firebase/` は application profile とは別の repository-wide shared dependency stack として扱う

**Rationale**: Firebase emulator stack は単一 application の所有物ではなく、複数 app が
参照する local dependency である。application container profile と同居させると、
shared dependency と deployable application の境界が曖昧になる。

**Alternatives considered**:

- 各 application compose に Firebase emulator 定義を埋め込む
- application feature の一部として emulator stack を再定義する
