# 15.3 Perfil produção

> **TL;DR**
> `compose.prod.yml`. `RACK_ENV=production`. `${JWT_SECRET:?}` e `${WEBHOOK_SECRET:?}`. Caddy :80 → web:9292. Healthcheck `/up`. TLS, DNS, Kamal: quadro. Sem cert neste recorte.

## Conteúdo

- [Secret](#secret)
- [Puma](#puma)
- [Proxy](#proxy)
- [O que ainda não é](#o-que-ainda-não-é)
- [Como rodar](#como-rodar)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Secret

**O que é:**
O fallback de dev **some**. `IngressosEnv` aborta. Compose recusa interpolate vazio.

**Como funciona:**

```bash
JWT_SECRET=umsegredo WEBHOOK_SECRET=outrosecreto \
  docker compose -f compose.prod.yml up --build
```

Seed **não** roda no prod YAML (só migrate). Conta você cria no curl. Dev YAML seeda João.

**Na entrevista:**
> "Production sem secret não sobe. Eu não deixo o fallback no ar."

---

## Puma

**O que é:**
`config/puma.rb`. Bind 0.0.0.0. `PORT`, `WEB_CONCURRENCY`, `PUMA_THREADS` no env.

**Como funciona:**
Prod: 1 worker, 5 threads neste YAML. Ajuste é carga. 0.0.0.0 porque localhost no container não é o proxy.

**Na entrevista:**
> "Bind 0.0.0.0. Threads no env. Eu não hardcode 9292 só no host."

---

## Proxy

**O que é:**
Caddy reverse-proxy :80 → web:9292. O host fala 80. O Puma não publica 9292 no prod YAML — só a rede interna. Espera: no compose.prod web **não** tem ports. Só proxy 80. Bom.

**Como funciona:**
TLS: `caddy reverse-proxy --from example.com --to web:9292` pede DNS e 443. Recorte: HTTP 80. Capítulo: “Let's Encrypt é o from https://”.

**Na entrevista:**
> "Proxy na frente. TLS é o Caddy com host e 443. Neste YAML eu não finjo certificado."

---

## O que ainda não é

**O que é:**
A lista honesta.

**Como funciona:**
Kamal, Kubernetes, Terraform, CDN, WAF, backup automatizado, multi-região, conta AWS. Você desenha. O handbook não tem cloud account.

**Na entrevista:**
> "Com o livro eu subo o compose prod na VPS. DNS e TLS eu configuro no Caddy. Orquestrador é outro recorte."

---

## Como rodar

**O que é:**
Dev e prod.

**Como funciona:**

```bash
cd projects/15-ingressos-docker
docker compose up --build
docker compose -f compose.prod.yml config   # valida
```

**Na entrevista:**
> "up --build no 15. Login seed no compose dev. Prod eu passo o secret."

---

## Recapitulando

- secret obrigatório
- bind 0.0.0.0
- proxy :80
- TLS no quadro
- não é Kamal

---

## Exercícios práticos

### Exercício 1: compose prod sem env

**Enunciado:** O que o Docker diz?

<details>
<summary>Solução</summary>

Erro de interpolate `JWT_SECRET obrigatório`. Não chega a bootar Ruby. O `:?` do compose é o primeiro cadeado.

**Pontos-chave:**
- compose
- abort Ruby é o segundo
</details>

---

*Parte do [Ruby Projects Handbook](/)*
