# 5.7 Como rodar

> **TL;DR**
> Três terminais: `redis-server`, `bundle exec sidekiq`, `bin/rails s`. Login seed. Check-in de stay futura. Job scheduled no worker. `bin/rails reports:daily` enfileira o relatório. Mails em `tmp/mails`. Specs: `bundle exec rspec` — **sem** Redis. Fonte: [código](/docs/05-pet-hotel-sidekiq/codigo).

## Conteúdo

- [Redis](#redis)
- [bundle, db, três processos](#bundle-db-três-processos)
- [Ver o lembrete](#ver-o-lembrete)
- [Ver o relatório](#ver-o-relatório)
- [tmp/mails](#tmpmails)
- [bundle exec rspec](#bundle-exec-rspec)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Redis

**O que é:**
O primeiro processo. Sem ele o Puma explode no `perform_later`.

**Como funciona:**

```bash
redis-server
```

Default 6379. Docker no 7 sobe isso por você.

**Na entrevista:**
> "Redis primeiro. Senão o check-in grava e o enqueue 500."

---

## bundle, db, três processos

**O que é:**
O ritual.

**Como funciona:**

```bash
cd projects/05-pet-hotel-sidekiq
bundle install
bin/rails db:prepare
bin/rails s
```

Outro terminal:

```bash
cd projects/05-pet-hotel-sidekiq
bundle exec sidekiq
```

Login `joao@email.com` / `senha123`.

**Na entrevista:**
> "Puma, Sidekiq, Redis. Eu mostro os três terminais. Um README com só rails s mente o recorte."

---

## Ver o lembrete

**O que é:**
Stay scheduled da Luna. Check-in. Check-out daqui a dias.

**Como funciona:**
O worker loga o enqueue scheduled. O mail **não** chega agora — `wait_until`. Para ver o mail na call: `bin/rails runner 'CheckoutReminderJob.perform_now(Stay.checked_in.first.id)'` com o Thor do seed (já checked_in). Cai em `tmp/mails`.

**Na entrevista:**
> "Scheduled não é now. Na call eu perform_now no runner para mostrar o arquivo. O wait_until eu mostro no código."

---

## Ver o relatório

**O que é:**
O rake.

**Como funciona:**

```bash
bin/rails reports:daily
```

Worker loga o job. `tmp/mails` ganha o relatório do João. Thor no body. Luna não.

**Na entrevista:**
> "Eu disparei o rake na mão. O cron seria a mesma linha às 7h."

---

## tmp/mails

**O que é:**
`delivery_method = :file`. Cada mail um arquivo.

**Como funciona:**
Abre a pasta. Lê o subject. Sem Mailhog. Sem letter_opener gem.

**Na entrevista:**
> "O arquivo é o SMTP deste recorte. Eu leio o disco, não a caixa do Gmail."

---

## bundle exec rspec

**O que é:**
Doze examples. Sem Redis.

**Como funciona:**

```bash
bundle exec rspec
```

Mata o `redis-server` e o spec continua verde. Prova o adapter `:test`.

**Na entrevista:**
> "CI sem Redis. Development com Redis. Eu separo os dois no quadro."

---

## Recapitulando

- Redis, Sidekiq, Puma
- perform_now na call para ver o mail já
- rake para o relatório
- tmp/mails
- rspec sem broker

---

## Exercícios práticos

### Exercício 1: Sidekiq sem Redis

**Enunciado:** Você sobe o Sidekiq e esquece o Redis. O que o terminal mostra?

<details>
<summary>Solução</summary>

Erro de conexão. Retry. Não consome. Puma pode estar no ar. Check-in 500 no enqueue. Ligar o Redis. Não “debugar o job”.

**Pontos-chave:**
- erro de conexão primeiro
- três processos
- 500 no web = Redis, não o model
</details>

### Exercício 2: Porta 3000 do 2

**Enunciado:** Check-in não enfileira. Não tem log no Sidekiq. Suspeita?

<details>
<summary>Solução</summary>

Você está no Puma do projeto 2. Adapter default, sem Sidekiq. Olha o diretório. Sobe o 5.

**Pontos-chave:**
- app errado
- o 2 não tem perform_later
- prompt
</details>

---

*Parte do [Ruby Projects Handbook](/)*
