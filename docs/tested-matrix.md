# Tested Matrix

Last validated: 2026-06-01, Asia/Tashkent.

| Component | Tested Version / Value |
| --- | --- |
| OS | Fedora release 44 (Forty Four) |
| Kernel | 7.0.10-201.fc44.x86_64 |
| ERPNext | 16.20.0, version-16, `ff46d20` |
| Frappe | 16.19.0, version-16, `ba18090` |
| Bench mode | Local bench, no Docker |
| Site host | `erpnext.localhost` |
| ERPNext web | `127.0.0.1:8000` |
| ERPNext socket.io | `127.0.0.1:9000` |
| Dragonfly | v1.38.1 |
| Dragonfly cache | `127.0.0.1:13400`, cache mode |
| Dragonfly queue | `127.0.0.1:13401`, persistent mode |
| Dragonfly socket.io | `127.0.0.1:13402`, persistent mode |
| Redis compatibility advertised by Dragonfly | Redis 7.4.0 |
| Python | 3.14.5 |
| Node.js | v22.22.2 |

## Gate Result

Production gate: passed.

Command:

```bash
PROJECT_ROOT=/home/abdulfattox/Desktop/erpnext \
BENCH_DIR=/home/abdulfattox/Desktop/erpnext/frappe-bench \
SITE_NAME=erpnext.localhost \
ERP_URL=http://erpnext.localhost:8000 \
EXTRA_PATH=/home/abdulfattox/Desktop/erpnext/bin \
DRAGONFLY_GATE_QUEUE_JOBS=25 \
DRAGONFLY_GATE_SOAK_SECONDS=60 \
./scripts/production-gate.sh
```

Observed result:

```text
Dragonfly compatibility checks passed.
OK   Dragonfly compatibility
ERPNext Dragonfly full replacement health OK
OK   ERPNext health
OK   Dragonfly 13400 INFO
OK   Dragonfly 13400 memory
OK   Dragonfly 13401 INFO
OK   Dragonfly 13401 memory
OK   Dragonfly 13402 INFO
OK   Dragonfly 13402 memory
OK   ERPNext worker online after queue batch
OK   soak 60s
ERPNext Dragonfly production gate passed.
```
