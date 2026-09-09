# 7.5 Como rodar (e o que mudaria em produção)

> **TL;DR**
> `cd projects/07-pet-hotel-docker`. `docker compose up --build`. `http://127.0.0.1:3000`. Login seed. `docker compose exec web bin/rails reports:daily`. `docker compose down`. Produção: SECRET, Postgres, `RAILS_ENV=production`, assets, Redis persistente, healthcheck. Não está neste YAML. Fonte: [código](/docs/07-pet-hotel-docker/codigo).

## Conteúdo

- [up --build](#up---build)
- [Login e o worker](#login-e-o-worker)
- [exec](#exec)
- [down](#down)
- [O que mudaria em produção](#o-que-mudaria-em-produção)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## up --build

**O que é:**
Builda a imagem do 5, sobe os três.

**Como funciona:**

```bash
cd projects/07-pet-hotel-docker
docker compose up --build
```

Primeira vez: bundle na imagem. Demora. Segunda: cache das gems. Logs dos três serviços no mesmo terminal. `-d` se quiser solto.

**Na entrevista:**
> "up --build. Eu mostro o browser. Sem Docker na máquina, eu falo o YAML no quadro e paro."

---

## Login e o worker

**O que é:**
A prova de que não é só o Puma.

**Como funciona:**
Login `joao@email.com` / `senha123`. Check-in de stay futura. Log do **worker** mostra o job scheduled. Sem worker, o Redis empilha e ninguém consome.

**Na entrevista:**
> "Eu olho o log do worker, não só o 200 do web. Três serviços, três logs."

---

## exec

**O que é:**
Comando num container que já está up.

**Como funciona:**

```bash
docker compose exec web bin/rails reports:daily
docker compose exec worker ls tmp/mails
```

Rake no web enfileira. Worker manda o mail. ls no worker.

**Na entrevista:**
> "exec web para o rake. O cron da máquina chamaria a mesma coisa. Sem container cron neste recorte."

---

## down

**O que é:**
Mata os containers. Volume fica.

**Como funciona:**

```bash
docker compose down
docker compose down -v   # apaga o sqlite
```

Sobe de novo sem `-v`: Thor ainda está. Com `-v`: seed de novo no prepare.

**Na entrevista:**
> "down não é drop database. -v é. Eu falo a diferença."

---

## O que mudaria em produção

**O que é:**
O quadro honesto. Este YAML não vai para a AWS.

**Como funciona:**

| Aqui | Produção |
|---|---|
| `RAILS_ENV=development` | `production` |
| secret no development.rb | `SECRET_KEY_BASE` no env |
| SQLite no volume | Postgres serviço + backups |
| async/file mail | SMTP / adapter |
| Redis sem persistência | Redis com volume / managed |
| uma stage | multi-stage, user non-root |
| sem healthcheck | healthcheck + restart |
| bind 3000 no host | Nginx / load balancer |
| cron na sua máquina | CronJob / scheduler |

Capítulo 8 desenha a Pousada em escala. Este 7.5 lista o delta do YAML.

**Na entrevista:**
> "Este compose ensina o trio. Produção eu troco o banco, o secret e o env. Eu não finjo que o YAML já é prod."

---

## Recapitulando

- up --build, porta 3000
- log do worker
- exec no rake
- down vs down -v
- produção é outra lista

---

## Exercícios práticos

### Exercício 1: Porta 3000 ocupada

**Enunciado:** O 5 ainda está no `bin/rails s` da máquina. Compose sobe e falha no bind. O que você faz?

<details>
<summary>Solução</summary>

Mata o Puma da máquina ou muda o map `3001:3000`. Dois donos da 3000. Igual o conflito 2 vs 4, agora com Docker.

**Pontos-chave:**
- host port
- um dono
- 3001:3000
</details>

### Exercício 2: Compose sem --build depois de mudar o job

**Enunciado:** Você mudou o mailer no 5, `compose up` sem `--build`. O mail velho continua. Por quê?

<details>
<summary>Solução</summary>

Código está na imagem. Volume não tem Ruby. Sem rebuild, imagem velha. `--build` ou `compose build && up`.

**Pontos-chave:**
- imagem ≠ volume
- código na imagem
- banco no volume
</details>

---

*Parte do [Ruby Projects Handbook](/)*
