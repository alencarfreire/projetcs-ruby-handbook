# 14 — Ingressos (produto)

API de venda de ingressos: eventos, lotes, reserva, webhook de pagamento (PSP falso), jobs. Roda + Sequel + Rodauth JWT. Sem Stripe.

```
projects/14-ingressos/
  app.rb                 orquestra
  routes/                eventos, locais, lotes, pedidos, pagamentos, webhooks
  lib/reservar_lote.rb   C — estoque
  lib/confirmar_pagamento.rb
  lib/webhook_schema.rb  D — contrato do PSP
  jobs/
  test/
```

## O que você constrói

João cadastra “Sunset Jazz” e o lote Pista (R$ 80,00 = 8000 centavos, 50 un). Maria reserva. O PSP falso assina o webhook. Pedido vira `paid`. Logout coloca o JWT na denylist.

## O que você treina

- UPDATE condicional de estoque (não `quantity -= 1` em Ruby)
- Reserva 15 min + `bin/expire`
- HMAC no webhook vs JWT no resto
- Idempotência por `idempotency_key`
- Sidekiq sem Rails; mail em `tmp/mails`
- `/up`, `X-Request-Id`, log JSON no stdout
- `DATABASE_URL` sqlite ou postgres

## Como rodar (local, SQLite)

```bash
cd projects/14-ingressos
bundle install
bundle exec ruby bin/seed
bundle exec puma
```

Login: `joao@email.com` / `senha123` (seed). Paths Rodauth: `/create-account`, `/login`. Campo `login`.

```bash
curl -s -D - -X POST http://127.0.0.1:9292/login \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"login":"joao@email.com","password":"senha123"}'
# copia Authorization

curl -s http://127.0.0.1:9292/lotes -H "Authorization: $TOKEN" -H "Accept: application/json"
curl -s -X POST http://127.0.0.1:9292/pedidos \
  -H "Authorization: $TOKEN" -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"lote_id":1,"quantity":1}'
```

Pagar (PSP falso):

```bash
curl -s -X POST http://127.0.0.1:9292/pagamentos/simular \
  -H "Authorization: $TOKEN" -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"pedido_id":1,"status":"paid"}'
# devolve payload + signature

curl -s -X POST http://127.0.0.1:9292/webhooks/pagamento \
  -H "Content-Type: application/json" \
  -H "X-Signature: $SIG" \
  -d "$PAYLOAD"
```

Expirar reservas: `bundle exec ruby bin/expire`

Testes: `bundle exec rake test` (sem Redis).

Worker (opcional): `REDIS_URL=redis://localhost:6379/0 bundle exec sidekiq -r ./jobs/sidekiq.rb`

## Status do pedido

`reserved` → `paid` | `expired` | `failed`

Estoque baixa na **reserva**. Pago não baixa de novo. Expired/failed devolve.

## O que NÃO entra (de propósito)

- Stripe / Pagar.me
- RBAC organizador vs comprador
- Kubernetes, Kamal, AWS
- Prometheus
