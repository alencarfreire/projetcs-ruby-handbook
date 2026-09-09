# 5.3 Lembrete de check-out

> **TL;DR**
> No check-in com sucesso: `CheckoutReminderJob.set(wait_until: check_out 8h).perform_later(stay.id)`. O job busca a stay de novo. Se ainda `checked_in`, manda mail. Se já saiu ou sumiu, no-op / discard. Passa id. Não passa o objeto.

## Conteúdo

- [O enqueue](#o-enqueue)
- [wait_until](#wait_until)
- [perform](#perform)
- [O mailer](#o-mailer)
- [id, não objeto](#id-não-objeto)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O enqueue

**O que é:**
Depois do `update(status: :checked_in)`. Falhou o update, não enfileira.

**Como funciona:**

```ruby
def enqueue_checkout_reminder(stay)
  reminder_at = stay.check_out.to_time.change(hour: 8)
  return unless reminder_at.future?

  CheckoutReminderJob.set(wait_until: reminder_at).perform_later(stay.id)
end
```

Se o check-out já passou das 8h (stay atrasada), não agenda no passado. Recorte: skip. Em produção você poderia enfileirar na hora.

**Quando usar:**
Efeito colateral **depois** da regra persistir. Enfileirar antes do save e o save falhar: mail zumbi.

**Na entrevista:**
> "Eu enfileiro depois do update true. Stay.id. 8h da data de check_out."

---

## wait_until

**O que é:**
Scheduled set no Redis. O worker não pega antes da hora.

**Como funciona:**
`Date#to_time` + `change(hour: 8)`. Time zone do app. Recorte: default. Entrevista pode puxar `config.time_zone` — você fala “aqui eu não setei; em produção eu seto Brasil e o 8h é 8h de Brasília”.

**Na entrevista:**
> "wait_until não é sleep. É score no Redis. O processo não fica preso."

---

## perform

**O que é:**
A verdade **agora**, não a verdade do enqueue.

**Como funciona:**

```ruby
def perform(stay_id)
  stay = Stay.includes(:pet, :owner, :user).find(stay_id)
  return unless stay.checked_in?

  CheckoutReminderMailer.remind(stay).deliver_now
end
```

`deliver_now` no job: o worker já é o background. `deliver_later` enfileiraria de novo. Recorte: now.

`discard_on ActiveRecord::RecordNotFound` — stay apagada, job morre limpo. Sem retry infinito.

**Na entrevista:**
> "O job pergunta o status agora. Enqueue não congela o Thor como hospedado. Check-out antecipado cancela o mail sem cancelar o job."

---

## O mailer

**O que é:**
`CheckoutReminderMailer.remind(stay)`. Subject com o nome do pet. To: `stay.user.email` — João, a recepção, não a Maria.

**Como funciona:**
Development: arquivo em `tmp/mails`. Test: `ActionMailer::Base.deliveries`. Sem SMTP.

**Na entrevista:**
> "O mail é da recepção. Maria não opera o hotel. from pousada@thor.local. SMTP fica para produção."

---

## id, não objeto

**O que é:**
A regra de ouro. Fila serializa JSON. Active Record na fila é snapshot velho **e** GlobalID.

**Como funciona:**
`perform_later(stay.id)`. Perform faz `find`. Coluna mudou: você vê a mudança. `perform_later(stay)` serializa GlobalID; stay apagada vira `DeserializationError`. Recorte usa id + `RecordNotFound` + discard.

**Na entrevista:**
> "Eu passo o id. O objeto na fila é o Thor de três dias atrás. O banco é o Thor de agora."

---

## Recapitulando

- Enqueue depois do save
- wait_until 8h
- perform olha checked_in agora
- deliver_now no worker
- id na mensagem

---

## Exercícios práticos

### Exercício 1: Cancelar o job no check-out

**Enunciado:** O entrevistador pede para apagar o job scheduled no check-out. Você faz?

<details>
<summary>Solução</summary>

Dá, com API do Sidekiq e o jid salvo na stay. Recorte: não. O job é barato e idempotente. Check-out antecipado: perform no-op. Menos estado. Se a vaga exige cancel, você desenha o jid.

**Pontos-chave:**
- idempotência > cancel
- jid é outro recorte
- no-op é válido
</details>

### Exercício 2: deliver_later no job

**Enunciado:** Você escreve `remind(stay).deliver_later` dentro do perform. O que acontece?

<details>
<summary>Solução</summary>

Dois jobs. O de lembrete só enfileira o de mail. Funciona. Recorte demais. `deliver_now` no worker já está fora do Puma. Entrevista: “later no request, now no worker”.

**Pontos-chave:**
- later = fila
- o perform já é a fila
- now aqui
</details>

---

*Parte do [Ruby Projects Handbook](/)*
