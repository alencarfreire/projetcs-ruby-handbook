# 5.2 Redis + Sidekiq + Active Job

> **TL;DR**
> Active Job é a interface. Sidekiq é o adapter. Redis é o broker. Em test, adapter `:test` — array na memória, sem Redis. Em development/production, `:sidekiq`. `config/sidekiq.yml` lista as filas `default` e `mailers`.

## Conteúdo

- [Active Job](#active-job)
- [O adapter](#o-adapter)
- [Redis](#redis)
- [sidekiq.yml](#sidekiqyml)
- [O initializer](#o-initializer)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Active Job

**O que é:**
A API do Rails. `perform_later`, `set(wait_until:)`, `ApplicationJob`. Você não chama `Sidekiq::Worker` neste recorte.

**Como funciona:**

```ruby
CheckoutReminderJob.set(wait_until: reminder_at).perform_later(stay.id)
```

Trocar Sidekiq por Solid Queue no futuro: o controller não muda. O adapter muda. Entrevista puxa isso.

**Quando usar:**
Sempre no Rails 4.2+. Sidekiq puro existe. Recorte: Active Job.

**Na entrevista:**
> "perform_later é Active Job. Sidekiq está embaixo. Se a vaga pede include Sidekiq::Worker, eu falo o trade-off: mais opções, menos portabilidade."

---

## O adapter

**O que é:**
Quem executa.

**Como funciona:**

| Env | Adapter | Redis? |
|---|---|---|
| test | `:test` | não |
| development | `:sidekiq` | sim |
| production | `:sidekiq` | sim |

`:async` rodaria no processo do Puma. Morre no `Ctrl+C`. Mentira para o recorte de três processos.

`:inline` roda na hora, no request. O POST esperaria o mail. Pior.

**Na entrevista:**
> "Test não sobe Redis. :test guarda o job num array. have_enqueued_job lê esse array."

---

## Redis

**O que é:**
A lista. Persistência da fila. Não é cache neste recorte — é broker.

**Como funciona:**
`REDIS_URL` default `redis://localhost:6379/0`. Sem Redis no ar, `perform_later` em development explode. Specs não. README: `redis-server` primeiro.

**Quando usar:**
Sidekiq exige. Adapter async não.

**Na entrevista:**
> "Redis é a fila. SQLite é o hotel. Eu não guardo Stay no Redis."

---

## sidekiq.yml

**O que é:**
Concurrency e filas que o processo escuta.

**Como funciona:**

```yaml
:concurrency: 5
:queues:
  - default
  - mailers
```

Jobs de mail: `queue_as :mailers`. Se o yml só tiver `default`, o mailer job fica parado. Entrevista clássica.

Sobe: `bundle exec sidekiq`. Lê o yml sozinho se estiver no lugar certo; senão `-C config/sidekiq.yml`.

**Na entrevista:**
> "queue_as mailers. O processo tem que escutar mailers. Fila errada é job invisível, não erro."

---

## O initializer

**O que é:**
URL do Redis no client e no server.

**Como funciona:**

```ruby
redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
Sidekiq.configure_server { |c| c.redis = { url: redis_url } }
Sidekiq.configure_client { |c| c.redis = { url: redis_url } }
```

Puma é **client** (enfileira). Sidekiq é **server** (consome). Os dois precisam da URL. Docker no 7 seta `REDIS_URL=redis://redis:6379/0`.

**Na entrevista:**
> "Client e server. Puma não é o worker. Os dois apontam para o mesmo Redis."

---

## Recapitulando

- Active Job na boca, Sidekiq embaixo
- `:test` no spec, `:sidekiq` no resto
- Redis = fila
- Filas no yml têm que incluir `mailers`

---

## Exercícios práticos

### Exercício 1: Job some

**Enunciado:** Check-in 200. Sidekiq UI (se tivesse) não mostra o job. Três suspeitas?

<details>
<summary>Solução</summary>

1. Adapter ainda `:async` — foi para a memória do Puma.
2. Fila `mailers` fora do yml.
3. Redis errado (Puma no 6379/0, Sidekiq no /1).

**Pontos-chave:**
- adapter
- nome da fila
- URL
</details>

### Exercício 2: Por que não inline no test

**Enunciado:** `queue_adapter = :inline` no test. O spec de enqueue quebra?

<details>
<summary>Solução</summary>

Sim. Inline executa já. `have_enqueued_job` não vê fila — o mail já saiu. `:test` deixa na array. Spec de perform chama `perform_now`. Dois testes, dois momentos.

**Pontos-chave:**
- enqueue ≠ perform
- :test guarda
- :inline executa
</details>

---

*Parte do [Ruby Projects Handbook](/)*
