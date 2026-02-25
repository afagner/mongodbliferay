#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# No Windows (Git Bash/MSYS), Podman precisa de caminhos no formato Windows nos volumes
# cygpath -w gera D:\path; usamos barras no resto para evitar segundo ':' antes de /data/db
VOLUME_ROOT="$PROJECT_ROOT"
if command -v cygpath &>/dev/null; then
  VOLUME_ROOT="$(cygpath -w "$PROJECT_ROOT" | sed 's/\\/\//g')"
fi

POD_NAME=liferay-prod
NET_NAME=liferay-prod-net

echo "[1/6] Criando network..."
podman network create "$NET_NAME" 2>/dev/null || true

echo "[2/6] Criando pod..."
podman pod create --name "$POD_NAME" --network "$NET_NAME" -p 8080:80

echo "[3/6] Criando containers..."
podman create --pod "$POD_NAME" --name mongodb \
  --restart=always \
  -v "$VOLUME_ROOT/mongodb/data:/data/db" \
  -v "$VOLUME_ROOT/mongodb/init:/docker-entrypoint-initdb.d:ro" \
  -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=rootProd@123 \
  mongo:7

podman create --pod "$POD_NAME" --name mysql \
  --restart=always \
  -v "$VOLUME_ROOT/mysql/data:/var/lib/mysql" \
  -v "$VOLUME_ROOT/mysql/init:/docker-entrypoint-initdb.d:ro" \
  -e MYSQL_ROOT_PASSWORD=rootProd@123 \
  -e MYSQL_DATABASE=lportal \
  -e MYSQL_USER=liferay \
  -e MYSQL_PASSWORD=liferayProd@123 \
  mysql:8.0

podman create --pod "$POD_NAME" --name elasticsearch \
  --restart=always \
  -v "$VOLUME_ROOT/elasticsearch/data:/usr/share/elasticsearch/data" \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0

podman create --pod "$POD_NAME" --name liferay \
  --restart=always \
  -v "$VOLUME_ROOT/liferay/data:/opt/liferay/data" \
  -v "$VOLUME_ROOT/liferay/deploy:/opt/liferay/deploy" \
  -v "$VOLUME_ROOT/liferay/logs:/opt/liferay/logs" \
  -e LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED=false \
  liferay/portal:7.4.3.132-ga132

podman create --pod "$POD_NAME" --name nginx \
  --restart=always \
  -v "$VOLUME_ROOT/nginx/conf.d:/etc/nginx/conf.d:ro" \
  nginx:alpine

echo "[4/6] Iniciando containers (ordem: mongodb, mysql, elasticsearch, liferay, nginx)..."
podman start mongodb
sleep 5
podman start mysql
sleep 10
podman start elasticsearch
sleep 5
podman start liferay
sleep 15
podman start nginx

echo "[6/6] Concluído."
echo "  Pod: $POD_NAME"
echo "  Acesso: http://localhost:8080"
echo ""
echo "  IMPORTANTE: O Liferay leva 1 a 3 minutos para subir por completo."
echo "  Aguarde antes de abrir a página; se abrir cedo, recarregue após 2 min."
