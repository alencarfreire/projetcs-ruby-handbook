# Sumário

* [Introdução](README.md)
* [Projetos e comandos](projetos.md)
* [Roadmap](roadmap.md)
* [Guia](GUIDE.md)

## 1. HTTP API pura

Código: [fonte completa](docs/01-http-api/codigo.md)

* [1.1 O problema e o recorte](docs/01-http-api/01-o-problema.md)
* [1.2 Servidor HTTP com stdlib](docs/01-http-api/02-servidor-http.md)
* [1.3 Rotas na mão (method + path)](docs/01-http-api/03-rotas.md)
* [1.4 JSON request/response](docs/01-http-api/04-json.md)
* [1.5 Store em memória](docs/01-http-api/05-store.md)
* [1.6 Status codes que caem em entrevista](docs/01-http-api/06-status-codes.md)
* [1.7 Como rodar e testar com curl](docs/01-http-api/07-como-rodar.md)
* [Código completo](docs/01-http-api/codigo.md)

## 2. Pet hotel em Rails

Código: [fonte do pet hotel](docs/02-pet-hotel/codigo.md)

* [2.1 O problema e o recorte](docs/02-pet-hotel/01-o-problema.md)
* [2.2 Models e migrations](docs/02-pet-hotel/02-models.md)
* [2.3 Auth com `has_secure_password`](docs/02-pet-hotel/03-auth.md)
* [2.4 Owners e pets](docs/02-pet-hotel/04-owners-pets.md)
* [2.5 Estadia: entrada, saída, noites, total](docs/02-pet-hotel/05-estadia.md)
* [2.6 Validações que o entrevistador puxa](docs/02-pet-hotel/06-validacoes.md)
* [2.7 Request specs](docs/02-pet-hotel/07-request-specs.md)
* [2.8 Como rodar](docs/02-pet-hotel/08-como-rodar.md)
* [Código (models e auth)](docs/02-pet-hotel/codigo.md)

## 3. Pet hotel API-only

Código: [fonte da API](docs/03-pet-hotel-api/codigo.md)

* [3.1 O problema e o recorte](docs/03-pet-hotel-api/01-o-problema.md)
* [3.2 api_only e o que o 2 escondia no ERB](docs/03-pet-hotel-api/02-api-only.md)
* [3.3 Token: has_secure_token + Bearer](docs/03-pet-hotel-api/03-token.md)
* [3.4 JSON de owners, pets, stays](docs/03-pet-hotel-api/04-json.md)
* [3.5 Check-in, check-out e 4xx](docs/03-pet-hotel-api/05-status-codes.md)
* [3.6 Recorte por user: 401 vs 404](docs/03-pet-hotel-api/06-401-vs-404.md)
* [3.7 Request specs](docs/03-pet-hotel-api/07-request-specs.md)
* [3.8 Como rodar e testar com curl](docs/03-pet-hotel-api/08-como-rodar.md)
* [Código (token e JSON)](docs/03-pet-hotel-api/codigo.md)

## 4. Hotwire — quadro de ocupação

Código: [fonte Hotwire](docs/04-pet-hotel-hotwire/codigo.md)

* [4.1 O problema e o recorte](docs/04-pet-hotel-hotwire/01-o-problema.md)
* [4.2 Drive vs Frame vs Stream](docs/04-pet-hotel-hotwire/02-drive-frame-stream.md)
* [4.3 Frame da ocupação](docs/04-pet-hotel-hotwire/03-frame.md)
* [4.4 Stream no check-in e no check-out](docs/04-pet-hotel-hotwire/04-stream.md)
* [4.5 O que o Stream não faz (outra aba)](docs/04-pet-hotel-hotwire/05-outra-aba.md)
* [4.6 Como rodar](docs/04-pet-hotel-hotwire/06-como-rodar.md)
* [Código (quadro)](docs/04-pet-hotel-hotwire/codigo.md)

## 5. Sidekiq — lembrete e relatório

