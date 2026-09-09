# 14.4 Webhook HMAC e idempotência

> **TL;DR**
> `POST /webhooks/pagamento` **sem JWT**. `X-Signature` HMAC-SHA256 do **body cru**. Schema (D) antes do call. `idempotency_key` unique. Replay 200, um row. `paid` não baixa estoque de novo. `failed` devolve se ainda reserved.

## Conteúdo

- [JWT vs HMAC](#jwt-vs-hmac)
- [Body cru](#body-cru)
- [Schema](#schema)
- [Replay](#replay)
- [Simular](#simular)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## JWT vs HMAC

**O que é:**
O PSP não é a Maria. Não tem `/login`. Tem um secret compartilhado.

**Como funciona:**
Ramo `webhooks` **não** chama `require_login!`. Assinatura inválida: 401 `{ "error": "assinatura inválida" }`. João no `/pedidos` continua JWT.

**Na entrevista:**
> "Webhook não usa o token do user. HMAC do body. Barreira diferente, ramo diferente."

---

## Body cru

**O que é:**
Você assina os bytes. Re-serializar o Hash muda a ordem das chaves e quebra a assinatura.

**Como funciona:**
Middleware `RawBody` guarda `env["RAW_BODY"]` e rebobina o `rack.input` para o json_parser. HMAC usa RAW_BODY. Parser usa o mesmo JSON.

**Na entrevista:**
> "Eu hasheio o body que chegou. Não o Hash que o parser montou."

---

## Schema

**O que é:**
`WebhookSchema.call`. `pedido_id`, `status` in paid/failed, `idempotency_key`. Failure 422 **antes** de ConfirmarPagamento.

**Como funciona:**
JSON lixo: 400. Shape errado: 422. Assinatura errada: 401. Ordem: HMAC → parse → schema → call.

**Na entrevista:**
> "D na porta. Payload podre não chega no estoque. 401 ≠ 422."

---

## Replay

**O que é:**
O PSP retria. Unique em `webhook_events.idempotency_key`. Segundo insert viola unique: devolve o pedido já processado. 200. Estoque intacto.

**Como funciona:**
`ConfirmarPagamento` olha a chave primeiro. paid em pedido já paid: no-op. failed em reserved: devolve quantity **uma vez** (update where status reserved).

**Na entrevista:**
> "Idempotência é unique + early return. Eu não baixo duas vezes. At-least-once do PSP."

---

## Simular

**O que é:**
`POST /pagamentos/simular` com JWT. Devolve `{ payload, signature, url }`. Você cola no webhook. Sem conta Stripe.

**Como funciona:**
O mesmo HMAC do secret. A call de produção só troca quem chama o POST.

**Na entrevista:**
> "O simulador é o PSP. O webhook não sabe se veio do curl ou do Stripe."

---

## Recapitulando

- HMAC sem JWT
- RAW_BODY
- schema antes
- unique key
- paid não re-decrementa

---

## Exercícios práticos

### Exercício 1: Assinar o Hash to_json

**Enunciado:** Você `JSON.generate(params)` para o HMAC. Quebra quando?

<details>
<summary>Solução</summary>

Quando a ordem das chaves do PSP ≠ a do Ruby. Signature mismatch 401. Bytes do request.

**Pontos-chave:**
- body cru
- ordem
</details>

---

*Parte do [Ruby Projects Handbook](/)*
