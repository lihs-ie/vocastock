FROM haskell:9.2.8 AS builder

WORKDIR /workspace/applications/backend/image-worker

COPY applications/backend/image-worker/cabal.project cabal.project
COPY applications/backend/image-worker/image-worker.cabal image-worker.cabal
COPY applications/backend/image-worker/app app
COPY applications/backend/image-worker/src src
COPY applications/backend/image-worker/tests/feature tests/feature
COPY applications/backend/image-worker/tests/support tests/support
COPY applications/backend/image-worker/tests/unit tests/unit

RUN env CABAL_DIR=/tmp/cabal cabal install exe:image-worker \
    --disable-tests \
    --install-method=copy \
    --installdir=/out \
    --overwrite-policy=always

FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates libffi8 libgmp10 netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/image-worker /usr/local/bin/image-worker
COPY docker/applications/image-worker/entrypoint.sh /usr/local/bin/vocas-worker-entrypoint

RUN chmod +x /usr/local/bin/vocas-worker-entrypoint /usr/local/bin/image-worker

ENTRYPOINT ["/usr/local/bin/vocas-worker-entrypoint"]
