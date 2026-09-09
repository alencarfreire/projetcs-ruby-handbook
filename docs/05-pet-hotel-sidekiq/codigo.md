# Código — Pet hotel Sidekiq

O recorte que o entrevistador puxa, nesta página. O app inteiro está em `projects/05-pet-hotel-sidekiq`. Sem GitHub.

## Como rodar

```bash
redis-server
cd projects/05-pet-hotel-sidekiq
bundle install
bin/rails db:prepare
bin/rails s
# outro terminal:
bundle exec sidekiq
```

Login: `joao@email.com` / `senha123`. Relatório: `bin/rails reports:daily`. Specs: `bundle exec rspec`.

Walkthrough: [5.1](/docs/05-pet-hotel-sidekiq/01-o-problema) → [5.7](/docs/05-pet-hotel-sidekiq/07-como-rodar).

## Pasta

```
projects/05-pet-hotel-sidekiq/
  app/jobs/checkout_reminder_job.rb
  app/jobs/occupancy_report_job.rb
  app/mailers/checkout_reminder_mailer.rb
  app/controllers/stays_controller.rb
  lib/tasks/reports.rake
  config/sidekiq.yml
```

## app/jobs/checkout_reminder_job.rb

<<< @/projects/05-pet-hotel-sidekiq/app/jobs/checkout_reminder_job.rb

## app/jobs/occupancy_report_job.rb

<<< @/projects/05-pet-hotel-sidekiq/app/jobs/occupancy_report_job.rb

## lib/tasks/reports.rake

<<< @/projects/05-pet-hotel-sidekiq/lib/tasks/reports.rake

## app/controllers/stays_controller.rb

<<< @/projects/05-pet-hotel-sidekiq/app/controllers/stays_controller.rb

## config/sidekiq.yml

<<< @/projects/05-pet-hotel-sidekiq/config/sidekiq.yml
