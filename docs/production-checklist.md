# Production Checklist

- Apply the Frappe client tracking fallback patch.
- Confirm `dragonfly --version`.
- Confirm `redis-cli -p <port> PING` for all three Dragonfly instances.
- Run `./scripts/dragonfly-full-check.sh`.
- Run `./scripts/dragonfly-full-health.sh`.
- Run at least a short soak test before live traffic.
- Verify ERPNext login, desk load, background jobs, scheduler, socket.io updates, and long-running reports.
- Keep Redis/Valkey rollback files and database backups.
- Monitor Dragonfly memory, restarts, and queue depth.
