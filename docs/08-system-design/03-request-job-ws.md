# 8.3 Request vs job vs websocket

> **TL;DR**
> Três cabos. Request: o humano espera. Job: o humano não espera. Websocket: o humano já está na página e o servidor fala. Escolher o cabo errado é o bug de desenho mais comum neste domínio.

## Conteúdo

- [A regra](#a-regra)
- [O que é request](#o-que-é-request)
- [O que é job](#o-que-é-job)
- [O que é websocket](#o-que-é-websocket)
- [O 4 no meio](#o-4-no-meio)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A regra

**O que é:**
Uma frase para o quadro.

**Como funciona:**
- O operador precisa da resposta **agora** para continuar o clique → request (e talvez Stream no response).
- O trabalho é para **depois** ou para **outro sistema** (mail, PDF, relatório) → job.
- Alguém **já está olhando** e não clicou → websocket (ou polling, se o cabo não valer a pena).

**Na entrevista:**
> "Eu escolho o cabo pela espera. Agora, depois, ou empurrado."

---

## O que é request

**O que é:**
Check-in, CRUD, login. 200 em dezenas de ms. A regra do model roda aqui. Sem “enfileira o check-in”.

**Como funciona:**
Check-in na fila: o quadro mente até o worker. Dois workers, duas `checked_in`. A validação tem que ser no write síncrono, no banco. Job **depois** avisa. Job não autoriza o Thor a entrar.

**Na entrevista:**
> "Check-in é request. A regra unique checked_in é transação. Fila não é lock."

---

## O que é job

**O que é:**
Lembrete 8h. Relatório 7h. Gerar recibo PDF. Ping no WhatsApp da Maria. Tudo que pode esperar e pode falhar e retentar.

**Como funciona:**
Id na mensagem. Perform lê o agora. At-least-once. Outbox se o enqueue não pode se perder (8.5). Não usar job para “salvar a stay”.

**Na entrevista:**
> "Job é efeito. Stay é fato. Eu não inverto."

---

## O que é websocket

**O que é:**
O quadro aberto. TV. Segunda recepção. Fan-out pequeno.

**Como funciona:**
Broadcast depois do commit do request. Payload: HTML do 6 ou JSON da linha. Adapter Redis quando tem mais de um web. Auth no handshake (cookie ou token). Stream por account/user.

Polling a cada 5s: 20 telas × 12 req/min. Postgres aguenta. Cable vale quando o push é o produto (“ao vivo”) ou a carga de poll dói. Entrevista: você conhece os dois.

**Na entrevista:**
> "WS quando tem olho aberto. Polling quando eu não quero Redis adapter. Check-in não espera o WS."

---

## O 4 no meio

**O que é:**
Turbo Stream no response. Não é WS. Não é job.

**Como funciona:**
A aba que clicou atualiza sem reload. Barato. Sem Redis. Convive com o 6: a aba do clique usa o response; as outras usam o cabo. Ou só o cabo, e a aba do clique também recebe o broadcast (pode duplicar o replace — idempotente no DOM).

**Na entrevista:**
> "Stream no POST é cortesia da aba. Cable é o resto. Eu posso ter os dois."

---

## Recapitulando

- Agora = request
- Depois = job
- Olho aberto = WS (ou poll)
- Check-in não vai para a fila
- 4 e 6 são cabos de UI, não de domínio

---

## Exercícios práticos

### Exercício 1: Check-in async

**Enunciado:** “Enfileira o check-in para não travar.” Por que não?

<details>
<summary>Solução</summary>

O operador precisa saber se o Thor entrou. 422 tem que voltar no clique. Fila + “processando...” vira fila de recepção. A validação unique precisa do banco na hora. Travar 20ms de update não é o problema.

**Pontos-chave:**
- feedback no clique
- regra síncrona
- fila é o mail
</details>

### Exercício 2: Relatório no WS

**Enunciado:** Empurrar o relatório diário no quadro via Cable. Bom?

<details>
<summary>Solução</summary>

Relatório é mail/arquivo. O quadro é occupancy agora. Misturar: o painel ganha um toast. Pode. Não substitui o mail do João que não está com o browser aberto. Cabo ≠ inbox.

**Pontos-chave:**
- destinatário ausente
- mail para quem não está inscrito
- quadro = agora
</details>

---

*Parte do [Ruby Projects Handbook](/)*
