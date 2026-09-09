# 14.5 Denylist e testes

> **TL;DR**
> Logout grava fingerprint SHA256 do `Authorization` em `jwt_denylist`. `require_login!` consulta. Token velho 401. Testes: minitest + rack-test. `bundle exec rake test`. Sem Redis. Sem Capybara.

## Conteúdo

- [O 11.3 era honesto](#o-113-era-honesto)
- [Fingerprint](#fingerprint)
- [rack-test](#rack-test)
- [O que o suite cobre](#o-que-o-suite-cobre)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O 11.3 era honesto

**O que é:**
JWT não revoga de graça. Aqui o logout **mata**.

**Como funciona:**
`after_logout` insert. `require_login!` depois do Rodauth: se a fingerprint existe, 401 `token revogado`. Sem jti no payload — o recorte hasheia o header que o cliente mandou.

**Na entrevista:**
> "Eu não minto o logout. Denylist. Token no header, hash na tabela, 401."

---

## Fingerprint

**O que é:**
SHA256 do valor de `Authorization`. Não guarda o JWT em claro.

**Como funciona:**
Logout precisa **mandar** o token. POST `/logout` JSON + header. DELETE sem body no Rodauth json: :only deu 400 neste recorte — o README usa POST.

**Na entrevista:**
> "Logout com o mesmo Authorization. Sem o header eu não sei o que revogar."

---

## rack-test

**O que é:**
`call(env)` sem porta. O mesmo app.

**Como funciona:**
`test/test_helper.rb` aponta sqlite `storage/test.sqlite3`. Migra. Limpa tabelas no setup. Envolve `RequestLog` + `RawBody` — senão o webhook não tem RAW_BODY e o `/up` não ganha request id.

**Na entrevista:**
> "Teste é Rack. Eu não subo Puma no CI. Redis não entra neste suite."

---

## O que o suite cobre

**O que é:**
Os curls que a entrevista puxa.

**Como funciona:**
401 sem token. Reservar ok e estoque. Esgotado 422. HMAC inválido 401. Replay um row. Logout 401. Expire devolve quantity. `/up` 200.

**Na entrevista:**
> "Oito examples. Fluxo, não coverage theatre. Esgotado e replay são os dois que o entrevistador desenha."

---

## Recapitulando

- denylist no logout
- POST /logout
- minitest + rack-test
- sqlite de test
- sem Redis no rake test

---

## Exercícios práticos

### Exercício 1: Teste sem RawBody

**Enunciado:** HMAC sempre 401 no test, 200 no curl. Por quê?

<details>
<summary>Solução</summary>

O test não passou no middleware RawBody. `env["RAW_BODY"]` nil. Body do parser ≠ bytes. config.ru tem o wrap; o `def app` do test também precisa.

**Pontos-chave:**
- mesmo stack
- RAW_BODY
</details>

---

*Parte do [Ruby Projects Handbook](/)*
