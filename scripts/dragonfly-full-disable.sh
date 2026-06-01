#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_bench

if [ -f "$CONFIG_BACKUP" ]; then
  cp "$CONFIG_BACKUP" "$CONFIG"
else
  echo "Missing config backup: $CONFIG_BACKUP" >&2
  exit 1
fi

if [ -f "$PROCFILE_BACKUP" ]; then
  cp "$PROCFILE_BACKUP" "$PROCFILE"
else
  echo "Missing Procfile backup: $PROCFILE_BACKUP" >&2
  exit 1
fi

rm -f "$MARKER"
"$REPO_DIR/scripts/dragonfly-full-stop.sh"

echo "Dragonfly full replacement disabled and Redis Procfile restored."
