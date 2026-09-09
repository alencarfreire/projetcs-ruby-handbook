# 5.5 Falha, retry, idempotência

> **TL;DR**
> Sidekiq retenta por padrão. Por isso o perform tem que poder rodar duas vezes. Lembrete: se já `checked_out`, return. Stay sumiu: `discard_on RecordNotFound` — não retenta o fantasma. Mail duplicado é o risco se você mandar sem olhar o status.

## Conteúdo

- [At-least-once](#at-least-once)
- [Idempotência](#idempotência)
- [discard_on](#discard_on)
- [O que retry não cura](#o-que-retry-não-cura)
- [Redis cai](#redis-cai)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## At-least-once

**O que é:**
O worker pode executar o job, mandar o mail, e morrer antes de acusar o Redis. Redis devolve o job. Segundo perform.

**Como funciona:**
Filas sérias não são exactly-once de graça. Você desenha o perform para o segundo run não explodir e, se possível, não mandar o segundo mail.

Neste recorte o segundo mail **pode** sair: não há tabela `reminders_sent`. Você fala isso. A cerca é o status `checked_in`. Check-out antecipado evita o primeiro. Crash no meio do primeiro: segundo mail. Take-home aceita. Produção: coluna `reminder_sent_at`.

**Na entrevista:**
> "At-least-once. Eu não prometo um mail. Eu prometo que o perform não corrompe o Stay. Duplicata de mail é o próximo recorte: um timestamp."

---

## Idempotência

**O que é:**
Rodar de novo não muda o domínio para um estado inválido. Stay continua stay.

**Como funciona:**
`return unless stay.checked_in?` — o segundo run depois do check-out não “reabre” o Thor. Não dá `update(status: :checked_in)`. Só lê e talvez manda mail.

Relatório: mandar duas vezes o mesmo e-mail. Chato. Não quebra o hotel. `find_each` + retry de um user não reprocessa os outros.

**Na entrevista:**
> "Idempotente no domínio. O mail pode duplicar. O Thor não volta para checked_in sozinho."

---

## discard_on

**O que é:**
Não retenta o impossível.

**Como funciona:**

```ruby
discard_on ActiveRecord::RecordNotFound
```

Stay 999999. `find` explode. Sem discard: retry até o dead set. Com discard: log e some. Spec: `perform_now(9_999_999)` não levanta.

`DeserializationError` seria o GlobalID. Recorte usa id, então RecordNotFound.

**Na entrevista:**
> "discard no not found. Retry não ressuscita a stay. Dead set é para bug, não para delete."

---

## O que retry não cura

**O que é:**
Senha SMTP errada, Redis cheio, código bugado que sempre explode.

**Como funciona:**
Retry exponencial. 25 vezes default do Sidekiq — pesado. Recorte não customiza `sidekiq_options retry:`. Você fala o default e que em produção você baixaria o retry do mailer.

Bug no perform: retry não conserta. Olha o dead.

**Na entrevista:**
> "Retry é para falha transitória. Redis piscou. Não é para rescue vazio."

---

## Redis cai

**O que é:**
`perform_later` no Puma falha. Check-in **já** salvou. Thor está hospedado. Lembrete perdido.

**Como funciona:**
Ordem: save, depois enqueue. Redis down: 500 no POST depois do commit. Usuário vê erro, Thor já está `checked_in`. Você recarrega: quadro certo, job não. Recorte: aceita. Produção: transaction outbox, ou enqueue primeiro com compensação — outro quadro. Capítulo 8.

**Na entrevista:**
> "Eu salvo depois enfileiro. Redis cai: domínio ok, job some. Outbox é o próximo desenho, não este app."

---

## Recapitulando

- At-least-once, não exactly-once
- Perform lê o agora
- discard no not found
- Retry ≠ conserto de bug
- Redis down ≠ rollback do Stay

---

## Exercícios práticos

### Exercício 1: reminder_sent_at

**Enunciado:** Desenhe a coluna que mata a duplicata de mail. Onde o job escreve?

<details>
<summary>Solução</summary>

`stays.reminder_sent_at`. Perform: se checked_in e `reminder_sent_at.nil?`, manda mail e seta Time.current. Segundo run vê o timestamp, return. Race: dois workers, dois mails — unique index ou `update_all` condicional. Recorte deste app: sem a coluna. Quadro: você desenha.

**Pontos-chave:**
- coluna no domínio
- write depois do mail ou update atômico
- race é a pergunta seguinte
</details>

### Exercício 2: Enqueue dentro da transaction

**Enunciado:** `Stay.transaction { stay.update!; perform_later }` e o Redis é mais rápido que o commit. O que o job vê?

<details>
<summary>Solução</summary>

Job roda, `find` não acha o status novo (ou a stay). Retry. Ou not found. Clássico. Enfileirar **depois** do commit. `after_commit` no model faria isso; neste recorte o controller enfileira depois do `update` que já commitou (autocommit). Entrevista puxa after_commit vs request.

**Pontos-chave:**
- job mais rápido que commit
- after_commit
- aqui o update já commitou
</details>

---

*Parte do [Ruby Projects Handbook](/)*
