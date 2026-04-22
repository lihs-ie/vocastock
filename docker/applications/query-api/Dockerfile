FROM rust:bookworm AS builder

WORKDIR /workspace

COPY Cargo.toml Cargo.toml
COPY applications/backend/graphql-gateway applications/backend/graphql-gateway
COPY applications/backend/command-api applications/backend/command-api
COPY applications/backend/query-api applications/backend/query-api
COPY packages/rust/shared-auth packages/rust/shared-auth
COPY packages/rust/shared-firestore packages/rust/shared-firestore
COPY packages/rust/shared-pubsub packages/rust/shared-pubsub
COPY packages/rust/shared-runtime packages/rust/shared-runtime

RUN cargo build --release --bin query-api

FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

ENV VOCAS_SERVICE_HOST=0.0.0.0 \
    VOCAS_SERVICE_PORT=18182 \
    VOCAS_READINESS_PATH=/readyz

COPY --from=builder /workspace/target/release/query-api /usr/local/bin/query-api

EXPOSE 18182

ENTRYPOINT ["/usr/local/bin/query-api"]
