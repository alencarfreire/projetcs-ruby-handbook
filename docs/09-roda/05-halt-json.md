# 9.5 Halt, status, JSON

> **TL;DR**
> Create 201 + `Location`. Lista 200 array. Show 200 objeto. Sem title 422 com `errors`. Id sumiu 404. O Hash do evento é o body. Sem serializer. `EVENTS` e `NEXT_ID` são a store.

## Conteúdo

- [A store](#a-store)
- [Create 201](#create-201)
- [422](#422)
- [404](#404)
- [O shape de erro](#o-shape-de-erro)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A store

**O que é:**
Duas constantes na classe. Hash de eventos. Array de um inteiro para o próximo id.

**Como funciona:**

```ruby
EVENTS = {}
NEXT_ID = [1]
```

O Array existe porque constante Ruby não reatribui fácil. `NEXT_ID[0] += 1` muta o conteúdo. `EVENTS[id] = event` muta o Hash. Processo único. Puma com vários workers seria outro recorte — cada worker um Hash. Recorte: um processo, um Hash.

**Quando usar:**
Este capítulo. Fase 2 troca por tabela.

**Na entrevista:**
> "Hash e next_id. Igual um Map. Worker demais duplica a store. Eu falo e não abro cluster agora."

---

## Create 201

**O que é:**
Nasceu recurso. Status 201. Header Location. Body é o evento.

**Como funciona:**

```ruby
id = NEXT_ID[0]
NEXT_ID[0] += 1
event = { "id" => id, "title" => title, "venue" => venue }
EVENTS[id] = event
response.status = 201
response["Location"] = "/eventos/#{id}"
event
```

O return do bloco é o body. Location aponta para o GET que já existe.

**Na entrevista:**
> "201 não é 200. Location é o membro. O cliente não adivinha o id — mas o body também leva."

---

## 422

**O que é:**
O JSON veio. O title não. Recurso entendido, recusado.

**Como funciona:**

```ruby
title = r.params["title"].to_s.strip
r.halt(422, { "errors" => ["title não pode ficar em branco"] }) if title.empty?
```

Não é 400. 400 é parse. JSON lixo: o json_parser default 400. Title vazio: 422. A entrevista puxa a diferença.

**Na entrevista:**
> "400 parse. 422 regra. Title vazio é regra. JSON quebrado é parse."

---

## 404

**O que é:**
O Integer casou. O Hash não tem a chave.

**Como funciona:**

```ruby
event = EVENTS[id]
r.halt(404, { "errors" => ["não encontrado"] }) unless event
```

Path `/eventos/abc`: Integer não casa. Também 404, mas **antes** do halt — a árvore não entrou. `/eventos/9` entra e halt. Os dois são 404 para o cliente. Para você, um é matcher, outro é store.

**Na entrevista:**
> "404 do matcher e 404 do Hash. O curl não distingue. Eu distingo no quadro."

---

## O shape de erro

**O que é:**
`{ "errors": [String] }`. Sempre array. Um shape.

**Como funciona:**
422 e 404 usam a mesma chave. O cliente trata um formato. Sem `{ "error": "..." }` misturado.

**Na entrevista:**
> "errors é array. Um shape. Eu não invento error no 404 e errors no 422."

---

## Recapitulando

- Hash + next_id no processo
- 201 Location no create
- 422 title
- 404 id
- errors array

---

## Exercícios práticos

### Exercício 1: Location sem body

**Enunciado:** Você devolve 201, Location, body vazio. Vale?

<details>
<summary>Solução</summary>

HTTP aceita. API chata: o cliente faz GET extra. Recorte: body + Location. Os dois.

**Pontos-chave:**
- 201
- Location
- body ajuda o curl
</details>

### Exercício 2: venue vazio

**Enunciado:** POST só com title. venue?

<details>
<summary>Solução</summary>

String vazia vira `nil` no Hash. Title passa. 201. Venue não é obrigatório neste recorte. Lote é que vai exigir mais campo — depois.

**Pontos-chave:**
- title cerca
- venue opcional
- não inventar validação
</details>

---

*Parte do [Ruby Projects Handbook](/)*
