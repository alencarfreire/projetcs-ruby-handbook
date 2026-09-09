# Projetos

Walkthrough é `docs/`. Código que sobe é `projects/`. Aqui está a pasta e o comando.

## Árvore

```
projects-ruby-handbook/
├── docs/
│   ├── 01-http-api/              walkthrough 1.1 → 1.7
│   ├── 02-pet-hotel/             walkthrough 2.1 → 2.8
│   ├── 03-pet-hotel-api/         walkthrough 3.1 → 3.8
│   ├── 04-pet-hotel-hotwire/     walkthrough 4.1 → 4.6
│   ├── 05-pet-hotel-sidekiq/     walkthrough 5.1 → 5.7
│   ├── 06-pet-hotel-cable/       walkthrough 6.1 → 6.6
│   ├── 07-pet-hotel-docker/      walkthrough 7.1 → 7.5
│   ├── 08-system-design/         prática 8.1 → 8.6
│   ├── 09-roda/                  9.1 → 9.6
│   ├── 10-sequel/                10.1 → 10.6
│   ├── 11-roda-pragmatic/        A
│   ├── 12-roda-modular/          B
│   ├── 13-roda-arquiteturas/     C/D
│   ├── 14-ingressos/             produto
│   └── 15-ingressos-ops/         compose
└── projects/
    ├── 01-http-api/              Ruby puro, stdlib
    ├── 02-pet-hotel/             Rails HTML
    ├── 03-pet-hotel-api/         Rails API + token
    ├── 04-pet-hotel-hotwire/     Turbo
    ├── 05-pet-hotel-sidekiq/     Sidekiq
    ├── 06-pet-hotel-cable/       Action Cable
    ├── 07-pet-hotel-docker/      Dockerfile + compose
    ├── 09-roda-routing/          Roda, Hash
    ├── 10-sequel-sqlite/         Sequel
    ├── 11-roda-pragmatic/        A JWT
    ├── 12-roda-modular/          B hash_routes
    ├── 14-ingressos/             lote, reserva, webhook
    └── 15-ingressos-docker/      compose + prod
```

## 1. HTTP API pura

Fonte na íntegra e como rodar, neste handbook: [código completo](/docs/01-http-api/codigo).

### Como rodar

```bash
cd projects/01-http-api
ruby server.rb
# ou
ruby bin/server
```

Sobe em `http://127.0.0.1:4567`. Sem `bundle`. Sem Gemfile. `Ctrl+C` zera o Hash.

### Comando que prova

```bash
curl -s http://127.0.0.1:4567/tasks
# []
```

CRUD, 4xx e o resto dos curls: [código completo](/docs/01-http-api/codigo).

### O que tem no arquivo

Três peças, três arquivos:

| Arquivo | Papel |
|---|---|
| `lib/task_server.rb` | TCPServer, lê HTTP, escreve HTTP |
| `lib/router.rb` | method + path |
| `lib/task_store.rb` | `@tasks` + `@next_id` |

Não é Rails. Sem Gemfile.

Walkthrough: [1.1](/docs/01-http-api/01-o-problema) → [1.7](/docs/01-http-api/07-como-rodar).

## Fonte — HTTP API

O mesmo código que está em `projects/01-http-api`. Sem sair do handbook.

### server.rb

<<< @/projects/01-http-api/server.rb

### bin/server

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../server"
TaskServer.new.start
```

### lib/task_server.rb

<<< @/projects/01-http-api/lib/task_server.rb

### lib/router.rb

<<< @/projects/01-http-api/lib/router.rb

### lib/task_store.rb

<<< @/projects/01-http-api/lib/task_store.rb

## 2. Pet hotel (Pousada do Thor)

Fonte e como rodar no handbook: [código do pet hotel](/docs/02-pet-hotel/codigo).

### Como rodar

```bash
cd projects/02-pet-hotel
bundle install
bin/rails db:prepare
bin/rails s
```

Abre `http://127.0.0.1:3000`. Login seed: `joao@email.com` / `senha123`.

```bash
bundle exec rspec
```

Walkthrough: [2.1](/docs/02-pet-hotel/01-o-problema) → [2.8](/docs/02-pet-hotel/08-como-rodar).

## 3. Pet hotel API-only

Fonte: [código da API](/docs/03-pet-hotel-api/codigo).

```bash
cd projects/03-pet-hotel-api
bundle install
bin/rails db:prepare
bin/rails s
```

`POST /api/v1/login` com `joao@email.com` / `senha123`. Copia o `token`. Header `Authorization: Bearer`.

