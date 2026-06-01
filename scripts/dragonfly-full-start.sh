#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd dragonfly
require_cmd redis-cli

start_instance() {
  local name="$1"
  local port="$2"
  local mode="${3:-persistent}"
  local maxmemory="${4:-768mb}"
  local instance_dir="$DFLY_DIR/$name"
  local pid_file="$instance_dir/$name.pid"
  local log_file="$instance_dir/$name.log"
  local args=(
    --bind=127.0.0.1
    --port="$port"
    --dir="$instance_dir/data"
    --dbfilename=dump
    --maxmemory="$maxmemory"
    --proactor_threads=2
  )

  mkdir -p "$instance_dir/data"

  if ss -ltn | grep -q ":$port "; then
    echo "Dragonfly $name port $port is already in use."
    return 0
  fi

  if [ "$mode" = "cache" ]; then
    args+=(--cache_mode=true)
  fi

  setsid dragonfly "${args[@]}" > "$log_file" 2>&1 < /dev/null &
  echo "$!" > "$pid_file"

  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if redis-cli -p "$port" PING >/dev/null 2>&1; then
      echo "Dragonfly $name started on 127.0.0.1:$port"
      return 0
    fi
    sleep 0.2
  done

  echo "Dragonfly $name did not answer on port $port. Log: $log_file" >&2
  return 1
}

start_instance cache "$DFLY_CACHE_PORT" cache "$DFLY_CACHE_MAXMEMORY"
start_instance queue "$DFLY_QUEUE_PORT" persistent "$DFLY_QUEUE_MAXMEMORY"
start_instance socketio "$DFLY_SOCKETIO_PORT" persistent "$DFLY_SOCKETIO_MAXMEMORY"
