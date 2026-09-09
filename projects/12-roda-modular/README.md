# 12 — Roda modular (B): hash_routes

Arquitetura B. `app.rb` orquestra. Ramos `eventos` e `locais`. Mesmo JWT da A. Sem compra. Sem webhook de pagamento.

```
projects/12-roda-modular/
  app.rb
  db.rb
  routes/eventos.rb
  routes/locais.rb
  migrate/
```

## O que você constrói

Dois prefixos. `/eventos` e `/locais`. Cada arquivo um `hash_branch`. Cadeado no ramo.

## O que você treina

- plugin `:hash_routes`
- `App.hash_branch "eventos"`
- `r.hash_routes` no orquestrador
- Busca do ramo em Hash (O(1) no prefixo)
- Barreira `require_authentication` **dentro** do ramo

## Como rodar

```bash
cd projects/12-roda-modular
bundle install
bundle exec ruby bin/migrate
bundle exec puma
```

Login igual ao 11 (`/create-account`, `/login`, campo `login`). Depois:

```bash
curl -s -X POST http://127.0.0.1:9292/locais \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"name":"Sala 2"}'

curl -s -X POST http://127.0.0.1:9292/eventos \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"title":"Sunset Jazz","venue":"Sala 2"}'
```

## O que NÃO entra (de propósito)

- Lote com estoque, pedido, webhook de pagamento
- Hexagonal, dry-rb
- Um único `route` gigante (isso é A)
