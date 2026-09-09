# 10.4 Dataset devolve Hash

> **TL;DR**
> `first` e `all` materializam. Cada row é Hash com chave symbol. `insert` devolve o id. `where` encadeia. Sem objeto Evento neste capítulo — isso é o 10.5.

## Conteúdo

- [all e first](#all-e-first)
- [insert](#insert)
- [where](#where)
- [examples/](#examples)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## all e first

**O que é:**
O disparo. Dataset vira array ou um Hash.

**Como funciona:**

```ruby
DB[:eventos].all
# [{ id: 1, title: "Sunset Jazz", venue: "Sala 2", starts_at: ... }]

DB[:eventos].first[:title]
# "Sunset Jazz"
```

`row[:title]` não `row.title`. Hash. Se você chama `row.title`, explode. A entrevista espera esse tropeço.

**Na entrevista:**
> "Hash. Chave symbol. title não é método. Model é que vira método."

---

## insert

**O que é:**
Escreve. Devolve o id inteiro no SQLite.

**Como funciona:**

```ruby
id = DB[:eventos].insert(title: "Noite Ruby", venue: "Auditório", starts_at: Time.new(2026, 12, 1, 19, 0, 0))
row = DB[:eventos].where(id: id).first
```

`examples/insert.rb` faz isso. Sem `save`. Sem callback.

**Na entrevista:**
> "insert. Hash de colunas. id de volta. Sem after_create."

---

## where

**O que é:**
Filtro. Continua dataset até `first`/`all`.

**Como funciona:**

```ruby
DB[:eventos].where(title: "Sunset Jazz").first
DB[:eventos].where { starts_at > Time.now }  # bloco Sequel, recorte: falar, não precisa no script
```

SQL injection: hash no where é bound. String crua não. Recorte: hash.

**Na entrevista:**
> "where com Hash. Bind. Eu não interpolo title na string SQL."

---

## examples/

**O que é:**
Dois scripts. Sem teste theatre. Você roda.

**Como funciona:**
`list.rb` each e puts. `insert.rb` p e um row. README manda os dois.

**Na entrevista:**
> "Eu não subi server. Eu rodei o script. A tabela falou."

---

## Recapitulando

- all/first materializam Hash
- insert devolve id
- where encadeia
- chave symbol
- scripts, sem HTTP

---

## Exercícios práticos

### Exercício 1: row.title

**Enunciado:** No console você digita `DB[:eventos].first.title`. O que explode?

<details>
<summary>Solução</summary>

NoMethodError. Hash não tem `title`. `row[:title]`. Ou `Evento.first.title` no 10.5.

**Pontos-chave:**
- Hash vs model
- symbol
- o tropeço da entrevista
</details>

---

*Parte do [Ruby Projects Handbook](/)*
