# 14.1 O produto: vender ingresso

> **TL;DR**
> Trilha Roda deixa de ser CRUD de evento. João cadastra o lote Pista. Maria reserva. Estoque baixa com UPDATE condicional. Pagamento é PSP falso + webhook. Um app: `projects/14-ingressos`. Sem Stripe. Sem hotel.

## Conteúdo

- [O que este projeto é](#o-que-este-projeto-é)
- [O recorte](#o-recorte)
- [Os status](#os-status)
- [C e D no código](#c-e-d-no-código)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que este projeto é

**O que é:**
A API que o 9–12 prepararam. Eventos e locais continuam. Entram lote, pedido, webhook, denylist, job, `/up`.

**Como funciona:**
Pasta nova. A 12 não muda. Você sobe `bundle exec puma` depois do `bin/seed`. Login João. Lote Pista 50 un, 8000 centavos.

**Quando usar:**
Quando a pergunta é “monta o produto”. Não o take-home de 45 min (isso é 11). Este é o fim de semana.

**Na entrevista:**
> "Evento eu já tinha. Lote é preço e quantidade. Pedido é a reserva. Webhook é o pago. Eu não começo pelo Stripe."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| lotes, pedidos, webhook HMAC | Stripe, Pagar.me |
| `ReservarLote` (C) | RBAC organizador/comprador |
| `WebhookSchema` (D) | Kubernetes, Kamal |
| denylist no logout | Prometheus |
| Sidekiq + mail arquivo | SMTP real |
| sqlite local, postgres no compose | AWS |

**Na entrevista:**
> "PSP falso. O contrato do webhook é o ponto. A conta do Stripe é outro recorte."

---

## Os status

**O que é:**
`reserved` → `paid` | `expired` | `failed`.

**Como funciona:**
POST `/pedidos` reserva 15 min e **baixa estoque agora**. Webhook `paid` não baixa de novo. `failed`/`expired` devolve. Oversell se você decrementar só no pago — a entrevista puxa. Este recorte segura na reserva.

**Na entrevista:**
> "Eu baixo na reserva com UPDATE where quantity >= n. Pago não toca estoque. Expire devolve."

---

## C e D no código

**O que é:**
Não é pasta hexagonal. É dois arquivos.

**Como funciona:**
`lib/reservar_lote.rb` não dá `require "roda"`. `lib/webhook_schema.rb` valida o JSON **antes** de `ConfirmarPagamento`. O route só traduz Result em 201/422.

**Na entrevista:**
> "C no estoque. D no payload do PSP. GET /eventos continua dataset. Eu não hexagonalizo lista."

---

## Como o walkthrough anda

**O que é:**
14.2 schema. 14.3 reserva. 14.4 webhook. 14.5 testes e logout. 14.6 jobs, log, postgres. 14.7 como rodar. Ops (compose) é o 15.

**Na entrevista:**
> "Eu reservei a Pista, simulei o pago, o pedido ficou paid, o replay do webhook não baixou de novo."

---

## Recapitulando

- um produto, pasta 14
- reserva baixa estoque
- webhook confirma
- C e D nos lib/
- cloud fica no 15.8

---

## Exercícios práticos

### Exercício 1: Por que não Stripe

**Enunciado:** O entrevistador pede a gem. Você instala?

<details>
<summary>Solução</summary>

Não neste recorte. O ponto é HMAC, idempotência, status. A gem esconde o contrato. PSP falso devolve o mesmo JSON. Trocar o simulador por Stripe é adapter.

**Pontos-chave:**
- contrato
- sem gem de PSP
- adapter depois
</details>

---

*Parte do [Ruby Projects Handbook](/)*
