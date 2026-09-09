# 15.2 Dockerfile e compose

> **TL;DR**
> Imagem Ruby, libpq + sqlite-dev, Gemfile primeiro, `COPY . .`. Web: migrate + seed + puma. Worker: migrate + sidekiq. Postgres 16. Redis 7. Volume no PG.

## Conteúdo

- [Dockerfile](#dockerfile)
- [web e worker](#web-e-worker)
- [postgres](#postgres)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Dockerfile

**O que é:**
A mesma imagem para web e worker. Command diferente.

**Como funciona:**
`libpq-dev` porque a gem `pg` compila. sqlite-dev para o default local — na imagem o compose usa postgres, mas o Gemfile tem as duas.

Gemfile.lock entra no context. Sem lock o Docker não reproduz.

**Na entrevista:**
> "Uma imagem, dois commands. pg no Gemfile mesmo se o laptop usa sqlite."

---

## web e worker

**O que é:**
Puma vs Sidekiq. Os dois `DATABASE_URL` iguais. Os dois `JWT_SECRET` iguais — o worker não valida JWT, mas o boot carrega `env.rb`.

**Como funciona:**
Web publica 9292. Worker sem porta. `SIDEKIQ=1` no web liga o enqueue.

**Na entrevista:**
> "Enqueue no Puma. Consume no worker. Sem worker a fila enche e o expire não corre — bin/expire ainda existe no exec."

---

## postgres

**O que é:**
O banco do compose. Volume `pg-data`. User/senha/db `ingressos`.

**Como funciona:**
`DATABASE_URL=postgres://ingressos:ingressos@postgres:5432/ingressos`. Hostname `postgres`. Local sem compose continua sqlite.

**Na entrevista:**
> "O volume é o Jazz. down -v zera. sqlite do laptop não é este postgres."

---

## Recapitulando

- libpq
- uma imagem
- PG no compose
- sqlite no laptop

---

## Exercícios práticos

### Exercício 1: COPY . antes do bundle

**Enunciado:** Dói?

<details>
<summary>Solução</summary>

Todo save de Ruby rebundla. Gemfile primeiro. Camada.

**Pontos-chave:**
- cache
- Gemfile.lock
</details>

---

*Parte do [Ruby Projects Handbook](/)*
