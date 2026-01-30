#!/bin/bash
set -euo pipefail

# Health Check Script
# Usage: ./health-check.sh <base-url>

BASE_URL=${1:-${BASE_URL:-http://localhost:8080}}

check_endpoint() {
  local endpoint=$1
  local url="$BASE_URL$endpoint"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url")

  if [ "$code" = "200" ]; then
    echo "✅ $endpoint OK (HTTP 200)"
  else
    echo "❌ $endpoint FAILED (HTTP $code)"
    return 1
  fi
}

echo "Running health checks against $BASE_URL"

check_endpoint "/health"
check_endpoint "/swagger/index.html"

if curl -s "$BASE_URL/health" | grep -q '"database":"ok"'; then
  echo "✅ Database connection OK"
else
  echo "⚠️ Database connection not confirmed"
fi

if curl -s "$BASE_URL/health" | grep -q '"cache":"ok"'; then
  echo "✅ Cache connection OK"
else
  echo "ℹ️ Cache not confirmed (may be disabled)"
fi

echo "Health checks completed"
