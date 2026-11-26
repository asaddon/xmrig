#!/bin/sh
set -e

# If the command passed is 'xmrig', shift it away to process arguments
if [ "$1" = "xmrig" ]; then
    shift
fi

# If direct flags or arguments are supplied, pass them straight to xmrig
if [ $# -gt 0 ]; then
    exec /usr/local/bin/xmrig "$@"
fi

# If pool and wallet address are provided via environment variables, construct the CLI command
if [ -n "$POOL_URL" ] && [ -n "$WALLET_ADDRESS" ]; then
    ARGS="-o ${POOL_URL} -u ${WALLET_ADDRESS} -p ${POOL_PASS:-${PASSWORD:-x}} --donate-level ${DONATE_LEVEL:-1} --http-host 0.0.0.0 --http-port ${HTTP_PORT:-18080}"
    [ -n "$RIG_ID" ] && ARGS="${ARGS} --rig-id ${RIG_ID}"
    [ -n "$ALGO" ] && ARGS="${ARGS} -a ${ALGO}"
    [ -n "$COIN" ] && ARGS="${ARGS} --coin ${COIN}"
    [ -n "$EXTRA_ARGS" ] && ARGS="${ARGS} ${EXTRA_ARGS}"
    # shellcheck disable=SC2086
    exec /usr/local/bin/xmrig $ARGS
fi

# Fallback: run xmrig with any local or default config.json
exec /usr/local/bin/xmrig "$@"
