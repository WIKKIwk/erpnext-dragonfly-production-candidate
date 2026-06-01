#!/usr/bin/env bash
set -euo pipefail

systemctl --user disable --now erpnext-bench.service erpnext-dragonfly-cache.service erpnext-dragonfly-queue.service erpnext-dragonfly-socketio.service 2>/dev/null || true

rm -f "$HOME/.config/systemd/user/erpnext-bench.service"
rm -f "$HOME/.config/systemd/user/erpnext-dragonfly-cache.service"
rm -f "$HOME/.config/systemd/user/erpnext-dragonfly-queue.service"
rm -f "$HOME/.config/systemd/user/erpnext-dragonfly-socketio.service"

systemctl --user daemon-reload

echo "User systemd services removed."
