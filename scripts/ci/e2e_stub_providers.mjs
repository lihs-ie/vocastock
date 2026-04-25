#!/usr/bin/env node
// Test-scope HTTP stub that pretends to be the Anthropic Messages API so
// the E2E round-trip smoke can exercise the real worker -> provider
// transport path without hitting the live endpoint. Used only from
// `scripts/ci/run_e2e_round_trip_smoke.sh` and kept under `scripts/ci/`
// so production binaries never link or reference it.
//
// Usage:
//   node scripts/ci/e2e_stub_providers.mjs [--port <port>] \
//     [--access-log <path>]
//
// - When `--port` is omitted the stub picks a free port and logs it as
//   `listening on <port>` on stdout so the driver can parse it.
// - Each incoming request is appended to the access log file (if the
//   `--access-log` flag is provided) in the form `ISO8601 METHOD PATH`.
// - Responds to:
//     GET  /readyz             -> 200 `OK`
//     POST /v1/messages        -> 200 JSON (Anthropic success body)
//     *                        -> 404
//
// Shutdown: SIGTERM / SIGINT close the server cleanly so the driver's
// trap can proceed with the rest of the cleanup steps.

import { createServer } from "node:http";
import { appendFile, mkdir } from "node:fs/promises";
import { dirname } from "node:path";

function parseArgs(argv) {
  const parsed = { port: 0, accessLogPath: null };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--port") {
      const value = argv[index + 1];
      if (!value) {
        throw new Error("--port requires a value");
      }
      parsed.port = Number.parseInt(value, 10);
      if (Number.isNaN(parsed.port)) {
        throw new Error(`invalid --port value: ${value}`);
      }
      index += 1;
    } else if (arg === "--access-log") {
      const value = argv[index + 1];
      if (!value) {
        throw new Error("--access-log requires a value");
      }
      parsed.accessLogPath = value;
      index += 1;
    } else {
      throw new Error(`unsupported argument: ${arg}`);
    }
  }
  return parsed;
}

// Success JSON payload mirroring ExplanationWorker.AnthropicAdapter's
// expected schema (summary / senses / frequency / sophistication /
// pronunciation / etymology / similar_expressions). The inner object is
// serialized into `content[0].text` exactly like the real Anthropic API
// returns it.
const explanationPayload = {
  summary: "E2E smoke explanation",
  senses: [
    { label: "smoke term", nuance: "a deterministic fixture used by CI" },
  ],
  frequency: "OFTEN",
  sophistication: "VERY_BASIC",
  pronunciation: { weak: "/smoke/", strong: "/SMOKE/" },
  etymology: "Introduced by the E2E smoke harness (specs/025).",
  similar_expressions: [
    {
      value: "synthetic",
      meaning: "manufactured for testing",
      comparison: "emphasises origin rather than behaviour",
    },
  ],
};

const anthropicSuccessBody = JSON.stringify({
  id: "msg_e2e_round_trip",
  content: [
    {
      type: "text",
      text: JSON.stringify(explanationPayload),
    },
  ],
});

async function appendAccessLog(accessLogPath, method, path) {
  if (!accessLogPath) {
    return;
  }
  await mkdir(dirname(accessLogPath), { recursive: true });
  const line = `${new Date().toISOString()} ${method} ${path}\n`;
  await appendFile(accessLogPath, line, "utf8");
}

async function drainBody(request) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    request.on("data", (chunk) => chunks.push(chunk));
    request.on("end", () => resolve(Buffer.concat(chunks)));
    request.on("error", reject);
  });
}

async function handleRequest(accessLogPath, request, response) {
  const method = request.method ?? "GET";
  const path = request.url ?? "/";

  await drainBody(request);
  await appendAccessLog(accessLogPath, method, path);

  if (method === "GET" && path === "/readyz") {
    response.writeHead(200, { "content-type": "text/plain" });
    response.end("OK");
    return;
  }

  if (method === "POST" && path === "/v1/messages") {
    response.writeHead(200, { "content-type": "application/json" });
    response.end(anthropicSuccessBody);
    return;
  }

  response.writeHead(404, { "content-type": "text/plain" });
  response.end("not found");
}

async function main() {
  const { port, accessLogPath } = parseArgs(process.argv.slice(2));

  const server = createServer((request, response) => {
    handleRequest(accessLogPath, request, response).catch((error) => {
      console.error("[e2e-stub] request handler failed:", error);
      try {
        response.writeHead(500, { "content-type": "text/plain" });
        response.end("internal error");
      } catch {
        // ignore — connection may already be closed
      }
    });
  });

  server.on("listening", () => {
    const address = server.address();
    if (address && typeof address === "object") {
      process.stdout.write(`listening on ${address.port}\n`);
    }
  });

  for (const signal of ["SIGINT", "SIGTERM"]) {
    process.on(signal, () => {
      server.close(() => process.exit(0));
    });
  }

  // Bind to all interfaces so that compose containers can reach the stub
  // via `host.docker.internal:host-gateway` (the bridge gateway IP, not
  // the host loopback). Local dev still reaches it via 127.0.0.1.
  server.listen(port, "0.0.0.0");
}

main().catch((error) => {
  console.error("[e2e-stub] failed to start:", error);
  process.exitCode = 1;
});
