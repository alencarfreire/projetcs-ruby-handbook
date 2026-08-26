# 1.5 Store em memória

> **TL;DR**
> O banco deste app é um Hash no processo: `@tasks = {}`. Chave Integer. Valor Hash com `id`, `title`, `completed` em string. `@next_id` é o autoincrement. POST cria. PUT substitui title e completed — os dois. PATCH mescla só o que veio. DELETE apaga. Mata o processo, zerou. Igual o `List<Task>` + `nextId` no handler Java. Diferente do PHP, que zera no request. Diferente do Rails, que é tabela.

## Conteúdo

- [O banco de bolso](#o-banco-de-bolso)
- [Chave Integer, valor Hash](#chave-integer-valor-hash)
- [Autoincrement](#autoincrement)
- [POST cria](#post-cria)
- [PUT substitui](#put-substitui)
- [PATCH mescla](#patch-mescla)
- [DELETE apaga](#delete-apaga)
- [Validação rasa](#validação-rasa)
- [Some quando o processo morre](#some-quando-o-processo-morre)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O banco de bolso

**O que é:**
`@tasks` e `@next_id` na instância do servidor. Sem SQL. Sem arquivo. Sem Redis. O store vive no heap do processo Ruby — o mesmo lugar onde o Java guarda o `List` no handler.

**Como funciona:**

```ruby
def initialize(host = "127.0.0.1", port = 4567)
  @host = host
  @port = port
  @tasks = {}
  @next_id = 1
end
```

Chegou um POST. Você valida. Gera o `id`. Empurra no Hash. Devolve 201. O próximo GET lê o mesmo Hash. Não tem `INSERT`. Não tem `commit`.

Três mundos, três stores. O entrevistador puxa isso:

| Onde | O que é o banco | Quando some |
|---|---|---|
| Java (`HttpServer` + handler) | `List<Task>` + `int nextId` | processo JVM morre |
| PHP (script + built-in server) | array no script | fim de cada request |
| Rails | Active Record / tabela | não some no restart |
| Este app | `@tasks` + `@next_id` | processo Ruby morre |

PHP engana. Dois curls, dois processos (ou o worker reseta o script). O array não atravessa o POST e o GET. Java e este Ruby se parecem: o objeto do servidor fica de pé. Rails é outro jogo: a linha sobrevive ao `rails restart`.

**Quando usar:**
Live coding. Take-home de um arquivo. Qualquer hora que o ponto seja HTTP, não persistência.

**Na entrevista:**
> "O store é um Hash na instância. Igual o List no handler Java. Diferente do PHP que morre no request. Diferente do Active Record. Recorte: sem banco."

---

## Chave Integer, valor Hash

**O que é:**
A fila do lookup. `@tasks[1]` — Integer. O JSON na porta não tem Integer de chave de objeto. Por isso o valor interno usa string nas chaves do recurso: `"id"`, `"title"`, `"completed"`. `JSON.generate` e `JSON.parse` falam essa língua.

**Como funciona:**

```ruby
@tasks[1] = {
  "id" => 1,
  "title" => "Comprar ração do Thor",
  "completed" => false
}

@tasks[1]
# => { "id" => 1, "title" => "Comprar ração do Thor", "completed" => false }

@tasks.values
# => array que o GET /tasks devolve
```

A chave do store é o `id`. Não é string `"1"`. A rota captura `(\d+)`, você faz `Integer(match[1])`, busca. Se você guardar com Integer e buscar com string, o Ruby não acha. Hash compara por igualdade de objeto, não por “parece número”.

O valor não é classe `Task`. É Hash. Java teria POJO. Rails teria model. Aqui o “model” cabe em três chaves. Se o entrevistador puxar OOP, você extrai. Não começa por ela.

**Quando usar:**
Sempre neste projeto. Um recurso, um Hash, uma chave Integer.

**Exemplo prático:**
`GET /tasks/1` não varre. É lookup. `O(1)`. Lista é `@tasks.values` — a ordem de inserção do Hash no Ruby 3 é estável. Você não promete sort. Se o entrevistador quiser ordem, você ordena na hora. Não agora.

**Na entrevista:**
> "Chave Integer, valor Hash com id, title, completed em string. JSON.parse devolve string. Eu não misturo Symbol no payload."

---

## Autoincrement

**O que é:**
`@next_id`. Começa em 1. Cada POST bem-sucedido pega o número e soma um. Sem `SERIAL`. Sem sequence. Sem `SecureRandom`.

**Como funciona:**

```ruby
id = @next_id
@next_id += 1
```

Ordem importa. Você copia, depois incrementa. Se incrementar antes e o PUT falhar no meio, não tem PUT aqui — mas o hábito vale: o `id` que você devolve é o que você guardou.

DELETE não reaproveita o número. Apagou o 2, o próximo POST continua 4 se 3 já saiu. Igual autoincrement de tabela. O Java do `nextId++` faz a mesma coisa. Rails com `id` integer também. Não é bug. É o recorte.

**Quando usar:**
Só no create. PUT, PATCH e DELETE usam o `id` da URL. Ninguém manda `id` no body para criar. Se mandar, você ignora. O servidor manda no recurso.

**Na entrevista:**
> "next_id na instância. POST pega e soma. Delete não recicla. Reiniciou o processo, volta a 1 — e a lista também some."

---

## POST cria

**O que é:**
Nasceu um recurso. Status 201. Header `Location: /tasks/:id`. Body com a task inteira.

**Como funciona:**
Você parseia o JSON. Title obrigatório. Completed opcional — se não veio, `false`. Gera `id`. Monta o Hash. Guarda. Devolve.

```ruby
task = {
  "id" => id,
  "title" => data["title"],
  "completed" => data.key?("completed") ? data["completed"] : false
}
@tasks[id] = task
[201, "Created", task, { "Location" => "/tasks/#{id}" }]
```

`data.key?("completed")` — presença, não truthiness. Se o cliente mandar `"completed": false`, você guarda false. Se testar `if data["completed"]`, false some e vira o default. Entrevista puxa isso.

**Exemplo prático:**

```bash
curl -s -D - -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Levar Luna no vet"}'
```

201. Location. `"completed": false`. O GET seguinte vê a mesma task. Mesmo processo. Se você matou o servidor no meio, o GET mente — lista vazia, next_id de novo 1.

**Na entrevista:**
> "POST lê o JSON, gera id, default completed false, 201 e Location. O id não vem do cliente."

---

## PUT substitui

**O que é:**
O recurso inteiro de novo. Title e completed, os dois. Id continua o da URL. O que não veio, não “fica o antigo” — PUT não é mescla.

**Como funciona:**
404 se o `id` não existe. Title válido. `completed` tem que estar no JSON. Boolean de verdade. Aí você monta um Hash novo e sobrescreve `@tasks[id]`.

```ruby
return missing_completed unless data.key?("completed")

task = {
  "id" => id,
  "title" => data["title"],
  "completed" => data["completed"]
}
@tasks[id] = task
```

PUT sem `completed` → 400 `"completed é obrigatório"`. PUT com `"completed": "true"` (string) → 400. PUT que tenta mudar o `id` pelo body → o id da URL ganha. Você nem lê `data["id"]`.

**Quando usar:**
Cliente que manda o documento completo. Formulário “salvar tudo”. Idempotente: o mesmo PUT duas vezes deixa o mesmo estado.

**Na entrevista:**
> "PUT substitui title e completed. Os dois. Sem completed, 400. O Rails junta PUT e PATCH no update — aqui eu distingo."

---

## PATCH mescla

**O que é:**
Só o que veio. Title sozinho, completed sozinho, os dois, ou um JSON vazio que não mexe em nada. O resto do recurso fica.

**Como funciona:**
404 se não achou. Se veio `title`, valida title. Se veio `completed`, valida boolean. Aí atribui só as chaves presentes.

```ruby
task["title"] = data["title"] if data.key?("title")
task["completed"] = data["completed"] if data.key?("completed")
```

De novo: `key?`. PATCH `{"completed": false}` marca false. Sem `key?`, false é falsy e o title que você não mandou também não entra — mas o completed não atualiza. Bug clássico.

PATCH não cria. Sem o `id` no store, 404. Não é upsert. POST cria. PATCH edita.

**PUT vs PATCH — o ponto que confunde:**

No Rails, `PUT /tasks/:id` e `PATCH /tasks/:id` caem no mesmo `update` quase sempre. Strong params, `task.update(params)`. O framework não obriga você a exigir o recurso inteiro no PUT. Spring separa `@PutMapping` e `@PatchMapping` — mas muita gente implementa os dois iguais. Aqui não tem annotation e não tem `update` mágico. Você mesmo decide. PUT incompleto é 400. PATCH incompleto é 200 e o campo que não veio fica.

**Exemplo prático:**

```bash
# só marca feita — title permanece
curl -s -X PATCH http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

**Na entrevista:**
> "PATCH mescla. PUT substitui. No Rails os dois viram update. Neste app eu separo, porque o entrevistador pergunta a diferença."

---

## DELETE apaga

**O que é:**
Saiu do Hash. 204. Body vazio. `Content-Length: 0`. Sem JSON de “apagado com sucesso”.

**Como funciona:**

```ruby
return not_found unless @tasks.key?(id)

@tasks.delete(id)
[204, "No Content", nil, {}]
```

`key?` antes do `delete`. Apagar o que não existe é 404, não 204. Segunda DELETE no mesmo id: 404. Não é idempotente no sentido “sempre 204”. Alguns tutoriais devolvem 204 nas duas. Aqui o contrato é: não achei, 404. Igual GET, PUT, PATCH.

O `id` não volta para o `@next_id`. Buraco na sequência. Lookup do id morto: 404.

**Quando usar:**
O cliente quer o recurso fora. Sem soft delete. Sem `deleted_at`. Sumiu do Hash, sumiu da lista.

**Na entrevista:**
> "DELETE tira do Hash e devolve 204 sem body. Id que não existe: 404. Não reciclo o número."

---

## Validação rasa

**O que é:**
O mínimo para o store não guardar lixo. Não é Active Record. Não é Bean Validation. Três regras.

**Como funciona:**

| Campo | POST | PUT | PATCH |
|---|---|---|---|
| `title` | string não vazia | string não vazia | se veio, string não vazia |
| `completed` | se veio, boolean | obrigatório, boolean | se veio, boolean |
| `id` | servidor gera | URL manda | URL manda |

Title: `is_a?(String)` e `!title.strip.empty?`. Número 1 não é title. `""` não é title. `"   "` não é title. `nil` não é title.

Completed: `true` ou `false`. Só. `"true"` é string. `0` e `1` não entram. JSON `null` não é boolean.

PUT exige a chave `completed`. Ausência ≠ false. Ausência é 400 `"completed é obrigatório"`. POST sem a chave é false. São regras diferentes de propósito.

JSON que não é objeto — array, string, vazio — cai no parse e vira 400. Isso é o capítulo do JSON. O store assume Hash.

**Quando usar:**
Antes de escrever no `@tasks`. Validou, guarda. Não validou, 400, o Hash nem vê.

**Exemplo prático:**

```ruby
def require_title(data)
  title = data["title"]
  return nil if title.is_a?(String) && !title.strip.empty?

  [400, "Bad Request", { "error" => "title é obrigatório" }, {}]
end
```

**Na entrevista:**
> "Title string não vazia. Completed boolean de verdade. PUT exige completed. PATCH só valida o que veio. Sem gem de validação."

---

## Some quando o processo morre

**O que é:**
O recorte mais alto desta API. Grite. `@tasks` não é banco. É memória. `Ctrl+C`, acabou.

**Como funciona:**
Ruby aloca o Hash no processo. Não tem fsync. Não tem WAL. O SO libera a RAM. Sobe de novo:

```ruby
@tasks = {}
@next_id = 1
```

POST, GET, POST no mesmo `ruby server.rb`: os três veem a mesma lista. Mata. Sobe. GET → `[]`. O id 1 nasce de novo, outra task. Não é a antiga.

Java: mata a JVM, o `List<Task>` some. PHP: você nem precisa matar — o array já morreu no fim do curl. Rails: `rails restart` e a tabela ainda está no SQLite. Quem veio de Laravel ou Rails e esconde o “some no restart” parece que não recortou. Quem fala parece que sabe o tempo de vida.

Dois processos, duas listas. Porta 4567 e porta 4568 não compartilham `@tasks`. Sem Redis no meio. Sem arquivo “depois eu coloco”.

**Quando usar:**
O exercício inteiro. Persistência é o projeto 2, com tabela. Aqui o ponto é HTTP + Hash.

**Importante na entrevista:**
Falar em voz alta. “Tá em memória. Reiniciou, zerou.” Se o entrevistador veio de PHP, complete: “o processo fica de pé entre um curl e outro, não é request-in request-out”. Se veio de Rails: “não tem Active Record neste. É o List do handler Java, em Ruby”.

**Na entrevista:**
> "Store em memória. Igual List mais nextId no Java. PHP zera no request. Rails persiste na tabela. Este app some quando o processo morre. Para o exercício serve."

---

## Recapitulando

- `@tasks = {}` — chave Integer, valor Hash com `"id"`, `"title"`, `"completed"`.
- `@next_id` autoincrement. DELETE não recicla.
- POST cria, 201, Location. Completed default false.
- PUT substitui title e completed. Os dois obrigatórios.
- PATCH mescla com `key?`. Rails junta os dois no `update`. Aqui não.
- DELETE tira do Hash, 204, body vazio. Id sumido: 404.
- Title string não vazia. Completed boolean. PUT exige completed.
- Mata o processo, zerou. Dizer isso.

---

## Exercícios práticos

### Exercício 1: O PUT veio sem completed

**Enunciado:** O cliente manda `PUT /tasks/1` com `{"title":"Vacina do Bidu"}`. A task 1 existe, completed é `false`. O que o servidor faz e por quê? E se fosse PATCH com o mesmo body?

<details>
<summary>Solução</summary>

PUT: 400 `"completed é obrigatório"`. Substituição exige os dois campos. Você não “completa” com o valor antigo — senão PUT vira PATCH.

PATCH: 200. Title vira `"Vacina do Bidu"`. Completed continua `false`. Só veio title, só title muda.

No Rails, os dois requests caem no `update` e o completed antigo permanece nos dois. Aqui a diferença é o contrato.

**Pontos-chave:**
- PUT incompleto é erro, não mescla
- PATCH incompleto é sucesso
- `key?("completed")` no PUT, não default false
</details>

### Exercício 2: Dois POSTs, um restart, um GET

**Enunciado:** Você sobe o servidor. Dois POSTs. Mata o processo. Sobe de novo. `GET /tasks`. O que volta? Compare com o mesmo roteiro em Java (`List` no handler), PHP (array no script) e Rails (tabela).

<details>
<summary>Solução</summary>

`[]`. `@tasks` novo. `@next_id` = 1. As duas tasks morreram com o processo.

Java: o `List<Task>` também some quando a JVM cai. Enquanto a JVM está de pé, os dois POSTs ficam. Igual aqui.

PHP: você nem chega no restart. Cada POST já era um array novo. O GET nunca veria os POSTs, a menos que o script gravasse arquivo.

Rails: `GET /tasks` devolve as duas linhas. Active Record lê a tabela. Restart não apaga.

**Pontos-chave:**
- Memória = processo
- PHP morre no request; Ruby deste app morre no processo
- Tabela sobrevive; Hash não
- Falar o “zerou” na entrevista
</details>

### Exercício 3: PATCH com completed false

**Enunciado:** Task 1 está `{"id":1,"title":"Comprar ração do Thor","completed":true}`. O cliente manda `PATCH /tasks/1` com `{"completed":false}`. Um colega escreveu `task["completed"] = data["completed"] if data["completed"]`. O que acontece? Como você corrige?

<details>
<summary>Solução</summary>

`false` é falsy. O `if data["completed"]` não entra. A task continua `true`. O PATCH “não fez nada” e ainda devolve 200. Mentira silenciosa.

Correção: presença da chave.

```ruby
task["completed"] = data["completed"] if data.key?("completed")
```

O mesmo buraco existe no POST se você escrever `data["completed"] || false`. False viraria false… espera: `false || false` é false, ok. Mas `data["completed"] || false` com `completed: false` também é false. O perigo real no POST é outro: você precisa de `key?` para não tratar ausência igual a false quando for validar tipo. No PATCH, `if data["completed"]` é o bug que o entrevistador planta.

**Pontos-chave:**
- `false` é valor, não ausência
- `key?` decide mescla
- 200 com estado errado é pior que 400
</details>

---

*Parte do [Ruby Projects Handbook](/)*
