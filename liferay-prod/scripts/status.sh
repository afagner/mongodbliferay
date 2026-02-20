#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Pods ==="
podman pod ps

echo ""
echo "=== Containers ==="
podman ps -a --filter pod=liferay-prod
