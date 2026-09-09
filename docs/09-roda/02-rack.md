# 9.2 Rack

> **TL;DR**
> Roda é um app Rack. `call(env)` devolve `[status, headers, body]`. Puma fala HTTP e entrega o `env`. `config.ru` aponta para o app. Sem Rack, não tem Roda. Sem Puma (ou outro server), não tem porta.

## Conteúdo

- [O que é Rack](#o-que-é-rack)
- [call(env)](#callenv)
- [config.ru](#configru)
- [Puma](#puma)
- [freeze.app](#freezeapp)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que é Rack

**O que é:**
O contrato. Quase todo servidor Ruby web fala Rack. Rails fala. Sinatra fala. Roda fala. Hanami fala.

**Como funciona:**
O server (Puma) lê o TCP, monta um Hash `env` (`REQUEST_METHOD`, `PATH_INFO`, `rack.input`). Chama `app.call(env)`. Você devolve um array de três peças. O server escreve o HTTP.

No Java isso é Servlet. No WSGI do Python, `environ` + `start_response`. No PHP, o SAPI monta `$_SERVER` — não é um `call`, é o script inteiro.

**Quando usar:**
Sempre que o Ruby é HTTP. Até o `TCPServer` da outra trilha é “Rack na mão”. Aqui você não monta o HTTP. O Puma monta.

**Na entrevista:**
> "Roda não escuta a porta. Puma escuta. Roda é o call(env). Eu não misturo os dois nomes."

---

## call(env)

**O que é:**
Um método. Um Hash entra. Um Array sai.

**Como funciona:**

```ruby
status, headers, body = app.call(env)
# 200, { "content-type" => "application/json" }, ["{}"]
```

Você quase nunca chama `call` no dia a dia. O server chama. O teste chama (`Rack::MockRequest`). O `route do |r|` é açúcar em cima disso: o `r` é o request Rack.

**Exemplo prático:**
`GET /` neste projeto. `PATH_INFO` é `/`. O bloco `r.root` casa. Você devolve o Hash `{ "name" => "ingressos-routing" }`. O plugin `json` vira body JSON. Status 200.

**Na entrevista:**
> "env é o request. O array de três é a response. Roda preenche os dois. Puma serializa o fio."

---

## config.ru

**O que é:**
O arquivo que o Puma lê. Uma linha que importa. Uma linha que `run`.

**Como funciona:**

```ruby
require_relative "app"
run App.freeze.app
```

`rackup` também lê `config.ru`. `bundle exec puma` procura esse arquivo no diretório.

Sem `config.ru`, você teria que passar o app na mão. Recorte: o arquivo existe.

**Quando usar:**
Todo app Rack. Rails também tem. Roda também.

**Na entrevista:**
> "config.ru é o gancho. run App. O server não sabe o que é Roda. Sabe o que é call."

---

## Puma

**O que é:**
O processo na porta. Default 9292 neste recorte.

**Como funciona:**

```bash
cd projects/09-roda-routing
bundle exec puma
```

Threads. HTTP/1.1. `Ctrl+C` mata o processo e o Hash. Não é Unicorn. Não é Passenger. Recorte: Puma chega.

**Na entrevista:**
> "Puma na 9292. Roda não tem bind. Se a porta muda, é o server, não o route."

---

## freeze.app

**O que é:**
O jeito Roda de fechar o app depois de carregar plugins e rotas. Congela. Menos mutação em produção.

**Como funciona:**
`App.freeze.app` devolve o app Rack congelado. No `config.ru` é o recorte. Em teste você pode `App.app` sem freeze, se precisar recarregar. Neste take-home o freeze está no ru.

**Na entrevista:**
> "freeze.app. Plugins já carregaram. Rotas já existem. Eu não mudo a classe no request."

---

## Recapitulando

- Roda ⊆ Rack
- `call(env)` → `[status, headers, body]`
- `config.ru` + Puma
- Porta é o server
- freeze.app no ru

---

## Exercícios práticos

### Exercício 1: Roda escuta 9292?

**Enunciado:** O entrevistador fala “o Roda sobe na 9292”. Você corrige?

<details>
<summary>Solução</summary>

Corrige. Puma (ou rackup) escuta. Roda é o app. Trocar Puma por outro server Rack: a mesma `App`. A porta é flag do server.

**Pontos-chave:**
- server ≠ app
- config.ru
- bind é Puma
</details>

### Exercício 2: Sem config.ru

**Enunciado:** Você esquece o arquivo. Como sobe?

<details>
<summary>Solução</summary>

`rackup` reclama. Puma também. Dá para `Puma::Launcher` na mão. Recorte: o arquivo. Uma linha `run`. Sem drama.

**Pontos-chave:**
- ru é o contrato do server
- require app
- run freeze.app
</details>

---

*Parte do [Ruby Projects Handbook](/)*
