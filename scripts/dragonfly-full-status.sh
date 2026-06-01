#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

echo "Config:"
jq '.redis_cache, .redis_queue, .redis_socketio' "$CONFIG"

echo
echo "Ports:"
ss -ltnp | grep -E ":(${DFLY_CACHE_PORT}|${DFLY_QUEUE_PORT}|${DFLY_SOCKETIO_PORT}|8000|9000)\b" || true

echo
echo "Dragonfly:"
redis-cli -p "$DFLY_CACHE_PORT" INFO server | sed -n '1,12p'
redis-cli -p "$DFLY_QUEUE_PORT" INFO server | sed -n '1,12p'
redis-cli -p "$DFLY_SOCKETIO_PORT" INFO server | sed -n '1,12p'

echo
echo "Bench:"
cd "$BENCH_DIR"
bench --site "$SITE_NAME" doctor
