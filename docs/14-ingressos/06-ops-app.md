# 14.6 Jobs, log, Postgres

> **TL;DR**
> Sidekiq::Job, não ActiveJob. Expire e mail. Mail é arquivo em `tmp/mails`. Sem Redis o enqueue no-op — `bin/expire` cobre. `/up` pinga o DB. Log JSON no stdout: method, path, status, request_id, duration_ms. `DATABASE_URL` postgres ou sqlite.

## Conteúdo

- [Sidekiq sem Rails](#sidekiq-sem-rails)
- [Mail arquivo](#mail-arquivo)
- [/up e o log](#up-e-o-log)
- [DATABASE_URL](#database_url)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Sidekiq sem Rails

**O que é:**
`include Sidekiq::Job`. `jobs/sidekiq.rb` carrega DB e as classes. `REDIS_URL` liga o enqueue (`SidekiqOptional`).

**Como funciona:**
Na reserva, `perform_at(reserved_until)`. No pago, `perform_async` do mail. Sem Redis: jobs não enfileiram, regra continua via `bin/expire`. Teste não precisa do broker.

**Na entrevista:**
> "Roda não traz ActiveJob. Sidekiq::Job. O expire é a mesma classe do bin."

---

## Mail arquivo

**O que é:**
`IngressoMail` escreve `tmp/mails/pedido-ID.txt`. Sem SMTP. Sem ActionMailer.

**Como funciona:**
O job só manda se o pedido está `paid`. Replay de webhook não duplica o row; o job pode disparar de novo — recorte: arquivo sobrescreve. Produção: SMTP + idempotência de e-mail. Capítulo fala.

**Na entrevista:**
> "O mail é disco. Eu leio o arquivo. SMTP é env de produção, não gem neste take-home."

---

## /up e o log

**O que é:**
Saúde e rastro.

**Como funciona:**
`GET /up` → `{ "ok": true }` depois de `DB.test_connection`. Middleware `RequestLog` gera `X-Request-Id` (ou propaga). Uma linha JSON no stdout. Sem Datadog. Métrica = duration_ms no log.

**Na entrevista:**
> "up é o healthcheck do compose. request_id atravessa. APM é outro recorte. Eu não finjo Prometheus."

---

## DATABASE_URL

**O que é:**
`db.rb` escolhe. `postgres://` → `Sequel.connect`. Senão sqlite em `storage/`.

**Como funciona:**
Local default sqlite. Teste sqlite. Compose postgres. Migrations Sequel iguais. Gem `pg` no Gemfile mesmo quando você não sobe PG na máquina.

**Na entrevista:**
> "A URL decide o adapter. Dataset não muda. Eu não reescrevo ReservarLote para o Postgres."

---

## Recapitulando

- Sidekiq::Job
- bin/expire sempre
- mail em arquivo
- /up + request_id
- sqlite ou postgres

---

## Exercícios práticos

### Exercício 1: Production sem JWT_SECRET

**Enunciado:** O que o boot faz?

<details>
<summary>Solução</summary>

`IngressosEnv.jwt_secret` aborta. Compose prod recusa o interpolate `${JWT_SECRET:?...}`. Dois cadeados. Dev tem fallback. Production não.

**Pontos-chave:**
- env
- abort
- fallback só no dev
</details>

---

*Parte do [Ruby Projects Handbook](/)*
