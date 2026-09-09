# Código — Ingressos

App em `projects/14-ingressos`.

## Como rodar

```bash
cd projects/14-ingressos
bundle install
bundle exec ruby bin/seed
bundle exec puma
```

Testes: `bundle exec rake test`. Walkthrough: [14.1](/docs/14-ingressos/01-o-problema) → [14.7](/docs/14-ingressos/07-como-rodar).

## lib/reservar_lote.rb

<<< @/projects/14-ingressos/lib/reservar_lote.rb

## lib/confirmar_pagamento.rb

<<< @/projects/14-ingressos/lib/confirmar_pagamento.rb

## lib/webhook_schema.rb

<<< @/projects/14-ingressos/lib/webhook_schema.rb

## app.rb

<<< @/projects/14-ingressos/app.rb
