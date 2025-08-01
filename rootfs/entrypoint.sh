#!/usr/bin/env sh

: ${BLOCKSDIR:="/var/bitcoin/blocks/"}
: ${CHAIN:="main"}
: ${CONF:="/etc/bitcoin/bitcoin.conf"}
: ${CONNECT}
: ${DATADIR:="/var/bitcoin/data/"}
: ${DBCACHE}
: ${DISABLEWALLET}
: ${DISCOVER}
: ${DNSSEED}
: ${LISTEN}
: ${MAXCONNECTIONS}
: ${PRUNE}
: ${RPCALLOWIP:="172.16.0.0/12"}
: ${RPCPASSWORD}
: ${RPCTHREADS}
: ${RPCUSER}
: ${TXINDEX}
: ${UPNP}
: ${WALLETBROADCAST}
: ${WALLETDIR:="/var/bitcoin/wallets/"}
: ${WHITELIST}

mkdir -p \
    "$BLOCKSDIR" \
    "$DATADIR" \
    "$WALLETDIR" \
    "/var/log/bitcoin/"

chown nobody:nogroup \
    "/var/log/bitcoin/"

# -------------------------------------------------------------------------------
#    Bootstrap bitcoin services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create bitcoin environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/bitcoin/environment

    echo "$BLOCKSDIR"       > /run/bitcoin/environment/BLOCKSDIR
    echo "$CONF"            > /run/bitcoin/environment/CONF
    echo "$CHAIN"           > /run/bitcoin/environment/CHAIN
    echo "$CONNECT"         > /run/bitcoin/environment/CONNECT
    echo "$DATADIR"         > /run/bitcoin/environment/DATADIR
    echo "$DBCACHE"         > /run/bitcoin/environment/DBCACHE
    echo "$DISABLEWALLET"   > /run/bitcoin/environment/DISABLEWALLET
    echo "$DISCOVER"        > /run/bitcoin/environment/DISCOVER
    echo "$DNSSEED"         > /run/bitcoin/environment/DNSSEED
    echo "$LISTEN"          > /run/bitcoin/environment/LISTEN
    echo "$MAXCONNECTIONS"  > /run/bitcoin/environment/MAXCONNECTIONS
    echo "$PRUNE"           > /run/bitcoin/environment/PRUNE
    echo "$RPCALLOWIP"      > /run/bitcoin/environment/RPCALLOWIP
    echo "$RPCPASSWORD"     > /run/bitcoin/environment/RPCPASSWORD
    echo "$RPCTHREADS"      > /run/bitcoin/environment/RPCTHREADS
    echo "$RPCUSER"         > /run/bitcoin/environment/RPCUSER
    echo "$TXINDEX"         > /run/bitcoin/environment/TXINDEX
    echo "$UPNP"            > /run/bitcoin/environment/UPNP
    echo "$WALLETBROADCAST" > /run/bitcoin/environment/WALLETBROADCAST
    echo "$WALLETDIR"       > /run/bitcoin/environment/WALLETDIR
    echo "$WHITELIST"       > /run/bitcoin/environment/WHITELIST
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
