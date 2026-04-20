FROM haskell:9.2.8 AS builder

WORKDIR /workspace/applications/backend/explanation-worker

COPY applications/backend/explanation-worker/cabal.project cabal.project
COPY applications/backend/explanation-worker/explanation-worker.cabal explanation-worker.cabal
COPY applications/backend/explanation-worker/app app
COPY applications/backend/explanation-worker/src src
COPY applications/backend/explanation-worker/tests/feature tests/feature
COPY applications/backend/explanation-worker/tests/support tests/support
COPY applications/backend/explanation-worker/tests/unit tests/unit

RUN env CABAL_DIR=/tmp/cabal cabal update
RUN env CABAL_DIR=/tmp/cabal cabal install exe:explanation-worker \
    --disable-tests \
    --install-method=copy \
    --installdir=/out \
    --overwrite-policy=always

FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates libffi8 libgmp10 netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/explanation-worker /usr/local/bin/explanation-worker
COPY docker/applications/explanation-worker/entrypoint.sh /usr/local/bin/vocas-worker-entrypoint

RUN chmod +x /usr/local/bin/vocas-worker-entrypoint /usr/local/bin/explanation-worker

ENTRYPOINT ["/usr/local/bin/vocas-worker-entrypoint"]