Código: [fonte Sidekiq](docs/05-pet-hotel-sidekiq/codigo.md)

* [5.1 O que não cabe no request](docs/05-pet-hotel-sidekiq/01-o-problema.md)
* [5.2 Redis + Sidekiq + Active Job](docs/05-pet-hotel-sidekiq/02-tres-processos.md)
* [5.3 Lembrete de check-out](docs/05-pet-hotel-sidekiq/03-lembrete.md)
* [5.4 Relatório diário](docs/05-pet-hotel-sidekiq/04-relatorio.md)
* [5.5 Falha, retry, idempotência](docs/05-pet-hotel-sidekiq/05-falha.md)
* [5.6 Specs de job](docs/05-pet-hotel-sidekiq/06-specs.md)
* [5.7 Como rodar](docs/05-pet-hotel-sidekiq/07-como-rodar.md)
* [Código (jobs)](docs/05-pet-hotel-sidekiq/codigo.md)

## 6. Action Cable — painel ao vivo

Código: [fonte Cable](docs/06-pet-hotel-cable/codigo.md)

* [6.1 Recorte: outra aba](docs/06-pet-hotel-cable/01-o-problema.md)
* [6.2 Connection e current_user](docs/06-pet-hotel-cable/02-connection.md)
* [6.3 Channel + stream_for](docs/06-pet-hotel-cable/03-channel.md)
* [6.4 Broadcast no check-in e no check-out](docs/06-pet-hotel-cable/04-broadcast.md)
* [6.5 Specs](docs/06-pet-hotel-cable/05-specs.md)
* [6.6 Como rodar](docs/06-pet-hotel-cable/06-como-rodar.md)
* [Código (channel)](docs/06-pet-hotel-cable/codigo.md)

## 7. Docker Compose

Código: [Dockerfile e compose](docs/07-pet-hotel-docker/codigo.md)

* [7.1 Recorte: empacotar](docs/07-pet-hotel-docker/01-o-problema.md)
* [7.2 Dockerfile](docs/07-pet-hotel-docker/02-dockerfile.md)
* [7.3 Compose: web, worker, redis](docs/07-pet-hotel-docker/03-compose.md)
* [7.4 Env, volume, rede](docs/07-pet-hotel-docker/04-env-volume.md)
* [7.5 Como rodar (e produção)](docs/07-pet-hotel-docker/05-como-rodar.md)
* [Código (compose)](docs/07-pet-hotel-docker/codigo.md)

## 8. System design do hotel

Sem `projects/08`. Prática de quadro.

* [8.1 O problema em escala](docs/08-system-design/01-o-problema.md)
* [8.2 Recorte do quadro](docs/08-system-design/02-recorte-quadro.md)
* [8.3 Request vs job vs websocket](docs/08-system-design/03-request-job-ws.md)
* [8.4 Occupancy e consistência](docs/08-system-design/04-consistencia.md)
* [8.5 Redis cai, worker atrasou, token vazou](docs/08-system-design/05-falhas.md)
* [8.6 Exercício de desenho](docs/08-system-design/06-exercicio.md)

## Trilha Roda (ingressos)

Independente da Pousada. Conceitos 9–13. Produto 14. Ops 15.

## 9. Roda sozinho

Código: [árvore de rotas](docs/09-roda/codigo.md)

* [9.1 O problema e o recorte](docs/09-roda/01-o-problema.md)
* [9.2 Rack](docs/09-roda/02-rack.md)
* [9.3 A árvore `route do |r|`](docs/09-roda/03-arvore.md)
* [9.4 Plugins](docs/09-roda/04-plugins.md)
* [9.5 Halt, status, JSON](docs/09-roda/05-halt-json.md)
* [9.6 Como rodar](docs/09-roda/06-como-rodar.md)
* [Código](docs/09-roda/codigo.md)

## 10. Sequel sozinho

Código: [dataset](docs/10-sequel/codigo.md)

