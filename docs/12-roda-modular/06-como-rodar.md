# 12.6 Como rodar

> **TL;DR**
> `cd projects/12-roda-modular`. `bundle install`. `bundle exec ruby bin/migrate`. `bundle exec puma`. Login igual A. POST `/locais` e POST `/eventos`. Fonte: [código](/docs/12-roda-modular/codigo).

## Conteúdo

- [migrate e puma](#migrate-e-puma)
- [dois prefixos](#dois-prefixos)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## migrate e puma

**O que é:**
Três tabelas: accounts, locais, eventos.

**Como funciona:**

```bash
cd projects/12-roda-modular
bundle install
bundle exec ruby bin/migrate
bundle exec puma
```

9292. Pasta **outra** que a 11. SQLite outro arquivo.

**Na entrevista:**
> "B não é o A editado. É outra pasta. Eu não quebro o take-home A."

---

## dois prefixos

**O que é:**
A prova do módulo.

**Como funciona:**
Cria conta. Login. POST Sala 2 em `/locais`. POST Jazz em `/eventos`. GET nos dois. Sem token 401 nos dois ramos. `/` 200 sem token.

**Na entrevista:**
> "Dois POSTs, dois arquivos. app.rb não cresceu."

---

## Recapitulando

- pasta 12
- três tabelas
- dois ramos
- JWT igual A

---

## Exercícios práticos

### Exercício 1: Porta 9292 do 11

**Enunciado:** Você sobe o 12 e o login cria conta que “já existe”. O que houve?

<details>
<summary>Solução</summary>

O 11 ainda está na 9292. Mata. Ou outra porta. Cada pasta um sqlite. Conta “já existe” é o processo errado, não o hash_routes.

**Pontos-chave:**
- processo
- pasta
- sqlite separado
</details>

---

*Parte do [Ruby Projects Handbook](/)*
