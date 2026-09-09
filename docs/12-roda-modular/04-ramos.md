# 12.4 Ramos: eventos e locais

> **TL;DR**
> Cada arquivo: `require_authentication` na primeira linha útil. GET/POST na coleção. GET no Integer. 422 e 404 no próprio ramo. Um domínio, um arquivo, uma barreira.

## Conteúdo

- [Cadeado no ramo](#cadeado-no-ramo)
- [eventos.rb](#eventosrb)
- [locais.rb](#locaisrb)
- [404 de outro prefixo](#404-de-outro-prefixo)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Cadeado no ramo

**O que é:**
`rodauth.require_authentication` **dentro** do `hash_branch`. Não no orquestrador.

**Como funciona:**
Root e login livres. `/eventos` e `/locais` trancados. Um ramo futuro público (health detalhado) não herda cadeado global.

**Na entrevista:**
> "Cadeado no ramo. Pai despacha. Filho tranca. Webhook de pagamento, no projeto grande, pode ter outra barreira — assinatura, não JWT."

---

## eventos.rb

**O que é:**
O CRUD da A, recortado. Mesmo halt, mesmo insert.

**Como funciona:**
Quem lê o arquivo vê só evento. Sem `locais`. Review cabe.

**Na entrevista:**
> "O 422 de title está no eventos.rb. Eu não caço no app.rb."

---

## locais.rb

**O que é:**
O segundo ciclo. Campo `name`. Tabela `locais`.

**Como funciona:**
Cópia da forma, outro dataset. Prova que o plugin não é “só eventos em outro arquivo”. É outro prefixo.

**Na entrevista:**
> "Locais é o segundo Hash key. Mesmo padrão. Outra tabela."

---

## 404 de outro prefixo

**O que é:**
`GET /lotes` — não tem branch. hash_routes não casa. 404. Sem cair em eventos.

**Como funciona:**
O Hash não tem a chave `lotes`. Fim. No projeto grande você adiciona `routes/lotes.rb` e a chave passa a existir.

**Na entrevista:**
> "Prefixo sem branch é 404. Eu não misturo com o 404 do id."

---

## Recapitulando

- cadeado no filho
- um arquivo, um dataset
- prefixo desconhecido 404
- lote = chave nova depois

---

## Exercícios práticos

### Exercício 1: Cadeado só no pai

**Enunciado:** `require_authentication` no `route` antes do `hash_routes`. Pior?

<details>
<summary>Solução</summary>

Tranca **todos** os ramos. Webhook público quebra. Health autenticado sem querer. Ramo é o lugar certo quando as barreiras diferem. Pai único vale se **tudo** atrás do JWT — e ainda assim o filho documenta.

**Pontos-chave:**
- barreira por domínio
- webhook futuro
- documentar no arquivo
</details>

---

*Parte do [Ruby Projects Handbook](/)*
