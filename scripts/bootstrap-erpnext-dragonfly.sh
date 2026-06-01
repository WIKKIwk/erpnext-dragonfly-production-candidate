#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  cp "$REPO_DIR/.env.example" "$ENV_FILE"
  echo "Created $ENV_FILE from .env.example."
  echo "Edit it with your PROJECT_ROOT, BENCH_DIR, SITE_NAME, and ERP_URL, then run this script again." >&2
  exit 1
fi

# shellcheck disable=SC1091
. "$REPO_DIR/scripts/lib.sh"

if ! command -v dragonfly >/dev/null 2>&1; then
  "$REPO_DIR/scripts/install-dragonfly.sh"
fi

"$REPO_DIR/scripts/dragonfly-full-enable.sh"
"$REPO_DIR/scripts/install-user-systemd.sh"

systemctl --user restart erpnext-bench.service
"$REPO_DIR/scripts/dragonfly-full-health.sh"

echo "ERPNext is running with Dragonfly."
