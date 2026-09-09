# 6.3 Channel + stream_for

> **TL;DR**
> `OccupancyChannel` herda `ApplicationCable::Channel`. `subscribed` chama `stream_for current_user`. O nome do stream é o user. Broadcast usa o mesmo user. JS: `consumer.subscriptions.create("OccupancyChannel", { received })`.

## Conteúdo

- [subscribed](#subscribed)
- [stream_for](#stream_for)
- [O consumer JS](#o-consumer-js)
- [occupancy.js](#occupancyjs)
- [importmap](#importmap)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## subscribed

**O que é:**
O client pediu o channel. Você decide o stream.

**Como funciona:**

```ruby
class OccupancyChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Sem `stream_from "occupancy"` global. Sem args do client neste recorte — o user já veio da connection. Cliente não escolhe o stream. Senão Ana pede o stream do João.

**Na entrevista:**
> "subscribed. O client não manda user_id. Eu já sei quem é. Senão é IDOR no cabo."

---

## stream_for

**O que é:**
Helper que monta um nome de stream a partir do model. `broadcast_to(user, ...)` publica nesse nome.

**Como funciona:**
Dois users, dois streams. João inscrito não vê o payload da Ana. Spec: `have_stream_for(joao)`.

`stream_from` com o id do user na string é o mesmo, na mão. `stream_for` evita o typo.

**Na entrevista:**
> "stream_for user. broadcast_to user. Os dois têm que casar. String na mão eu erro o prefixo."

---

## O consumer JS

**O que é:**
`createConsumer()` aponta para `/cable`.

**Como funciona:**

```javascript
import { createConsumer } from "@rails/actioncable"
export default createConsumer()
```

Default path `/cable`. Route `mount ActionCable.server => "/cable"`. Sem o mount, 404 no WS.

**Na entrevista:**
> "createConsumer. Path /cable. Cookie vai sozinho no mesmo host."

---

## occupancy.js

**O que é:**
A inscrição e o `received`.

**Como funciona:**

```javascript
import consumer from "channels/consumer"

consumer.subscriptions.create("OccupancyChannel", {
  received(data) {
    const root = document.getElementById("occupancy-live")
    if (root && data.html) root.innerHTML = data.html
  }
})
```

`application.js` importa esse arquivo em **toda** página. Received com `occupancy-live` ausente: no-op. Stay show não tem o div. Broadcast chega, JS ignora. Barato neste recorte.

Poderia importar só no index. Recorte: um import, guard no DOM.

**Na entrevista:**
> "received troca o innerHTML. Se o div não está, eu não quebro. Stay show não é o painel."

---

## importmap

**O que é:**
Pin do Action Cable ESM da gem. Pin da pasta channels.

**Como funciona:**

```ruby
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
```

Sem npm. Sem Webpack. Igual o Turbo do 4, outro pacote.

**Na entrevista:**
> "actioncable.esm.js vem da gem. Eu não npm install actioncable."

---

## Recapitulando

- subscribed + stream_for user
- client não escolhe o stream
- createConsumer /cable
- received + innerHTML
- importmap da gem

---

## Exercícios práticos

### Exercício 1: params[:user_id] no subscribe

**Enunciado:** O JS manda `{ user_id: 1 }`. O channel faz `stream_for User.find(params[:user_id])`. Buraco?

<details>
<summary>Solução</summary>

Sim. Ana assina o João. Sempre `current_user` da connection. Params do client não autorizam.

**Pontos-chave:**
- IDOR no cabo
- identity na connection
- params não são trust
</details>

### Exercício 2: JSON vs HTML no payload

**Enunciado:** Por que HTML e não `{ pet: "Thor" }` para o JS montar a linha?

<details>
<summary>Solução</summary>

Recorte: o servidor já sabe renderizar o quadro. JS burro. JSON exigiria o JS conhecer colunas, dinheiro, empty state. Entrevista de front: JSON. Este livro: HTML no cabo, igual o 4 mandava HTML no Stream.

**Pontos-chave:**
- HTML no servidor
- JS é transporte até o div
- JSON é outro recorte
</details>

---

*Parte do [Ruby Projects Handbook](/)*
