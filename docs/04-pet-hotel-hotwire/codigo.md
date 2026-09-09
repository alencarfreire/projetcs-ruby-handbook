# Código — Pet hotel Hotwire (quadro)

O recorte que o entrevistador puxa, nesta página. O app inteiro está em `projects/04-pet-hotel-hotwire`. Sem GitHub.

## Como rodar

```bash
cd projects/04-pet-hotel-hotwire
bundle install
bin/rails db:prepare
bin/rails s
```

Login: `joao@email.com` / `senha123`. Specs: `bundle exec rspec`.

Walkthrough: [4.1](/docs/04-pet-hotel-hotwire/01-o-problema) → [4.6](/docs/04-pet-hotel-hotwire/06-como-rodar).

## Pasta

```
projects/04-pet-hotel-hotwire/
  app/javascript/application.js
  config/importmap.rb
  app/views/occupancy/_board.html.erb
  app/views/stays/_stay.html.erb
  app/views/stays/status_change.turbo_stream.erb
  app/controllers/stays_controller.rb
```

## app/javascript/application.js

<<< @/projects/04-pet-hotel-hotwire/app/javascript/application.js

## config/importmap.rb

<<< @/projects/04-pet-hotel-hotwire/config/importmap.rb

## app/views/occupancy/_board.html.erb

<<< @/projects/04-pet-hotel-hotwire/app/views/occupancy/_board.html.erb

## app/views/stays/status_change.turbo_stream.erb

<<< @/projects/04-pet-hotel-hotwire/app/views/stays/status_change.turbo_stream.erb

## app/controllers/stays_controller.rb

<<< @/projects/04-pet-hotel-hotwire/app/controllers/stays_controller.rb
