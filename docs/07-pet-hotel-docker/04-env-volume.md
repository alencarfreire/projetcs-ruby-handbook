# 7.4 Env, volume, rede

> **TL;DR**
> `REDIS_URL=redis://redis:6379/0`. Hostname = nome do serviço. Volume `sqlite-data` em `/app/storage` nos dois Rails — o mesmo arquivo. Rede default do compose: os três se encontram pelo nome. Sem `127.0.0.1`.

## Conteúdo

- [REDIS_URL](#redis_url)
- [A rede](#a-rede)
- [O volume](#o-volume)
- [Dois processos, um SQLite](#dois-processos-um-sqlite)
- [O que não está no volume](#o-que-não-está-no-volume)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## REDIS_URL

**O que é:**
O initializer do 5 já lê `ENV.fetch("REDIS_URL", "redis://localhost:6379/0")`. No compose você **seta** a URL. No laptop, o default localhost. No container, localhost é mentira.

**Como funciona:**

```yaml
environment:
  RAILS_ENV: development
  REDIS_URL: redis://redis:6379/0
```

`redis` é DNS interno. Porta 6379 **dentro** da rede. Não publica Redis no host neste recorte — não precisa.

**Na entrevista:**
> "O hostname é o serviço. Eu não coloco o IP. Compose DNS."

---

## A rede

**O que é:**
Compose cria uma bridge. Serviços no `compose.yml` entram nela.

**Como funciona:**
Web resolve `redis`. Worker resolve `redis`. Host resolve `127.0.0.1:3000` porque `ports` mapeia. Host **não** resolve `redis` — a menos que você publique 6379.

**Na entrevista:**
> "Rede interna. Eu só publico o HTTP. Redis não precisa da sua máquina."

---

## O volume

**O que é:**
Disco que sobrevive ao container. SQLite é arquivo. Sem volume, `down` apaga o Thor.

**Como funciona:**

```yaml
volumes:
  - sqlite-data:/app/storage
```

`database.yml` do 5: `storage/development.sqlite3`. Bate.

`docker compose down` — volume fica. `down -v` — zerou. Seed no próximo up.

**Na entrevista:**
> "SQLite é arquivo. Volume no storage. Sem volume o banco é efêmero. Postgres seria outro serviço — capítulo 8."

---

## Dois processos, um SQLite

**O que é:**
Web e worker montam o **mesmo** named volume. Sem isso o worker não vê o check-in.

**Como funciona:**
Check-in no web grava no arquivo. Job no worker `Stay.find`. Mesmo path `/app/storage`. SQLite + dois writers: recorte de take-home. Produção: Postgres. Você fala.

**Na entrevista:**
> "Os dois Rails no mesmo volume. Worker sem o volume: RecordNotFound no job. O domínio 'sumiu'."

---

## O que não está no volume

**O que é:**
`tmp/mails`. Código. Gems.

**Como funciona:**
Mailer `:file` escreve `tmp/mails` **no container que rodou o job** — o worker. `docker compose exec worker ls tmp/mails`. Web não vê. Não está no volume. Recorte: ok. Produção: SMTP, não arquivo.

Código vem da imagem. Mudou o 5: rebuild. Volume não guarda Ruby.

**Na entrevista:**
> "Volume é o banco. Mail em arquivo é disco do worker. SMTP no 8."

---

## Recapitulando

- REDIS_URL com hostname redis
- rede default
- volume sqlite nos dois Rails
- down -v zera
- mails não estão no volume

---

## Exercícios práticos

### Exercício 1: REDIS_URL localhost no compose

**Enunciado:** Você esquece o env. Default do initializer: localhost:6379. Sintoma?

<details>
<summary>Solução</summary>

Puma no container tenta Redis em si mesmo. Connection refused. Check-in 500. Redis está saudável no outro container. Env.

**Pontos-chave:**
- localhost relativo
- nome do serviço
- 500 no enqueue
</details>

### Exercício 2: Volume só no web

**Enunciado:** Worker sem volume. Job de lembrete. O que o perform vê?

<details>
<summary>Solução</summary>

SQLite vazio (ou outro arquivo). Stay id do web não existe. discard_on RecordNotFound. Mail não sai. Volume nos dois.

**Pontos-chave:**
- um arquivo
- dois processos
- mesmo mount
</details>

---

*Parte do [Ruby Projects Handbook](/)*
