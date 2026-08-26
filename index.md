---
layout: home

hero:
  name: Ruby Projects Handbook
  text: Do HTTP puro ao Rails. Você constrói.
  tagline: Em desenvolvimento. Projeto 1 no ar. Por IA com Vinícius Freire
  actions:
    - theme: brand
      text: Projetos e comandos
      link: /projetos
    - theme: alt
      text: Walkthrough
      link: /docs/01-http-api/01-o-problema
    - theme: alt
      text: GitHub
      link: https://github.com/alencarfreire/projetcs-ruby-handbook

features:
  - icon: 🛠️
    title: Projeto, não verbete
    details: Cada capítulo aponta para código que sobe. O rails-handbook é a teoria. Aqui você monta.

  - icon: 🔌
    title: HTTP puro primeiro
    details: Sem Rails, sem gem de web, sem banco. Task em Hash. O processo morre, os dados somem.

  - icon: 🚂
    title: Rails no bolso
    details: Depois, pet hotel com SQLite e has_secure_password. Telas, flash, request spec.

  - icon: 🎯
    title: Na entrevista
    details: Resposta falada. O que você diria no quadro — não o nome da gem.
---

## Estado

**Em desenvolvimento.** Fases 0–2 (HTTP API + pet hotel).

**Já dá para estudar**
- [Pasta, comandos e fonte](/projetos)
- Projeto 1: [código](/docs/01-http-api/codigo) · `ruby server.rb`
- Projeto 2: [models e auth](/docs/02-pet-hotel/codigo) · `bin/rails s`
- Walkthrough [1.1](/docs/01-http-api/01-o-problema) e [2.1](/docs/02-pet-hotel/01-o-problema)

**Recorte dos projetos 1 e 2**
- **1. HTTP API pura** — tasks, stdlib, memória. No ar
- **2. Pet hotel** — Rails, owners, pets, estadias. No ar

**Entra depois**
- 3. Pet hotel API-only + JSON + token
- 4. Hotwire (quadro de ocupação)
- 5. Sidekiq (lembrete e relatório)
- 6. Action Cable (painel ao vivo)
- 7. Docker Compose
- 8. System design do hotel

Detalhe no [roadmap](/roadmap).

## Sobre o projeto

Formato inspirado no [Ruby/Rails Interview Handbook](https://github.com/alencarfreire/ruby-handbook). Conteúdo novo, em pt-BR, escrito por IA com [Vinícius Freire](https://github.com/alencarfreire).

O código está no [GitHub](https://github.com/alencarfreire/projetcs-ruby-handbook).
