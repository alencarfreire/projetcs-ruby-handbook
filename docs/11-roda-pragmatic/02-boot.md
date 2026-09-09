# 11.2 Boot: db.rb + app.rb

> **TL;DR**
> `require_relative "db"` no `app.rb`. `DB` global. Migration cria `accounts` e `eventos`. `bin/migrate` antes do Puma. Sem Rails autoload.

## Conteúdo

- [db.rb](#dbrb)
- [accounts e eventos](#accounts-e-eventos)
- [require](#require)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## db.rb

**O que é:**
A mesma ideia da fase 10. Path sqlite. Constante `DB`.

**Como funciona:**
O app Roda não abre conexão no `route`. Abre no load. Request usa `DB[:eventos]`.

**Na entrevista:**
> "Boot carrega o banco. Route usa. Eu não conecto por request."

---

## accounts e eventos

**O que é:**
Uma migration. Duas tabelas.

**Como funciona:**
`accounts`: id, status (2 = verificado neste recorte, sem e-mail de confirm), email unique, password_hash.
`eventos`: igual a fase 10.

Rodauth espera `accounts` com essas colunas quando `account_password_hash_column :password_hash`. Sem essa config ele procura tabela de hash separada.

**Na entrevista:**
> "password_hash na accounts. Eu digo a coluna. Senão o Rodauth procura outra tabela."

---

## require

**O que é:**
Ruby explícito. Sem Zeitwerk.

**Como funciona:**
`config.ru` → `app.rb` → `db.rb`. freeze.app no ru.

**Na entrevista:**
> "require_relative. Sem autoload. O arquivo que eu não requirei não existe."

---

## Recapitulando

- DB no boot
- duas tabelas
- password_hash na accounts
- migrate antes do puma

---

## Exercícios práticos

### Exercício 1: Puma sem migrate

**Enunciado:** Sintoma?

<details>
<summary>Solução</summary>

create-account explode no insert: no such table accounts. Rodar `bin/migrate`. Não é o JWT.

**Pontos-chave:**
- tabela
- migrate
- não culpar o token
</details>

---

*Parte do [Ruby Projects Handbook](/)*
