#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

POD_NAME=liferay-prod
NET_NAME=liferay-prod-net

echo "Parando pod e containers..."
podman pod stop "$POD_NAME" 2>/dev/null || true
podman rm -f mongodb elasticsearch liferay nginx 2>/dev/null || true
podman pod rm -f "$POD_NAME" 2>/dev/null || true

echo "Removendo volumes (conteúdo em mongodb/data e elasticsearch/data)..."
find "$PROJECT_ROOT/mongodb/data" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT/elasticsearch/data" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
# Descomente para reset total do Liferay:
# rm -rf "$PROJECT_ROOT/liferay/data"/*
# rm -rf "$PROJECT_ROOT/liferay/deploy"/*
# rm -rf "$PROJECT_ROOT/liferay/logs"/*

echo "Removendo network..."
podman network rm "$NET_NAME" 2>/dev/null || true

echo "Reset concluído."
