# 10 — Sequel: eventos no SQLite

Persistência sem HTTP. Sem Roda. Tabela `eventos`. Dataset devolve Hash. Model é opcional.

```
projects/10-sequel-sqlite/
  db.rb                 Sequel.sqlite
  migrate/001_eventos.rb
  lib/evento.rb         Sequel::Model (capítulo 10.5)
  examples/list.rb
  examples/insert.rb
  Rakefile
  bin/console
```

## O que você constrói

Tabela de eventos: `title`, `starts_at`, `venue`. Seed “Sunset Jazz”. Console e dois scripts.

## O que você treina

- `DB = Sequel.sqlite(...)`
- `DB[:eventos]` é o dataset
- Row é Hash (`row[:title]`)
- Migration Sequel, não `rails g`
- `Sequel::Model` quando vale — e quando o dataset chega

## Como rodar

```bash
cd projects/10-sequel-sqlite
bundle install
bundle exec ruby bin/seed
bundle exec ruby examples/list.rb
bundle exec ruby bin/console
```

No console:

```ruby
DB[:eventos].all
DB[:eventos].where(title: "Sunset Jazz").first
Evento.first.title
```

O sqlite fica em `storage/app.sqlite3`. Restart **não** apaga. Diferente do Hash do 9.

## O que NÃO entra (de propósito)

- Roda, Puma, HTTP
- Rodauth
- Lotes, pedidos, webhook
- Postgres
