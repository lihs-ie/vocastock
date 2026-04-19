FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install --yes --no-install-recommends netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY docker/applications/explanation-worker/entrypoint.sh /usr/local/bin/vocas-worker-entrypoint

RUN chmod +x /usr/local/bin/vocas-worker-entrypoint

ENTRYPOINT ["/usr/local/bin/vocas-worker-entrypoint"]
