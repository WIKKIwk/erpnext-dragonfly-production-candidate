# Production Validation Report

Validation date: 2026-06-01.

## Scope

This report covers Dragonfly replacing ERPNext/Frappe Redis-compatible endpoints:

- cache
- queue
- socket.io

It also covers the Frappe client tracking fallback patch included in this repository.

## Environment

See `docs/tested-matrix.md`.

## Results

| Check | Result |
| --- | --- |
| Dragonfly cache PING | Passed |
| Dragonfly queue PING | Passed |
| Dragonfly socket.io PING | Passed |
| String command compatibility | Passed |
| Hash command compatibility | Passed |
| List command compatibility | Passed |
| Sorted set compatibility | Passed |
| Lua `EVAL` compatibility | Passed |
| Stream group compatibility | Passed |
| Pub/sub publish compatibility | Passed |
| RESP3 client tracking check | Passed |
| ERPNext HTTP health | Passed |
| ERPNext `clear-cache` | Passed |
| ERPNext worker health | Passed |
| ERPNext background job enqueue batch | Passed |
| 60-second soak loop | Passed |

Gate parameters:

```text
Queue jobs: 25
Soak: 60 seconds
Dragonfly instances: 3
Failed gate checks: 0
```

## Production Readiness Statement

For the tested environment in `docs/tested-matrix.md`, this Dragonfly setup is production-ready after the production gate passes.

The claim is scoped to this ERPNext/Frappe version, Dragonfly version, configuration, and workload shape. Custom apps, integrations, larger workloads, or future upstream changes must pass the same gate and a longer soak before being treated as covered.

## Next Validation Targets

- 24-hour soak with scheduled jobs enabled
- restart recovery test for all three Dragonfly instances
- queue durability test during service restart
- Redis/Valkey versus Dragonfly memory and latency comparison
- VPS validation with production process manager and backups
