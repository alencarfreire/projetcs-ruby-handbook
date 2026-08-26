# 1.3 Rotas na mão (method + path)

> **TL;DR**
> Não tem `routes.rb`. Não tem `@GetMapping`. Não tem `app.get`. Você é o router: um `if` no path, um `case` no method. `/tasks` é a coleção. `/tasks/:id` é o membro — e `:id` aqui é regex `\A/tasks/(\d+)\z`, só dígito. Query string você corta antes. Path que não existe: 404. Path que existe, método que não: 405 + header `Allow`. JSON e Hash ficam para 1.4 e 1.5.

## Conteúdo

- [Você é o router](#você-é-o-router)
- [Method + path](#method--path)
- [A query string some antes](#a-query-string-some-antes)
- [Coleção e membro](#coleção-e-membro)
- [O regex do :id](#o-regex-do-id)
- [404 não é 405](#404-não-é-405)
- [O case/when do dispatch](#o-casewhen-do-dispatch)
- [O que o Rails esconde](#o-que-o-rails-esconde)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Você é o router

**O que é:**
Roteamento é a pergunta “esse request cai em qual ramo?”. No Rails, `config/routes.rb`. No Spring, annotation no controller. No Express, `app.get("/tasks", ...)`. Aqui não tem tabela de rotas. Tem um método `dispatch`. Você escreve o mapa na mão.

**Como funciona:**
O 1.2 já te deu method, path e body. O `handle` chama `dispatch(method, path, body)`. O `dispatch` devolve status, reason, payload e um Hash de headers extras. Sem DSL. Sem `resources`. Sem `Router` de gem. Se você vier de Rails, o instinto é procurar o arquivo de rotas. Não tem. O arquivo é o `server.rb`. O router é o `if`/`elsif`/`else`.

**Quando usar:**
Exercício “HTTP sem framework”. Live coding de 45 minutos. Take-home de um arquivo. Qualquer hora que o entrevistador queira ver se você sabe o que o `routes.rb` esconde.

**Exemplo prático:**
O mesmo `GET /tasks`, quatro peles:

| Stack | Quem decide o ramo |
|---|---|
| Rails | `resources :tasks` → `TasksController#index` |
| Spring | `@GetMapping("/tasks")` no método |
| Express | `app.get("/tasks", handler)` |
| Este app | `if path == "/tasks"` + `when "GET"` |

**Na entrevista:**
> "Aqui não tem router. Eu sou o router. Chegou method e path, eu decido o ramo no dispatch. O Rails faz isso no routes.rb. O Spring faz com annotation. Eu faço com if e case."

---

## Method + path

**O que é:**
A chave da rota não é só o path. É o par. `GET /tasks` lista. `POST /tasks` cria. Mesmo path, outro verbo, outro ramo. Quem olha só o path mistura lista com create.

**Como funciona:**
O contrato deste app:

| Método | Path | Ramo |
|---|---|---|
| `GET` | `/tasks` | lista |
| `POST` | `/tasks` | cria |
| `GET` | `/tasks/:id` | um |
| `PUT` | `/tasks/:id` | substitui |
| `PATCH` | `/tasks/:id` | parcial |
| `DELETE` | `/tasks/:id` | apaga |

Dois paths. Seis pares. O resto é erro — e o tipo do erro depende de *qual* parte falhou.

**Quando usar:**
Antes de escrever o `if`. Você desenha a tabela. Depois o código só copia. Sem tabela, você inventa `POST /tasks/:id` no meio do live coding.

**Exemplo prático:**
João manda `GET /tasks`. Cai no primeiro ramo. Maria manda `POST /tasks` com um title. Mesmo path, outro method, outro ramo. O path sozinho não decide nada.

**Na entrevista:**
> "Rota é method mais path. GET /tasks lista. POST /tasks cria. Se eu olhar só o path, eu misturo os dois."

---

## A query string some antes

**O que é:**
O cliente pode mandar `GET /tasks?completed=false`. A request line traz o `?` e o que vem depois. Isso **não** entra no roteamento. Você corta.

**Como funciona:**
No `handle`, antes do `dispatch`:

```ruby
method, raw_path, _ = request_line.split(" ")
path = raw_path.to_s.split("?", 2).first
```

`/tasks?completed=false` vira `/tasks`. `/tasks/1?foo=bar` vira `/tasks/1`. O `dispatch` nunca vê o `?`.

Se você comparar `raw_path == "/tasks"`, o GET com query vira 404. O path “bate” para o humano e falha para o `==`. No Rails, o router já separa `request.path` de `request.query_parameters`. No Express, `req.path` e `req.query`. Aqui você faz o recorte na mão — e faz **antes** do `if`.

Filtro por `completed` não entra neste capítulo. Cortar a query não é implementar filtro. É não deixar o `?` quebrar a rota.

**Quando usar:**
Sempre. Mesmo que você ignore a query para sempre. O corte é higiene do path.

**Exemplo prático:**

```bash
curl -i 'http://127.0.0.1:4567/tasks?completed=false'
# cai em GET /tasks — lista. Não é 404.
```

**Na entrevista:**
> "Eu corto a query string antes de rotear. Senão GET /tasks?x=1 não bate com /tasks e vira 404. Filtro eu não implemento agora. Só não deixo o ponto de interrogação quebrar o path."

---

## Coleção e membro

**O que é:**
Dois shapes. Coleção: `/tasks`. Membro: `/tasks/:id`. REST clássico. O Rails chama isso de collection e member em `resources :tasks`. Aqui os nomes não aparecem no código. Os dois `if` aparecem.

**Como funciona:**
Coleção responde a `GET` e `POST`. Membro responde a `GET`, `PUT`, `PATCH`, `DELETE`. Não tem `POST /tasks/:id`. Não tem `DELETE /tasks`. Se o cliente mandar, não é 404 — o path existe. É 405.

Por que dois `if` e não um `case` no path: o membro não é string fixa. É padrão. `==` resolve a coleção. Regex resolve o membro. O `else` é “path desconhecido”.

**Quando usar:**
CRUD de um recurso. Sempre que o entrevistador falar REST. A distinção collection/member é o vocabulário. O código é `==` + `match`.

**Exemplo prático:**

```ruby
if path == "/tasks"
  # coleção — GET lista, POST cria
elsif path.match(%r{\A/tasks/(\d+)\z})
  # membro — GET, PUT, PATCH, DELETE
else
  # 404
end
```

**Na entrevista:**
> "Dois paths. /tasks é a coleção. /tasks/:id é o membro. No Rails isso é resources :tasks. Aqui são dois if. DELETE na coleção não existe — o path existe, o método não."

---

## O regex do :id

**O que é:**
`:id` no Rails é um segmento. Aqui `:id` não existe como sintaxe. Existe um regex: `\A/tasks/(\d+)\z`. Âncoras nos dois lados. Grupo só de dígitos.

**Como funciona:**
`\A` é começo da string. `\z` é fim da string. `(\d+)` captura um ou mais dígitos. Sem as âncoras, `/foo/tasks/1/bar` poderia colar. Sem o `(\d+)`, `/tasks/abc` passaria como membro.

```ruby
elsif (match = path.match(%r{\A/tasks/(\d+)\z}))
  id = Integer(match[1])
```

`match[1]` é o grupo. `Integer` transforma. A chave Integer o Hash usa no 1.5. Neste capítulo o ponto é outro: se o regex não bate, você **não entra** no `elsif`. Cai no `else`. 404.

Isso pega gente na entrevista. `/tasks/abc` “parece” membro. Não é. `abc` não é `\d+`. Path desconhecido. 404. Não é 400. 400 é body ruim — capítulo 1.4. Aqui o path nem mapeou.

| Path | Por quê 404 |
|---|---|
| `/tasks/abc` | não é dígito |
| `/tasks/1a` | não é só dígito |
| `/tasks/` | não tem id |
| `/tasks/1/edit` | sobra segmento |
| `/task/1` | recurso no singular |
| `/tasks/1/` | barra no fim — `\z` não deixa |

`/tasks/01` bate: `\d+` aceita zero à esquerda. `Integer("01")` vira `1`. Detalhe. Não invente id alfanumérico neste app.

**Quando usar:**
Todo membro. Se o entrevistador pedir UUID, você troca `\d+`. Não começa por isso. Task neste projeto tem id inteiro.

**Exemplo prático:**
`/tasks/1` → grupo `"1"`, membro. `/tasks/abc` → `nil`, 404. `/tasks/1/edit` → `nil`, 404. `/tasks/01` → grupo `"01"`, membro.

**Na entrevista:**
> "Id só dígito. O regex é começo, /tasks/, um ou mais dígitos, fim. /tasks/abc não entra no membro — é 404, não 400. 400 é JSON. Aqui o path não mapeou."

---

## 404 não é 405

**O que é:**
Dois erros que o júnior junta. 404: o path não existe neste app. 405: o path existe, o method não está mapeado. 405 leva header `Allow` com a lista do que vale.

**Como funciona:**
RFC: `405 Method Not Allowed` deve dizer quais métodos o recurso aceita. Sem `Allow`, o cliente só vê “não”. Com `Allow`, o cliente vê o contrato.

| Request | Status | `Allow` |
|---|---|---|
| `PUT /tasks` | 405 | `GET, POST` |
| `DELETE /tasks` | 405 | `GET, POST` |
| `POST /tasks/1` | 405 | `GET, PUT, PATCH, DELETE` |
| `GET /foobar` | 404 | — |
| `GET /tasks/abc` | 404 | — |
| `OPTIONS /tasks` | 405 | `GET, POST` |

`OPTIONS` não está no contrato. Path `/tasks` existe. Método não. 405. Não implementamos CORS.

O ponto que o entrevistador puxa: “por que `/tasks/abc` não é 405?”. Porque 405 exige recurso identificado. `/tasks/abc` não identificou recurso nenhum. O mapa não tem esse path. 404.

No Spring, method errado no `@RequestMapping` vira 405. No Express, se você só registrou `app.get`, o `POST` cai no 404 genérico — muita gente esquece o 405. Aqui você distingue de propósito.

**Quando usar:**
Sempre que o path está no mapa e o verbo não. Coleção e membro têm listas diferentes. Copiar o `Allow` errado é mentir o contrato.

**Exemplo prático:**

```bash
curl -i -X DELETE http://127.0.0.1:4567/tasks
# 405    Allow: GET, POST

curl -i -X POST http://127.0.0.1:4567/tasks/1
# 405    Allow: GET, PUT, PATCH, DELETE

curl -i http://127.0.0.1:4567/tasks/abc
# 404
```

**Importante na entrevista:**
404 do path e 404 do id inexistente são coisas diferentes. `/tasks/abc` nem entrou no membro. `/tasks/99` entrou, o store não achou o 99 — isso é 1.5. Neste capítulo o 404 é só path. Não misture.

**Na entrevista:**
> "Path que eu não conheço: 404. Path que eu conheço e o verbo não está no case: 405 com Allow. DELETE em /tasks é 405, Allow GET e POST. GET /tasks/abc é 404 — abc não é id."

---

## O case/when do dispatch

**O que é:**
O mapa virando código. Os `when` reais do `server.rb`. Sem JSON. Sem `@tasks`. Só o ramo.

**Como funciona:**

```ruby
def dispatch(method, path, body)
  if path == "/tasks"
    case method
    when "GET" then [200, "OK", @tasks.values, {}]
    when "POST" then create_task(body)
    else
      [405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, POST" }]
    end
  elsif (match = path.match(%r{\A/tasks/(\d+)\z}))
    id = Integer(match[1])
    case method
    when "GET" then show_task(id)
    when "PUT" then replace_task(id, body)
    when "PATCH" then patch_task(id, body)
    when "DELETE" then delete_task(id)
    else
      [405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, PUT, PATCH, DELETE" }]
    end
  else
    [404, "Not Found", { "error" => "não encontrado" }, {}]
  end
end
```

Primeiro o path. Depois o method. O `else` de dentro é 405. O `else` de fora é 404. O risco real: esquecer o `== "/tasks"` e deixar a coleção ir para o 404.

O `body` passa adiante. Quem parseia JSON é o 1.4. Quem mexe no Hash é o 1.5. O `dispatch` só escolhe o método.

**Quando usar:**
Depois que a tabela do contrato está no quadro. Não escreva o `case` inventando verbo.

**Exemplo prático:**
`PUT /tasks` não tem `when "PUT"` na coleção. Cai no `else` interno. 405. `Allow` da coleção. `GET /tasks/2` tem `when "GET"` no membro. Cai em `show_task`. Se o 2 não existe, o 404 vem de lá — store, não router.

**Na entrevista:**
> "Primeiro eu fecho o path. Depois o case do method. Else de dentro é 405 com Allow. Else de fora é 404. O body eu só repasso. Parse é o próximo capítulo."

---

## O que o Rails esconde

**O que é:**
A mesma tabela, com DSL. Você precisa saber falar os dois lados: o que você escreveu na mão e o que o framework geraria.

**Como funciona:**
No Rails, `resources :tasks, only: %i[index show create update destroy]` explode no mesmo mapa: `GET/POST /tasks` e `GET/PUT/PATCH/DELETE /tasks/:id`. Quase o nosso. A diferença: o Rails junta PUT e PATCH no mesmo `update`. Aqui são dois `when` — `replace_task` e `patch_task`. O 1.5 explica a semântica. O roteamento já separa.

No Spring, seis annotations: `@GetMapping`, `@PostMapping`, `@PutMapping`, `@PatchMapping`, `@DeleteMapping`. O dispatcher do Spring faz o `if` que você escreveu.

No Express: `app.get("/tasks", ...)`, `app.post`, `app.put("/tasks/:id", ...)`. `:id` no Express é string. `req.params.id` vem `"1"`. Você converte. Aqui o regex já exige dígito — `"abc"` nem vira param.

Não puxe Sinatra no meio deste arquivo para “ficar mais bonito”. Sinatra é gem de web. Quebra o recorte.

**Quando usar:**
Vaga Rails. Você mostra o projeto 1 e fala: “eu sei o que o `resources` gera, porque eu já escrevi na mão”. O pet hotel usa o `routes.rb` de verdade — outro projeto, outro domínio.

**Exemplo prático:**
Pergunta clássica: “como você faria isso em Rails?”. Resposta curta: `resources :tasks`. Resposta completa: “e eu distinguiria PUT de PATCH no controller, porque o `resources` sozinho joga os dois no `update`”.

**Na entrevista:**
> "No Rails eu escreveria resources :tasks. No Spring, um GetMapping por verbo. Aqui não tem DSL. O dispatch é o routes.rb. PUT e PATCH eu já separo no case — o Rails costuma juntar."

---

## Recapitulando

- Não tem router. Você é o router: `dispatch`.
- Rota é method + path. Path sozinho não decide o ramo.
- Query string some no `split("?", 2)` antes do mapa.
- `/tasks` é coleção. `/tasks/:id` é membro.
- `:id` é `\A/tasks/(\d+)\z`. `/tasks/abc` é 404.
- Path desconhecido: 404. Método fora do `case`: 405 + `Allow`.
- `Allow` da coleção: `GET, POST`. Do membro: `GET, PUT, PATCH, DELETE`.
- Rails `resources :tasks`, Spring `@GetMapping`, Express `app.get` — mesmo mapa, outra pele.
- JSON e Hash não entram aqui. 1.4 e 1.5.

---

## Exercícios práticos

### Exercício 1: Por que `/tasks/abc` é 404?

**Enunciado:** O entrevistador manda `GET /tasks/abc` e pergunta se é 400 (“id inválido”) ou 404. O que você responde, e o que o regex tem a ver com isso?

<details>
<summary>Solução</summary>

404. O membro só existe se o path bate `\A/tasks/(\d+)\z`. `abc` não é `\d+`. O `elsif` não entra. Cai no `else` do path. 404.

400 é body: JSON quebrado, title vazio. Capítulo 1.4. Aqui o request nem chegou num ramo de recurso.

Não é 405: 405 é path conhecido, verbo errado. `/tasks/abc` não é path conhecido.

**Pontos-chave:**
- Regex não bate → path desconhecido
- 400 não é rota
- 405 exige recurso mapeado
</details>

### Exercício 2: O `Allow` certo

**Enunciado:** Chegam dois curls: `DELETE /tasks` e `POST /tasks/1`. Status e header `Allow` de cada um. Por que as listas são diferentes?

<details>
<summary>Solução</summary>

`DELETE /tasks` → 405, `Allow: GET, POST`. Coleção só lista e cria.

`POST /tasks/1` → 405, `Allow: GET, PUT, PATCH, DELETE`. Membro não cria. Create é `POST /tasks`.

As listas saem do `else` de cada `case`. Copiar o `Allow` da coleção no membro é mentir o contrato.

```bash
curl -i -X DELETE http://127.0.0.1:4567/tasks
curl -i -X POST http://127.0.0.1:4567/tasks/1
```

**Pontos-chave:**
- 405 sem `Allow` é resposta manca
- Coleção e membro têm verbos diferentes
- O header copia o `when` que existe
</details>

### Exercício 3: A query não é rota

**Enunciado:** Um colega compara `raw_path` com `"/tasks"` e o `GET /tasks?completed=false` volta 404. O que quebrou? Como você corrige sem implementar filtro?

<details>
<summary>Solução</summary>

A request line traz `/tasks?completed=false`. `== "/tasks"` falha. O path “humano” é a coleção. O path “cru” não.

Correção: cortar **antes** do `dispatch`.

```ruby
method, raw_path, _ = request_line.split(" ")
path = raw_path.to_s.split("?", 2).first
dispatch(method, path, body)
```

Agora o ramo é `GET /tasks`. A query some. Filtro por `completed` não entra neste recorte. O bug era o `?` no `==`, não a falta de busca.

**Pontos-chave:**
- Query não faz parte da chave da rota
- Cortar não é filtrar
- 404 aqui era falso negativo
</details>

---

*Parte do [Ruby Projects Handbook](/)*
