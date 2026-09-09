# 5.6 Specs de job

> **TL;DR**
> Adapter `:test`. `have_enqueued_job` no POST de check-in. `perform_now` + `ActionMailer::Base.deliveries` no job spec. Sem Redis. Sem processo Sidekiq. Sem FactoryBot.

## Conteúdo

- [Dois momentos](#dois-momentos)
- [Enqueue no request](#enqueue-no-request)
- [Perform no job spec](#perform-no-job-spec)
- [discard](#discard)
- [O que não entra](#o-que-não-entra)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Dois momentos

**O que é:**
Enfileirou? Executou certo? Duas perguntas. Dois specs.

**Como funciona:**
Request spec não chama o mailer. Job spec não sobe o POST. Se você só testa perform, o controller pode ter esquecido o `perform_later`. Se você só testa enqueue, o perform pode mandar mail no check-out.

**Na entrevista:**
> "Eu testo o gatilho e o perform. Separado. Inline no test esconderia o gatilho."

---

## Enqueue no request

**O que é:**
O example no `stays_and_occupancy_spec`.

**Como funciona:**

```ruby
expect {
  post check_in_stay_path(stay)
}.to have_enqueued_job(CheckoutReminderJob).with(stay.id)
```

`ActiveJob::TestHelper` no `rails_helper`. Stay com `check_out` futuro — senão o controller skipa e o spec falha sem explicar.

Não asserta `at:` do wait_until neste recorte. Frágil de fuso. O with(id) basta.

**Na entrevista:**
> "have_enqueued_job. with stay.id. Eu não comparo Time com milissegundo."

---

## Perform no job spec

**O que é:**
`spec/jobs/checkout_reminder_job_spec.rb` e o do relatório.

**Como funciona:**
Checked_in: um mail, subject com Thor, to João.
Checked_out: zero mails.
Relatório: body tem Thor, não Luna.

`perform_now` — sincrono, adapter irrelevante.

**Na entrevista:**
> "deliveries. Eu não abro o tmp/mails no spec. Test adapter do mailer."

---

## discard

**O que é:**
Stay inexistente. `expect { perform_now(9_999_999) }.not_to raise_error`.

**Como funciona:**
Prova o `discard_on`. Sem isso, o example vermelho com RecordNotFound. A entrevista vê o spec e acredita no discard.

**Na entrevista:**
> "O spec do id fantasma. Retry não está em teste — o default do Sidekiq. Discard está."

---

## O que não entra

**O que é:**
rspec-sidekiq gem. Stub de Redis. System spec do crontab.

**Como funciona:**
Active Job test helper cobre o recorte. Você não prova que o cron do SO existe. Prova que o rake existe rodando `bin/rails reports:daily` na mão, no 5.7.

**Na entrevista:**
> "Eu não testo o crontab. Eu testo o rake na call e o job no rspec."

---

## Recapitulando

- Enqueue ≠ perform
- `:test` + deliveries
- with(id)
- discard com id fantasma
- Sem Redis no CI

---

## Exercícios práticos

### Exercício 1: Spec verde, produção muda

**Enunciado:** Você esquece `queue_adapter = :sidekiq` no development. Specs verdes. João não recebe mail. Por quê?

<details>
<summary>Solução</summary>

Test usa `:test` e `perform_now`. Development `:async` ou esquecido: job some no Puma ou nem enfileira no Redis. Spec não cobre o adapter de dev. README dos três processos cobre. Entrevista: “o spec não substitui o sidekiq no ar”.

**Pontos-chave:**
- spec ≠ processo
- adapter por env
- README é parte do recorte
</details>

### Exercício 2: have_enqueued_job no check-out

**Enunciado:** Check-out também deveria enfileirar? Spec espera zero jobs. O que você cobre?

<details>
<summary>Solução</summary>

Neste recorte check-out não enfileira. Spec extra: `expect { post check_out }.not_to have_enqueued_job(CheckoutReminderJob)`. Documenta o negativo. Não está no repo — exercício. Você escreve se o entrevistador puxar.

**Pontos-chave:**
- negativo é spec
- um gatilho só
- check-out = no-op no perform, não novo job
</details>

---

*Parte do [Ruby Projects Handbook](/)*
