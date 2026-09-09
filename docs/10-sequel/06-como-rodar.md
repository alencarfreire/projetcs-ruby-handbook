# 10.6 Como rodar

> **TL;DR**
> `cd projects/10-sequel-sqlite`. `bundle install`. `bundle exec ruby bin/seed`. `bundle exec ruby examples/list.rb`. Console: `DB[:eventos].all`. Fonte: [código](/docs/10-sequel/codigo).

## Conteúdo

- [seed](#seed)
- [list e insert](#list-e-insert)
- [console](#console)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## seed

**O que é:**
Migra e insere Sunset Jazz se faltar.

**Como funciona:**

```bash
cd projects/10-sequel-sqlite
bundle install
bundle exec ruby bin/seed
# seed ok. Eventos: 1
```

Duas vezes: count continua 1. Guarda no title.

**Na entrevista:**
> "seed migra. Jazz uma vez. Eu não duplico no segundo run."

---

## list e insert

**O que é:**
Os two scripts.

**Como funciona:**

```bash
bundle exec ruby examples/list.rb
# 1  Sunset Jazz  Sala 2

bundle exec ruby examples/insert.rb
# Hash da Noite Ruby
```

**Na entrevista:**
> "list.rb leu a tabela. insert.rb devolveu o Hash. Sem curl."

---

## console

**O que é:**
IRB com `DB` e `Evento`.

**Como funciona:**

```bash
bundle exec ruby bin/console
```

```ruby
DB[:eventos].all
Evento.first.title
```

**Na entrevista:**
> "No console eu mostro Hash e model no mesmo processo."

---

## Recapitulando

- bin/seed
- examples
- console
- sqlite sobrevive

---

## Exercícios práticos

### Exercício 1: Esqueceu o seed

**Enunciado:** list.rb não imprime nada. O que olhar?

<details>
<summary>Solução</summary>

Tabela vazia. Rodar seed. Ou insert. Não é o dataset “quebrado”. `DB[:eventos].count`.

**Pontos-chave:**
- count
- seed
- arquivo existe?
</details>

---

*Parte do [Ruby Projects Handbook](/)*
