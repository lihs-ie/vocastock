FROM haskell:9.2.8 AS builder

WORKDIR /workspace/applications/backend/billing-worker

COPY applications/backend/billing-worker/cabal.project cabal.project
COPY applications/backend/billing-worker/billing-worker.cabal billing-worker.cabal
COPY applications/backend/billing-worker/app app
COPY applications/backend/billing-worker/src src
COPY applications/backend/billing-worker/tests tests
COPY packages/haskell/vocas-worker-core /workspace/packages/haskell/vocas-worker-core

RUN env CABAL_DIR=/tmp/cabal cabal update
RUN env CABAL_DIR=/tmp/cabal cabal install exe:billing-worker \
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
