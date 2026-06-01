# Production Gate

Run the production gate against a configured ERPNext bench:

```bash
./scripts/production-gate.sh
```

The gate verifies:

- Dragonfly Redis compatibility for cache, queue, and socket.io ports
- Dragonfly server and memory info
- ERPNext HTTP health
- ERPNext `clear-cache`
- ERPNext worker health
- Background job enqueue batch
- Short soak loop with HTTP, cache, worker, and Dragonfly PING checks

Tunable parameters:

```bash
DRAGONFLY_GATE_QUEUE_JOBS=50 DRAGONFLY_GATE_SOAK_SECONDS=300 ./scripts/production-gate.sh
```

Passing this gate means the Dragonfly setup is production-ready for the tested ERPNext/Frappe version, configuration, and workload shape. The guarantee is scoped to that tested environment; custom apps, integrations, future upstream changes, and larger workloads must pass the same gate and soak tests before being treated as covered.
