# 03 — Pet hotel API-only

Mesmo hotel da Pousada do Thor. Rails API, JSON, token no header. Sem HTML, sem cookie de sessão.

```
projects/03-pet-hotel-api/
  README.md
  app/models/                 User (+ api_token), Owner, Pet, Stay
  app/controllers/api/v1/     login, occupancy, CRUD
  app/controllers/concerns/   payloads (Hash → JSON)
  spec/requests/              fluxos principais
  db/seeds.rb                 João, Maria, Thor, Luna, Bidu
```

## O que você constrói

API JSON da recepção. João loga, ganha um Bearer, cadastra Maria, hospeda Thor. Occupancy lista quem está `checked_in`. Dinheiro em centavos (integer).

## O que você treina

- `config.api_only = true` — sem ERB, sem cookie
- `has_secure_token :api_token` + `Authorization: Bearer`
- Logout regenera o token — o Bearer antigo morre
- `render json:` com Hash explícito. Sem Jbuilder
- 401 (sem token) vs 404 (recurso de outro user)
- 201 + `Location` no create; 204 no DELETE
- `nights` e `total_cents` no JSON, integer
- Request spec com `as: :json`. Sem FactoryBot

## Como rodar

Ruby 3.3+ / Rails 8.1. SQLite.

```bash
cd projects/03-pet-hotel-api
bundle install
bin/rails db:prepare
bin/rails s
```

Sobe em `http://127.0.0.1:3000`. Seed: `joao@email.com` / `senha123`.

```bash
bundle exec rspec
bin/rails routes
```

## Endpoints

Login (devolve o token):

```bash
curl -s -X POST http://127.0.0.1:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@email.com","password":"senha123"}'
```

Resposta: `{ "id":1, "name":"João", "email":"joao@email.com", "token":"..." }`. Copia o `token`.

```bash
TOKEN="cole_o_token"

curl -s http://127.0.0.1:3000/api/v1/occupancy \
  -H "Authorization: Bearer $TOKEN"

curl -s http://127.0.0.1:3000/api/v1/owners \
  -H "Authorization: Bearer $TOKEN"

curl -s -X POST http://127.0.0.1:3000/api/v1/owners \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"owner":{"name":"Carlos","email":"carlos@email.com"}}'

curl -s -X POST http://127.0.0.1:3000/api/v1/stays/1/check_in \
  -H "Authorization: Bearer $TOKEN"
```

| Método | Path | Papel |
|---|---|---|
| POST | `/api/v1/signup` | cria user + token |
| POST | `/api/v1/login` | email/senha → user + token |
| DELETE | `/api/v1/logout` | regenera token (204) |
| GET | `/api/v1/occupancy` | stays `checked_in` |
| CRUD | `/api/v1/owners` | donos do user |
| CRUD | `/api/v1/pets` | pets do user |
| CRUD | `/api/v1/stays` | hospedagens |
| POST | `/api/v1/stays/:id/check_in` | status → `checked_in` |
| POST | `/api/v1/stays/:id/check_out` | status → `checked_out` |

Sem token: 401 `{ "errors": ["token ausente ou inválido"] }`. Recurso de outro user: 404. Validação: 422.

## O que NÃO entra (de propósito)

- JWT (gem)
- Devise, knock
- Jbuilder, Alba, ActiveModelSerializers
- HTML, cookie de sessão
- Hotwire, Sidekiq, Action Cable
- CORS (`rack-cors`) — o cliente deste recorte é curl
