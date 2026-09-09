# 09 — Roda: árvore de rotas (eventos)

API JSON de eventos em Roda. Sem Sequel. Sem Rodauth. Store em Hash no processo: some quando o Puma morre.

```
projects/09-roda-routing/
  README.md    este arquivo
  Gemfile
  config.ru    rackup / puma
  app.rb       Roda, um route do |r|
```

## O que você constrói

Lista e cria eventos: `id`, `title`, `venue`. Árvore `r.on "eventos"`. JSON na porta.

## O que você treina

- Roda é um app Rack
- `route do |r|` hierárquico: `r.on`, `r.is`, `r.get`, `r.post`
- Plugins `json`, `json_parser`, `halt`
- Hash no processo — mata o servidor, zerou
- 201 + Location no create; 422 sem title; 404 no id

## Como rodar

Ruby 3.3+.

```bash
cd projects/09-roda-routing
bundle install
bundle exec puma
```

Sobe em `http://127.0.0.1:9292`. `Ctrl+C` zera o Hash.

## Endpoints

| Método | Path | Sucesso |
|---|---|---|
| `GET` | `/` | `{ "name": "ingressos-routing" }` |
| `GET` | `/eventos` | 200, array |
| `POST` | `/eventos` | 201 + `Location` |
| `GET` | `/eventos/:id` | 200, um evento |

Sem title: 422 `{ "errors": ["title não pode ficar em branco"] }`. Id inexistente: 404.

### Curls

```bash
curl -s http://127.0.0.1:9292/
# {"name":"ingressos-routing"}

curl -s http://127.0.0.1:9292/eventos
# []

curl -s -i -X POST http://127.0.0.1:9292/eventos \
  -H "Content-Type: application/json" \
  -d '{"title":"Sunset Jazz","venue":"Sala 2"}'
# 201, Location: /eventos/1

curl -s http://127.0.0.1:9292/eventos/1
```

## O que NÃO entra (de propósito)

- Sequel, SQL, arquivo sqlite
- Rodauth, JWT, senha
- hash_routes
- Lote, pedido, webhook, compra
