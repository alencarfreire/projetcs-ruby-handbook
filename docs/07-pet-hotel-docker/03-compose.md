# 7.3 Compose: web, worker, redis

> **TL;DR**
> Três serviços. Mesma imagem no web e no worker. Redis é `redis:7-alpine`. Web publica 3000. Worker não publica porta. Os dois dependem do redis. `db:prepare` no command — a imagem não traz o SQLite.

## Conteúdo

- [Três serviços](#três-serviços)
- [A mesma imagem](#a-mesma-imagem)
- [depends_on](#depends_on)
- [command](#command)
- [O que o compose não faz](#o-que-o-compose-não-faz)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Três serviços

**O que é:**
Os três processos do 5, agora com nome.

**Como funciona:**

| Serviço | Processo | Porta |
|---|---|---|
| `web` | Puma | 3000:3000 |
| `worker` | Sidekiq | nenhuma |
| `redis` | Redis 7 | interna 6379 |

Worker sem porta: você não fala com ele por HTTP. Fala via Redis. Sidekiq Web UI não entra neste recorte.

**Na entrevista:**
> "Worker sem ports. Se eu publicar 3000 nos dois, colidem. O worker não é um servidor HTTP."

---

## A mesma imagem

**O que é:**
`build` idêntico nos dois. Command diferente.

**Como funciona:**
Compose builda uma vez (mesmo context). Web: `rails s`. Worker: `sidekiq -C config/sidekiq.yml`. Gemfile já tem sidekiq. Sem segunda Dockerfile.

**Na entrevista:**
> "Uma imagem, dois comandos. Eu não faço Dockerfile.worker."

---

## depends_on

**O que é:**
Ordem de **start**, não de ready.

**Como funciona:**
Web e worker `depends_on: redis`. Redis sobe primeiro. Redis “ready” é rápido. **Não** espera o `db:prepare` do web. Por isso o worker também roda `db:prepare`. Idempotente. Corrida: os dois migrando — SQLite aguenta o recorte. Postgres pediria um init container.

**Na entrevista:**
> "depends_on não é healthcheck. Redis up ≠ Rails migrated. Os dois preparam o banco."

---

## command

**O que é:**
Sobrescreve o CMD da imagem.

**Como funciona:**

```yaml
command: bash -c "bin/rails db:prepare && exec bin/rails s -b 0.0.0.0 -p 3000"
```

`exec` substitui o bash — sinal chega no Puma. Sem exec, Ctrl+C no compose às vezes atrasa.

Seed no `db:prepare` (development): João existe. Login seed funciona no browser.

**Na entrevista:**
> "db:prepare no start. A imagem não copia o sqlite. Volume vazio: cria, migra, seeda."

---

## O que o compose não faz

**O que é:**
A lista curta.

**Como funciona:**
Não sobe cron. Não espera o web ficar healthy para o worker. Não faz backup do volume. Não põe Nginx. Recorte de entrevista, não de SRE.

**Na entrevista:**
> "Compose de bolso. Produção é o 7.5 e o capítulo 8."

---

## Recapitulando

- web, worker, redis
- uma imagem
- depends_on ≠ ready
- db:prepare nos dois Rails
- worker sem porta

---

## Exercícios práticos

### Exercício 1: Worker com ports 3000

**Enunciado:** Você copia o bloco web para o worker e esquece de tirar ports. O que acontece?

<details>
<summary>Solução</summary>

Bind da 3000 duas vezes no host. Compose falha no segundo. Ou o worker tenta `rails s` se você copiou o command também. Olha o command. Sidekiq.

**Pontos-chave:**
- uma porta no host
- worker ≠ puma
- copiar bloco é o bug
</details>

### Exercício 2: image: em vez de build

**Enunciado:** Dá para publicar a imagem e o compose só dar `image:`?

<details>
<summary>Solução</summary>

Dá. Recorte local: `build`. Entrevista de CI: build no pipeline, compose de prod usa `image: ghcr.io/...`. Este livro não publica registry.

**Pontos-chave:**
- build local
- image remota
- take-home = build
</details>

---

*Parte do [Ruby Projects Handbook](/)*
