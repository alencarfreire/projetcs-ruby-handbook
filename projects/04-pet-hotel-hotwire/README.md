# 04 — Pet hotel Hotwire (quadro de ocupação)

Mesmo hotel HTML do projeto 2. Turbo Drive, Frame no quadro, Stream no check-in/check-out. Sem Cable: outra aba não atualiza.

```
projects/04-pet-hotel-hotwire/
  README.md
  app/javascript/application.js   import "@hotwired/turbo-rails"
  app/views/occupancy/_board.html.erb
  app/views/stays/status_change.turbo_stream.erb
  app/controllers/stays_controller.rb
  spec/requests/
```

## O que você constrói

Quadro “quem está no hotel agora” em `turbo_frame_tag "occupancy"`. Check-out no próprio quadro troca o HTML do frame. Check-in/check-out na stay atualiza o card. Sem recarregar a página.

## O que você treina

- Turbo Drive nos links e forms (de graça com o importmap)
- Turbo Frame: recorte de um pedaço do DOM
- Turbo Stream: `replace` occupancy + stay, `update` flash
- `respond_to format.turbo_stream` / `format.html`
- Request spec com `Accept: text/vnd.turbo-stream.html`
- O limite: Stream no **response deste POST**. Outra aba não vê — projeto 6

## Como rodar

Ruby 3.3+ / Rails 8.1. SQLite.

```bash
cd projects/04-pet-hotel-hotwire
bundle install
bin/rails db:prepare
bin/rails s
```

Abre `http://127.0.0.1:3000`. Login seed: `joao@email.com` / `senha123`.

No quadro, Thor está hospedado. Clica **Fazer check-out**. A linha some sem reload. Abre a mesma URL em outra aba **antes** do clique: a outra aba continua com o Thor. Isso não é bug — é o recorte.

```bash
bundle exec rspec
```

## Telas (o que muda em relação ao 2)

| Tela | Hotwire |
|---|---|
| `/` ocupação | Frame `occupancy` + botão check-out |
| `/stays/:id` | Frame do stay + Stream no check-in/out |
| resto do CRUD | Drive (visita sem reload cheio de layout) |

## O que NÃO entra (de propósito)

- Stimulus
- Action Cable / Turbo Streams over Cable
- Sidekiq
- API JSON
- morphing, lazy frames, paginação
