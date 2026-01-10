ARG ALPINE_VERSION=3.23
ARG BITCOIN_VERSION=29.2
ARG QUIX_SIGS_VERSION=da891fb3c964af486e8450daf3c908bd6e996815
ARG S6_OVERLAY_VERSION=3.2.1.0

FROM alpine:${ALPINE_VERSION} AS base

ARG S6_OVERLAY_VERSION

RUN apk add --virtual .build-deps \
        xz \
    && case "$(uname -m)" in \
        aarch64) \
            S6_OVERLAY_ARCHITECTURE="aarch64" \
        ;; arm*) \
            S6_OVERLAY_ARCHITECTURE="arm" \
        ;; x86_64) \
            S6_OVERLAY_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C / \
    && apk del .build-deps

FROM base AS bitcoin

ARG BITCOIN_VERSION
ARG QUIX_SIGS_VERSION

RUN apk add \
        boost-dev \
        build-base \
        chrpath \
        cmake \
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

RUN export CFLAGS="-O2 -g1" CPPFLAGS="-O2 -g1" CXXFLAGS="-O2 -g1" \
    && cmake \
        -B output \
        -DBUILD_CLI="ON" \
        -DBUILD_DAEMON="ON" \
        -DBUILD_GUI="OFF" \
        -DBUILD_SHARED_LIBS="OFF" \
        -DBUILD_TESTS="OFF" \
        -DBUILD_TX="ON" \
        -DBUILD_UTIL="ON" \
        -DBUILD_WALLET_TOOL="ON" \
        -DINSTALL_MAN="OFF" \
        -DREDUCE_EXPORTS="ON" \
        -DWITH_CCACHE="OFF" \
        -DWITH_SQLITE="ON" \
    && cmake \
        --build output \
        -j $(( $(nproc) + 1 )) \
    && strip -v /build/bitcoin/output/bin/bitcoin* \
    && sha256sum /build/bitcoin/output/bin/bitcoin*

FROM base

RUN apk add --no-cache \
        libevent \
        libsodium \
        libstdc++ \
        libzmq \
        sqlite-libs

COPY --link --from=bitcoin /build/bitcoin/output/bin/bitcoin*  /usr/local/bin/

COPY /rootfs/ /

ENV BLOCKSDIR="/mnt/storage/blocks/"
ENV DATADIR="/mnt/storage/data/"
ENV WALLETDIR="/mnt/storage/wallets/"

ENTRYPOINT ["/entrypoint.sh"]

# REST
EXPOSE 8080

# RPC (mainnet, testnet, regnet)
EXPOSE 8332 18332 18443

# P2P (mainnet, testnet, regnet)
EXPOSE 8333 18333 18444

# ZMQ
EXPOSE 28332 28333 28334 28335 28336

VOLUME /mnt/storage/
VOLUME /var/log/bitcoin/