* [10.1 O problema e o recorte](docs/10-sequel/01-o-problema.md)
* [10.2 Conexão e DB[:eventos]](docs/10-sequel/02-conexao.md)
* [10.3 Migrations](docs/10-sequel/03-migrations.md)
* [10.4 Dataset devolve Hash](docs/10-sequel/04-dataset-hash.md)
* [10.5 Sequel::Model](docs/10-sequel/05-model.md)
* [10.6 Como rodar](docs/10-sequel/06-como-rodar.md)
* [Código](docs/10-sequel/codigo.md)

## 11. A — pragmática (Roda + Sequel + Rodauth)

Código: [app.rb](docs/11-roda-pragmatic/codigo.md)

* [11.1 Arquitetura A](docs/11-roda-pragmatic/01-o-problema.md)
* [11.2 Boot](docs/11-roda-pragmatic/02-boot.md)
* [11.3 Rodauth e JWT](docs/11-roda-pragmatic/03-rodauth.md)
* [11.4 CRUD de eventos](docs/11-roda-pragmatic/04-crud.md)
* [11.5 401, 404, 422](docs/11-roda-pragmatic/05-status.md)
* [11.6 Quando A dói](docs/11-roda-pragmatic/06-quando-a-doi.md)
* [11.7 Como rodar](docs/11-roda-pragmatic/07-como-rodar.md)
* [Código](docs/11-roda-pragmatic/codigo.md)

## 12. B — hash_routes

Código: [ramos](docs/12-roda-modular/codigo.md)

* [12.1 Arquitetura B](docs/12-roda-modular/01-o-problema.md)
* [12.2 Plugin hash_routes](docs/12-roda-modular/02-plugin.md)
* [12.3 app.rb magro](docs/12-roda-modular/03-app-magro.md)
* [12.4 Ramos: eventos e locais](docs/12-roda-modular/04-ramos.md)
* [12.5 O(1) vs só r.on](docs/12-roda-modular/05-o1.md)
* [12.6 Como rodar](docs/12-roda-modular/06-como-rodar.md)
* [Código](docs/12-roda-modular/codigo.md)

## 13. C hexagonal e D dry-rb

Sem `projects/13`. Prática de quadro.

* [13.1 Mapa A / B / C / D](docs/13-roda-arquiteturas/01-mapa.md)
* [13.2 C: hexagonal](docs/13-roda-arquiteturas/02-hexagonal.md)
* [13.3 D: dry-rb](docs/13-roda-arquiteturas/03-dry-rb.md)
* [13.4 Como escolher](docs/13-roda-arquiteturas/04-escolher.md)
* [13.5 Exercício de desenho](docs/13-roda-arquiteturas/05-exercicio.md)

## 14. Ingressos (produto)

Código: [ReservarLote e webhook](docs/14-ingressos/codigo.md)

* [14.1 O produto](docs/14-ingressos/01-o-problema.md)
* [14.2 Schema lote e pedido](docs/14-ingressos/02-schema.md)
* [14.3 ReservarLote](docs/14-ingressos/03-reservar.md)
* [14.4 Webhook HMAC](docs/14-ingressos/04-webhook.md)
* [14.5 Denylist e testes](docs/14-ingressos/05-testes.md)
* [14.6 Jobs, log, Postgres](docs/14-ingressos/06-ops-app.md)
* [14.7 Como rodar](docs/14-ingressos/07-como-rodar.md)
* [Código](docs/14-ingressos/codigo.md)

## 15. Ops e deploy

Código: [compose](docs/15-ingressos-ops/codigo.md)

* [15.1 Empacotar o 14](docs/15-ingressos-ops/01-o-problema.md)
* [15.2 Dockerfile e compose](docs/15-ingressos-ops/02-compose.md)
* [15.3 Perfil produção](docs/15-ingressos-ops/03-producao.md)
* [Código](docs/15-ingressos-ops/codigo.md)
