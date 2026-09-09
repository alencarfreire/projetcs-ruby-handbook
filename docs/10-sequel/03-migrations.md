# 10.3 Migrations

> **TL;DR**
> `migrate/001_eventos.rb`. `Sequel.migration { change { create_table :eventos } }`. `bin/migrate` chama `Sequel::Migrator`. Sem `rails g`. Sem schema.rb obrigatório neste recorte — o arquivo sqlite é a verdade.

## Conteúdo

- [O arquivo](#o-arquivo)
- [change](#change)
- [Migrator](#migrator)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O arquivo

**O que é:**
Um Ruby. Prefixo numérico. Ordem.

**Como funciona:**

```ruby
Sequel.migration do
  change do
    create_table :eventos do
      primary_key :id
      String :title, null: false
      Time :starts_at
      String :venue
    end
  end
end
```

`String` com S maiúsculo é tipo Sequel. `null: false` no title. `starts_at` pode ser nil neste recorte.

**Na entrevista:**
> "Migration Sequel. create_table no Ruby. Eu não escrevo CREATE TABLE na mão — mas o Sequel gera."

---

## change

**O que é:**
Bloco reversível. `up`/`down` existem. Recorte: `change`.

**Como funciona:**
`create_table` no `change` o Migrator sabe dropar no rollback. Recorte sem rollback no README. Você fala que existe.

**Na entrevista:**
> "change. Um bloco. Rollback é drop_table. Eu não implemento down neste take-home."

---

## Migrator

**O que é:**
`Sequel::Migrator.run(DB, "migrate")`. Tabela interna de versão.

**Como funciona:**
`bin/migrate` e `bin/seed` (seed migra antes). Rodar duas vezes: no-op. Seed olha `where(title: "Sunset Jazz").empty?` para não duplicar.

**Na entrevista:**
> "Migrator guarda a versão. Seed não é migration. Seed é insert com guarda."

---

## Recapitulando

- 001_eventos.rb
- create_table Sequel
- Migrator.run
- seed ≠ migrate

---

## Exercícios práticos

### Exercício 1: rails g

**Enunciado:** O entrevistador pede o generator. Você tem?

<details>
<summary>Solução</summary>

Não. Arquivo na pasta. Nome 001. Recorte honesto. Generator é Rails.

**Pontos-chave:**
- arquivo
- sem generator
- numerar
</details>

---

*Parte do [Ruby Projects Handbook](/)*
