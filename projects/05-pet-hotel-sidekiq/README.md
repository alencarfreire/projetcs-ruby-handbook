# 05 — Pet hotel Sidekiq (lembrete e relatório)

Mesmo hotel HTML do projeto 2. Check-in enfileira um lembrete para o dia do check-out. Um rake enfileira o relatório diário de ocupação. Worker é Sidekiq. Cron do SO dispara o rake. Sem `sidekiq-cron`.

```
projects/05-pet-hotel-sidekiq/
  app/jobs/checkout_reminder_job.rb
  app/jobs/occupancy_report_job.rb
  app/mailers/
  lib/tasks/reports.rake
  config/sidekiq.yml
  spec/jobs/
```

## O que você constrói

Três processos: Puma, Sidekiq, Redis. No check-in do Thor, o request **não** espera o dia do check-out. Enfileira `CheckoutReminderJob` com `wait_until` 8h desse dia. Se o Thor já saiu, o job no-op. Relatório: `bin/rails reports:daily`.

## O que você treina

- Active Job adapter `:sidekiq` (dev/prod) e `:test` (spec)
- Passar **id**, não o objeto
- `wait_until` no lembrete
- Idempotência: job olha o status agora
- `discard_on ActiveRecord::RecordNotFound`
- Mailer com `delivery_method = :file` em development (`tmp/mails`)
- Rake enfileira; cron do SO dispara o rake — Sidekiq não é o cron
- Spec de enqueue + perform, sem Redis

## Como rodar

Ruby 3.3+ / Rails 8.1. SQLite. Redis local.

```bash
redis-server
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

Login seed: `joao@email.com` / `senha123`. Faz check-in de uma stay com check-out futuro. O job aparece no Sidekiq (scheduled). Mail em `tmp/mails` quando o worker rodar o job.

Relatório agora:

```bash
bin/rails reports:daily
```

Cron (não entra no repo, entra no quadro):

```
0 7 * * * cd /caminho/05-pet-hotel-sidekiq && bin/rails reports:daily
```

```bash
bundle exec rspec
```

Specs não precisam de Redis nem de Sidekiq no ar.

## O que NÃO entra (de propósito)

- `sidekiq-cron` / Sidekiq Pro
- SendGrid, SMTP de verdade
- Action Cable, Hotwire, API JSON
- Postgres
