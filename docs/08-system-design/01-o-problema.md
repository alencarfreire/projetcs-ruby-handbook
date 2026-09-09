# 8.1 O problema em escala

> **TL;DR**
> Os projetos 2–7 cabem num laptop. Este capítulo é o quadro. A Pousada ganha dez recepções, um app mobile, um painel na TV, mil pets no fim de semana. SQLite não é o vilão — é o recorte que acabou. Você desenha. Sem código novo.

## Conteúdo

- [O que este capítulo é](#o-que-este-capítulo-é)
- [O que não é](#o-que-não-é)
- [A Pousada cresceu](#a-pousada-cresceu)
- [O que você já tem](#o-que-você-já-tem)
- [A pergunta da entrevista](#a-pergunta-da-entrevista)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que este capítulo é

**O que é:**
Prática de system design no domínio que você construiu. Sem `projects/08`. Sem gem nova.

**Como funciona:**
Você aponta para os apps 2–7 e fala o que quebra quando o número muda. Uma recepção → dez. Um Puma → N. Um SQLite → Postgres. Um async Cable → Redis adapter. Um token na coluna → revogação.

**Quando usar:**
A parte “desenha no quadro” da entrevista. Depois do take-home. Quando o entrevistador fecha o laptop e pega o marcador.

**Na entrevista:**
> "Eu já subi o hotel. Agora eu desenho o que eu não pus no take-home, e por quê."

---

## O que não é

**O que é:**
Não é Netflix. Não é Uber de pets. Não é marketplace. Continua a recepção da Pousada do Thor.

**Como funciona:**
Crescer não muda o domínio: Owner, Pet, Stay, centavos integer, uma `checked_in` por pet. Muda o envelope: banco, fila, cabo, auth, falha.

Se o entrevistador puxar “app do dono agenda sozinho”, você recorta: isso é outro ator. Maria deixa de ser só cadastro. Fora, a menos que peçam.

**Na entrevista:**
> "Eu não desenho o Airbnb. Eu desenho a recepção maior. Recorte continua."

---

## A Pousada cresceu

**O que é:**
Números para o quadro. Inventados. Servem para forçar escolha.

**Como funciona:**

| Agora (projetos) | Escala do quadro |
|---|---|
| 1 user João | 20 recepcionistas, 3 filiais |
| SQLite arquivo | Postgres |
| 1 Puma | 3 web + 3 workers |
| Cable async | Redis pub/sub |
| Token na coluna User | token por device + rotate |
| Mail em tmp/mails | SMTP + fila |
| Cron na máquina | scheduler |

Filial: ainda um `user_id` ou vira `account_id`? Entrevista. Recorte sugerido: `Account has_many users`. Você não implementa. Você desenha.

**Na entrevista:**
> "Três filiais. Eu não começo pelo Kubernetes. Eu pergunto: um banco ou três? Um quadro ou três?"

---

## O que você já tem

**O que é:**
O inventário. A entrevista ama quem reusa o take-home.

**Como funciona:**

- 2: domínio, HTML, session, regra no model
- 3: JSON, Bearer, 401/404
- 4: HTML parcial no response
- 5: fila, id na mensagem, idempotência rasa
- 6: cabo, stream por user
- 7: três processos, volume, hostname

Cada peça já tem limite documentado no próprio recorte. Este capítulo junta os limites.

**Na entrevista:**
> "O model Stay continua. Eu não redesenho nights em Float porque cresceu. Integer continua."

---

## A pergunta da entrevista

**O que é:**
“Desenha o hotel.” 30–45 minutos. Você recorta de novo.

**Como funciona:**
1. Atores: recepção, (talvez) app interno.
2. Fluxos: check-in, quadro, lembrete, API.
3. Dados: Stay é a fonte da ocupação.
4. Cabos: HTTP, WS, fila.
5. Falha: Redis, worker, dois check-ins.

Os capítulos 8.2–8.5 são essas cinco. 8.6 é o exercício único.

**Na entrevista:**
> "Eu recorto o quadro em atores, fluxos, dados, cabos, falha. Sem isso eu desenho um boneco de microserviço."

---

## Recapitulando

- Sem código. Quadro.
- Mesmo domínio, envelope maior
- Inventário 2–7
- Números para forçar escolha
- Cinco blocos, um exercício

---

## Exercícios práticos

### Exercício 1: O entrevistador pede Kafka

**Enunciado:** Você desenha Redis + Sidekiq. Ele fala Kafka. O que você faz?

<details>
<summary>Solução</summary>

Pergunta o porquê. Um hotel com 20 recepções não precisa de log de eventos distribuído. Se a empresa já tem Kafka, você encaixa o worker como consumer. Se não tem, Redis é o recorte. Não aceite o nome da moda sem carga.

**Pontos-chave:**
- carga antes da ferramenta
- Redis aguenta o quadro
- Kafka é outro problema
</details>

### Exercício 2: Multi-tenant de verdade

**Enunciado:** Três marcas de hotel, um Rails. Onde entra o `account_id`?

<details>
<summary>Solução</summary>

Em Stay, Pet, Owner, User. Query sempre scoped. Token/session carrega account. Occupancy não mistura Thor de um hotel com Bidu do outro. SQLite único ainda “funciona” até o disco. Postgres + índice `(account_id, ...)`. Sem account_id no JSON do cliente — igual o `user_id` do 3.

**Pontos-chave:**
- scope na query
- não no payload de entrada
- índice composto
</details>

---

*Parte do [Ruby Projects Handbook](/)*
