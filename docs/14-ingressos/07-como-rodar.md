# 14.7 Como rodar o produto

> **TL;DR**
> `cd projects/14-ingressos`. `bundle install`. `bundle exec ruby bin/seed`. `bundle exec puma`. Login João. Reserva Pista. Simula pago. `rake test`. Worker e Redis opcionais. Compose é o 15. Fonte: [código](/docs/14-ingressos/codigo).

## Conteúdo

- [seed e puma](#seed-e-puma)
- [curls](#curls)
- [expire e test](#expire-e-test)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## seed e puma

**O que é:**
João, Maria, Sunset Jazz, lote Pista 50×8000.

**Como funciona:**

```bash
cd projects/14-ingressos
bundle install
bundle exec ruby bin/seed
bundle exec puma
```

9292. Senha seed `senha123`. Campo `login`.

**Na entrevista:**
> "Seed não é o PSP. Seed é o Jazz e a Pista. O pago eu simulo no curl."

---

## curls

**O que é:**
Login → TOKEN → POST pedidos → simular → webhook.

**Como funciona:**
README tem o roteiro. `-D -` no login. `X-Signature` no webhook. Sem signature 401. Replay a mesma key: 200, um `webhook_events`.

**Na entrevista:**
> "Eu mostrei esgotado 422 e replay 200. Os dois curls que o quadro pede."

---

## expire e test

**O que é:**
Relógio e CI.

**Como funciona:**

```bash
bundle exec ruby bin/expire
bundle exec rake test
```

Oito examples. Sem Redis.

**Na entrevista:**
> "rake test verde. Expire no script. Sidekiq se o Redis estiver — não é obrigatório para a prova da regra."

---

## Recapitulando

- seed + puma
- JWT nos pedidos
- HMAC no webhook
- rake test
- compose no 15

---

## Exercícios práticos

### Exercício 1: 9292 do 12

**Enunciado:** Você reserva e não existe /pedidos. O que houve?

<details>
<summary>Solução</summary>

Puma ainda é o 12. Mata. Sobe o 14. Path /pedidos é desta pasta.

**Pontos-chave:**
- processo
- pasta
</details>

---

*Parte do [Ruby Projects Handbook](/)*
