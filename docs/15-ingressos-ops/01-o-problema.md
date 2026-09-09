# 15.1 Empacotar o 14

> **TL;DR**
> Sem domínio novo. Compose: web, worker, postgres, redis. Context `../14-ingressos`. Development no `compose.yml`. Produção no `compose.prod.yml` + secret no env + proxy :80. Não é AWS.

## Conteúdo

- [O que é o 15](#o-que-é-o-15)
- [O recorte](#o-recorte)
- [Dois YAML](#dois-yaml)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que é o 15

**O que é:**
A receita. Zero `routes/`. O código é o 14.

**Como funciona:**
`docker compose up --build`. 9292. Seed João. Worker consome expire e mail. Postgres é o banco. Redis é a fila.

**Quando usar:**
“Sobe isso”. Entrevista de Docker na stack Roda. O 7 era o hotel Rails. Este é ingressos.

**Na entrevista:**
> "Quatro serviços. Web não é worker. Postgres não é sqlite. Redis não é o domínio."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| web, worker, postgres, redis | Kubernetes |
| env JWT_SECRET / WEBHOOK_SECRET | Kamal, Terraform |
| proxy Caddy :80 no prod | Let's Encrypt neste YAML |
| healthcheck `/up` | CDN, WAF |

**Na entrevista:**
> "Compose de bolso. Cloud eu desenho: DNS, TLS, backup. Não finjo que o YAML já é a AWS."

---

## Dois YAML

**O que é:**
`compose.yml` development, secret de compose, seed no start.
`compose.prod.yml` `RACK_ENV=production`, secret obrigatório, proxy, sem seed automático (migrate sim).

**Como funciona:**
Prod aborta sem env. Dev tem fallback no Ruby **e** secret no compose para o HMAC bater entre web e o curl.

**Na entrevista:**
> "Production sem JWT_SECRET não sobe. Dev não mente que é prod."

---

## Recapitulando

- empacota o 14
- quatro serviços
- dois YAML
- não é o cloud

---

## Exercícios práticos

### Exercício 1: localhost no REDIS_URL do compose

**Enunciado:** Sintoma?

<details>
<summary>Solução</summary>

Worker e web tentam Redis em si mesmos. Enqueue falha. Hostname `redis`.

**Pontos-chave:**
- DNS do compose
- localhost relativo
</details>

---

*Parte do [Ruby Projects Handbook](/)*
