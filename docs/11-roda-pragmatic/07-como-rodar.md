# 11.7 Como rodar

> **TL;DR**
> `cd projects/11-roda-pragmatic`. `bundle install`. `bundle exec ruby bin/migrate`. `bundle exec puma`. POST `/create-account`, POST `/login`, copia `Authorization`, POST `/eventos`. Fonte: [código](/docs/11-roda-pragmatic/codigo).

## Conteúdo

- [migrate](#migrate)
- [curls](#curls)
- [401 de propósito](#401-de-propósito)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## migrate

**O que é:**
accounts + eventos.

**Como funciona:**

```bash
cd projects/11-roda-pragmatic
bundle install
bundle exec ruby bin/migrate
bundle exec puma
```

9292. Gemfile: roda, puma, sequel, sqlite3, rodauth, bcrypt, jwt.

**Na entrevista:**
> "jwt gem porque o feature JWT do Rodauth usa. Eu não implemento HS256 na mão."

---

## curls

**O que é:**
A prova. Campo `login`. Header `Accept: application/json`.

**Como funciona:**
README tem o roteiro. `-D -` mostra o `Authorization`. Copia. Lista eventos `[]`. POST Jazz 201. GET sem token 401.

**Na entrevista:**
> "login no JSON. Authorization na response. Sem token 401. Jazz 201."

---

## 401 de propósito

**O que é:**
O curl sem header. Você mostra.

**Como funciona:**
`GET /eventos` só com Accept. 401. Depois cola o token. 200.

**Na entrevista:**
> "Eu bato o 401 na call. Senão parece que o ramo é público."

---

## Recapitulando

- migrate + puma
- create-account / login
- Authorization
- 401 sem token

---

## Exercícios práticos

### Exercício 1: Accept

**Enunciado:** Sem `Accept: application/json` o login HTML-404. Por quê?

<details>
<summary>Solução</summary>

`json: :only` quer JSON. Accept e Content-Type. README tem os dois. Sem Accept o Rodauth pode recusar o modo JSON.

**Pontos-chave:**
- Accept
- Content-Type
- json: :only
</details>

---

*Parte do [Ruby Projects Handbook](/)*
