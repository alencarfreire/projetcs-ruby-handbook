# 8.5 Redis cai, worker atrasou, token vazou

> **TL;DR**
> Três falhas que a entrevista puxa. Redis down: check-in já commitou, job some — outbox ou aceite. Worker atrasou: lembrete chega 11h, ainda idempotente. Token vazou: regenerate (3) ou rotate por device. O quadro não promete exactly-once.

## Conteúdo

- [Redis down](#redis-down)
- [Outbox](#outbox)
- [Worker atrasou](#worker-atrasou)
- [Token vazou](#token-vazou)
- [Puma morreu no meio do broadcast](#puma-morreu-no-meio-do-broadcast)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Redis down

**O que é:**
O 5 já mostrou: save, depois enqueue. Enqueue explode. Stay salva. Lembrete perdido.

**Como funciona:**
Opções no quadro:
1. Aceitar. Reconciliar com rake noturno (“stays checked_in com check_out=hoje sem reminder”).
2. Outbox: tabela `outbox_events` na **mesma** transação do Stay. Worker relê e publica no Redis.
3. Enqueue primeiro: job roda, stay ainda não existe — retry. Pior para o operador (check-in 500 sem stay).

Recorte honesto: 1 no take-home, 2 no desenho.

**Na entrevista:**
> "Eu não finjo transação com Redis. Outbox no Postgres. Ou um rake de reconciliação. Os dois são válidos."

---

## Outbox

**O que é:**
Uma tabela. `event_type`, `payload`, `published_at`. Commit junto com a stay.

**Como funciona:**
Processo (pode ser o próprio Sidekiq polling, ou um publisher) lê `published_at IS NULL`, manda para Redis, marca publicado. At-least-once de novo: publisher pode marcar depois de mandar. Job idempotente.

Não implementa neste livro. Desenha.

**Na entrevista:**
> "Outbox é linha no mesmo commit. A fila é derivado. Stay não depende do Redis para existir."

---

## Worker atrasou

**O que é:**
Fila cheia. Lembrete das 8h roda 11h. Thor ainda `checked_in`? Manda. Já saiu? No-op.

**Como funciona:**
SLA do mail: “no dia”, não “às 8:00:00”. Relatório das 7h às 9h ainda é o relatório. Se o atraso importa (SMS na hora da saída), você olha métrica de lag da fila e escala worker. Compose do 7: um worker. Produção: `replicas`.

Dead set: olha, não ignora. Mailer com SMTP 530: retry. Bug no perform: morto até deploy.

**Na entrevista:**
> "Atraso é lag. Idempotência segura o conteúdo. Escala o worker. Não mudo o check-in para sincrono por causa do mail."

---

## Token vazou

**O que é:**
Bearer do 3 no screenshot, no log, no celular perdido.

**Como funciona:**
Logout regenera. Um token por user: **todos** os clients caem. Produção: tabela `api_tokens` (device, last_used, revoke). JWT: `exp` curto + refresh, denylist se precisar matar antes do exp.

Cookie do HTML: `reset_session` + HttpOnly + Secure em produção. XSS lê o Bearer se estiver no localStorage. Recorte 3: o cliente é curl. App real: memória, não localStorage, ou cookie.

**Na entrevista:**
> "Vazou: regenerate. Um token só é simples e pune os outros devices. Tabela de tokens se a vaga tem mobile + Insomnia juntos."

---

## Puma morreu no meio do broadcast

**O que é:**
Stay commitada. `broadcast_to` não saiu. Quadro stale até o próximo evento ou F5.

**Como funciona:**
Aceitável para o quadro. Se precisar garantir o push: outbox de “occupancy_changed” e um publisher. Ou a página faz poll de backup a cada 30s. Híbrido: Cable + poll lento.

**Na entrevista:**
> "Broadcast é best-effort. GET é a verdade. A TV pode F5. O banco não mente."

---

## Recapitulando

- Redis down ≠ rollback do Stay
- Outbox no desenho
- Lag ≠ bug de conteúdo se idempotente
- Token: regenerate / tabela / exp
- Broadcast best-effort; GET verdade

---

## Exercícios práticos

### Exercício 1: Reconciliação

**Enunciado:** Escreva o rake que salva o lembrete perdido.

<details>
<summary>Solução</summary>

Stays `checked_in` com `check_out = Date.current` (ou Date.current..+1) que não têm `reminder_sent_at`. `perform_later(id)` para cada uma. Roda de hora em hora. Cobre Redis down e job discard errado. Coluna `reminder_sent_at` entra junto.

**Pontos-chave:**
- query do domínio
- mesmo job
- hora em hora, não no request
</details>

### Exercício 2: JWT exp 30 dias

**Enunciado:** O entrevistador ama JWT sem denylist, exp de um mês. Resposta?

<details>
<summary>Solução</summary>

Roubo vale 30 dias. Logout mente. Você pede exp curto (15 min) + refresh. Ou volta para token na tabela. JWT longo sem denylist é cookie eterno sem HttpOnly.

**Pontos-chave:**
- exp é a revogação
- logout precisa de denylist ou exp curto
- tabela ainda ganha no take-home
</details>

---

*Parte do [Ruby Projects Handbook](/)*
