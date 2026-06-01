#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

SOAK_SECONDS="${DRAGONFLY_GATE_SOAK_SECONDS:-60}"
QUEUE_JOBS="${DRAGONFLY_GATE_QUEUE_JOBS:-25}"

require_cmd redis-cli
require_cmd curl
require_bench

check() {
  local label="$1"
  shift
  if "$@"; then
    echo "OK   $label"
  else
    echo "FAIL $label" >&2
    exit 1
  fi
}

cd "$BENCH_DIR"

check "Dragonfly compatibility" "$REPO_DIR/scripts/dragonfly-full-check.sh"
check "ERPNext health" "$REPO_DIR/scripts/dragonfly-full-health.sh"

for port in "$DFLY_CACHE_PORT" "$DFLY_QUEUE_PORT" "$DFLY_SOCKETIO_PORT"; do
  check "Dragonfly $port INFO" bash -lc "redis-cli -p '$port' INFO server | grep -q '^dragonfly_version:'"
  check "Dragonfly $port memory" bash -lc "redis-cli -p '$port' INFO memory | grep -q '^used_memory:'"
done

echo "Enqueuing $QUEUE_JOBS background jobs through ERPNext..."
for i in $(seq 1 "$QUEUE_JOBS"); do
  enqueue_log="/tmp/erpnext-dragonfly-gate-enqueue-$i.log"
  if bench --site "$SITE_NAME" execute frappe.enqueue \
    --kwargs "{\"method\":\"frappe.ping\",\"queue\":\"short\",\"job_name\":\"dragonfly_gate_ping_$i\"}" \
    >"$enqueue_log" 2>&1; then
    :
  elif grep -q "Object of type <class 'rq.job.Job'>" "$enqueue_log"; then
    :
  else
    cat "$enqueue_log" >&2
      exit 1
  fi
done

sleep 3
check "ERPNext worker online after queue batch" bash -lc "bench --site '$SITE_NAME' doctor | grep -q 'Workers online: 1'"

end_at=$((SECONDS + SOAK_SECONDS))
while [ "$SECONDS" -lt "$end_at" ]; do
  curl -fsSI "$ERP_URL" >/dev/null
  bench --site "$SITE_NAME" clear-cache >/dev/null
  bench --site "$SITE_NAME" doctor | grep -q "Workers online: 1"
  redis-cli -p "$DFLY_CACHE_PORT" PING >/dev/null
  redis-cli -p "$DFLY_QUEUE_PORT" PING >/dev/null
  redis-cli -p "$DFLY_SOCKETIO_PORT" PING >/dev/null
  sleep 5
done

echo "OK   soak ${SOAK_SECONDS}s"
echo "ERPNext Dragonfly production gate passed."
