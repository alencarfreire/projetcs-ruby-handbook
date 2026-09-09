# Roadmap

Projetos de bolso. Código que roda + walkthrough. Tom do piloto (`docs/01-http-api/01-o-problema.md`) é lei.

Fases 0–16 feitas: hotel 1–8, conceitos Roda 9–13, produto ingressos 14, Docker 15.

## Fases

| Fase | O quê | Status |
|---|---|---|
| 0 | Repo, GUIDE, VitePress, piloto 1.1 + esqueleto `GET /tasks` | feito |
| 1 | Walkthrough 1.2–1.7 + API completa (verbos, 4xx, curls) | feito |
| 2 | Projeto 2 inteiro (Rails + walkthrough 2.1–2.8) | feito |
| 3 | Sidebar, Pages (`/projetcs-ruby-handbook/`), aviso do que falta | feito |
| 4 | Projeto 3 API-only + token + walkthrough 3.1–3.8 | feito |
| 5 | Projeto 4 Hotwire (quadro) + walkthrough 4.1–4.6 | feito |
| 6 | Projeto 5 Sidekiq + walkthrough 5.1–5.7 | feito |
| 7 | Projeto 6 Action Cable + walkthrough 6.1–6.6 | feito |
| 8 | Projeto 7 Docker Compose + walkthrough 7.1–7.5 | feito |
| 9 | Capítulo 8 system design (sem código) | feito |
| 10 | Roda sozinho (eventos no Hash) | feito |
| 11 | Sequel sozinho (eventos no SQLite) | feito |
| 12 | A pragmática: Roda + Sequel + Rodauth JWT | feito |
| 13 | B hash_routes (eventos + locais) | feito |
| 14 | C hexagonal e D dry-rb (quadro) | feito |
| 15 | Produto ingressos (lote, reserva, webhook, jobs) | feito |
| 16 | Docker + perfil produção dos ingressos | feito |

## Recortes

**Projeto 1 — HTTP API pura.** Tasks em memória. `socket` + `json`. Sem gem de web, sem SQL.

**Projeto 2 — Pet hotel.** Rails 8.1, SQLite, `has_secure_password`. CRUD de owners, pets, stays. Sem Hotwire, sem Sidekiq, sem API JSON.

**Projeto 3 — API-only.** Mesmo hotel. Bearer + `has_secure_token`. Sem JWT.

**Projeto 4 — Hotwire.** Frame no quadro. Stream no check-out. Sem Cable.

**Projeto 5 — Sidekiq.** Lembrete `wait_until`. Relatório via rake. Sem `sidekiq-cron`.

**Projeto 6 — Action Cable.** Painel ao vivo. Connection + `stream_for` user.

**Projeto 7 — Docker.** Compose web + worker + redis do 5. SQLite no volume.

**Capítulo 8 — System design.** Quadro. Sem `projects/08`.

**Projeto 9 — Roda.** Árvore, Hash, eventos. Sem Sequel.

**Projeto 10 — Sequel.** Dataset Hash, SQLite. Sem HTTP.

**Projeto 11 — A.** Roda + Sequel + Rodauth JWT.

**Projeto 12 — B.** hash_branch eventos e locais.

**Capítulo 13 — C/D.** Quadro. Sem pasta de app.

**Projeto 14 — Ingressos.** Lotes, reserva, webhook HMAC, denylist, Sidekiq, `/up`.

**Projeto 15 — Ops.** Compose web/worker/postgres/redis. Prod: secret + proxy.

**Ainda fora:** Stripe real, Kamal, Kubernetes, TLS Let's Encrypt no YAML.

## Regras de execução

- Um arquivo de walkthrough por vez. Sem dump de pasta.
- Não traduzir rails-handbook nem php-handbook. Escrever do zero.
- Walkthrough em `docs/`. Código em `projects/`. Não misturar.
- Projeto 1 = tasks. Projetos 2–8 = hotel. Projetos 9–15 = ingressos. Não cruzar domínio.
- Recortes independentes: o 2 não acumula o 4.
- Commit por fase, mensagem em inglês.
