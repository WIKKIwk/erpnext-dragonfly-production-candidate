# Architecture

This setup keeps ERPNext/Frappe unchanged at the application boundary. Only the Redis-compatible services behind Frappe are changed.

## Services

```text
ERPNext/Frappe bench
  redis_cache    -> Dragonfly cache instance, cache mode
  redis_queue    -> Dragonfly queue instance, persistent mode
  redis_socketio -> Dragonfly socket.io instance, persistent mode
```

## Why Three Instances

ERPNext already separates cache, queue, and socket.io Redis endpoints. Keeping that separation makes rollback simpler and avoids mixing ephemeral cache pressure with queue data.

## Compatibility Patch

Frappe can enable Redis client-side tracking for local client cache invalidation. Some Dragonfly versions reject the exact command variant used by Frappe. The included patch marks Frappe's local client cache as unhealthy and lets normal Redis-compatible commands continue.

That means Dragonfly can still serve cache, queue, stream, and pub/sub workloads while Frappe falls back from client-side tracking.
