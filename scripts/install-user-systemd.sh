#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

UNIT_DIR="$HOME/.config/systemd/user"
mkdir -p "$UNIT_DIR"

env_file="$REPO_DIR/.env"
if [ ! -f "$env_file" ]; then
  echo "Missing $env_file. Copy .env.example to .env first." >&2
  exit 1
fi

require_cmd dragonfly
require_cmd bench
require_bench

dragonfly_bin="$(command -v dragonfly)"
bench_bin="$(command -v bench)"
service_path="${EXTRA_PATH:-}:$HOME/.local/bin:/usr/local/bin:/usr/bin"

cat > "$UNIT_DIR/erpnext-dragonfly-cache.service" <<UNIT
[Unit]
Description=ERPNext Dragonfly cache
After=default.target

[Service]
Type=simple
EnvironmentFile=$env_file
ExecStart=$dragonfly_bin --bind=127.0.0.1 --port=$DFLY_CACHE_PORT --dir=$PROJECT_ROOT/dragonfly-full/cache/data --dbfilename=dump --maxmemory=$DFLY_CACHE_MAXMEMORY --proactor_threads=2 --cache_mode=true
Restart=on-failure
RestartSec=2
LimitNOFILE=262144

[Install]
WantedBy=default.target
UNIT

cat > "$UNIT_DIR/erpnext-dragonfly-queue.service" <<UNIT
[Unit]
Description=ERPNext Dragonfly queue
After=default.target

[Service]
Type=simple
EnvironmentFile=$env_file
ExecStart=$dragonfly_bin --bind=127.0.0.1 --port=$DFLY_QUEUE_PORT --dir=$PROJECT_ROOT/dragonfly-full/queue/data --dbfilename=dump --maxmemory=$DFLY_QUEUE_MAXMEMORY --proactor_threads=2
Restart=on-failure
RestartSec=2
LimitNOFILE=262144

[Install]
WantedBy=default.target
UNIT

cat > "$UNIT_DIR/erpnext-dragonfly-socketio.service" <<UNIT
[Unit]
Description=ERPNext Dragonfly socket.io backend
After=default.target

[Service]
Type=simple
EnvironmentFile=$env_file
ExecStart=$dragonfly_bin --bind=127.0.0.1 --port=$DFLY_SOCKETIO_PORT --dir=$PROJECT_ROOT/dragonfly-full/socketio/data --dbfilename=dump --maxmemory=$DFLY_SOCKETIO_MAXMEMORY --proactor_threads=2
Restart=on-failure
RestartSec=2
LimitNOFILE=262144

[Install]
WantedBy=default.target
UNIT

cat > "$UNIT_DIR/erpnext-bench.service" <<UNIT
[Unit]
Description=ERPNext Frappe bench
After=erpnext-dragonfly-cache.service erpnext-dragonfly-queue.service erpnext-dragonfly-socketio.service
Requires=erpnext-dragonfly-cache.service erpnext-dragonfly-queue.service erpnext-dragonfly-socketio.service

[Service]
Type=simple
EnvironmentFile=$env_file
WorkingDirectory=$BENCH_DIR
Environment=PATH=$service_path
ExecStart=$bench_bin start
Restart=on-failure
RestartSec=5
LimitNOFILE=262144

[Install]
WantedBy=default.target
UNIT

systemctl --user daemon-reload
systemctl --user enable erpnext-dragonfly-cache.service erpnext-dragonfly-queue.service erpnext-dragonfly-socketio.service erpnext-bench.service

echo "User systemd services installed and enabled."
echo "Start with: systemctl --user start erpnext-bench.service"
