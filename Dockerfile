# Build Stage
FROM alpine:3.20 AS builder

RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    hwloc-dev \
    libuv-dev \
    linux-headers \
    openssl-dev

WORKDIR /xmrig

COPY . .

# Set DONATE_LEVEL via build arg: defaults to 1 (enabled like original), can be set to 0 to disable
ARG DONATE_LEVEL=1

RUN cmake -Bbuild \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_HWLOC=ON \
    -DWITH_TLS=ON \
    -DDONATE_LEVEL=${DONATE_LEVEL} \
    && cmake --build build -- -j$(nproc)

# Final Runtime Stage
FROM alpine:3.20

LABEL org.opencontainers.image.title="xmrig-moneroocean" \
      org.opencontainers.image.description="XMRig miner Docker image optimized for MoneroOcean pool algorithm switching" \
      org.opencontainers.image.url="https://github.com/asaddon/xmrig"

RUN apk add --no-cache \
    hwloc \
    libuv \
    openssl

WORKDIR /xmrig

COPY --from=builder /xmrig/build/xmrig /usr/local/bin/xmrig
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

# Environment variables for configuration
ENV POOL_URL="gulf.moneroocean.stream:20004" \
    WALLET_ADDRESS="4Arsu3rcec1Tnu3gFaNTY19FgzkAVyvasKHHi8myw2LaVGckXXpEe5h52s2JHGyMJXHUtB4Vkrw7PC2YabnmhbYwUtCc5e9" \
    POOL_PASS="x" \
    RIG_ID="" \
    ALGO="" \
    COIN="" \
    DONATE_LEVEL="1" \
    EXTRA_ARGS=""

EXPOSE 18080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["xmrig"]
