# 11.5 401, 404, 422

> **TL;DR**
> 401 o Rodauth. 422 o title. 404 o id. 201 o insert. 200 o GET. Create-account e login do Rodauth devolvem **200** com `{ "success": "..." }` — não 201. O recorte não briga com o default.

## Conteúdo

- [401](#401)
- [422 e 404](#422-e-404)
- [200 do Rodauth](#200-do-rodauth)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## 401

**O que é:**
Sem JWT. JWT lixo. `require_authentication`.

**Como funciona:**
Body `{ "error": "Please login to continue" }` (inglês default). Chave `error`, singular — o Rodauth. Seus 404/422 usam `errors` array. Dois shapes. Você **fala**. Unificar é config. Recorte: conviver e apontar.

**Na entrevista:**
> "401 é o Rodauth. error singular. Os meus 422 são errors array. Eu não escondo a costura."

---

## 422 e 404

**O que é:**
Os mesmos halt da fase 9. Agora o 404 é `where.first` nil, não Hash constante.

**Como funciona:**
Title vazio: halt 422 **depois** do require. Sem token você nem chega no title. Ordem: identidade, depois regra, depois recurso.

**Na entrevista:**
> "401 antes. 422 title. 404 id. A ordem é o cadeado, a regra, a store."

---

## 200 do Rodauth

**O que é:**
`/create-account` 200. `/login` 200. Não é REST de recurso Evento.

**Como funciona:**
Auth não é CRUD de account neste recorte. É feature. 200 + success + header Authorization. Você não força 201 no plugin.

**Na entrevista:**
> "Create-account 200. Evento 201. Eu não misturo os dois contratos."

---

## Recapitulando

- 401 Rodauth
- 422/404 seus
- shapes diferentes, dito
- 201 só no evento

---

## Exercícios práticos

### Exercício 1: Traduzir o 401

**Enunciado:** Dá?

<details>
<summary>Solução</summary>

Dá. Config do Rodauth (`unauthenticated_notice` / json error). Recorte não traduz. Take-home: default. Vaga pt-BR: você configura e mostra.

**Pontos-chave:**
- default inglês
- config existe
- não agora
</details>

---

*Parte do [Ruby Projects Handbook](/)*
