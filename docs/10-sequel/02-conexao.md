# 10.2 Conexão e DB[:eventos]

> **TL;DR**
> `DB = Sequel.sqlite(path)`. `DB[:eventos]` é o dataset da tabela. Sem connection pool na sua mão. Um arquivo. Um constante `DB`.

## Conteúdo

- [Sequel.sqlite](#sequelsqlite)
- [O dataset](#o-dataset)
- [storage/](#storage)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Sequel.sqlite

**O que é:**
A conexão. Um path. Um objeto.

**Como funciona:**

```ruby
DIR = File.expand_path("storage", __dir__)
Dir.mkdir(DIR) unless Dir.exist?(DIR)
DB = Sequel.sqlite(File.join(DIR, "app.sqlite3"))
```

`db.rb` é o boot. Scripts dão `require_relative "../db"`. Sem Rails. Sem `database.yml`.

Postgres seria `Sequel.postgres(...)`. Recorte: SQLite. A API do dataset não muda.

**Na entrevista:**
> "DB é a conexão. sqlite no path. Eu não escondo atrás de um adapter Rails."

---

## O dataset

**O que é:**
`DB[:eventos]`. Representa a tabela. Encadeia `where`, `insert`, `all`.

**Como funciona:**

```ruby
DB[:eventos].all
DB[:eventos].where(title: "Sunset Jazz").first
DB[:eventos].insert(title: "Noite Ruby", venue: "Auditório")
```

Lazy até você materializar (`all`, `first`, `each`). O SQL aparece se você ligar o log. Recorte: sem logger obrigatório. `DB[:eventos].sql` devolve o SELECT.

**Na entrevista:**
> "DB[:eventos] não é um array. É o dataset. all dispara. where encadeia."

---

## storage/

**O que é:**
A pasta do arquivo. gitignore do sqlite. `bin/seed` cria se faltar.

**Como funciona:**
Clone, seed, arquivo nasce. Sem volume Docker nesta fase.

**Na entrevista:**
> "O banco é um arquivo. Eu mostro o path. Não é mágica de DATABASE_URL ainda."

---

## Recapitulando

- Um `DB`
- Dataset `DB[:eventos]`
- Path em storage/
- SQL quando você pede

---

## Exercícios práticos

### Exercício 1: DB[:evento] no singular

**Enunciado:** Você erra o nome. Sintoma?

<details>
<summary>Solução</summary>

SQLite cria tabela na hora em alguns inserts? Sequel no sqlite pode explodir “no such table”. O nome é `eventos`, plural, igual a migration. Dataset não pluraliza sozinho como Active Record.

**Pontos-chave:**
- nome literal
- sem inflector
- migration manda
</details>

---

*Parte do [Ruby Projects Handbook](/)*
