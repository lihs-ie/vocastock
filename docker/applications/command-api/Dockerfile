FROM rust:bookworm AS builder

WORKDIR /workspace

COPY Cargo.toml Cargo.toml
COPY applications/backend/graphql-gateway applications/backend/graphql-gateway
COPY applications/backend/command-api applications/backend/command-api
COPY applications/backend/query-api applications/backend/query-api
COPY packages/rust/shared-auth packages/rust/shared-auth
COPY packages/rust/shared-runtime packages/rust/shared-runtime

RUN cargo build --release --bin command-api

FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

ENV VOCAS_SERVICE_HOST=0.0.0.0 \
    VOCAS_SERVICE_PORT=18181 \
    VOCAS_READINESS_PATH=/readyz

COPY --from=builder /workspace/target/release/command-api /usr/local/bin/command-api

EXPOSE 18181

ENTRYPOINT ["/usr/local/bin/command-api"]
