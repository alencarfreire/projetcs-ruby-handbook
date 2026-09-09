# 06 — Pet hotel Action Cable (painel ao vivo)

Mesmo hotel HTML do projeto 2. Check-in/check-out empurra o HTML do quadro via WebSocket. A outra janela do João atualiza. Sem Turbo Stream over Cable: o channel aparece no código.

```
projects/06-pet-hotel-cable/
  app/channels/application_cable/connection.rb
  app/channels/occupancy_channel.rb
  app/javascript/channels/occupancy.js
  app/controllers/stays_controller.rb
  spec/channels/
```

## O que você constrói

Duas janelas no `/`. Check-in do Thor numa. A outra pinta o Thor sem F5. Connection lê `session[:user_id]`. Anônimo é rejeitado. Broadcast é `OccupancyChannel.broadcast_to(current_user, { html: ... })`.

## O que você treina

- Connection: identidade no handshake
- Channel: `stream_for current_user`
- Broadcast no check-in/check-out (não no model callback — o controller é o fio)
- JS mínimo: `createConsumer`, `innerHTML`
- Adapter `async` em development/test. Redis adapter é o 7/8
- Channel spec + `have_broadcasted_to`

## Como rodar

```bash
cd projects/06-pet-hotel-cable
bundle install
bin/rails db:prepare
bin/rails s
```

Login `joao@email.com` / `senha123`. Abre `/` em duas janelas. Na hospedagem da Luna (scheduled), faz check-in. A janela do quadro ganha a Luna.

```bash
bundle exec rspec
```

Sem Redis. Adapter `async` / `test`.

## O que NÃO entra (de propósito)

- Turbo Streams over Cable (`turbo_stream_from`)
- AnyCable
- Sidekiq, API JSON
- Redis adapter (fica para o Docker / system design)
- Stimulus
