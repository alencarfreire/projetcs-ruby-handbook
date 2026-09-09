# 14.2 Schema: lote e pedido

> **TL;DR**
> Lote: `evento_id`, `name`, `price_cents`, `quantity`, janela. Pedido: `account_id`, `lote_id`, `quantity`, `total_cents`, `status`, `reserved_until`. Centavos integer. Sem Float.

## Conteúdo

- [Lote](#lote)
- [Pedido](#pedido)
- [CRUD /lotes](#crud-lotes)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Lote

**O que é:**
A prateleira. Pista, VIP. Preço e quantidade.

**Como funciona:**

```ruby
Integer :price_cents, null: false
Integer :quantity, null: false
```

`total_cents` do pedido = `price_cents * quantity` no `ReservarLote`. Cliente não manda o total.

Janela `sales_starts_at` / `sales_ends_at`. Fora da janela: 422.

**Na entrevista:**
> "Centavos. O cliente não calcula. quantity no lote é o estoque livre."

---

## Pedido

**O que é:**
A intenção da Maria. Não é o ingresso PDF. É a linha que o webhook fecha.

**Como funciona:**
`reserved_until` = agora + 15 min. `bin/expire` e o job olham isso. Sem item table extra neste recorte — quantity no próprio pedido. Cabe no quadro.

**Na entrevista:**
> "Um pedido, um lote, um quantity. Item vira tabela quando o carrinho misturar lotes. Agora não."

---

## CRUD /lotes

**O que é:**
hash_branch. JWT. POST com `evento_id`, `name`, `price_cents`, `quantity`.

**Como funciona:**
GET lista. Filtro `?evento_id=`. 422 se evento sumiu. Recorte: qualquer account autenticado cria lote — **sem RBAC**. O capítulo fala: produção pede papel organizador.

**Na entrevista:**
> "RBAC eu nomeio. Neste recorte o JWT basta. A entrevista de papel é outro quadro."

---

## Recapitulando

- price_cents integer
- quantity é estoque
- pedido carrega total e status
- 15 min de reserva

---

## Exercícios práticos

### Exercício 1: total no JSON de entrada

**Enunciado:** Maria manda `total_cents: 1`. Você aceita?

<details>
<summary>Solução</summary>

Não. permit/params do pedido são `lote_id` e `quantity`. Total sai do lote. Fraude clássica.

**Pontos-chave:**
- servidor calcula
- centavos
</details>

---

*Parte do [Ruby Projects Handbook](/)*
