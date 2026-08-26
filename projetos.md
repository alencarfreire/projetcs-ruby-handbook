# Projetos

Walkthrough é `docs/`. Código que sobe é `projects/`. Aqui está a pasta e o comando.

## Árvore

```
projects-ruby-handbook/
├── docs/                         walkthrough (entrevista)
│   └── 01-http-api/              1.1 → 1.7
└── projects/                     app que roda
    └── 01-http-api/
        ├── README.md             o que constrói, comandos, curls
        ├── bin/server            executável
        ├── server.rb             sobe a API
        └── lib/
            ├── task_server.rb    TCP + HTTP
            ├── router.rb         method + path
            └── task_store.rb     Hash em memória
```

O pet hotel (`projects/02-pet-hotel`) entra na fase 2. Pasta ainda não existe.

## 1. HTTP API pura

Fonte na íntegra, neste handbook: [código completo](/docs/01-http-api/codigo). Como rodar: [README](/projects/01-http-api/).

### Como rodar

```bash
cd projects/01-http-api
ruby server.rb
# ou
ruby bin/server
```

Sobe em `http://127.0.0.1:4567`. Sem `bundle`. Sem Gemfile. `Ctrl+C` zera o Hash.

### Comando que prova

```bash
curl -s http://127.0.0.1:4567/tasks
# []
```

CRUD, 4xx e o resto dos curls: [README do projeto](/projects/01-http-api/).

### O que tem no arquivo

Três peças, três arquivos:

| Arquivo | Papel |
|---|---|
| `lib/task_server.rb` | TCPServer, lê HTTP, escreve HTTP |
| `lib/router.rb` | method + path |
| `lib/task_store.rb` | `@tasks` + `@next_id` |

Não é Rails. Sem Gemfile.

Walkthrough: [1.1](/docs/01-http-api/01-o-problema) → [1.7](/docs/01-http-api/07-como-rodar).

## Fonte — HTTP API

O mesmo código que está em `projects/01-http-api`. Sem sair do handbook.

### server.rb

<<< @/projects/01-http-api/server.rb

### bin/server

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../server"
TaskServer.new.start
```

### lib/task_server.rb

<<< @/projects/01-http-api/lib/task_server.rb

### lib/router.rb

<<< @/projects/01-http-api/lib/router.rb

### lib/task_store.rb

<<< @/projects/01-http-api/lib/task_store.rb

## 2. Pet hotel — ainda não

Quando entrar:

```
projects/02-pet-hotel/     app Rails
docs/02-pet-hotel/         walkthrough 2.1 → 2.8
```

Comando previsto: `bin/rails db:setup` e `bin/rails s`.
