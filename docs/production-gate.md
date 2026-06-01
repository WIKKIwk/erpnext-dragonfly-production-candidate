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

Passing this gate means the Dragonfly setup is a production-ready candidate for the tested ERPNext/Frappe version and workload shape. It is not a blanket guarantee for every ERPNext app, custom integration, or future upstream change.