Walkthrough: [3.1](/docs/03-pet-hotel-api/01-o-problema) → [3.8](/docs/03-pet-hotel-api/08-como-rodar).

## 4. Hotwire (quadro)

Fonte: [código Hotwire](/docs/04-pet-hotel-hotwire/codigo).

```bash
cd projects/04-pet-hotel-hotwire
bundle install
bin/rails db:prepare
bin/rails s
```

Login seed. Check-out no quadro. Outra aba não atualiza.

Walkthrough: [4.1](/docs/04-pet-hotel-hotwire/01-o-problema) → [4.6](/docs/04-pet-hotel-hotwire/06-como-rodar).

## 5. Sidekiq

Fonte: [código Sidekiq](/docs/05-pet-hotel-sidekiq/codigo).

```bash
redis-server
cd projects/05-pet-hotel-sidekiq
bundle install
bin/rails db:prepare
bin/rails s
# outro terminal:
bundle exec sidekiq
```

Relatório: `bin/rails reports:daily`. Specs sem Redis.

Walkthrough: [5.1](/docs/05-pet-hotel-sidekiq/01-o-problema) → [5.7](/docs/05-pet-hotel-sidekiq/07-como-rodar).

## 6. Action Cable

Fonte: [código Cable](/docs/06-pet-hotel-cable/codigo).

```bash
cd projects/06-pet-hotel-cable
bundle install
bin/rails db:prepare
bin/rails s
```

Duas janelas no `/`. Check-in numa, quadro pinta na outra.

Walkthrough: [6.1](/docs/06-pet-hotel-cable/01-o-problema) → [6.6](/docs/06-pet-hotel-cable/06-como-rodar).

## 7. Docker Compose

Fonte: [Dockerfile e compose](/docs/07-pet-hotel-docker/codigo). Empacota o 5.

```bash
cd projects/07-pet-hotel-docker
docker compose up --build
```

Walkthrough: [7.1](/docs/07-pet-hotel-docker/01-o-problema) → [7.5](/docs/07-pet-hotel-docker/05-como-rodar).

## 8. System design

Sem app. [8.1](/docs/08-system-design/01-o-problema) → [8.6](/docs/08-system-design/06-exercicio).

## 9. Roda sozinho

Fonte: [código](/docs/09-roda/codigo).

```bash
cd projects/09-roda-routing
bundle install
bundle exec puma
```

Walkthrough: [9.1](/docs/09-roda/01-o-problema) → [9.6](/docs/09-roda/06-como-rodar).

## 10. Sequel sozinho

Fonte: [código](/docs/10-sequel/codigo).

```bash
cd projects/10-sequel-sqlite
bundle install
bundle exec ruby bin/seed
bundle exec ruby examples/list.rb
```

Walkthrough: [10.1](/docs/10-sequel/01-o-problema) → [10.6](/docs/10-sequel/06-como-rodar).

## 11. A pragmática

Fonte: [código](/docs/11-roda-pragmatic/codigo).

```bash
cd projects/11-roda-pragmatic
bundle install
bundle exec ruby bin/migrate
bundle exec puma
```

Walkthrough: [11.1](/docs/11-roda-pragmatic/01-o-problema) → [11.7](/docs/11-roda-pragmatic/07-como-rodar).

## 12. B hash_routes

Fonte: [código](/docs/12-roda-modular/codigo).

```bash
cd projects/12-roda-modular
bundle install
bundle exec ruby bin/migrate
bundle exec puma
```

Walkthrough: [12.1](/docs/12-roda-modular/01-o-problema) → [12.6](/docs/12-roda-modular/06-como-rodar).

## 13. C e D

Sem app. [13.1](/docs/13-roda-arquiteturas/01-mapa) → [13.5](/docs/13-roda-arquiteturas/05-exercicio).

## 14. Ingressos

Fonte: [código](/docs/14-ingressos/codigo).

```bash
cd projects/14-ingressos
bundle install
bundle exec ruby bin/seed
bundle exec puma
bundle exec rake test
```

Walkthrough: [14.1](/docs/14-ingressos/01-o-problema) → [14.7](/docs/14-ingressos/07-como-rodar).

## 15. Docker ingressos

Fonte: [compose](/docs/15-ingressos-ops/codigo).

```bash
cd projects/15-ingressos-docker
docker compose up --build
```

Walkthrough: [15.1](/docs/15-ingressos-ops/01-o-problema) → [15.3](/docs/15-ingressos-ops/03-producao).
