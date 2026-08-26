# Sumário

* [Introdução](README.md)
* [Roadmap](roadmap.md)
* [Guia](GUIDE.md)

## 1. HTTP API pura

Código: [`projects/01-http-api`](projects/01-http-api)

* [1.1 O problema e o recorte](docs/01-http-api/01-o-problema.md)
* [1.2 Servidor HTTP com stdlib](docs/01-http-api/02-servidor-http.md)
* [1.3 Rotas na mão (method + path)](docs/01-http-api/03-rotas.md)
* [1.4 JSON request/response](docs/01-http-api/04-json.md)
* [1.5 Store em memória](docs/01-http-api/05-store.md)
* [1.6 Status codes que caem em entrevista](docs/01-http-api/06-status-codes.md)
* [1.7 Como rodar e testar com curl](docs/01-http-api/07-como-rodar.md)

## 2. Pet hotel em Rails

Código: `projects/02-pet-hotel` — fase 2

* 2.1 O problema e o recorte
* 2.2 Models e migrations
* 2.3 Auth com `has_secure_password`
* 2.4 Owners e pets
* 2.5 Estadia: entrada, saída, noites, total
* 2.6 Validações que o entrevistador puxa
* 2.7 Request specs
* 2.8 Como rodar

## Depois (não implementar agora)

* 3. Pet hotel API-only + JSON + token
* 4. Hotwire: quadro de ocupação
* 5. Sidekiq: lembrete e relatório
* 6. Action Cable: painel ao vivo
* 7. Docker Compose
* 8. System design do hotel
