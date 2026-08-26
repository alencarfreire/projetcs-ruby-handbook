# 1.6 Status codes que caem em entrevista

> **TL;DR**
> Seis status. Só esses. 200 no GET, PUT e PATCH. 201 no POST, com `Location: /tasks/:id`. 204 no DELETE — sem body, `Content-Length: 0`. 400 quando o JSON quebra, o title falta ou o `completed` não é boolean. 404 quando o id não existe ou o path é desconhecido. 405 quando o path existe e o método não — e você manda `Allow`. O entrevistador puxa 201 vs 200, 204 vs 200, 404 vs 405.

## Conteúdo

- [O recorte dos status](#o-recorte-dos-status)
- [200 OK](#200-ok)
- [201 Created e o header Location](#201-created-e-o-header-location)
- [201 vs 200 no POST](#201-vs-200-no-post)
- [204 No Content](#204-no-content)
- [204 vs 200 no DELETE](#204-vs-200-no-delete)
- [400 Bad Request](#400-bad-request)
- [404 Not Found](#404-not-found)
- [405 Method Not Allowed](#405-method-not-allowed)
- [404 vs 405](#404-vs-405)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O recorte dos status

**O que é:** a tabela que o `TaskServer` honra. Não é a RFC inteira. É o que o app devolve em `projects/01-http-api/server.rb`.

**Como funciona:**

| Status | Quando |
|---|---|
| 200 | GET lista, GET um, PUT, PATCH |
| 201 | POST cria + `Location` |
| 204 | DELETE apaga, body vazio |
| 400 | JSON inválido, title faltando, `completed` que não é boolean |
| 404 | id inexistente **ou** path desconhecido |
| 405 | método errado no path que existe + `Allow` |

Seis números. Auth, conflito, mídia, validação de framework — fora. Não invente status que o servidor não emite.

No Rails você escreve `status: :created` e esquece o número. No Spring, `ResponseEntity.status(HttpStatus.CREATED)`. Aqui você escreve `201` na response line. O entrevistador vê o protocolo, não a annotation.

**Quando usar:** toda resposta. Sem status o cliente chuta.

**Na entrevista:**
> "Eu recorto em seis. 200, 201, 204, 400, 404, 405. O resto eu não invento. Neste app, não."

## 200 OK

**O que é:** deu certo e tem body. Leitura e atualização. Não é criação. Não é exclusão.

**Como funciona:** quatro caminhos no `dispatch`: GET da lista, GET de um, PUT, PATCH. Todos `[200, "OK", payload, {}]`.

Lista vazia também é 200. `[]` é payload válido. Não é 404. 404 é “não achei o recurso”. A coleção existe — está vazia.

PUT e PATCH devolvem a task depois da mudança. Rails faz `render json: task` — 200 implícito. Spring faz `ResponseEntity.ok(task)`. Sucesso com representação.

**Quando usar:** GET, PUT, PATCH. Sempre com `Content-Type: application/json`.

**Exemplo prático:**

```bash
curl -s -i http://127.0.0.1:4567/tasks
# HTTP/1.1 200 OK  →  []

curl -s -i -X PATCH http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
# HTTP/1.1 200 OK
```

**Na entrevista:**
> "200 é sucesso com body. Lista vazia é 200 com []. PUT e PATCH devolvem a task. Não misturo 200 com criação nem com delete."

## 201 Created e o header Location

**O que é:** nasceu um recurso. O body é a task. O header `Location` aponta para ela: `/tasks/:id`.

**Como funciona:** `create_task` gera o id, guarda no Hash, devolve:

```ruby
[201, "Created", task, { "Location" => "/tasks/#{id}" }]
```

A response fica `HTTP/1.1 201 Created`, `Location: /tasks/1`, e o JSON da task.

Rails: `render json: task, status: :created, location: task_url(task)`. Spring: `ResponseEntity.created(uri).body(task)`. Os dois escondem a linha que você monta na mão.

O cliente não adivinha o id. `Location` é o contrato. O body é a representação pronta. Os dois: “criei, está aqui, é isto”.

**Quando usar:** só no POST que inseriu. Title faltou? 400. 201 mente se o Hash não ganhou chave.

**Exemplo prático:**

```bash
curl -s -i -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Levar Luna no vet"}'
# HTTP/1.1 201 Created
# Location: /tasks/1
```

**Na entrevista:**
> "POST bem-sucedido é 201 e Location: /tasks/:id. Rails faz status: :created. Spring faz ResponseEntity.created. Sem Location o cliente não sabe o URI."

## 201 vs 200 no POST

**O que é:** a pergunta depois do “POST cria”. Por que não 200?

**Como funciona:** 200 diz “tratei o request”. 201 diz “nasceu um recurso, tem URI novo”. POST que só dispara um job pode ser 200. POST que cria a task da Luna é 201.

Se você devolver 200, o cliente lê o body. O protocolo não anunciou criação. Cache, cliente REST, o próximo dev — perdem o sinal. `Location` sem 201 fica manco: status e header andam juntos.

POST neste app não é idempotente: dois POSTs, duas tasks, dois ids. Dois 201 estão certos. Dois 200 esconderiam que nasceram dois recursos.

**Importante na entrevista:** não basta “201 é created”. Fale o par: status + `Location`. Quem fala só o número decorou a tabela. Quem aponta o header implementou.

**Na entrevista:**
> "200 no POST até funciona no Postman. 201 + Location é o contrato. Rails: status: :created. Spring: ResponseEntity.created. Sem isso eu tratei o request — não anunciei o recurso."

## 204 No Content

**O que é:** deu certo e não tem o que devolver. DELETE da task. Body nenhum. `Content-Length: 0`.

**Como funciona:**

```ruby
def delete_task(id)
  return not_found unless @tasks.key?(id)
  @tasks.delete(id)
  [204, "No Content", nil, {}]
end
```

`payload` nil. `respond` não manda `Content-Type`. Não manda `{}`. Manda `HTTP/1.1 204 No Content` e `Content-Length: 0`.

Rails: `head :no_content`. Não é `render json: nil`. `head` escreve status e fecha. Spring: `ResponseEntity.noContent().build()`. Os três: sucesso sem representação.

**Quando usar:** DELETE que achou o id e apagou. Id fora do Hash? 404 — o delete não aconteceu.

**Exemplo prático:**

```bash
curl -s -i -X DELETE http://127.0.0.1:4567/tasks/1
# HTTP/1.1 204 No Content
# Content-Length: 0
```

Sem `-i` você vê vazio e acha que quebrou. 204 é vazio.

**Na entrevista:**
> "DELETE devolve 204. Sem body. Content-Length 0. Rails é head :no_content. Spring é noContent(). Eu não mando JSON vazio — JSON vazio já é body."

## 204 vs 200 no DELETE

**O que é:** o outro par que o entrevistador ama. Apaguei. Devolvo a task morta ou devolvo silêncio?

**Como funciona:** 200 no DELETE com a task no body: o cliente vê o que sumiu. Alguma API faz isso. Não é este recorte. Aqui o recurso acabou. Não tem representação. 204.

200 com `{}` também é errado neste app. `{}` é objeto JSON. Tem body. Tem `Content-Type`. 204 não tem.

A armadilha do framework: no Rails, `render json: task` depois do `destroy` vira 200 com body. `head :no_content` é o outro caminho. Neste servidor a escolha está no `nil` do payload — o `respond` bifurca.

Se o DELETE não achou o id, não é 204. 204 mentiria: “apaguei com sucesso” o que não existia. É 404.

**Na entrevista:**
> "204 vs 200 no DELETE: 204 é sucesso, nada para ler. 200 seria devolver a task apagada. Eu recorto no silêncio. Rails head :no_content. Id inexistente é 404 — 204 mentiria."

## 400 Bad Request

**O que é:** o cliente mandou lixo ou incompleto. Path certo. Método certo. Body não.

**Como funciona:** três casos. Só esses.

1. JSON inválido — parse quebra, body vazio, body que não é objeto → `"JSON inválido"`.
2. Title faltando — nil, string vazia, só espaço, ou sem a chave → `"title é obrigatório"`.
3. `completed` não boolean — string `"true"`, número, null quando a chave veio → `"completed deve ser boolean"`.

PUT ainda exige a chave `completed`. Faltou: 400. PATCH não exige — PATCH é parcial. Mesmo status, regra diferente por verbo.

Não é erro de negócio rico. É: não deu para montar a task.

**Quando usar:** antes de mexer no Hash. 400 não cria, não atualiza.

**Exemplo prático:**

```bash
curl -s -i -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" -d '{quebrado'
# 400 JSON inválido

curl -s -i -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" -d '{}'
# 400 title é obrigatório

curl -s -i -X PATCH http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" -d '{"completed":"sim"}'
# 400 completed deve ser boolean
```

**Na entrevista:**
> "400 é body ruim. JSON quebrado, title faltando, completed que não é boolean. Path certo — não é 404. Método certo — não é 405. Recuso e não toco no Hash."

## 404 Not Found

**O que é:** não achei. Duas origens, um status.

**Como funciona:**

1. Path desconhecido — não é `/tasks`, não casa `/tasks/:id`. `GET /foo`. Fora do recorte → 404.
2. Id inexistente — o path casou, o Hash não tem a chave. `GET /tasks/99`. `DELETE /tasks/99`. PUT e PATCH no id que nunca existiu.

Lista vazia **não** é 404. `GET /tasks` → 200 e `[]`. A coleção existe.

**Quando usar:** path que o `dispatch` não mapeia. Id que `@tasks[id]` não acha. Os dois.

**Exemplo prático:**

```bash
curl -s -i http://127.0.0.1:4567/tasks/99     # 404
curl -s -i http://127.0.0.1:4567/nao-existe  # 404
```

**Na entrevista:**
> "404 são dois casos. Path que eu não mapeio. Id que não está no Hash. GET /tasks vazio é 200 com []. Não misturo coleção vazia com recurso ausente."

## 405 Method Not Allowed

**O que é:** o path existe. O verbo não. Você avisa quais verbos servem: header `Allow`.

**Como funciona:** dois `else` no `case` do método:

```ruby
# path /tasks
[405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, POST" }]

# path /tasks/:id
[405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, PUT, PATCH, DELETE" }]
```

`POST /tasks/1` — o path existe no roteamento. POST não. 405, `Allow: GET, PUT, PATCH, DELETE`.

`DELETE /tasks` — a coleção existe. DELETE nela não. 405, `Allow: GET, POST`.

Sem `Allow` o 405 fica mudo. RFC pede o header. Spring: `ResponseEntity.status(METHOD_NOT_ALLOWED).header("Allow", ...)`. Você escreve no `extra`.

**Quando usar:** path casou. Método caiu no `else`. Path desconhecido é 404, não 405.

**Exemplo prático:**

```bash
curl -s -i -X POST http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Vacina do Bidu"}'
# HTTP/1.1 405 Method Not Allowed
# Allow: GET, PUT, PATCH, DELETE
```

**Na entrevista:**
> "405 é path certo, verbo errado. Eu mando Allow. POST em /tasks/1 não é 404 — a rota existe, o POST não."

## 404 vs 405

**O que é:** o ponto que o entrevistador adora. Os dois “não deu”. A pergunta é: não deu porque o recurso não existe, ou porque o verbo é o errado?

**Como funciona:** ordem no `dispatch`: primeiro o path, depois o método.

| Request | Por quê | Status |
|---|---|---|
| `GET /nao-existe` | path desconhecido | 404 |
| `GET /tasks/99` | path ok, id fora do Hash | 404 |
| `POST /tasks/1` | path `/tasks/:id` existe, POST não | 405 + Allow |
| `DELETE /tasks` | path `/tasks` existe, DELETE não | 405 + Allow |
| `PUT /foo` | path desconhecido | 404 — nem chega no Allow |

Quem devolve 404 em `POST /tasks/1` diz “essa URI não existe”. Existe. Você busca, substitui, pacha, apaga. Só não cria no id. Quem devolve 405 em `GET /nao-existe` diz “o path existe, troque o verbo”. Não existe. Não tem `Allow` honesto.

No Rails, rota não batida costuma 404. Verbo errado na rota batida costuma 405. O `routes.rb` decide. Aqui o `if path` decide. Mesma regra, sem DSL.

**Importante na entrevista:** dois eixos: path e método. 404 é falha de path ou de id. 405 é sucesso de path e falha de método. Quem mistura os dois não roteou — chutou um erro genérico.

**Na entrevista:**
> "404 vs 405: path não existe ou id fora do Hash, 404. Path existe e verbo não, 405 com Allow. POST /tasks/1 é 405. GET /tasks/99 é 404. O entrevistador quer essa frase."

## Recapitulando

- Seis status. Recorte. O que o `server.rb` devolve.
- 200: GET, PUT, PATCH. Lista vazia é 200 com `[]`.
- 201: POST criou. Body da task + `Location: /tasks/:id`. Rails `status: :created`. Spring `ResponseEntity.created`.
- 201 vs 200 no POST: 200 trata o request. 201 anuncia recurso novo.
- 204: DELETE. Sem body. `Content-Length: 0`. Rails `head :no_content`. Spring `noContent()`.
- 204 vs 200 no DELETE: 200 devolveria a task apagada. 204 é silêncio. 204 em id inexistente mente — aí é 404.
- 400: JSON inválido, title faltando, `completed` não boolean. Path e método ok. Store intacto.
- 404: path desconhecido **ou** id inexistente. Dois casos, um número.
- 405: path existe, método não. Header `Allow`.
- 404 vs 405: o eixo path/método. Frase de quadro.

## Exercícios práticos

### Exercício 1: Por que 201 e não 200 no POST?

**Enunciado:** João cria a task `"Comprar ração do Thor"`. O body volta certo, o id é 1. Um colega manda 200 e esquece o `Location`. O que você fala no quadro — e o que o `create_task` precisa devolver?

<details>
<summary>Solução</summary>

200 diz que o request foi tratado. Não diz que nasceu recurso. Sem `Location` o cliente não tem o URI. O par certo é 201 + `Location: /tasks/1` + body da task.

```ruby
[201, "Created", task, { "Location" => "/tasks/#{id}" }]
```

Rails: `status: :created` + `location:`. Spring: `ResponseEntity.created(uri).body(task)`. Mesma linha, outra pele.

Dois POSTs seguidos: duas tasks, dois 201. Não é bug. POST neste app não é idempotente.

**Pontos-chave:**
- 201 anuncia criação; 200 não
- `Location` é contrato, não enfeite
- Sem o par, o cliente adivinha o id
</details>

### Exercício 2: DELETE com body — pode?

**Enunciado:** Maria quer `DELETE /tasks/1` devolvendo a task apagada em 200. Outra pessoa quer `{}` em 204. O que o recorte deste app manda — e como o Rails e o Spring escrevem isso?

<details>
<summary>Solução</summary>

Recorte: 204, payload `nil`, `Content-Length: 0`. Sem JSON. Sem `{}`. `{}` já é body — 204 não tem body.

```ruby
@tasks.delete(id)
[204, "No Content", nil, {}]
```

Rails: `head :no_content`. Não é `render json: task` depois do destroy — isso vira 200. Spring: `ResponseEntity.noContent().build()`.

Se o id 1 não está no Hash, 404. 204 diria “apaguei” o que não existia.

**Pontos-chave:**
- 204 é silêncio; 200 no DELETE seria a task morta
- `{}` não é 204
- id inexistente não é 204
</details>

### Exercício 3: 404 ou 405?

**Enunciado:** Três curls. Para cada um, status e porquê. Depois a frase que você fala se o entrevistador perguntar a diferença.

```bash
curl -i http://127.0.0.1:4567/tasks/99
curl -i -X POST http://127.0.0.1:4567/tasks/1 -d '{"title":"x"}'
curl -i http://127.0.0.1:4567/foo
```

<details>
<summary>Solução</summary>

1. `GET /tasks/99` → 404. Path casou. Id não está no Hash.
2. `POST /tasks/1` → 405 + `Allow: GET, PUT, PATCH, DELETE`. Path `/tasks/:id` existe. POST não.
3. `GET /foo` → 404. Path desconhecido. Nem chega em método.

Frase: 404 é path desconhecido ou id inexistente. 405 é path conhecido, verbo errado, e você manda `Allow`. Quem devolve 404 no POST em `/tasks/1` não roteou — chutou.

**Pontos-chave:**
- Dois eixos: path e método
- 404 tem duas origens; 405 tem uma
- `Allow` só faz sentido no 405
</details>

---

*Parte do [Ruby Projects Handbook](/)*
