# Código — Pet hotel API (token e JSON)

O recorte que o entrevistador puxa, nesta página. O app inteiro está em `projects/03-pet-hotel-api`. Sem GitHub.

## Como rodar

```bash
cd projects/03-pet-hotel-api
bundle install
bin/rails db:prepare
bin/rails s
```

Login: `POST /api/v1/login` com `joao@email.com` / `senha123`. Copia o `token`. Specs: `bundle exec rspec`.

Walkthrough: [3.1](/docs/03-pet-hotel-api/01-o-problema) → [3.8](/docs/03-pet-hotel-api/08-como-rodar).

## Pasta

```
projects/03-pet-hotel-api/
  app/models/user.rb
  app/controllers/application_controller.rb
  app/controllers/concerns/payloads.rb
  app/controllers/api/v1/sessions_controller.rb
  app/controllers/api/v1/stays_controller.rb
  config/routes.rb
  db/seeds.rb
```

## config/routes.rb

<<< @/projects/03-pet-hotel-api/config/routes.rb

## app/models/user.rb

<<< @/projects/03-pet-hotel-api/app/models/user.rb

## app/controllers/application_controller.rb

<<< @/projects/03-pet-hotel-api/app/controllers/application_controller.rb

## app/controllers/concerns/payloads.rb

<<< @/projects/03-pet-hotel-api/app/controllers/concerns/payloads.rb

## app/controllers/api/v1/sessions_controller.rb

<<< @/projects/03-pet-hotel-api/app/controllers/api/v1/sessions_controller.rb

## app/controllers/api/v1/stays_controller.rb

<<< @/projects/03-pet-hotel-api/app/controllers/api/v1/stays_controller.rb

## db/seeds.rb

<<< @/projects/03-pet-hotel-api/db/seeds.rb
