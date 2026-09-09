# 8.4 Occupancy e consistência

> **TL;DR**
> Duas recepções. Um pet. A regra continua no banco: um `checked_in` por pet. Índice unique. Request síncrono. Centavos integer. O quadro pode ficar meio segundo stale — o write não.

## Conteúdo

- [A corrida](#a-corrida)
- [Unique no banco](#unique-no-banco)
- [O quadro stale](#o-quadro-stale)
- [Dinheiro](#dinheiro)
- [Filial](#filial)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A corrida

**O que é:**
João e Ana clicam check-in do Thor no mesmo segundo. Dois requests.

**Como funciona:**
O model `only_one_checked_in_stay_per_pet` faz `exists?` e depois `update`. Dois processos passam no exists. Dois inserts. Sem unique index, dois Thor hospedados. A validação Ruby **não** basta em escala.

Migration de verdade:

```ruby
add_index :stays, :pet_id, unique: true, where: "status = 1"
```

Partial unique. SQLite/Postgres. O segundo commit levanta `RecordNotUnique`. Você traduz para 422. O take-home 2 não pôs o índice. O quadro 8 põe.

**Na entrevista:**
> "Validação no model é UX. Unique no banco é a cerca. Eu desenho os dois."

---

## Unique no banco

**O que é:**
A fonte. Ruby é o filtro educado.

**Como funciona:**
`rescue ActiveRecord::RecordNotUnique` no controller, 422. Idempotente. Retry do client não duplica.

Check-out: status muda, o índice libera o pet. Nova stay `checked_in` entra.

**Na entrevista:**
> "Partial index where status = checked_in. Unique em pet_id solto bloquearia o histórico."

---

## O quadro stale

**O que é:**
TV na parede. Broadcast atrasou 300ms. Thor já entrou no banco. Quadro velho.

**Como funciona:**
Aceitável. Occupancy é leitura eventualmente consistente em dezenas de ms. Write não é. F5 / próximo broadcast corrige. Não trave o check-in no ACK de todas as TVs.

Se o negócio for catraca física, aí sim o write path espera o hardware. Recorte hotel: o banco é a verdade. O quadro é espelho.

**Na entrevista:**
> "Stale no quadro eu aceito. Stale no write eu não. Unique index, não unique no HTML."

---

## Dinheiro

**O que é:**
`nightly_rate_cents` integer. `total_cents` método. Continua.

**Como funciona:**
Não Float. Não “arredonda na API”. Relatório soma integer. Fatura: o total é função das datas + diária **no momento do cálculo**. Se a diária pode mudar no meio da stay, você decide: congelar `total_cents` na coluna no check-in, ou sempre recalcular. Recorte atual recalcula. Escala com disputa de preço: congela no check-in.

**Na entrevista:**
> "Integer. Se a diária muda, eu pergunto se congela. Default do take-home: recalcula. Produção de fatura: congela."

---

## Filial

**O que é:**
Dois hotéis, um pet? Improvável. Dois hotéis, um owner: comum.

**Como funciona:**
`account_id` em Stay. Unique `(account_id, pet_id) where checked_in`. Occupancy scoped. Cable `stream_for account`. Token/session com account.

**Na entrevista:**
> "Filial é account_id no Stay. Occupancy não é global. Unique é por hotel, a menos que o pet seja único no mundo."

---

## Recapitulando

- Corrida: unique no banco
- Ruby valida; índice garante
- Quadro pode atrasar
- Integer; congelar total se a diária muda
- Filial = scope

---

## Exercícios práticos

### Exercício 1: SELECT FOR UPDATE

**Enunciado:** Em vez de unique index, você abre transação e locka o pet. Válido?

<details>
<summary>Solução</summary>

Válido. Serializa os check-ins daquele pet. Mais simples de explicar, pior sob carga se o lock é largo. Unique index deixa o banco recusar sem lock explícito. Os dois funcionam. Entrevista: index + rescue é o recorte limpo.

**Pontos-chave:**
- lock vs unique
- unique não espera
- RecordNotUnique → 422
</details>

### Exercício 2: total_cents coluna

**Enunciado:** Você persiste total no check-in. Check-out antecipado de 3 para 1 diária. Recalcula?

<details>
<summary>Solução</summary>

Produto. Recalcular no check-out é honesto com a estadia real. Congelar é honesto com o orçamento combinado. Escolhe e documenta. Não deixa o cliente mandar o total. Servidor calcula.

**Pontos-chave:**
- política, não gem
- servidor calcula
- check-out pode mudar noites
</details>

---

*Parte do [Ruby Projects Handbook](/)*
