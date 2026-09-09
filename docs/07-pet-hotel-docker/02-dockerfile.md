# 7.2 Dockerfile

> **TL;DR**
> Imagem Ruby, instala sqlite-dev, `WORKDIR /app`, copia Gemfile **antes** do resto, `bundle install`, depois `COPY . .`. Camada das gems não quebra quando você muda um controller. CMD default é o Puma. O worker sobrescreve o comando no compose.

## Conteúdo

- [A base](#a-base)
- [Gems antes do código](#gems-antes-do-código)
- [COPY .](#copy-)
- [CMD](#cmd)
- [Por que não multi-stage pesado](#por-que-não-multi-stage-pesado)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A base

**O que é:**
`ruby:3.3-bookworm`. Debian. Compila o native do `sqlite3`.

**Como funciona:**

```dockerfile
FROM ruby:3.3-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libsqlite3-0 libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*
```

Sem `libsqlite3-dev`, `bundle install` do sqlite3 explode. `rm -rf /var/lib/apt/lists/*` enxuga a camada.

**Na entrevista:**
> "A gem sqlite3 é C. A imagem precisa do header. Alpine também dá — recorte Debian."

---

## Gems antes do código

**O que é:**
A ordem do COPY. Cache de camada.

**Como funciona:**

```dockerfile
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
```

Mudou `stays_controller.rb`: rebuild usa cache do `bundle install`. Mudou Gemfile: bundle de novo. Entrevista clássica de Docker.

**Na entrevista:**
> "Gemfile primeiro. Senão todo save de Ruby rebundla. Camada é cache."

---

## COPY .

**O que é:**
O app. Respeita o `.dockerignore` do context (o 5).

**Como funciona:**
Sem dockerignore, você copia `tmp/`, sqlite, log. Imagem gorda. E pior: sqlite de dev dentro da imagem, volume por cima — confusão. Ignore `storage`, `tmp`, `*.sqlite3`.

**Na entrevista:**
> "dockerignore no context. tmp e sqlite não entram na imagem. Volume é o banco."

---

## CMD

**O que é:**
Default: Puma bind 0.0.0.0. Sem bind, escuta localhost **dentro** do container. Porta publicada, ninguém entra.

**Como funciona:**

```dockerfile
EXPOSE 3000
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
```

Compose do worker troca o command. A imagem é a mesma. Dois serviços, um build.

**Na entrevista:**
> "-b 0.0.0.0. Localhost no container não é o host. Eu já quebrei nisso."

---

## Por que não multi-stage pesado

**O que é:**
Stage de build + stage slim. Certo em produção. Recorte: uma stage. Development. Você fala o multi-stage no 7.5.

**Como funciona:**
Uma FROM. Imagem maior. Take-home lê em 20 linhas. Multi-stage: copiar gems, tirar build-essential. Capítulo “o que mudaria”.

**Na entrevista:**
> "Uma stage. Multi-stage eu desenho se pedirem produção. Aqui eu quero o trio no ar."

---

## Recapitulando

- Ruby + sqlite-dev
- Gemfile, bundle, depois código
- dockerignore no 5
- bind 0.0.0.0
- mesma imagem, command diferente

---

## Exercícios práticos

### Exercício 1: COPY . antes do bundle

**Enunciado:** Você inverte. O que dói no dia a dia?

<details>
<summary>Solução</summary>

Cada mudança de ERB invalida a camada do COPY e o bundle roda de novo. 2 minutos por save. A ordem existe para isso.

**Pontos-chave:**
- camada de cima invalida as de baixo
- gems mudam pouco
- código muda muito
</details>

### Exercício 2: -b 127.0.0.1

**Enunciado:** `docker compose up`, browser no host: connection refused. Puma loga que subiu. Onde?

<details>
<summary>Solução</summary>

Bind localhost do container. Publish `3000:3000` encaminha para a NIC do container, não para o loopback interno. `-b 0.0.0.0`.

**Pontos-chave:**
- localhost é relativo
- publish ≠ bind
- 0.0.0.0
</details>

---

*Parte do [Ruby Projects Handbook](/)*
