# 4.5 O que o Stream não faz (outra aba)

> **TL;DR**
> Stream viaja no response do POST. Quem não fez o POST não recebe o XML. A aba do lado, o celular na copa, o João no outro monitor — quadro velho. Isso é o recorte. Action Cable empurra o mesmo HTML por WebSocket. Projeto 6. Não misture os nomes.

## Conteúdo

- [Um request, um DOM](#um-request-um-dom)
- [A prova](#a-prova)
- [O que as pessoas chamam de realtime](#o-que-as-pessoas-chamam-de-realtime)
- [Ponte para o 6](#ponte-para-o-6)
- [Polling?](#polling)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Um request, um DOM

**O que é:**
HTTP request-response. Turbo Stream é body desse response. Não é push.

**Como funciona:**
Aba A POST check-out. Servidor devolve stream. Turbo na aba A aplica. Aba B está parada no GET antigo. Nenhum byte novo. Até F5.

No 2, a aba B também estava stale. Hotwire não piorou. Também não resolveu multi-aba.

**Quando usar:**
Quando o operador é um. Um browser. Uma recepção. A Pousada do take-home.

**Na entrevista:**
> "Stream não é WebSocket. É o HTML do response. A outra aba não é esse response."

---

## A prova

**O que é:**
O roteiro do README. Duas abas. Um clique.

**Como funciona:**
1. Login. `/` com o Thor.
2. Duplica a aba.
3. Na primeira, check-out.
4. Primeira: Thor some.
5. Segunda: Thor continua. Reload: some.

Se a segunda atualizasse, você instalou Cable sem perceber (`turbo_stream_from` + `broadcast_*`). Neste projeto não tem.

**Na entrevista:**
> "Eu demonstro as duas abas. A que clica atualiza. A outra não. Aí eu falo do 6."

---

## O que as pessoas chamam de realtime

**O que é:**
Três coisas diferentes no mesmo palavrão.

**Como funciona:**

| Nome | Cabo | Quem recebe |
|---|---|---|
| Turbo Stream no response | HTTP deste POST | quem clicou |
| Polling / refresh | HTTP GET periódico | quem está na página |
| Action Cable | WebSocket | quem está inscrito |

A entrevista usa “realtime” para as três. Você separa.

**Na entrevista:**
> "Realtime de Stream é o click. Realtime de Cable é o servidor falando. Eu não digo realtime sem dizer o cabo."

---

## Ponte para o 6

**O que é:**
O mesmo HTML de `_board`. Outro transporte.

**Como funciona:**
Projeto 6: `OccupancyChannel`, `broadcast_to(current_user, html)`. O JS na página troca o quadro. Check-in na aba A pinta a aba B.

Este projeto **não** inclui o channel. De propósito. Se você `broadcast` aqui, o recorte 4 e 6 viram o mesmo app e você não sabe o que o Frame faz sozinho.

**Quando usar:**
Quando o entrevistador pede “ao vivo”. Você: “neste recorte, não. No 6, sim. O HTML do quadro eu já tenho.”

**Na entrevista:**
> "O HTML eu reuso. O cabo muda. Frame/Stream primeiro, Cable depois."

---

## Polling?

**O que é:**
`meta refresh` ou `setInterval` GET no quadro. A aba B atualiza. Sem WebSocket.

**Como funciona:**
Serve. Custa request. Atraso = intervalo. Recorte: não entra. Você fala que existe. Cable é mais barato com poucos clientes olhando o mesmo quadro. Polling é mais simples operacionalmente (sem Redis adapter).

**Na entrevista:**
> "Polling eu conheço. Não está neste projeto. Cable no 6. Trade-off: simplicidade vs push."

---

## Recapitulando

- Stream = este response
- Outra aba stale
- “Realtime” são três cabos
- 6 reusa o HTML, muda o cabo
- Sem polling neste recorte

---

## Exercícios práticos

### Exercício 1: O entrevistador insiste que é bug

**Enunciado:** “A outra aba não atualizou, seu Turbo está quebrado.” Resposta?

<details>
<summary>Solução</summary>

Não está. Turbo aplicou o stream na aba do POST. A outra aba não fez POST. Eu mostro o Network: um request, um response stream. Na aba B, zero requests no clique. Bug seria a aba A não atualizar. Feature seria Cable.

**Pontos-chave:**
- Network tab
- um request
- nomes: Stream ≠ Cable
</details>

### Exercício 2: turbo_stream_from escondido

**Enunciado:** Você copia um snippet `turbo_stream_from "occupancy"` neste projeto. O que passa a ser verdade?

<details>
<summary>Solução</summary>

Você misturou o 6. Precisa de Cable, adapter, broadcast no model. O recorte 4 mente. Tira o snippet. Um projeto, um cabo.

**Pontos-chave:**
- from = inscrição
- replace no response = não precisa from
- não copie o README do Turbo inteiro
</details>

---

*Parte do [Ruby Projects Handbook](/)*
