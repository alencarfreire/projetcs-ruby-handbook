# 7.1 Recorte: empacotar, não novo domínio

> **TL;DR**
> Sem Stay nova. Sem tela nova. Você pega o projeto 5 (Puma + Sidekiq + Redis) e sobe os três em containers. `docker compose up --build`. Browser na 3000. O Thor continua no SQLite — agora num volume. Não é o compose da AWS.

## Conteúdo

- [Este projeto não é um Rails novo](#este-projeto-não-é-um-rails-novo)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [O context é o 5](#o-context-é-o-5)
- [O que fica de fora](#o-que-fica-de-fora)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Este projeto não é um Rails novo

**O que é:**
Pasta `projects/07-pet-hotel-docker/`: Dockerfile, compose.yml, README. Zero `app/models`.

**Como funciona:**
`build.context: ../05-pet-hotel-sidekiq`. A imagem é o 5. O 7 é a receita. Mudou o job no 5, rebuild. Não copie o Rails para cá — duas verdades.

**Quando usar:**
Entrevista “sobe isso com Docker”. Take-home que pede compose. Não quando pedem Kubernetes.

**Na entrevista:**
> "Eu não fiz o hotel de novo. Eu empacotei o 5. Três serviços: web, worker, redis."

---

## O problema

**O que é:**
Na máquina, três terminais. No compose, três serviços. O entrevistador quer ver que você sabe que o worker **não** é o web.

**Como funciona:**
Um `docker compose up`. Rede interna. Web fala `redis://redis:6379/0`. Hostname `redis` é o serviço. Na máquina era `localhost`. O nome mudou. O papel não.

**Na entrevista:**
> "localhost no container é o próprio container. O Redis é o hostname redis. Eu não coloco 127.0.0.1 no REDIS_URL."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Dockerfile da imagem Rails | Kamal, K8s |
| compose web + worker + redis | Postgres |
| volume SQLite | `RAILS_ENV=production` |
| `REDIS_URL` por env | Nginx, TLS |
| `db:prepare` no comando | multi-stage fancy, distroless |

Development no compose: `secret_key_base` já está no `development.rb` do 5. Produção exigiria SECRET, assets, host. Capítulo “o que mudaria” no 7.5.

**Na entrevista:**
> "Development de propósito. Eu não finjo produção sem Postgres e sem secret. Eu mostro os três processos."

---

## O context é o 5

**O que é:**
Docker build lê arquivos a partir do context. Dockerfile pode morar no 7.

**Como funciona:**

```yaml
build:
  context: ../05-pet-hotel-sidekiq
  dockerfile: Dockerfile
```

`COPY Gemfile` copia o Gemfile do **5**. `.dockerignore` que vale é o do **5**. O do 7 documenta.

**Na entrevista:**
> "Context é o código. Dockerfile é a receita. Podem estar em pastas diferentes."

---

## O que fica de fora

**O que é:**
A lista.

**Como funciona:**
Postgres, production, cron container, AnyCable, replica Redis. Capítulo 8 desenha isso no quadro. Este compose cabe em 40 linhas.

**Na entrevista:**
> "Se pedirem Postgres, eu troco o adapter e o serviço db. Neste recorte o volume sqlite ensina persistência sem migrar o banco."

---

## Como o walkthrough anda

**O que é:**
7.2 Dockerfile. 7.3 compose. 7.4 env/volume/rede. 7.5 como rodar + produção. [Código](/docs/07-pet-hotel-docker/codigo).

**Na entrevista:**
> "up --build. Login seed. reports:daily no exec. down."

---

## Recapitulando

- Empacota o 5, não clona o domínio
- Três serviços
- Context ≠ Dockerfile path
- Development, SQLite, volume
- localhost ≠ redis

---

## Exercícios práticos

### Exercício 1: Copiar o Rails para o 7

**Enunciado:** O entrevistador pergunta por que não tem `app/` aqui.

<details>
<summary>Solução</summary>

Duas cópias divergem. O 5 é a fonte. O 7 é embalagem. Rebuild lê o 5. Entrevista: “DRY do recorte”.

**Pontos-chave:**
- uma fonte
- context aponta
- 7 sem models
</details>

### Exercício 2: Um container só

**Enunciado:** Puma e Sidekiq no mesmo container com um process manager. Por que o handbook separa?

<details>
<summary>Solução</summary>

Escala diferente. Logs misturam. Restart do worker não precisa derrubar o HTTP. Compose existe para isso. Um container com `supervisord` é o anti-recorte.

**Pontos-chave:**
- um processo por container (quase)
- web ≠ worker
- redis é o terceiro
</details>

---

*Parte do [Ruby Projects Handbook](/)*
