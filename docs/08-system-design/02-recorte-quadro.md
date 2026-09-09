# 8.2 Recorte do quadro: API + HTML + job + live

> **TL;DR**
> Quatro caixas. HTML da recepção (2/4/6). API JSON (3). Worker (5). Redis (5/6/7). Postgres no meio. Você não funde tudo num “microsserviço de occupancy”. Stay é o agregado. O quadro é uma leitura.

## Conteúdo

- [As caixas](#as-caixas)
- [Um Rails ou quatro](#um-rails-ou-quatro)
- [Stay no centro](#stay-no-centro)
- [Quem fala com quem](#quem-fala-com-quem)
- [O que não ganha caixa](#o-que-não-ganha-caixa)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## As caixas

**O que é:**
O desenho mínimo.

**Como funciona:**

```
[Browser recepção] --HTTP--> [Web Rails]
[App interno]       --JSON--> [Web Rails]
[Web Rails]         --WS----> [Browser quadro]
[Web Rails]         --RPUSH-> [Redis] --> [Worker] --> [SMTP]
[Web Rails]         --SQL---> [Postgres]
[Worker]            --SQL---> [Postgres]
```

Cable adapter Redis: o web publica, os web workers recebem. Mesmo Redis da fila? Dá. Separar DB index 0/1 ou dois Redis. Entrevista: começa junto, separa se a fila enche.

**Na entrevista:**
> "Eu desenho web, worker, redis, postgres. O browser e o app são clientes. Occupancy não é um serviço."

---

## Um Rails ou quatro

**O que é:**
Este livro fez recortes em pastas. Produção pode ser **um** app com engines, ou o HTML + API no mesmo processo (`api_only` false, namespace `/api/v1`).

**Como funciona:**
Um repo, um deploy: HTML + JSON + jobs + cable. Os projetos 3–6 eram didáticos. Na empresa pequena, fundir. Na empresa com time de mobile só, a API pode ser o mesmo Rails com o namespace do 3.

Microsserviço de Stay: você duplica a regra `only_one_checked_in`. Não comece por aí.

**Na entrevista:**
> "Pastas do handbook são aulas. Produção eu junto no mesmo Rails até o time ou o deploy forçar o corte."

---

## Stay no centro

**O que é:**
A ocupação não é uma tabela à parte. É `stays.checked_in`.

**Como funciona:**
Check-in = update de status. Quadro = query. Lembrete = job lê a stay. API = o mesmo model. Se você materializar `occupancies` para “performance”, agora tem dois escritos. Recorte de escala ainda é a query com índice `(user_id, status)`.

**Na entrevista:**
> "Occupancy é leitura. Stay é escrita. Eu não crio um serviço para uma query."

---

## Quem fala com quem

**O que é:**
Setas. Sem seta, não existe.

**Como funciona:**
Mobile não fala com Redis. Browser não fala com Postgres. Worker não recebe HTTP do cliente. Web enfileira. Worker lê banco. Cable empurra HTML ou JSON para quem está inscrito.

O 4 (Stream no response) some em escala? Não. Continua útil na aba que clicou. O 6 cobre as outras. Os dois convivem.

**Na entrevista:**
> "O mobile usa o 3. A recepção usa HTML + cabo. O worker não é público."

---

## O que não ganha caixa

**O que é:**
CDN, Kafka, Elasticsearch, Kubernetes, service mesh. Só se a carga pedir.

**Como funciona:**
Busca de pet por nome: `LIKE` no Postgres. 20 recepções. Elastic é teatro. Kubernetes: 3 containers no compose já ensinaram o trio. Orquestração entra quando tem mais de uma máquina.

**Na entrevista:**
> "Eu resisto à caixa extra. Cada caixa é falha nova. Justifico com número."

---

## Recapitulando

- Quatro caixas + postgres
- Um Rails em produção pequena
- Stay agrega; occupancy lê
- Clientes não tocam Redis
- 4 e 6 convivem

---

## Exercícios práticos

### Exercício 1: Occupancy service

**Enunciado:** O entrevistador desenha um serviço só do quadro. Você compra?

<details>
<summary>Solução</summary>

Pergunta o write path. Se o serviço lê Stay de outro serviço, você ganhou latência e stale. Se duplica Stay, ganhou divergência. Query no Rails com índice. Serviço quando o quadro tiver fan-out de mil TVs e o HTML não couber no web. Não agora.

**Pontos-chave:**
- leitura vs escrita
- duplicar Stay dói
- índice primeiro
</details>

### Exercício 2: API e HTML em deploys separados

**Enunciado:** Dois deploys, um banco. Risco?

<details>
<summary>Solução</summary>

Migration. HTML deployou a coluna, API não. Ou o contrário. Lockstep ou expand/contract. Um deploy só evita. Se a empresa já separa, você desenha compatibilidade de schema.

**Pontos-chave:**
- schema compartilhado
- lockstep
- expand/contract
</details>

---

*Parte do [Ruby Projects Handbook](/)*
