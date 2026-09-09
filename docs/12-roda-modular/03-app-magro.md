# 12.3 app.rb magro

> **TL;DR**
> Plugins, Rodauth, `require` dos ramos, `route` de quatro linhas úteis. O CRUD não mora aqui. O orquestrador cabe no quadro.

## Conteúdo

- [A ordem do arquivo](#a-ordem-do-arquivo)
- [O route](#o-route)
- [freeze](#freeze)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A ordem do arquivo

**O que é:**
Classe + plugins. Require ramos. Classe de novo + route.

**Como funciona:**
`hash_branch` precisa da classe plugada. `route` precisa dos branches já registrados. Por isso o `require_relative "routes/eventos"` no meio.

**Na entrevista:**
> "Plugins. Require dos ramos. Route. Ordem. Eu não route antes do branch."

---

## O route

**O que é:**
Root, rodauth, hash_routes. Ponto.

**Como funciona:**
Sem `r.on "eventos"` aqui. Isso vive no arquivo do ramo. O orquestrador não conhece title nem name.

**Na entrevista:**
> "app.rb não sabe o 422 de title. eventos.rb sabe. Isso é a barreira de leitura, não só de auth."

---

## freeze

**O que é:**
`config.ru` freeze.app **depois** dos requires. Ramos já no Hash.

**Como funciona:**
Freeze cedo demais: branch não registra. Recorte: freeze no ru, último passo.

**Na entrevista:**
> "freeze no ru. Depois dos ramos. Senão o Hash de rotas nasceu vazio."

---

## Recapitulando

- ordem: plugin, require, route
- CRUD fora do app.rb
- freeze por último

---

## Exercícios práticos

### Exercício 1: Contar linhas

**Enunciado:** Por que “~35 linhas” importa?

<details>
<summary>Solução</summary>

Cabe no quadro. O entrevistador vê o fio. Se o orquestrador tem CRUD, você não fez B. Fez A com pastas.

**Pontos-chave:**
- quadro
- orquestrador
- CRUD no ramo
</details>

---

*Parte do [Ruby Projects Handbook](/)*
