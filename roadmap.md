# Roadmap

Projetos de bolso. Código que roda + walkthrough. Tom do piloto (`docs/01-http-api/01-o-problema.md`) é lei.

**Em desenvolvimento.** Fases 0–2 feitas. API-only, Hotwire, Sidekiq e o resto ainda vão entrar.

## Fases

| Fase | O quê | Status |
|---|---|---|
| 0 | Repo, GUIDE, VitePress, piloto 1.1 + esqueleto `GET /tasks` | feito |
| 1 | Walkthrough 1.2–1.7 + API completa (verbos, 4xx, curls) | feito |
| 2 | Projeto 2 inteiro (Rails + walkthrough 2.1–2.8) | feito |
| 3 | Sidebar, Pages (`/projetcs-ruby-handbook/`), aviso do que falta | em andamento |

## Já dá para estudar

**Piloto** — por que HTTP puro, recorte de tasks, esqueleto que lista `[]`.

## Recorte (fazer nas fases 1 e 2)

**Projeto 1 — HTTP API pura.** Tasks em memória. `socket` + `json`. Sem gem de web, sem SQL.

**Projeto 2 — Pet hotel.** Rails 7.1+, SQLite, `has_secure_password`. CRUD de owners, pets, stays. Index de quem está no hotel agora.

## Entra depois (não criar pasta)

- 3. Mesmo pet hotel, API-only + JSON + token (ou session API)
- 4. Hotwire: quadro de ocupação com Turbo Frame/Stream
- 5. Sidekiq: lembrete de check-out, relatório diário de ocupação
- 6. Action Cable: painel ao vivo de quem entrou/saiu
- 7. Docker Compose do pet hotel
- 8. System design do hotel (não é código — capítulo de prática)

## Regras de execução

- Um arquivo de walkthrough por vez. Sem dump de pasta.
- Não traduzir rails-handbook nem php-handbook. Escrever do zero.
- Walkthrough em `docs/`. Código em `projects/`. Não misturar.
- Projeto 1 = tasks. Projeto 2 = hotel. Não cruzar domínio.
- Sem commit até o piloto ser aprovado. Depois: commit por fase, mensagem em inglês.
- Piloto aprovado: seguir até o fim da fase pedida, sem parar no meio.
