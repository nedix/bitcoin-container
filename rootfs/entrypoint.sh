#!/usr/bin/env sh

: ${BLOCKSDIR:="/mnt/storage/blocks/"}
: ${CHAIN:="main"}
: ${CONF:="/etc/bitcoin/bitcoin.conf"}
: ${CONNECT}
: ${DATADIR:="/mnt/storage/data/"}
: ${DBCACHE}
: ${DEBUG}
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
: ${WALLETDIR:="/mnt/storage/wallets/"}
: ${WHITELIST}

# -------------------------------------------------------------------------------
#    Bootstrap bitcoin services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create bitcoin-daemon environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/bitcoin-daemon/environment/

    echo "$BLOCKSDIR"       > /run/bitcoin-daemon/environment/BLOCKSDIR
    echo "$CHAIN"           > /run/bitcoin-daemon/environment/CHAIN
    echo "$CONF"            > /run/bitcoin-daemon/environment/CONF
    echo "$CONNECT"         > /run/bitcoin-daemon/environment/CONNECT
    echo "$DATADIR"         > /run/bitcoin-daemon/environment/DATADIR
    echo "$DBCACHE"         > /run/bitcoin-daemon/environment/DBCACHE
    echo "$DEBUG"           > /run/bitcoin-daemon/environment/DEBUG
    echo "$DISABLEWALLET"   > /run/bitcoin-daemon/environment/DISABLEWALLET
    echo "$DISCOVER"        > /run/bitcoin-daemon/environment/DISCOVER
    echo "$DNSSEED"         > /run/bitcoin-daemon/environment/DNSSEED
    echo "$LISTEN"          > /run/bitcoin-daemon/environment/LISTEN
    echo "$MAXCONNECTIONS"  > /run/bitcoin-daemon/environment/MAXCONNECTIONS
    echo "$PRUNE"           > /run/bitcoin-daemon/environment/PRUNE
    echo "$RPCALLOWIP"      > /run/bitcoin-daemon/environment/RPCALLOWIP
    echo "$RPCPASSWORD"     > /run/bitcoin-daemon/environment/RPCPASSWORD
    echo "$RPCTHREADS"      > /run/bitcoin-daemon/environment/RPCTHREADS
    echo "$RPCUSER"         > /run/bitcoin-daemon/environment/RPCUSER
    echo "$TXINDEX"         > /run/bitcoin-daemon/environment/TXINDEX
    echo "$UPNP"            > /run/bitcoin-daemon/environment/UPNP
    echo "$WALLETBROADCAST" > /run/bitcoin-daemon/environment/WALLETBROADCAST
    echo "$WALLETDIR"       > /run/bitcoin-daemon/environment/WALLETDIR
    echo "$WHITELIST"       > /run/bitcoin-daemon/environment/WHITELIST

    # -------------------------------------------------------------------------------
    #    Create bitcoin-setup environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/bitcoin-setup/environment/

    echo "$BLOCKSDIR" > /run/bitcoin-setup/environment/BLOCKSDIR
    echo "$DATADIR"   > /run/bitcoin-setup/environment/DATADIR
    echo "$WALLETDIR" > /run/bitcoin-setup/environment/WALLETDIR
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
