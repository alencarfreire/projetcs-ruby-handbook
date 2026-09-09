# 11 — Roda pragmático (A): eventos + Rodauth JWT

Arquitetura A. Um `app.rb`, um `db.rb`. Sequel dataset. Rodauth JWT. Sem hash_routes. Sem lote.

```
projects/11-roda-pragmatic/
  app.rb
  db.rb
  migrate/001_accounts_and_eventos.rb
  config.ru
  bin/migrate
```

## O que você constrói

Conta (email/senha). Token JWT no header `Authorization`. CRUD raso de eventos na tabela.

## O que você treina

- Stack Jeremy Evans: Roda + Sequel + Rodauth
- `plugin :rodauth, json: :only` + `enable :jwt`
- `r.rodauth` e `rodauth.require_authentication`
- Dataset Hash no `route`
- JWT não revoga de graça — o capítulo fala

## Como rodar

```bash
cd projects/11-roda-pragmatic
bundle install
bundle exec ruby bin/migrate
bundle exec puma
```

`http://127.0.0.1:9292`.

### Curls

```bash
curl -s -D - -X POST http://127.0.0.1:9292/create-account \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"login":"joao@email.com","password":"senha123"}'

curl -s -D - -X POST http://127.0.0.1:9292/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"login":"joao@email.com","password":"senha123"}'
```

Copia o header `Authorization` da response.

```bash
TOKEN="eyJ..." # o valor do header Authorization

curl -s http://127.0.0.1:9292/eventos \
  -H "Authorization: $TOKEN" \
  -H "Accept: application/json"

curl -s -i -X POST http://127.0.0.1:9292/eventos \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"title":"Sunset Jazz","venue":"Sala 2"}'
```

Sem token: 401. Login usa `login` (email), não `email`. Paths Rodauth: `/create-account`, `/login`, `/logout`.

## O que NÃO entra (de propósito)

- hash_routes
- Interactors, dry-rb
- Lote, pedido, webhook, compra
- HTML, cookie de sessão
