#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd redis-cli

ports=("$DFLY_CACHE_PORT" "$DFLY_QUEUE_PORT" "$DFLY_SOCKETIO_PORT")
failures=0

check() {
  local label="$1"
  shift
  if "$@" >/dev/null; then
    echo "OK   $label"
  else
    echo "FAIL $label"
    failures=$((failures + 1))
  fi
}

redis_ok() {
  local port="$1"
  shift
  redis-cli -p "$port" "$@"
}

check_port() {
  local port="$1"
  local prefix="dfly:compat:$port"

  check "$port PING" redis_ok "$port" PING
  check "$port string SET/GET" bash -lc "redis-cli -p '$port' SET '$prefix:string' ok >/dev/null && [ \"\$(redis-cli -p '$port' GET '$prefix:string')\" = ok ]"
  check "$port hash HSET/HGET" bash -lc "redis-cli -p '$port' HSET '$prefix:hash' field value >/dev/null && [ \"\$(redis-cli -p '$port' HGET '$prefix:hash' field)\" = value ]"
  check "$port list LPUSH/BRPOP" bash -lc "redis-cli -p '$port' DEL '$prefix:list' >/dev/null && redis-cli -p '$port' LPUSH '$prefix:list' value >/dev/null && redis-cli -p '$port' BRPOP '$prefix:list' 1 | grep -q value"
  check "$port sorted-set ZADD/ZRANGE" bash -lc "redis-cli -p '$port' ZADD '$prefix:zset' 1 one >/dev/null && redis-cli -p '$port' ZRANGE '$prefix:zset' 0 -1 | grep -q one"
  check "$port lua EVAL" bash -lc "[ \"\$(redis-cli -p '$port' EVAL 'return redis.call(\"GET\", KEYS[1])' 1 '$prefix:string')\" = ok ]"
  check "$port stream XREADGROUP" bash -lc "redis-cli -p '$port' DEL '$prefix:stream' >/dev/null && redis-cli -p '$port' XGROUP CREATE '$prefix:stream' workers 0 MKSTREAM >/dev/null && id=\$(redis-cli -p '$port' XADD '$prefix:stream' '*' payload ok) && redis-cli -p '$port' XREADGROUP GROUP workers worker-1 COUNT 1 STREAMS '$prefix:stream' '>' | grep -q payload && redis-cli -p '$port' XACK '$prefix:stream' workers \"\$id\" >/dev/null"
  check "$port pubsub PUBLISH" bash -lc "redis-cli -p '$port' PUBLISH '$prefix:channel' hello >/dev/null"

  if redis-cli -3 -p "$port" CLIENT TRACKING ON >/dev/null 2>&1; then
    redis-cli -3 -p "$port" CLIENT TRACKING OFF >/dev/null 2>&1 || true
    echo "OK   $port client tracking RESP3"
  else
    echo "WARN $port client tracking RESP3 unsupported or syntax-limited"
  fi

  redis-cli -p "$port" DEL \
    "$prefix:string" \
    "$prefix:hash" \
    "$prefix:list" \
    "$prefix:zset" \
    "$prefix:stream" >/dev/null || true
}

for port in "${ports[@]}"; do
  check_port "$port"
done

if [ "$failures" -ne 0 ]; then
  echo "$failures compatibility checks failed." >&2
  exit 1
fi

echo "Dragonfly compatibility checks passed."
