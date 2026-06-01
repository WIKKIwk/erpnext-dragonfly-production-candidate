#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$REPO_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$REPO_DIR/.env"
  set +a
fi

PROJECT_ROOT="${PROJECT_ROOT:-$REPO_DIR}"
BENCH_DIR="${BENCH_DIR:-$PROJECT_ROOT/frappe-bench}"
SITE_NAME="${SITE_NAME:-erpnext.localhost}"
ERP_URL="${ERP_URL:-http://$SITE_NAME:8000}"

DFLY_CACHE_PORT="${DFLY_CACHE_PORT:-13400}"
DFLY_QUEUE_PORT="${DFLY_QUEUE_PORT:-13401}"
DFLY_SOCKETIO_PORT="${DFLY_SOCKETIO_PORT:-13402}"

DFLY_CACHE_MAXMEMORY="${DFLY_CACHE_MAXMEMORY:-512mb}"
DFLY_QUEUE_MAXMEMORY="${DFLY_QUEUE_MAXMEMORY:-768mb}"
DFLY_SOCKETIO_MAXMEMORY="${DFLY_SOCKETIO_MAXMEMORY:-512mb}"

DFLY_DIR="${PROJECT_ROOT}/dragonfly-full"
CONFIG="${BENCH_DIR}/sites/common_site_config.json"
CONFIG_BACKUP="${BENCH_DIR}/sites/common_site_config.redis-backup.json"
PROCFILE="${BENCH_DIR}/Procfile"
PROCFILE_BACKUP="${BENCH_DIR}/Procfile.redis-backup"
MARKER="${PROJECT_ROOT}/.dragonfly-full-enabled"

export PATH="${EXTRA_PATH:-}:$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

require_bench() {
  [ -d "$BENCH_DIR" ] || {
    echo "BENCH_DIR does not exist: $BENCH_DIR" >&2
    exit 1
  }
  [ -f "$CONFIG" ] || {
    echo "Missing common_site_config.json: $CONFIG" >&2
    exit 1
  }
  [ -f "$PROCFILE" ] || {
    echo "Missing Procfile: $PROCFILE" >&2
    exit 1
  }
}
