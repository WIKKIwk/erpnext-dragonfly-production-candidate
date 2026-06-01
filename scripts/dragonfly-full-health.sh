#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd redis-cli
require_cmd curl
require_bench

redis-cli -p "$DFLY_CACHE_PORT" PING >/dev/null
redis-cli -p "$DFLY_QUEUE_PORT" PING >/dev/null
redis-cli -p "$DFLY_SOCKETIO_PORT" PING >/dev/null

cd "$BENCH_DIR"

bench --site "$SITE_NAME" clear-cache >/dev/null
curl -fsSI "$ERP_URL" >/dev/null
bench --site "$SITE_NAME" doctor | grep -q "Workers online: 1"

echo "ERPNext Dragonfly full replacement health OK"
