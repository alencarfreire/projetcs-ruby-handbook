# Ruby Projects Handbook

> Projetos de bolso: HTTP puro, Rails, Roda. Código que roda + walkthrough em pt-BR de entrevista.

Trilhas 1–8 (Rails/hotel) e 9–15 (Roda/ingressos) no ar.

Site: https://alencarfreire.github.io/projetcs-ruby-handbook/

Não é o [rails-handbook](https://github.com/alencarfreire/ruby-handbook) de novo. Lá é teoria. Aqui você constrói.

## Sobre o livro

Cada projeto tem duas partes:

- **`projects/`** — app que sobe
- **`docs/`** — walkthrough, no tom de quadro e de entrevista

Formato inspirado no [Ruby/Rails Interview Handbook](https://github.com/alencarfreire/ruby-handbook). Conteúdo escrito do zero — não é tradução.

## Pasta

```
docs/01-http-api/                 walkthrough 1.1 → 1.7
docs/02-pet-hotel/                walkthrough 2.1 → 2.8
docs/03-pet-hotel-api/            walkthrough 3.1 → 3.8
docs/04-pet-hotel-hotwire/        walkthrough 4.1 → 4.6
docs/05-pet-hotel-sidekiq/        walkthrough 5.1 → 5.7
docs/06-pet-hotel-cable/          walkthrough 6.1 → 6.6
docs/07-pet-hotel-docker/         walkthrough 7.1 → 7.5
docs/08-system-design/            prática 8.1 → 8.6
projects/01-http-api/             HTTP puro
projects/02-pet-hotel/            Rails HTML
projects/03-pet-hotel-api/        Rails API + token
projects/04-pet-hotel-hotwire/    Turbo Frame/Stream
projects/05-pet-hotel-sidekiq/    Sidekiq + mail
projects/06-pet-hotel-cable/      Action Cable
projects/07-pet-hotel-docker/     Dockerfile + compose
docs/09-roda/                     walkthrough 9.1 → 9.6
docs/10-sequel/                   walkthrough 10.1 → 10.6
docs/11-roda-pragmatic/           A 11.1 → 11.7
docs/12-roda-modular/             B 12.1 → 12.6
docs/13-roda-arquiteturas/        C/D 13.1 → 13.5
docs/14-ingressos/                produto 14.1 → 14.7
docs/15-ingressos-ops/            compose 15.1 → 15.3
projects/09-roda-routing/         Roda, Hash
projects/10-sequel-sqlite/        Sequel, SQLite
projects/11-roda-pragmatic/       Roda + Sequel + Rodauth JWT
projects/12-roda-modular/         hash_routes
projects/14-ingressos/            lote, reserva, webhook
projects/15-ingressos-docker/     compose + perfil prod
```

## Já no ar

- [Projetos e comandos](projetos.md)
- [Código completo do projeto 1](docs/01-http-api/codigo.md) — `ruby server.rb`
- [Código do projeto 2](docs/02-pet-hotel/codigo.md) — `bin/rails s` (login `joao@email.com` / `senha123`)
- [Código da API](docs/03-pet-hotel-api/codigo.md) — Bearer + JSON
- [Código Hotwire](docs/04-pet-hotel-hotwire/codigo.md) — quadro em Frame
- [Código Sidekiq](docs/05-pet-hotel-sidekiq/codigo.md) — `redis-server` + worker
- [Código Cable](docs/06-pet-hotel-cable/codigo.md) — duas janelas
- [Dockerfile e compose](docs/07-pet-hotel-docker/codigo.md) — `docker compose up --build`
- [System design](docs/08-system-design/01-o-problema.md) — quadro, sem código
- [9 Roda](docs/09-roda/codigo.md) — `bundle exec puma`
- [10 Sequel](docs/10-sequel/codigo.md) — `ruby bin/seed`
- [11 A pragmática](docs/11-roda-pragmatic/codigo.md) — JWT + eventos
- [12 B hash_routes](docs/12-roda-modular/codigo.md) — eventos + locais
- [13 C e D](docs/13-roda-arquiteturas/01-mapa.md) — quadro
- [14 Ingressos](docs/14-ingressos/codigo.md) — reserva + webhook
- [15 Docker](docs/15-ingressos-ops/codigo.md) — `docker compose up --build`

## Recorte dos projetos

### 1. HTTP API pura (tasks)

Ruby 3.3+, stdlib (`socket` + `json`). Sem Rails, sem gem de web, sem banco. Store em memória. Recurso: Task (`id`, `title`, `completed`).

### 2. Pet hotel em Rails

Rails 8.1, SQLite, `has_secure_password`. Owners, pets, estadias. Telas HTML. Sem Devise, sem Hotwire, sem Sidekiq, sem API JSON.

### 3. Pet hotel API-only

Mesmo domínio. `api_only`. Token na tabela + Bearer. Sem JWT, sem Jbuilder.

### 4. Hotwire — quadro de ocupação

Turbo Frame no quadro. Stream no check-out. Outra aba não atualiza.

### 5. Sidekiq — lembrete e relatório

Check-in enfileira lembrete (`wait_until`). Rake `reports:daily`. Sem `sidekiq-cron`.

### 6. Action Cable — painel ao vivo

Duas janelas. Broadcast no check-in. Connection lê a session.

### 7. Docker Compose

Empacota o 5: web + worker + redis. SQLite no volume. Development.

### 8. System design

Quadro. Sem `projects/08`. Falha, consistência, escolha de cabo.

### 9–15. Trilha Roda (ingressos)

Independente da Pousada. Conceitos 9–13. Produto 14. Ops 15.

- **9** Roda sozinho: árvore `r.on "eventos"`, Hash
- **10** Sequel sozinho: `DB[:eventos]`, SQLite
- **11 A** Roda + Sequel + Rodauth JWT, um `app.rb`
- **12 B** `hash_branch` eventos e locais
- **13 C/D** hexagonal e dry-rb no quadro
- **14** produto: lote, reserva, webhook, jobs
- **15** compose web+worker+postgres+redis e perfil prod

Plano em [`roadmap.md`](roadmap.md) e [`SUMMARY.md`](SUMMARY.md).

## Como usar

**Para estudar:** abra o projeto, suba o servidor, leia o walkthrough na ordem. Cada capítulo aponta para o código.

**Antes da entrevista:** leia **Na entrevista** e rode os curls. O entrevistador quer ouvir o que você fez, não o nome da gem.

## Formato de cada capítulo

1. **TL;DR** — revisar rápido
2. **Conteúdo** — navegação
3. **O que é** / **Como funciona** / **Quando usar**
4. **Exemplo prático** — código do projeto
5. **Na entrevista** — resposta falada
6. **Exercícios práticos**

Regras em [`GUIDE.md`](GUIDE.md).

## Por onde começar

- [O problema e o recorte](docs/01-http-api/01-o-problema.md)
- [Como rodar o projeto 1](docs/01-http-api/codigo.md)
- [Roadmap](roadmap.md)

## Autoria

Escrito por IA com [Vinícius Freire](https://github.com/alencarfreire).

---

*Feito com 🤖 por [Vinícius Freire](https://github.com/alencarfreire)*
