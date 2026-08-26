# 02 — Pet hotel (Pousada do Thor)

App Rails HTML: donos, pets e hospedagens. Auth com `has_secure_password` e cookie de sessão. Sem API JSON.

```
projects/02-pet-hotel/
  README.md                 este arquivo
  app/models/               User, Owner, Pet, Stay
  app/controllers/          auth, occupancy, CRUD
  app/views/                HTML + forms + flash
  spec/requests/            fluxos principais
  db/seeds.rb               João, Maria, Thor, Luna, Bidu
```

## O que você constrói

Hotel “Pousada do Thor”. Cadastro/login, CRUD de donos, pets e stays. Tela de ocupação: quem está `checked_in` agora. Dinheiro em centavos (integer).

## O que você treina

- `has_secure_password` (bcrypt) e sessão no cookie
- REST HTML: `resources`, forms, flash
- `belongs_to :user` e CRUD só do user logado
- `enum` de status (`scheduled` / `checked_in` / `checked_out`)
- Validação no model: `check_out > check_in`, 1 stay `checked_in` por pet
- `nights` e `total_cents` em integer — nunca Float
- `includes(:pet, :owner)` para não N+1
- Request specs dos fluxos, sem coverage theatre

## Como rodar

Ruby 3.3+ / Rails 8.1. SQLite.

```bash
cd projects/02-pet-hotel
bundle install
bin/rails db:prepare
bin/rails s
```

Abre `http://127.0.0.1:3000`. Login seed: `joao@email.com` / `senha123`.

```bash
bundle exec rspec
bin/rails routes
```

`db:prepare` cria o banco, roda migrations e seeds no development.

## Telas (rotas)

| Método | Path | Tela |
|---|---|---|
| `GET` | `/` | Ocupação (stays `checked_in`) ou redirect para login |
| `GET/POST` | `/signup` | Cadastro |
| `GET/POST` | `/login` | Login |
| `DELETE` | `/logout` | Logout |
| `GET/POST` | `/owners` | Lista / cria dono |
| `GET/PATCH/DELETE` | `/owners/:id` | Mostra / edita / remove |
| `GET/POST` | `/pets` | Lista / cria pet |
| `GET/PATCH/DELETE` | `/pets/:id` | Mostra / edita / remove |
| `GET/POST` | `/stays` | Lista / cria hospedagem |
| `GET/PATCH/DELETE` | `/stays/:id` | Mostra / edita / remove |
| `POST` | `/stays/:id/check_in` | Status → `checked_in` |
| `POST` | `/stays/:id/check_out` | Status → `checked_out` |

## O que NÃO entra (de propósito)

- Devise
- Hotwire (Turbo / Stimulus)
- Sidekiq
- Pundit
- API JSON
