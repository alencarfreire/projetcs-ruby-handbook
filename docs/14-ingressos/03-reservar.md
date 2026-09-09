# 14.3 ReservarLote (C)

> **TL;DR**
> Classe Ruby pura. `call(account_id:, lote_id:, quantity:)`. `UPDATE lotes SET quantity = quantity - n WHERE id = ? AND quantity >= n`. Rowcount 0 → `esgotado`. Sem `require "roda"`. Sem `first` + `qty -= 1` em memória.

## Conteúdo

- [Por que não no route](#por-que-não-no-route)
- [O UPDATE](#o-update)
- [Result](#result)
- [Expire](#expire)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Por que não no route

**O que é:**
Dois POSTs no último ingresso. A regra tem que viver num lugar testável sem Rack.

**Como funciona:**
O ramo `pedidos` chama `ReservarLote.new.call`. 422 se `result.ok?` é false. O teste de estoque instancia a classe. GET /eventos continua no dataset.

**Na entrevista:**
> "C no coração. O route traduz. Eu testo ReservarLote com o sqlite de test, sem Puma — e ainda testo o POST no rack-test."

---

## O UPDATE

**O que é:**
A cerca. O banco serializa.

**Como funciona:**

```ruby
updated = @db[:lotes]
  .where(id: lote_id)
  .where(Sequel[:quantity] >= qty)
  .update(quantity: Sequel[:quantity] - qty)
return Result.err("esgotado") if updated.zero?
```

Dois requests, quantity 1: um rowcount 1, um 0. Sem unique index de pedido. O UPDATE é o lock lógico.

**Na entrevista:**
> "Eu não leio quantity, subtraio em Ruby, salvo. Isso race. UPDATE ... WHERE quantity >= n. Rowcount."

---

## Result

**O que é:**
`ok?`, `value`, `errors`. Caseiro. Não é dry-monads. O 13.3 continua válido — aqui um struct chega.

**Como funciona:**
`Result.ok(pedido)` / `Result.err("esgotado")`. O route não pergunta SQL.

**Na entrevista:**
> "Result caseiro. D puxa dry se o time já usa. O call não muda de ideia."

---

## Expire

**O que é:**
`ExpireReservations`. Pedidos `reserved` com `reserved_until` no passado viram `expired` e devolvem quantity. Idempotente: update status com where reserved.

**Como funciona:**
Fase 1 da call: `bin/expire`. Fase job: Sidekiq `perform_at`. Os dois chamam a mesma classe.

**Na entrevista:**
> "Expire é a mesma regra. Script ou worker. Eu não copio o SQL."

---

## Recapitulando

- UPDATE condicional
- Result
- sem Roda no lib
- expire devolve estoque

---

## Exercícios práticos

### Exercício 1: first + minus

**Enunciado:** `lote = first; lote[:quantity] -= n; update`. O que quebra?

<details>
<summary>Solução</summary>

Dois processos leem 1. Os dois escrevem 0 e criam dois pedidos. Oversell. UPDATE where é a cerca.

**Pontos-chave:**
- race
- rowcount
- sem read-modify-write
</details>

---

*Parte do [Ruby Projects Handbook](/)*
