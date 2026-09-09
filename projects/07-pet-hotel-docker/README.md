# 07 — Docker Compose do pet hotel

Empacota o projeto 5: web (Puma), worker (Sidekiq), Redis. Mesmo hotel. Sem Postgres. Sem `RAILS_ENV=production`. O recorte é três processos na sua máquina, agora em três containers.

```
projects/07-pet-hotel-docker/
  Dockerfile          imagem do 05
  compose.yml         web + worker + redis
  README.md
```

O código Rails **não** é copiado para cá. `build.context` aponta para `../05-pet-hotel-sidekiq`.

## O que você constrói

`docker compose up --build`. Browser em `http://127.0.0.1:3000`. Login seed. Worker consome a fila no Redis do compose. SQLite num volume — os dois processos Rails veem o mesmo Thor.

## O que você treina

- Dockerfile multi-camada raso: gems antes do código
- Compose: três serviços, uma rede
- `REDIS_URL=redis://redis:6379/0` — hostname é o nome do serviço
- Volume no `storage/` para o SQLite
- `db:prepare` no comando do web e do worker
- O que **não** é este compose: produção, Postgres, SECRET_KEY_BASE de verdade, asset compile

## Como rodar

Docker Desktop (ou Engine) no ar.

```bash
cd projects/07-pet-hotel-docker
docker compose up --build
```

Abre `http://127.0.0.1:3000`. Login: `joao@email.com` / `senha123`.

Relatório:

```bash
docker compose exec web bin/rails reports:daily
```

O worker no compose consome o job. Mail em `tmp/mails` **dentro** do container web/worker (não está no volume). Para ver: `docker compose exec worker ls tmp/mails` — se o mailer rodou no worker, a pasta é a do worker.

```bash
docker compose down
```

O volume `sqlite-data` sobrevive ao down. `down -v` apaga o Thor.

## O que NÃO entra (de propósito)

- Postgres
- `RAILS_ENV=production`
- Kamal, Kubernetes
- Nginx na frente
- Cron container (o rake continua manual / crontab da máquina)
