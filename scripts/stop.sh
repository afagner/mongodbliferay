#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

POD_NAME=liferay-prod

echo "Parando pod $POD_NAME..."
podman pod stop "$POD_NAME"
echo "Pod parado."
