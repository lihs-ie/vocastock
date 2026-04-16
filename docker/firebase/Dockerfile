FROM eclipse-temurin:21-jre-jammy

# Local host baseline is tracked separately in tooling/versions/approved-components.md.
ARG NODE_VERSION=24.14.1
ARG FIREBASE_TOOLS_VERSION=15.2.1

RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates curl git jq tini xz-utils \
  && rm -rf /var/lib/apt/lists/*

RUN arch="$(dpkg --print-architecture)" \
  && case "$arch" in \
    amd64) node_arch="x64" ;; \
    arm64) node_arch="arm64" ;; \
    *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
  esac \
  && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz" -o /tmp/node.tar.xz \
  && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
  && rm /tmp/node.tar.xz \
  && node --version | grep -q "v${NODE_VERSION}" \
  && npm install --global "firebase-tools@${FIREBASE_TOOLS_VERSION}" \
  && firebase --version | grep -q "^${FIREBASE_TOOLS_VERSION}$"

WORKDIR /workspace

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["firebase", "emulators:start", "--project", "demo-vocastock", "--config", "/workspace/firebase.json", "--only", "auth,firestore,storage,hosting,ui"]
