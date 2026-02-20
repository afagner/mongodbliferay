# Liferay Prod – Ambiente Podman

Ambiente de produção com Liferay Portal, MongoDB, Elasticsearch e NGINX em um pod Podman.

**Desenvolvido por Alexandre Fagner – Smanager**

## Pré-requisitos

- **Podman** instalado ([podman.io](https://podman.io))
- No Windows: **Git Bash** ou **WSL** para executar os scripts

## Como iniciar o projeto

1. Abra o terminal na pasta do projeto:

   ```bash
   cd liferay-prod
   ```

2. Execute o script de inicialização:

   ```bash
   ./scripts/start.sh
   ```

   Ou, no Windows (PowerShell/CMD):

   ```bash
   bash scripts/start.sh
   ```

3. Aguarde a subida dos containers (MongoDB → Elasticsearch → Liferay → NGINX). **O Liferay leva 1 a 3 minutos para iniciar.** Só abra a URL depois desse tempo; se a página aparecer sem formatação (sem CSS), aguarde mais e recarregue (F5).

4. Acesse:

   - **Liferay (via NGINX):** http://localhost:8080

## Scripts disponíveis

| Script        | Descrição                                      |
|---------------|-------------------------------------------------|
| `scripts/start.sh`   | Cria network, pod e containers e inicia tudo   |
| `scripts/stop.sh`   | Para o pod e os containers                      |
| `scripts/restart.sh`| Para e inicia novamente                         |
| `scripts/status.sh` | Lista pods e containers do ambiente             |
| `scripts/reset.sh`  | Para tudo, remove containers, pod, volumes e network |

## Versões dos componentes

| Componente     | Imagem / versão |
|----------------|------------------|
| Liferay Portal | `liferay/portal:7.4.3.132-ga132` (CE) |
| MongoDB        | `mongo:7` |
| Elasticsearch  | `docker.elastic.co/elasticsearch/elasticsearch:8.13.0` |
| NGINX          | `nginx:alpine` |

## Serviços

| Serviço        | Porta externa | Hostname no pod   |
|----------------|----------------|--------------------|
| NGINX          | 8080           | nginx              |
| Liferay        | —              | liferay (8080)     |
| MongoDB        | —              | mongodb (27017)    |
| Elasticsearch  | —              | elasticsearch (9200) |

## Estrutura de pastas

```
liferay-prod/
  scripts/          # start, stop, restart, reset, status
  liferay/data/     # dados e portal-ext.properties
  liferay/deploy/   # artefatos para deploy
  liferay/logs/     # logs do Liferay
  mongodb/data/     # dados do MongoDB
  mongodb/init/     # script de criação do DB e usuário
  elasticsearch/data/
  nginx/conf.d/     # configuração do reverse proxy
```

## Liferay e MongoDB

O Liferay está configurado para usar o **MongoDB como store do Document Library** (armazenamento de arquivos). A configuração está em `liferay/data/portal-ext.properties`. Após alterar essa configuração, reinicie o Liferay: `./scripts/restart.sh` ou `podman start liferay` (com o pod já rodando).

## Credenciais (MongoDB)

- **Root:** `root` / `rootProd@123`
- **DB:** `lportal`
- **Usuário Liferay:** `liferay` / `liferayProd@123`

## Troubleshooting

- **Pod já existe:** use `./scripts/stop.sh` e depois `./scripts/start.sh`, ou `./scripts/reset.sh` para recriar tudo (apaga dados de MongoDB e Elasticsearch).
- **Porta 8080 em uso:** altere a porta do pod em `scripts/start.sh` (ex.: `-p 9090:80` e acesse http://localhost:9090).
- **Erro de permissão nos scripts:** `chmod +x scripts/*.sh` (Linux/macOS/Git Bash).
