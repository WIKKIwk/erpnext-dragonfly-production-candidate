# User Systemd Units

The installer generates user-level systemd units dynamically from `.env`.

```bash
./scripts/install-user-systemd.sh
systemctl --user start erpnext-bench.service
systemctl --user status erpnext-bench.service
```

Generated units:

- `erpnext-dragonfly-cache.service`
- `erpnext-dragonfly-queue.service`
- `erpnext-dragonfly-socketio.service`
- `erpnext-bench.service`
