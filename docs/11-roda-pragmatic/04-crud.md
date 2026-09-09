# 11.4 CRUD de eventos no route

> **TL;DR**
> A mesma árvore da fase 9. A store agora é `DB[:eventos]`. `all` / `insert` / `where(id:)`. Hash na response. `require_authentication` no ramo. Sem model.

## Conteúdo

- [A árvore igual](#a-árvore-igual)
- [insert](#insert)
- [all e first](#all-e-first)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A árvore igual

**O que é:**
`r.on "eventos"`, `r.is`, `r.on Integer`. Você já viu no 9. Aqui o Hash `EVENTS` virou tabela.

**Como funciona:**
O cadeado é a novidade: primeira linha do ramo, `rodauth.require_authentication`. O resto é dataset.

**Na entrevista:**
> "A árvore não mudou. Mudou a store e o cadeado. Eu não reescrevo o roteamento porque apareceu Sequel."

---

## insert

**O que é:**
`DB[:eventos].insert(...)` devolve id. Você busca o row para o body 201.

**Como funciona:**

```ruby
id = DB[:eventos].insert(title: title, venue: venue, starts_at: r.params["starts_at"])
event = DB[:eventos].where(id: id).first
response.status = 201
response["Location"] = "/eventos/#{id}"
event
```

`starts_at` pode vir string ISO. SQLite guarda. Recorte raso: sem parse de Time rigoroso.

**Na entrevista:**
> "insert, where, first. Hash. 201 Location. Igual o 9, tabela no lugar do constante."

---

## all e first

**O que é:**
GET coleção: `DB[:eventos].all`. GET membro: `where(id: id).first` + halt 404.

**Como funciona:**
O json plugin serializa o Hash do Sequel (chaves symbol viram string no JSON). Curl não vê symbol.

**Na entrevista:**
> "all na lista. first no membro. 404 se nil. Dataset, não Evento.find."

---

## Recapitulando

- árvore do 9
- store do 10
- cadeado do 11.3
- Hash na porta

---

## Exercícios práticos

### Exercício 1: Evento.where

**Enunciado:** Você troca para Model no A. Quebra o recorte?

<details>
<summary>Solução</summary>

Funciona. A deixa de ser “zero camada”. Hash do dataset era o ponto. Model é B/C. Pode. O handbook no A fica no dataset.

**Pontos-chave:**
- A = dataset
- model é opção
- recorte
</details>

---

*Parte do [Ruby Projects Handbook](/)*
