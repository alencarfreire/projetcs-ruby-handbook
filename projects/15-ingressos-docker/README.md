# 15 — Docker dos ingressos

Empacota `projects/14-ingressos`: web (Puma), worker (Sidekiq), Postgres, Redis.

```
projects/15-ingressos-docker/
  Dockerfile
  compose.yml          development
  compose.prod.yml     RACK_ENV=production + proxy Caddy :80
```

## Como rodar (dev)

```bash
cd projects/15-ingressos-docker
docker compose up --build
```

API em `http://127.0.0.1:9292`. Seed: `joao@email.com` / `senha123`.

## Perfil produção (não é AWS)

Secrets **obrigatórios** no env. Proxy na 80. Sem TLS neste recorte (cert é o cloud).

```bash
JWT_SECRET=umsegredo WEBHOOK_SECRET=outrosecreto \
  docker compose -f compose.prod.yml up --build
```

Sem `JWT_SECRET` o compose recusa. O app em `RACK_ENV=production` também aborta se o secret faltar.

TLS de verdade, DNS, Kamal, backup: quadro. Não está neste YAML.

## O que NÃO entra

- Kubernetes, Terraform, conta de cloud
- Certificado Let's Encrypt (mencionado no walkthrough)
- Stripe
