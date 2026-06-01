#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd jq
require_bench

if [ ! -f "$CONFIG_BACKUP" ]; then
  cp "$CONFIG" "$CONFIG_BACKUP"
fi

if [ ! -f "$PROCFILE_BACKUP" ]; then
  cp "$PROCFILE" "$PROCFILE_BACKUP"
fi

"$REPO_DIR/scripts/dragonfly-full-start.sh"
"$REPO_DIR/scripts/dragonfly-full-check.sh"

tmp="$(mktemp)"
jq \
  --arg cache "redis://127.0.0.1:$DFLY_CACHE_PORT" \
  --arg queue "redis://127.0.0.1:$DFLY_QUEUE_PORT" \
  --arg socketio "redis://127.0.0.1:$DFLY_SOCKETIO_PORT" \
  '.redis_cache = $cache | .redis_queue = $queue | .redis_socketio = $socketio' \
  "$CONFIG" > "$tmp"
mv "$tmp" "$CONFIG"

node_bin="$(command -v node || true)"
if [ -z "$node_bin" ]; then
  node_bin="node"
fi

cat > "$PROCFILE" <<PROCFILE
web: bench serve --port 8000
socketio: $node_bin apps/frappe/socketio.js
watch: bench watch
schedule: bench schedule
worker: bench worker 1>> logs/worker.log 2>> logs/worker.error.log
PROCFILE

touch "$MARKER"

echo "Dragonfly full replacement enabled."
echo "redis_cache    -> redis://127.0.0.1:$DFLY_CACHE_PORT"
echo "redis_queue    -> redis://127.0.0.1:$DFLY_QUEUE_PORT"
echo "redis_socketio -> redis://127.0.0.1:$DFLY_SOCKETIO_PORT"
