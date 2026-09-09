# 6.1 Recorte: outra aba, não o mesmo POST

> **TL;DR**
> O projeto 4 atualiza quem clicou. Este atualiza quem está **inscrito**. Check-in na stay, quadro na outra janela pinta o Thor. WebSocket. Connection lê a session. Channel `stream_for current_user`. Sem Turbo Streams over Cable: o JS troca o `innerHTML`. Adapter `async` em dev/test.

## Conteúdo

- [Este projeto não é o 4](#este-projeto-não-é-o-4)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [O cabo](#o-cabo)
- [O que fica de fora](#o-que-fica-de-fora)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Este projeto não é o 4

**O que é:**
O 4 mandou Stream no **response**. Este manda JSON/HTML no **socket**. O clique pode estar em outra página.

**Como funciona:**
Janela A: `/stays/2` check-in da Luna. Janela B: `/` occupancy. B não fez POST. B recebe o broadcast. O 4 não faz isso.

**Quando usar:**
“Painel ao vivo”. Duas recepções. TV na parede. Entrevista que fala WebSocket.

**Na entrevista:**
> "No 4 o Stream era o body do POST. Aqui o POST devolve 302 igual o 2, e um broadcast no meio. A outra aba ouve o cabo."

---

## O problema

**O que é:**
O quadro na recepção fica aberto. Outra pessoa (ou outra janela do João) faz check-in. O quadro tem que pintar sem F5.

**Como funciona:**
`OccupancyChannel.broadcast_to(current_user, { html: ... })`. JS no `/` substitui `#occupancy-live`. Ana não recebe o broadcast do João: `stream_for current_user`.

**Exemplo prático:**
Duas janelas, mesmo login. Luna scheduled. Check-in numa. A outra lista a Luna.

**Na entrevista:**
> "stream_for user. Eu não emito para o mundo. O hotel da Ana não pinta o Thor do João."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Action Cable, `/cable` | AnyCable |
| Connection + session cookie | JWT no subprotocolo |
| `broadcast_to` no controller | `turbo_stream_from` |
| JS `innerHTML` | Stimulus, React |
| adapter `async` / `test` | Redis adapter (7/8) |
| channel spec | system spec de WS |

Por que JS cru, não Turbo Stream over Cable? Porque o ponto é o channel visível. `turbo_stream_from` esconde o cabo. O 4 já mostrou Stream. Aqui o cabo.

**Na entrevista:**
> "Eu não usei turbo_stream_from. Eu quis o channel no quadro. HTML eu já sei montar. O novo é o WebSocket."

---

## O cabo

**O que é:**
HTTP upgrade. Depois, frames WebSocket. Rails monta em `/cable`.

**Como funciona:**
Browser: `createConsumer()` conecta. Cookie de session vai no handshake. Connection aceita ou rejeita. Subscribe `OccupancyChannel`. Fica aberto.

Puma precisa de timeout longo no socket. Recorte local: default.

**Na entrevista:**
> "Handshake HTTP, depois WS. A session cookie autentica o cabo. Não é o Bearer do 3 — é o cookie do 2."

---

## O que fica de fora

**O que é:**
A lista.

**Como funciona:**
Redis adapter (fan-out entre processos Puma). AnyCable. Sidekiq. API. Stimulus. Auth no token de query string.

**Na entrevista:**
> "async adapter é um processo. Dois Pumas não se falam. Redis adapter no 7/8."

---

## Como o walkthrough anda

**O que é:**
6.2 connection. 6.3 channel. 6.4 broadcast. 6.5 specs. 6.6 como rodar. [Código](/docs/06-pet-hotel-cable/codigo).

**Na entrevista:**
> "Duas janelas. Check-in. A outra pintou. Network WS, não turbo-stream."

---

## Recapitulando

- Outra aba = outro cabo
- stream_for user
- JS innerHTML, channel visível
- async em dev
- Cookie no handshake

---

## Exercícios práticos

### Exercício 1: Mesmo HTML do 4?

**Enunciado:** Dá para reusar o `_board` do Hotwire?

<details>
<summary>Solução</summary>

Sim. O HTML do quadro é o mesmo domínio. O transporte muda. Neste repo os apps são recortes separados — o partial se parece, não é um gem compartilhado. Na entrevista: “o partial eu reuso; o cabo não.”

**Pontos-chave:**
- HTML ≠ cabo
- recortes independentes neste livro
- domínio igual
</details>

### Exercício 2: Broadcast para "occupancy"

**Enunciado:** `broadcast_to("occupancy")` global. O que vaza?

<details>
<summary>Solução</summary>

Ana vê o Thor do João. stream_for current_user existe para isso. String global é chat da casa. Hotel não é chat.

**Pontos-chave:**
- stream por user
- string global = todos
- recorte por user igual o HTML
</details>

---

*Parte do [Ruby Projects Handbook](/)*
