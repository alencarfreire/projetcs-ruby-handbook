# Código — Pet hotel Action Cable

O recorte que o entrevistador puxa, nesta página. O app inteiro está em `projects/06-pet-hotel-cable`. Sem GitHub.

## Como rodar

```bash
cd projects/06-pet-hotel-cable
bundle install
bin/rails db:prepare
bin/rails s
```

Login: `joao@email.com` / `senha123`. Duas janelas. Specs: `bundle exec rspec`.

Walkthrough: [6.1](/docs/06-pet-hotel-cable/01-o-problema) → [6.6](/docs/06-pet-hotel-cable/06-como-rodar).

## Pasta

```
projects/06-pet-hotel-cable/
  app/channels/application_cable/connection.rb
  app/channels/occupancy_channel.rb
  app/javascript/channels/occupancy.js
  app/controllers/stays_controller.rb
  config/cable.yml
```

## app/channels/application_cable/connection.rb

<<< @/projects/06-pet-hotel-cable/app/channels/application_cable/connection.rb

## app/channels/occupancy_channel.rb

<<< @/projects/06-pet-hotel-cable/app/channels/occupancy_channel.rb

## app/javascript/channels/occupancy.js

<<< @/projects/06-pet-hotel-cable/app/javascript/channels/occupancy.js

## app/javascript/channels/consumer.js

<<< @/projects/06-pet-hotel-cable/app/javascript/channels/consumer.js

## config/cable.yml

<<< @/projects/06-pet-hotel-cable/config/cable.yml
