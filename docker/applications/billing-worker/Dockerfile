# syntax=docker/dockerfile:1.7
FROM haskell:9.2.8 AS builder

WORKDIR /workspace/applications/backend/billing-worker

# Stage 1: copy cabal manifests only so the cabal update layer is cached
# until any cabal file changes.
COPY applications/backend/billing-worker/cabal.project cabal.project
COPY applications/backend/billing-worker/billing-worker.cabal billing-worker.cabal
COPY packages/haskell/vocas-worker-core/vocas-worker-core.cabal /workspace/packages/haskell/vocas-worker-core/vocas-worker-core.cabal

# CABAL_DIR points at a BuildKit cache mount whose id is shared across the
# 3 worker Dockerfiles, so the package store is reused between them and
# (when --cache-to=type=gha,mode=max is configured) across CI runs.
RUN --mount=type=cache,target=/tmp/cabal,sharing=locked,id=vocas-cabal-store \
    env CABAL_DIR=/tmp/cabal cabal update

# Stage 2: copy the source files.
COPY applications/backend/billing-worker/app app
COPY applications/backend/billing-worker/src src
COPY applications/backend/billing-worker/tests tests
COPY packages/haskell/vocas-worker-core /workspace/packages/haskell/vocas-worker-core

RUN --mount=type=cache,target=/tmp/cabal,sharing=locked,id=vocas-cabal-store \
    --mount=type=cache,target=/workspace/applications/backend/billing-worker/dist-newstyle,id=vocas-cabal-dist-billing \
    env CABAL_DIR=/tmp/cabal cabal install exe:billing-worker \
    --disable-tests \
    --install-method=copy \
    --installdir=/out \
    --overwrite-policy=always \
    --project-file=cabal.project

FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates libffi8 libgmp10 netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/billing-worker /usr/local/bin/billing-worker
COPY docker/applications/billing-worker/entrypoint.sh /usr/local/bin/vocas-worker-entrypoint

RUN chmod +x /usr/local/bin/vocas-worker-entrypoint /usr/local/bin/billing-worker

ENTRYPOINT ["/usr/local/bin/vocas-worker-entrypoint"]
