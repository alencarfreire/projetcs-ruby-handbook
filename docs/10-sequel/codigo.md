# Código — Sequel (eventos)

App em `projects/10-sequel-sqlite`. Sem HTTP.

## Como rodar

```bash
cd projects/10-sequel-sqlite
bundle install
bundle exec ruby bin/seed
bundle exec ruby examples/list.rb
```

Walkthrough: [10.1](/docs/10-sequel/01-o-problema) → [10.6](/docs/10-sequel/06-como-rodar).

## Pasta

```
projects/10-sequel-sqlite/
  db.rb
  migrate/001_eventos.rb
  lib/evento.rb
  examples/list.rb
```

## db.rb

<<< @/projects/10-sequel-sqlite/db.rb

## migrate/001_eventos.rb

<<< @/projects/10-sequel-sqlite/migrate/001_eventos.rb

## examples/list.rb

<<< @/projects/10-sequel-sqlite/examples/list.rb

## lib/evento.rb

<<< @/projects/10-sequel-sqlite/lib/evento.rb
