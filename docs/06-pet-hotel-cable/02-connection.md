# 6.2 Connection e current_user

> **TL;DR**
> O handshake do WebSocket ainda é HTTP. O cookie de session viaja. `ApplicationCable::Connection` lê `request.session[:user_id]`, busca o User, `identified_by :current_user`. Sem user: `reject_unauthorized_connection`. Anônimo não assina o quadro.

## Conteúdo

- [identified_by](#identified_by)
- [O cookie](#o-cookie)
- [reject](#reject)
- [find_by, não find](#find_by-não-find)
- [Não é o Bearer](#não-é-o-bearer)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## identified_by

**O que é:**
O Cable precisa saber quem é a conexão. Vira `current_user` nos channels.

**Como funciona:**

```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end
  end
end
```

`connect` roda uma vez. Channel `subscribed` herda `current_user`.

**Na entrevista:**
> "identified_by. Sem isso o channel não tem current_user. É o ApplicationController do cabo."

---

## O cookie

**O que é:**
Mesmo cookie do projeto 2. Same-origin. O browser manda no upgrade.

**Como funciona:**

```ruby
def find_verified_user
  user_id = request.session[:user_id]
  User.find_by(id: user_id) if user_id
end
```

SPA em outro host: cookie não vai. Aí token no protocolo. Recorte: mesmo host, cookie.

**Na entrevista:**
> "O cabo reusa a session. Eu não peço senha de novo. Eu também não colo o api_token na query do WS — vaza no log."

---

## reject

**O que é:**
Fecha o socket. 404/401 do cabo.

**Como funciona:**
Sem session: reject. User apagado, cookie zumbi: `find_by` nil, reject. Spec: `have_rejected_connection`.

O JS vê a conexão cair. Recorte: o quadro HTML ainda renderizou no GET — só o ao vivo some. Sem JS o quadro é o do 2.

**Na entrevista:**
> "Reject no handshake. Eu não deixo anônimo inscrito num stream vazio. Ele nem entra."

---

## find_by, não find

**O que é:**
A mesma lição do 2. `find` 500 no cabo. `find_by` nil, reject limpo.

**Como funciona:**
Session com id 999. `find` explode. Connection 500. `find_by` reject. Spec do anônimo + spec do user ok.

**Na entrevista:**
> "find_by no cabo. 500 no handshake é bug meu, não login velho."

---

## Não é o Bearer

**O que é:**
O projeto 3 autentica JSON com header. O 6 autentica WS com cookie. Dois recortes.

**Como funciona:**
API mobile + Cable: aí sim token no connect params. Recorte deste app: HTML + cookie. Não misture na call sem avisar.

**Na entrevista:**
> "Este painel é o browser da recepção. Cookie. Se a vaga for app mobile, eu passo o token no connect e acho o User pelo api_token."

---

## Recapitulando

- identified_by current_user
- session cookie no handshake
- reject anônimo
- find_by
- não é o token da API

---

## Exercícios práticos

### Exercício 1: Token na URL do WS

**Enunciado:** `ws://host/cable?token=abc`. Por que o handbook não faz?

<details>
<summary>Solução</summary>

Query string no access log, no proxy, no Referer. Cookie HttpOnly não aparece no JS. Recorte browser: cookie. Mobile: header ou subprotocolo, não query.

**Pontos-chave:**
- URL vaza
- cookie HttpOnly
- mobile é outro recorte
</details>

### Exercício 2: current_user no channel sem identified_by

**Enunciado:** Você esquece identified_by e lê session de novo no channel. Funciona?

<details>
<summary>Solução</summary>

Dá para ler `connection`. Sem identified_by, `current_user` no channel não existe. Você reimplementa. O helper existe para um lugar só: a Connection. DRY do cabo.

**Pontos-chave:**
- um lugar
- channel herda
- identified_by é o contrato
</details>

---

*Parte do [Ruby Projects Handbook](/)*
