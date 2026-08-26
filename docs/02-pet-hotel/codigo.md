# Código — Pet hotel (models e auth)

O recorte que o entrevistador puxa, nesta página. O app inteiro está em `projects/02-pet-hotel`. Sem GitHub.

## Como rodar

```bash
cd projects/02-pet-hotel
bundle install
bin/rails db:prepare
bin/rails s
```

Login: `joao@email.com` / `senha123`. Specs: `bundle exec rspec`.

Como rodar: veja o [código do pet hotel](/docs/02-pet-hotel/codigo). Walkthrough: [2.1](/docs/02-pet-hotel/01-o-problema) → [2.8](/docs/02-pet-hotel/08-como-rodar).

## Pasta

```
projects/02-pet-hotel/
  app/models/user.rb
  app/models/owner.rb
  app/models/pet.rb
  app/models/stay.rb
  app/controllers/application_controller.rb
  app/controllers/sessions_controller.rb
  config/routes.rb
  db/seeds.rb
```

## config/routes.rb

<<< @/projects/02-pet-hotel/config/routes.rb

## app/models/user.rb

<<< @/projects/02-pet-hotel/app/models/user.rb

## app/models/owner.rb

<<< @/projects/02-pet-hotel/app/models/owner.rb

## app/models/pet.rb

<<< @/projects/02-pet-hotel/app/models/pet.rb

## app/models/stay.rb

<<< @/projects/02-pet-hotel/app/models/stay.rb

## app/controllers/application_controller.rb

<<< @/projects/02-pet-hotel/app/controllers/application_controller.rb

## app/controllers/sessions_controller.rb

<<< @/projects/02-pet-hotel/app/controllers/sessions_controller.rb

## db/seeds.rb

<<< @/projects/02-pet-hotel/db/seeds.rb
