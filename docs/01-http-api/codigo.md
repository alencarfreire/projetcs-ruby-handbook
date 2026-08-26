# Código completo — HTTP API

O app inteiro, nesta página. Sem GitHub. Rode em `projects/01-http-api`. Leia aqui.

## Como rodar

```bash
cd projects/01-http-api
ruby server.rb
```

Sobe em `http://127.0.0.1:4567`. Sem `bundle`. Sem Gemfile.

```bash
curl -s http://127.0.0.1:4567/tasks
# []
```

Curls do CRUD: veja o [código completo](/docs/01-http-api/codigo). Walkthrough: [1.1](/docs/01-http-api/01-o-problema) → [1.7](/docs/01-http-api/07-como-rodar).

## Pasta

```
projects/01-http-api/
  README.md
  bin/server
  server.rb              sobe
  lib/task_server.rb     TCP + HTTP
  lib/router.rb          method + path
  lib/task_store.rb      Hash + @next_id
```

## server.rb

<<< @/projects/01-http-api/server.rb

## bin/server

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../server"
TaskServer.new.start
```

## lib/task_server.rb

<<< @/projects/01-http-api/lib/task_server.rb

## lib/router.rb

<<< @/projects/01-http-api/lib/router.rb

## lib/task_store.rb

<<< @/projects/01-http-api/lib/task_store.rb
