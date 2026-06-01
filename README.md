# ERPNext Dragonfly Production Candidate

Experimental tooling for running ERPNext/Frappe with Dragonfly as a Redis-compatible backend.

This repository provides a second production candidate path, not an upstream-supported ERPNext default. It is intended for controlled testing before live use.

## What It Replaces

Default ERPNext benches usually use separate Redis services for cache, queue, and socket.io. This setup runs three Dragonfly instances instead:

```text
redis_cache    -> redis://127.0.0.1:13400
redis_queue    -> redis://127.0.0.1:13401
redis_socketio -> redis://127.0.0.1:13402
```

## Current Status

- Full Redis endpoint replacement: experimental production candidate
- Cache-only Dragonfly mode: lower-risk candidate
- ERPNext/Frappe client tracking fallback patch: required for tested Frappe versions that reject Dragonfly's client tracking behavior
- Docker is not required

## Requirements

- A working ERPNext/Frappe bench
- `redis-cli`
- `jq`
- `curl`
- user-level `systemd` for service mode

## Quick Start

Install Dragonfly from the official upstream release:

```bash
./scripts/install-dragonfly.sh
```

Copy `.env.example` to `.env` and adjust paths:

```bash
cp .env.example .env
```

Enable full Dragonfly replacement:

```bash
./scripts/dragonfly-full-enable.sh
```

Install and start user systemd services:

```bash
./scripts/install-user-systemd.sh
systemctl --user start erpnext-bench.service
```

Check health:

```bash
./scripts/dragonfly-full-health.sh
```

Run a soak test:

```bash
./scripts/dragonfly-full-soak-test.sh 300
```

One-command bootstrap after `.env` is configured:

```bash
./scripts/bootstrap-erpnext-dragonfly.sh
```

Rollback:

```bash
./scripts/dragonfly-full-disable.sh
./scripts/uninstall-user-systemd.sh
```

## Frappe Patch

Apply the patch in `patches/frappe-dragonfly-client-tracking-fallback.patch` inside your Frappe app repository:

```bash
cd /path/to/frappe-bench/apps/frappe
git apply /path/to/erpnext-dragonfly-production-candidate/patches/frappe-dragonfly-client-tracking-fallback.patch
```

The patch keeps Frappe running when Dragonfly rejects the Redis client tracking command variant used by Frappe.

## Safety Notes

- Do not run this on a critical production instance without backups and a rollback window.
- Keep queue and socket.io Dragonfly instances persistent.
- Cache can run with `--cache_mode=true`.
- Validate background jobs with `bench --site <site> doctor` and an enqueue test.
- Keep Redis/Valkey backups until the Dragonfly path has survived real workload testing.

## License

The tooling in this repository is released under the MIT License. Dragonfly, ERPNext, and Frappe have their own licenses. This repository does not redistribute Dragonfly binaries.
