#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

SECONDS_TO_RUN="${1:-300}"
END_AT=$((SECONDS + SECONDS_TO_RUN))

require_cmd redis-cli
require_cmd curl
require_bench

cd "$BENCH_DIR"

while [ "$SECONDS" -lt "$END_AT" ]; do
  curl -fsSI "$ERP_URL" >/dev/null
  bench --site "$SITE_NAME" execute frappe.enqueue --kwargs '{"method":"frappe.ping","queue":"short","job_name":"dragonfly_soak_ping"}' >/tmp/erpnext-dragonfly-soak-enqueue.log 2>&1 || true
  bench --site "$SITE_NAME" doctor | grep -q "Workers online: 1"
  redis-cli -p "$DFLY_CACHE_PORT" PING >/dev/null
  redis-cli -p "$DFLY_QUEUE_PORT" PING >/dev/null
  redis-cli -p "$DFLY_SOCKETIO_PORT" PING >/dev/null
  sleep 10
done

echo "Soak test completed for ${SECONDS_TO_RUN}s"
