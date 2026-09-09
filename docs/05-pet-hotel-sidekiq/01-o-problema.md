# 5.1 O que não cabe no request

> **TL;DR**
> Check-in do Thor é rápido. Lembrar o João às 8h do dia da saída **não** é. Relatório diário de ocupação também não. O request devolve 302. O worker manda o mail depois. Redis segura a fila. Sidekiq é o processo. Sem `sidekiq-cron`: o rake enfileira, o cron do SO dispara o rake.

## Conteúdo

- [Este projeto não é o 2](#este-projeto-não-é-o-2)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [Três processos](#três-processos)
- [O que fica de fora](#o-que-fica-de-fora)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Este projeto não é o 2

**O que é:**
O 2 termina no redirect. Este continua depois do request. Mesmo HTML. Outro processo.

**Como funciona:**
João clica check-in. O controller grava `checked_in` e chama `perform_later`. O Puma não espera o mail. O Sidekiq pega o job quando a hora chegar.

No PHP você mandaria para uma fila Redis/Beanstalk. No Java, um `@Async` ou um broker. Aqui, Active Job + Sidekiq.

**Quando usar:**
Vaga que pede “background job”. Qualquer coisa que não pode prender o POST.

**Na entrevista:**
> "O request não manda o mail das 8h. Ele enfileira. Se o Puma mandasse o mail com sleep, eu travava a recepção."

---

## O problema

**O que é:**
Dois jobs. Lembrete: Thor sai hoje. Relatório: quem está `checked_in` agora, uma vez por manhã.

**Como funciona:**
Lembrete nasce no check-in, com `wait_until` 8h da data de `check_out`. Relatório não nasce num click — nasce no `bin/rails reports:daily`. Cron do SO chama o rake. O rake chama `perform_later` para cada User.

**Exemplo prático:**
Thor check-out daqui a 3 dias. Job scheduled no Sidekiq. João faz check-out amanhã. Job ainda roda no dia 3, vê `checked_out`, some sem mail. Idempotente.

**Na entrevista:**
> "Dois gatilhos. Check-in enfileira o lembrete. Cron enfileira o relatório. Sidekiq não é o cron."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Sidekiq + Redis + Active Job | `sidekiq-cron`, Sidekiq Pro |
| `wait_until` no lembrete | whenever gem |
| rake `reports:daily` | clockwork |
| Mailer `:file` / `:test` | SendGrid, SMTP |
| id no `perform` | objeto Active Record na fila |
| spec sem Redis | Capybara no worker |

**Na entrevista:**
> "Sidekiq-cron esconde o gatilho. Eu quero o rake no quadro. O cron do Linux é uma linha. A fila é outra."

---

## Três processos

**O que é:**
Puma, Sidekiq, Redis. Falta um, o recorte mente.

**Como funciona:**
Puma: HTTP. Sidekiq: `perform`. Redis: a lista. SQLite continua o domínio. Redis **não** é o banco do Thor.

`Ctrl+C` no Puma não mata o job scheduled. Mata o Sidekiq, o job fica no Redis até o worker voltar — se o adapter é Sidekiq. Adapter `:async` no Puma morre com o Puma. Por isso development aqui é `:sidekiq`.

**Na entrevista:**
> "Três processos. Redis não substitui o SQLite. Fila não é tabela de stay."

---

## O que fica de fora

**O que é:**
A lista.

**Como funciona:**
Hotwire, Cable, API, Postgres, SMTP de verdade, cron gem. Docker é o 7: empacota estes três processos.

**Na entrevista:**
> "O mail em tmp/mails. Eu não configuro SMTP neste take-home. O job existe. O mailer renderiza. Spec bate deliveries."

---

## Como o walkthrough anda

**O que é:**
5.2 Redis + adapter. 5.3 lembrete. 5.4 relatório. 5.5 falha. 5.6 specs. 5.7 como rodar. [Código](/docs/05-pet-hotel-sidekiq/codigo).

**Na entrevista:**
> "Eu subi Redis, Sidekiq e Puma. Check-in enfileirou. reports:daily enfileirou. Specs verde sem Redis."

---

## Recapitulando

- Request não espera o mail
- Dois gatilhos: check-in e rake
- Três processos
- Sem sidekiq-cron
- Idempotência no perform

---

## Exercícios práticos

### Exercício 1: sleep no controller

**Enunciado:** O entrevistador fala “então dá um sleep até o check-out”. Resposta?

<details>
<summary>Solução</summary>

Não. O thread do Puma fica preso. Restart perde o sleep. Dois check-ins, dois threads dormindo. Fila existe para isso. `wait_until` no Redis, worker acorda na hora.

**Pontos-chave:**
- request curto
- timer na fila, não no Puma
- restart do web não apaga o scheduled no Redis
</details>

### Exercício 2: Redis é o banco?

**Enunciado:** Thor está no Redis?

<details>
<summary>Solução</summary>

Não. Thor está no SQLite. Redis guarda o job: classe, args (`stay_id`), horário. O perform busca o Stay de novo. Por isso id, não snapshot.

**Pontos-chave:**
- fila ≠ domínio
- id na mensagem
- banco na hora do perform
</details>

---

*Parte do [Ruby Projects Handbook](/)*
