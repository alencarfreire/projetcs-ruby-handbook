# Ruby Projects Handbook

> Projetos de bolso: do HTTP puro ao Rails. Código que roda + walkthrough em pt-BR de entrevista.

**Em desenvolvimento.** Projeto 1 (HTTP API pura) no ar. Pet hotel entra na fase 2.

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
projects/01-http-api/             código que sobe
  README.md                       comandos e curls
  bin/server
  server.rb
  lib/task_server.rb              TCP + HTTP
  lib/router.rb                   rotas
  lib/task_store.rb               Hash
```

## Já no ar (fases 0–1)

- [Projetos e comandos](projetos.md)
- [projects/01-http-api](projects/01-http-api) — `ruby server.rb`
- Walkthrough [1.1](docs/01-http-api/01-o-problema.md) → [1.7](docs/01-http-api/07-como-rodar.md)

## Recorte dos projetos 1 e 2

### 1. HTTP API pura (tasks)

Ruby 3.3+, stdlib (`socket` + `json`). Sem Rails, sem gem de web, sem banco. Store em memória. Recurso: Task (`id`, `title`, `completed`).

### 2. Pet hotel em Rails

Rails 7.1+, SQLite, `has_secure_password`. Owners, pets, estadias. Telas HTML. Sem Devise, sem Hotwire, sem Sidekiq, sem API JSON.

Entra na fase 2.

## Entra depois

- 3. Mesmo pet hotel, API-only + JSON + token
- 4. Hotwire: quadro de ocupação
- 5. Sidekiq: lembrete de check-out, relatório diário
- 6. Action Cable: painel ao vivo
- 7. Docker Compose do pet hotel
- 8. System design do hotel (capítulo de prática, sem código)

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
- [Como rodar o projeto 1](projects/01-http-api/README.md)
- [Roadmap](roadmap.md)

## Autoria

Escrito por IA com [Vinícius Freire](https://github.com/alencarfreire).

---

*Feito com 🤖 por [Vinícius Freire](https://github.com/alencarfreire)*
