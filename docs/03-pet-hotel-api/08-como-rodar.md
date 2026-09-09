# 3.8 Como rodar e testar com curl

> **TL;DR**
> `cd projects/03-pet-hotel-api`. `bundle install`. `bin/rails db:prepare`. `bin/rails s`. Login seed: `joao@email.com` / `senha123`. POST `/api/v1/login`, copia o `token`, cola no `Authorization: Bearer`. Occupancy, owners, check-in. Specs: `bundle exec rspec`. Fonte: [código](/docs/03-pet-hotel-api/codigo). Sem tela. Sem cookie. Ctrl+C não apaga o SQLite — diferente do Hash do projeto 1.

## Conteúdo

- [Fonte no handbook](#fonte-no-handbook)
- [bundle e db:prepare](#bundle-e-dbprepare)
- [Login e o token](#login-e-o-token)
- [Roteiro de curls](#roteiro-de-curls)
- [401 de propósito](#401-de-propósito)
- [bundle exec rspec](#bundle-exec-rspec)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Fonte no handbook

**O que é:**
O app inteiro está neste livro. Você não precisa do GitHub para ler o contrato.

**Como funciona:**
Walkthrough é `docs/03-pet-hotel-api/`. Código que sobe é `projects/03-pet-hotel-api/`. A página [código](/docs/03-pet-hotel-api/codigo) cola User, ApplicationController, sessions, routes, stays. [Projetos](/projetos) tem a pasta e o comando.

**Quando usar:**
Antes do `bundle`. Na call, handbook + terminal.

**Na entrevista:**
> "O código está no handbook. Eu não dependo do GitHub para mostrar o Bearer."

---

## bundle e db:prepare

**O que é:**
Gems e banco. Igual o 2. SQLite em `storage/`.

**Como funciona:**

```bash
cd projects/03-pet-hotel-api
bundle install
bin/rails db:prepare
bin/rails s
```

`db:prepare` cria, migra, seeda. João, Maria, Thor checked_in, Luna scheduled. Porta 3000.

Não rode o 2 e o 3 na mesma porta. Mata um.

**Na entrevista:**
> "db:prepare. Seed igual ao HTML. O token do João nasce no create. Eu pego no login, não no sqlite."

---

## Login e o token

**O que é:**
O primeiro curl. Sem ele, o resto é 401.

**Como funciona:**

```bash
curl -s -X POST http://127.0.0.1:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@email.com","password":"senha123"}'
```

Body traz `token`. Copia. Exporta:

```bash
TOKEN="cole_aqui"
```

Signup também devolve token. Seed já tem o João — login chega.

`-i` mostra status. Sem `-i` você vê o JSON e esquece se foi 200 ou 401.

**Exemplo prático:**
Senha errada: 401 `{ "errors": ["e-mail ou senha inválidos"] }`. Sem `Content-Type`: params vazios, mesma 401. Olhe o header antes da senha.

**Na entrevista:**
> "Eu logoei, copiei o token, exportei TOKEN. Os curls seguintes usam o header. Eu não colo a senha no occupancy."

---

## Roteiro de curls

**O que é:**
A prova de que o recorte sobe. Occupancy, lista, create, check-in.

**Como funciona:**

```bash
curl -s http://127.0.0.1:3000/api/v1/occupancy \
  -H "Authorization: Bearer $TOKEN"

curl -s http://127.0.0.1:3000/api/v1/owners \
  -H "Authorization: Bearer $TOKEN"

curl -s -i -X POST http://127.0.0.1:3000/api/v1/owners \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"owner":{"name":"Carlos","email":"carlos@email.com"}}'
# 201, Location: .../owners/2

curl -s -X POST http://127.0.0.1:3000/api/v1/stays/1/check_out \
  -H "Authorization: Bearer $TOKEN"
```

Occupancy do seed lista o Thor. Check-out tira. Check-in de novo — se o model deixar no estado atual; Thor do seed já está `checked_in`. Check-out primeiro.

Create de stay:

```bash
curl -s -X POST http://127.0.0.1:3000/api/v1/stays \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"stay":{"pet_id":3,"check_in":"2026-09-10","check_out":"2026-09-13","nightly_rate_cents":8000}}'
```

Bidu é o pet 3 no seed se a ordem se manteve. Se o id mudou, `GET /api/v1/pets` primeiro. Não chute id.

**Quando usar:**
Antes da entrevista. O entrevistador quer ouvir que você rodou.

**Na entrevista:**
> "Occupancy do seed tem o Thor. Eu fiz check-out, a lista esvaziou. nights e total_cents vieram no JSON da stay."

---

## 401 de propósito

**O que é:**
O curl que prova o cadeado. Sem teatro.

**Como funciona:**

```bash
curl -s -i http://127.0.0.1:3000/api/v1/occupancy
# 401

curl -s -i -X DELETE http://127.0.0.1:3000/api/v1/logout \
  -H "Authorization: Bearer $TOKEN"
# 204

curl -s -i http://127.0.0.1:3000/api/v1/occupancy \
  -H "Authorization: Bearer $TOKEN"
# 401 de novo — token regenerado
```

Depois do logout, login de novo para continuar.

**Na entrevista:**
> "Eu bati occupancy sem header: 401. Logout 204. O mesmo token 401. Isso é regenerate, não JWT exp."

---

## bundle exec rspec

**O que é:**
Os três arquivos. Dez examples. Sem Redis. Sem Chrome.

**Como funciona:**

```bash
bundle exec rspec
```

Verde. Se vermelho: migration pendente no test — `db:prepare` de novo. Token nil: `has_secure_token` não rodou, coluna sumiu.

**Na entrevista:**
> "Dez examples. Auth, CRUD, stay. Não é coverage 100. É o contrato."

---

## Recapitulando

- `db:prepare` + `bin/rails s`
- Login, TOKEN, Bearer
- Occupancy do seed tem o Thor
- Logout mata o token
- rspec sem serviço extra

---

## Exercícios práticos

### Exercício 1: Porta ocupada

**Enunciado:** `bin/rails s` reclama da 3000. O 2 ainda está no ar. O que você faz na call?

<details>
<summary>Solução</summary>

Mata o 2 ou sobe o 3 em outra porta: `bin/rails s -p 3001`. Ajusta o curl. Não fica brigando com o Puma. Dois recortes, dois processos. SQLite diferente — cada app tem seu `storage/`.

**Pontos-chave:**
- um processo por projeto
- sqlite não é compartilhado
- porta no curl
</details>

### Exercício 2: Token no README

**Enunciado:** Você quer colar o token do seed no README para o curl ficar de uma linha. Por que o handbook não cola?

<details>
<summary>Solução</summary>

Token é aleatório. Cada `db:prepare` / regenerate muda. README com string fixa mente. O contrato é: login, copia, exporta. Igual senha no header — pior. A senha do seed é de demo; o token não é estável.

**Pontos-chave:**
- token não é senha123
- login é o passo 1
- README não mente o valor
</details>

---

*Parte do [Ruby Projects Handbook](/)*
