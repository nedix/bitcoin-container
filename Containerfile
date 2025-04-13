ARG ALPINE_VERSION=3.21
ARG BITCOIN_VERSION=28.1
ARG QUIX_SIGS_VERSION=ae8dc71e44c5da8dad678467b58f7bd701040b31
ARG S6_OVERLAY_VERSION=3.2.0.0
ARG STARTUP_TIMEOUT=30

FROM alpine:${ALPINE_VERSION} AS base

ARG S6_OVERLAY_VERSION

RUN apk add --virtual .build-deps \
        xz \
    && case "$(uname -m)" in \
        aarch64|arm*) \
            CPU_ARCHITECTURE="aarch64" \
        ;; x86_64) \
            CPU_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${CPU_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C / \
    && apk del .build-deps

FROM base AS bitcoin

ARG BITCOIN_VERSION
ARG QUIX_SIGS_VERSION

RUN apk add \
        autoconf \
        automake \
        boost-dev \
        build-base \
        chrpath \
        file \
        git \
        gnupg \
        libevent-dev \
        libressl \
        libtool \
        linux-headers \
        sqlite-dev \
        zeromq-dev

WORKDIR /tmp/guix.sigs/

RUN git init "$PWD" \
    && git remote add -f origin -t \* https://github.com/bitcoin-core/guix.sigs \
    && git checkout "$QUIX_SIGS_VERSION" \
    && gpg --import ./builder-keys/* \
    && rm -rf "$PWD"

WORKDIR /build/bitcoin/

RUN git init "$PWD" \
    && git remote add -f origin -t \* https://github.com/bitcoin/bitcoin.git \
    && git checkout "v${BITCOIN_VERSION}" \
    && git verify-tag "v${BITCOIN_VERSION}"

RUN ./autogen.sh \
    && ./configure \
        CXXFLAGS="-O2" \
        --prefix="/opt/bitcoin" \
        --disable-ccache \
        --disable-man \
        --disable-shared \
        --disable-tests \
        --enable-reduce-exports \
        --enable-static \
        --with-daemon \
        --with-sqlite=yes \
        --with-utils \
        --without-gui \
        --without-libs \
    && make -j$(( $(nproc) + 1 )) \
    && make install \
    && strip -v /opt/bitcoin/bin/bitcoin* \
    && sha256sum /opt/bitcoin/bin/bitcoin*

FROM base

RUN apk add --no-cache \
        libevent \
        libsodium \
        libstdc++ \
        libzmq \
        sqlite-libs

COPY --link --from=bitcoin /opt/bitcoin/bin/bitcoin*  /usr/local/bin/

COPY /rootfs/ /

ARG STARTUP_TIMEOUT
ENV STARTUP_TIMEOUT="$STARTUP_TIMEOUT"

ENTRYPOINT ["/entrypoint.sh"]

# REST
EXPOSE 8080

# RPC (mainnet, testnet, regnet)
EXPOSE 8332 18332 18443

# P2P (mainnet, testnet, regnet)
EXPOSE 8333 18333 18444

# ZMQ
EXPOSE 28332 28333

VOLUME /var/bitcoin
