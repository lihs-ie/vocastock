# Local AI provider stub

Run the backend workers locally without paid Anthropic / Stability API keys. The stub mirrors the wire format of both providers so the real worker → Pub/Sub → Firestore round-trip exercises real adapters end-to-end.

## Quick start

Three independent commands (run each in its own terminal):

```bash
# 1. Firebase emulators (Firestore + Auth + Storage + Pub/Sub)
bash scripts/firebase/start_emulators.sh

# 2. AI provider stub (writes .env.stub at repo root)
bash scripts/dev/start_stub_providers.sh

# 3. Backend services pointing at the stub
docker compose --env-file .env.stub -f docker/applications/compose.yaml up
```

After step 2 the launcher prints the chosen port, the env-file path, the PID, and the log paths. Tear down in any order:

```bash
docker compose -f docker/applications/compose.yaml down
bash scripts/dev/stop_stub_providers.sh
bash scripts/firebase/stop_emulators.sh
```

## What the stub returns

The script under `scripts/ci/e2e_stub_providers.mjs` (shared with the e2e CI smoke) serves three endpoints:

| Method + path | Response |
| --- | --- |
| `GET /readyz` | 200 `OK` |
| `POST /v1/messages` | 200 JSON in Anthropic Messages API shape; the `content[0].text` is a JSON string with the required `CompletedExplanationPayload` fields (`summary`, `senses[]`, `frequency`, `sophistication`, `pronunciation`, `etymology`, `similar_expressions`). |
| `POST /v1/generation/{engineId}/text-to-image` | 200 JSON in Stability shape; `artifacts[0].base64` is a 1×1 transparent PNG (≈100 bytes). The image-worker base64-decodes it and uploads the bytes to the Cloud Storage emulator. |
| anything else | 404 |

Both successful responses are deterministic — the same explanation payload and the same PNG land for every request. That is intentional (see "Limitations" below).

## Customisation

Override these env vars before running `start_stub_providers.sh`:

| Var | Default | Notes |
| --- | --- | --- |
| `VOCAS_STUB_PROVIDERS_PORT` | auto-pick free port | If you pin one, avoid colliding with compose-published ports (graphql-gateway 18180 / command-api 18181 / query-api 18182). |
| `VOCAS_STUB_LOG_DIR` | `${TMPDIR:-/tmp}/vocastock-stub` | Houses `stub.log`, `access.log`, `pid`. |
| `VOCAS_STUB_ENV_FILE` | `${REPO_ROOT}/.env.stub` | Path the launcher writes; pass to compose with `--env-file`. Gitignored. |

The launcher refuses to start a second instance while another one is running (PID file check). Use `stop_stub_providers.sh` to stop, or `kill` the printed PID.

## Verification

After step 2 in "Quick start", probe the stub directly:

```bash
PORT=$(awk -F: '/ANTHROPIC_API_BASE_URL/ {split($NF,a,"/"); print a[3]}' .env.stub)

curl -fsS "http://127.0.0.1:${PORT}/readyz"
# OK

curl -fsS -X POST "http://127.0.0.1:${PORT}/v1/messages" \
  -H 'content-type: application/json' \
  -d '{"model":"claude-3-haiku","max_tokens":1024,"messages":[]}'
# JSON with content[0].text containing the explanation payload

curl -fsS -X POST "http://127.0.0.1:${PORT}/v1/generation/stable-diffusion-v1-6/text-to-image" \
  -H 'content-type: application/json' \
  -d '{"text_prompts":[{"text":"test","weight":1}],"cfg_scale":7,"height":512,"width":512,"samples":1,"steps":30}' \
  | jq -r '.artifacts[0].base64' | base64 --decode | file -
# /dev/stdin: PNG image data, 1 x 1, ...
```

After step 3, drive the GraphQL gateway (`http://127.0.0.1:18180/graphql`) with `registerVocabularyExpression` / `requestExplanationGeneration` / `requestImageGeneration` mutations from your usual harness. Tail `${VOCAS_STUB_LOG_DIR:-/tmp/vocastock-stub}/access.log` to confirm the workers reach the stub:

```
2026-04-25T05:42:01.012Z POST /v1/messages
2026-04-25T05:42:03.456Z POST /v1/generation/stable-diffusion-v1-6/text-to-image
```

The completed explanation document and the uploaded image should appear under the actor's `vocabularyExpressions` / `images` collections in the Firestore emulator UI at `http://127.0.0.1:4000`.

## Limitations

- **Deterministic output.** Every request gets the same explanation body / same 1×1 PNG. No prompt-driven variance; not suitable for visual review or fixture diversity.
- **No streaming.** Anthropic streaming responses (`message_delta` chunks) are not modelled — the stub returns the final body in a single response. Adapters that rely on streaming would need to be tested against the live API.
- **No error injection.** The stub never returns 4xx/5xx (other than the 404 fallthrough); rate-limit / quota-exhausted / network-blip behaviour is unmodelled.
- **No latency simulation.** Responses are instant. The projection-lag window between command acceptance and Firestore write is exercised by the workers' real Pub/Sub poll interval (`VOCAS_WORKER_POLL_INTERVAL_SECONDS`), not by stub latency.
- **OpenAI is not stubbed.** The codebase declares `OPENAI_API_KEY` and `LLM_PROVIDER` env vars but no worker reads them today. If an OpenAI adapter ships later, this stub will need a corresponding endpoint.
- **Path-suffix Stability match.** The stub matches any `POST /v1/generation/*/text-to-image`, regardless of engine id. A future `image-to-image` call would 404; widen the match if/when it lands.

## CI usage (for reference)

`scripts/ci/run_e2e_round_trip_smoke.sh` boots the same stub on every PR run via the e2e CI smoke job. It writes its own access log under `.artifacts/ci/logs/`, exports `ANTHROPIC_API_BASE_URL` / `STABILITY_API_BASE_URL` to the chosen port, and tears the stub down via the script's `trap cleanup EXIT`. Local dev borrows the same Node script but layers a launcher / stopper around it so multi-terminal workflows are ergonomic.
