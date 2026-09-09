# 5.4 Relatório diário

> **TL;DR**
> `OccupancyReportJob` recebe `user_id`, lista `checked_in`, manda mail. Gatilho: `bin/rails reports:daily`. O rake faz `User.find_each` + `perform_later`. Cron do SO chama o rake. Sidekiq não acorda sozinho às 7h.

## Conteúdo

- [O job](#o-job)
- [O rake](#o-rake)
- [Cron do SO](#cron-do-so)
- [Por que não sidekiq-cron](#por-que-não-sidekiq-cron)
- [find_each](#find_each)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O job

**O que é:**
Foto da ocupação **na hora do perform**, não na hora do rake.

**Como funciona:**

```ruby
def perform(user_id)
  user = User.find(user_id)
  stays = user.stays.checked_in.includes(:pet, :owner).order(:check_in)
  OccupancyReportMailer.daily(user, stays.to_a).deliver_now
end
```

`stays.to_a` — o mailer não recebe relação viva que muda no meio do render. Array.

Luna scheduled não entra. Thor checked_in entra. Igual o quadro.

**Na entrevista:**
> "O relatório é occupancy por e-mail. Mesma query do quadro. includes para não N+1 no mail."

---

## O rake

**O que é:**
O produtor. Não manda mail. Enfileira.

**Como funciona:**

```ruby
namespace :reports do
  task daily: :environment do
    User.find_each do |user|
      OccupancyReportJob.perform_later(user.id)
    end
  end
end
```

`bin/rails reports:daily`. Um job por user. Um user lento não segura o outro.

**Quando usar:**
Tarefa de relógio. Não no request da recepção.

**Na entrevista:**
> "O rake é barato. Ele só empurra ids. O worker manda o mail."

---

## Cron do SO

**O que é:**
Quem acorda o rake. Uma linha no crontab.

**Como funciona:**

```
0 7 * * * cd /caminho/05-pet-hotel-sidekiq && bin/rails reports:daily
```

Não está no repo. Está no quadro. Docker no 7 também não sobe um container `cron` neste recorte — você fala que em produção um scheduler (ou o cron da máquina) chama o mesmo rake.

**Na entrevista:**
> "Cron chama rake. Rake chama perform_later. Sidekiq consome. Três nomes, três papéis."

---

## Por que não sidekiq-cron

**O que é:**
Gem que agenda no Redis. Bonita. Esconde o gatilho.

**Como funciona:**
A entrevista vira “como o Sidekiq sabe as 7h?”. Resposta com gem: YAML mágico. Resposta deste livro: crontab. Você vê no `crontab -l`.

Em produção grande, um scheduler (Clockwork, Solid Queue recurring, Kubernetes CronJob) entra. Recorte: rake + cron.

**Na entrevista:**
> "sidekiq-cron eu conheço. Aqui eu quero o gatilho visível. A fila não é o relógio."

---

## find_each

**O que é:**
Batch. Não `User.all.each` carregando a tabela.

**Como funciona:**
Dois users na Pousada. `find_each` é teatro hoje. Amanhã 10 mil recepções. A entrevista puxa. Você já escreveu certo.

**Na entrevista:**
> "find_each. Eu não carrego todos os users para enfileirar ids."

---

## Recapitulando

- Job = foto checked_in agora
- Rake enfileira, não manda
- Cron do SO dispara o rake
- Sem gem de cron
- find_each

---

## Exercícios práticos

### Exercício 1: Relatório no check-in

**Enunciado:** Você enfileira o relatório também no check-in. Bom?

<details>
<summary>Solução</summary>

Não. Relatório é diário, não por evento. Check-in do Thor não é “fim do dia”. Você inundaria a caixa do João. Gatilho de relógio ≠ gatilho de domínio.

**Pontos-chave:**
- um job, um gatilho
- diário = cron
- evento = check-in
</details>

### Exercício 2: Um job para todos os users

**Enunciado:** `OccupancyReportJob.perform_later` sem args, o job itera users. Trade-off?

<details>
<summary>Solução</summary>

Um job longo. Falhou no user 80, retry manda de novo para 1–79. Idempotência de mail dói. Um job por user isola a falha. Recorte: por user.

**Pontos-chave:**
- job pequeno
- retry isolado
- id na mensagem
</details>

---

*Parte do [Ruby Projects Handbook](/)*
