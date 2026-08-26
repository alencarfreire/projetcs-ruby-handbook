# 01 — HTTP API pura (tasks)

API JSON de tasks em Ruby puro. Sem Rails. Sem gem de web. Sem banco. Store em memória: some quando o processo morre.

## O que você constrói

CRUD de Task — `id`, `title`, `completed` — em HTTP na mão (`socket` + `json`).

## O que você treina

- Servidor TCP e o texto HTTP (request line, headers, body)
- Rotas na mão: method + path
- JSON de entrada e saída
- Hash como banco (`@tasks` + `@next_id`)
- Status que caem em entrevista: 200, 201, 204, 400, 404, 405

## Como rodar

Ruby 3.3+. Sem `bundle`. Sem Gemfile.

```bash
cd projects/01-http-api
ruby server.rb
```

Sobe em `http://127.0.0.1:4567`. `Ctrl+C` mata o processo. O Hash some. Isso é o recorte.

## Endpoints

| Método | Path | Sucesso |
|---|---|---|
| `GET` | `/tasks` | 200, array JSON |
| `GET` | `/tasks/:id` | 200, um JSON |
| `POST` | `/tasks` | 201 + `Location: /tasks/:id` |
| `PUT` | `/tasks/:id` | 200, substitui `title` e `completed` |
| `PATCH` | `/tasks/:id` | 200, só os campos que vieram |
| `DELETE` | `/tasks/:id` | 204, sem body |

Erros: id inexistente → 404. JSON inválido ou campo faltando → 400. Método não mapeado → 405 + `Allow`. Path desconhecido → 404.

`Content-Type: application/json` em toda resposta com body.

### Curls

Lista vazia:

```bash
curl -s http://127.0.0.1:4567/tasks
# []
```

Cria:

```bash
curl -s -i -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Comprar ração do Thor"}'
# 201, Location: /tasks/1
```

Busca um:

```bash
curl -s http://127.0.0.1:4567/tasks/1
```

Lista:

```bash
curl -s http://127.0.0.1:4567/tasks
```

Substitui (PUT):

```bash
curl -s -X PUT http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Comprar ração do Thor","completed":true}'
```

Parcial (PATCH):

```bash
curl -s -X PATCH http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":false}'
```

Apaga:

```bash
curl -s -i -X DELETE http://127.0.0.1:4567/tasks/1
# 204
```

Erros:

```bash
curl -s -i http://127.0.0.1:4567/tasks/99
# 404

curl -s -i -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '{quebrado'
# 400

curl -s -i -X POST http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"x"}'
# 405
```

## O que NÃO entra (de propósito)

- Rails, Sinatra, Rack, Puma, gem `webrick`
- SQL, SQLite, arquivo, Redis
- Auth, CORS, paginação, versionamento
- Domínio do hotel (owner, pet, stay)
- Coverage theatre — o teste é o curl acima
