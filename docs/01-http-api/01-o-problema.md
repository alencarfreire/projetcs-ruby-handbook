# 1.1 O problema e o recorte

> **TL;DR**
> Você vai construir uma API de tasks em Ruby puro. Sem Rails, sem gem de web, sem banco. Hash na memória — igual um `List` no handler Java, diferente do PHP que zera a cada request, diferente da tabela no Rails. O processo morre, os dados somem. Recurso: Task — `id`, `title`, `completed`. Começa em `GET /tasks` → `[]`. O CRUD entra nos capítulos seguintes.

## Conteúdo

- [Este livro não é teoria](#este-livro-não-é-teoria)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [O recurso Task](#o-recurso-task)
- [O contrato HTTP](#o-contrato-http)
- [Por que some quando o processo morre](#por-que-some-quando-o-processo-morre)
- [O que fica de fora](#o-que-fica-de-fora)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [O que o esqueleto já faz](#o-que-o-esqueleto-já-faz)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Este livro não é teoria

**O que é:**
O [rails-handbook](https://github.com/alencarfreire/ruby-handbook) explica Ruby e Rails no quadro. Este livro pega um problema e você monta o app. Walkthrough numa pasta. Código que sobe na outra.

**Como funciona:**
Você lê o capítulo. Sobe o servidor. Bate o curl. O texto aponta para `projects/01-http-api`, não cola a pasta inteira no Markdown.

**Quando usar:**
Quando a pergunta da entrevista é “monta uma API” — não “o que é REST”.

**Na entrevista:**
> "Eu sei o verbete. Aqui eu mostro o request: chegou um GET, eu varri o Hash, devolvi JSON."

---

## O problema

**O que é:**
Uma lista de tasks. Criar, listar, buscar, editar, apagar. JSON na porta. Cliente qualquer: curl, Insomnia, o app do celular. O mesmo exercício que em Java vira `HttpServer` + `HttpHandler`, em Node vira `http.createServer`, em PHP vira um script atrás do built-in server. Aqui vira um processo Ruby escutando TCP.

**Como funciona:**
João abre o cliente e manda `POST /tasks` com `{"title":"Comprar ração do Thor"}`. Você lê o body, gera um `id`, guarda, devolve 201. Maria pede `GET /tasks`. Você devolve o array.

Não tem tela neste projeto. Não tem login. Não tem hotel. Hotel é o projeto 2.

Por que JSON e não HTML? Porque o entrevistador quer ver o protocolo. Rails esconde isso no `render json:`. Spring esconde no `@RestController`. Você não tem annotation. Você monta o `HTTP/1.1 201 Created` na mão.

**Quando usar:**
Take-home curto. Live coding de 45 minutos. Qualquer entrevista que pede “HTTP sem framework”.

**Exemplo prático:**
O domínio cabe num Hash:

```ruby
task = {
  id: 1,
  title: "Comprar ração do Thor",
  completed: false
}
```

Três campos. Sem `user_id`. Sem `due_date`. Sem tag. Recorte é isso: cabe no quadro.

**Na entrevista:**
> "O problema é CRUD de task. Eu recorto em três campos e deixo o resto de fora. Se o entrevistador quiser dono da task, a gente acrescenta. Não começo pelo banco."

---

## O recorte

**O que é:**
A lista do que entra e a lista do que não entra. Sem recorte você começa pelo Rails, gera scaffold, e não sabe o que o servidor faz. O recorte é a resposta de 45 minutos: o que cabe no quadro.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Ruby 3.3+ | Rails, Sinatra, Rack |
| `socket` + `json` (stdlib) | gem de web, Puma, WEBrick-como-gem |
| Hash em memória | SQL, SQLite, Redis |
| Task | Owner, Pet, Stay |
| JSON | HTML, view, template |
| curl | coverage theatre |

WEBrick saiu da stdlib no Ruby 3. A spec antiga pedia WEBrick. Instalar a gem resolve o `require` e quebra o recorte. No Java, `com.sun.net.httpserver.HttpServer` ainda vem no JDK — por isso o apipura usa ele sem Maven de web. No Ruby 3+ o equivalente “já vem” é `TCPServer`. Mesma ideia: HTTP na mão, zero gem.

**Quando usar:**
Sempre que o exercício diz “puro”. Puro não é “sem teste”. Puro é sem framework escondendo o protocolo.

Se a vaga é Rails, este projeto ainda vale: você mostra que sabe o que o `routes.rb` esconde. Depois o pet hotel usa o framework. Ordem importa.

**Exemplo prático:**
O store do app é isto:

```ruby
class TaskServer
  def initialize(port = 4567)
    @port = port
    @tasks = {}
    @next_id = 1
  end
end
```

`@tasks` é o banco. `@next_id` é o autoincrement. Não tem `INSERT`. Não tem `id SERIAL`.

No Java seria `private List<Task> tasks` + `private int nextId` no handler. No PHP de um script único, o array some no fim do request — cada curl seria uma lista nova, a menos que você grave em arquivo. Ruby aqui se parece mais com o Java: o processo fica de pé, o Hash vive na instância.

**Na entrevista:**
> "Recorte: HTTP + JSON + Hash. Sem gem de web. WEBrick não vem mais na stdlib — no Java o HttpServer ainda vem no JDK, no Ruby 3 eu abro um TCPServer e leio a request line. O entrevistador vê que eu sei o protocolo, não só o `rails g`."

---

## O recurso Task

**O que é:**
O único recurso deste projeto. `id` inteiro, `title` string, `completed` boolean.

**Como funciona:**

```ruby
# criação — o servidor preenche id e completed
{ "title" => "Levar Luna no vet" }

# o que você guarda
{ id: 1, title: "Levar Luna no vet", completed: false }

# o que você devolve
{ "id" => 1, "title" => "Levar Luna no vet", "completed" => false }
```

Chave do Hash interno: Integer (`@tasks[1]`). JSON na porta: número, string, boolean. Sem Symbol no JSON — JSON não tem Symbol. Java tem POJO + getter. PHP tem array associativo. Rails tem Active Record. Aqui o “model” é o Hash. Sem classe `Task` obrigatória. Se o entrevistador puxar OOP, você extrai. Não começa por ela.

**Quando usar:**
Um recurso só. Cinco verbos em cima dele. Entrevista de API começa aqui, não em seis models.

**Exemplo prático:**
Títulos do dia a dia do handbook. Não mistura com o hotel:

```ruby
"Comprar ração do Thor"
"Levar Luna no vet"
"Vacina do Bidu"
```

Thor, Luna e Bidu aparecem de novo no projeto 2, como pets. Aqui são só texto de task.

**Na entrevista:**
> "Task tem id, title, completed. Id eu gero. Title vem do JSON. Completed começa false. PUT substitui os dois campos. PATCH mexe no que veio."

---

## O contrato HTTP

**O que é:**
A tabela que você e o cliente assinam. Método + path + status. Sem essa tabela, cada um inventa.

**Como funciona:**

| Método | Path | Status de sucesso | O que faz |
|---|---|---|---|
| `GET` | `/tasks` | 200 | lista |
| `GET` | `/tasks/:id` | 200 | um |
| `POST` | `/tasks` | 201 + `Location` | cria |
| `PUT` | `/tasks/:id` | 200 | substitui |
| `PATCH` | `/tasks/:id` | 200 | parcial |
| `DELETE` | `/tasks/:id` | 204 | apaga |

Erros que caem em entrevista:

| Situação | Status |
|---|---|
| id inexistente | 404 |
| JSON inválido | 400 |
| método não mapeado | 405 |

`Content-Type: application/json` em toda resposta JSON. Body vazio no 204.

PUT vs PATCH é o ponto que o entrevistador puxa. PUT manda o recurso inteiro: `title` e `completed`. PATCH manda só o que muda: `{ "completed": true }`. No Rails, `PUT` e `PATCH` caem no mesmo `update` quase sempre — o framework não te obriga a distinguir. No Spring, `@PutMapping` vs `@PatchMapping`. Aqui não tem annotation: você mesmo decide. Se o PUT veio sem `title`, 400. Se o PATCH veio só com `completed`, 200 e o title fica.

**Quando usar:**
Antes de escrever o `if`. A tabela vai no README. O walkthrough 1.3 monta o roteamento. O 1.6 explica cada status.

**Exemplo prático:**
O primeiro contrato que tem que passar:

```bash
curl -s http://127.0.0.1:4567/tasks
# []
```

Lista vazia. 200. JSON. `[]` é payload válido — no Java seria `new ArrayList<>()` serializado. Não é “API incompleta”. É o store vazio falando a verdade. O resto dos verbos entra nos capítulos 1.3–1.5.

**Na entrevista:**
> "GET lista, GET id busca, POST cria com 201 e Location, PUT substitui, PATCH parcial, DELETE 204. Não achei o id: 404. JSON quebrado: 400. POST em path que só tem GET: 405. PUT e PATCH eu distingo — o Rails costuma juntar os dois no update."

---

## Por que some quando o processo morre

**O que é:**
`@tasks` vive no processo. `Ctrl+C`, os dados acabam. Não é bug. É o recorte.

**Como funciona:**
Ruby aloca o Hash no heap do processo. Não tem arquivo. Não tem `INSERT`. Mata o processo, o SO libera a memória. Sobe de novo: `@tasks = {}`, `@next_id = 1`.

```ruby
# processo 1
@tasks[1] = { id: 1, title: "Comprar ração do Thor", completed: false }

# você mata o servidor
# processo 2 — outro Hash, outro next_id
@tasks
# {}
```

Três linguagens, três tempos de vida — esse é o ponto:

| Onde | Onde vive a lista | Quando some |
|---|---|---|
| PHP (script + built-in server) | array no request | no fim de cada curl |
| Java (`HttpServer` + handler) | `List` no objeto | quando o processo JVM morre |
| Ruby neste projeto | Hash na instância | quando o processo Ruby morre |
| Rails / Laravel | tabela no SQLite/Postgres | não some no restart |

PHP engana quem vem de Laravel: cada request é um processo (ou um worker que reseta o script). Dois POSTs seguidos não compartilham o array, a menos que você grave em arquivo ou Redis. Java e Ruby-de-pé se parecem: a instância do handler/servidor segura a lista entre um curl e outro.

Por isso o teste “POST e em seguida GET” só funciona se você não matou o processo no meio. Dois terminais, mesmo servidor.

**Quando usar:**
Live coding. Take-home de um arquivo. Qualquer hora que persistência atrapalhe o ponto: o ponto é HTTP, não o banco.

**Quando não usar:**
App de verdade. Aí entra SQLite no projeto 2. Aí a estadia do Thor sobrevive ao reboot.

**Exemplo prático:**
Dois curls no mesmo processo veem o mesmo Hash. Dois processos não compartilham nada. Sem Redis. Sem arquivo. Sem “depois eu coloco o banco”.

**Importante na entrevista:**
Dizer isso em voz alta. Quem esconde o “some no restart” parece que não pensou. Quem fala parece que recortou. Se o entrevistador veio de PHP, deixe explícito: “aqui o processo fica de pé, não é request-in, request-out”.

**Na entrevista:**
> "Tá em memória, no processo. Igual o List do handler Java. Diferente do PHP que zera a cada request. Reiniciou, zerou. Para o exercício serve. Se precisar persistir, eu coloco SQLite — é o projeto 2, não este."

---

## O que fica de fora

**O que é:**
A lista do que você recusa no quadro, de propósito. Não é esquecimento.

**Como funciona:**

- **Auth.** Sem token, sem session, sem `has_secure_password`. Isso é projeto 2.
- **Banco.** Sem SQL. Sem `Gemfile`. Sem migration.
- **Validação rica.** Título vazio, título gigante, `completed` que não é boolean — entra quando o JSON e o store existirem. Agora o recorte é o contrato.
- **CORS, versionamento, paginação.** Fora. Um recurso, uma versão implícita, lista inteira.
- **Hotel.** Owner, Pet, Stay, diária em centavos — outro domínio, outro projeto.
- **Teste de coverage.** curl no README. minitest raso, se vier. Sem badge.

**Quando usar:**
Toda vez que o entrevistador puxar “e o login?”. Você aponta o recorte. Não improvisa Devise no meio do TCPServer.

**Na entrevista:**
> "Auth não entra neste. Sem gem de web, sem SQL. Se a vaga pede Rails, o próximo exercício é o pet hotel. Este aqui é o protocolo."

---

## Como o walkthrough anda

**O que é:**
Sete capítulos. Um arquivo cada. Este é o 1.1 — problema e recorte. Os outros montam a peça.

**Como funciona:**

| Cap | O que você monta |
|---|---|
| 1.1 | recorte, contrato, esqueleto que lista `[]` |
| 1.2 | TCPServer, request line, headers, response |
| 1.3 | method + path na mão, `:id`, 405 |
| 1.4 | JSON in, JSON out, 400 |
| 1.5 | `@tasks` + `@next_id`, POST/PUT/PATCH/DELETE |
| 1.6 | 200, 201, 204, 400, 404, 405 — o que o entrevistador puxa |
| 1.7 | README com curls de verdade |

Código em `projects/01-http-api`. Walkthrough em `docs/01-http-api`. Não mistura.

**Quando usar:**
Estudar na ordem. Pular o 1.2 e ir pro CRUD é voltar a “framework na cabeça”.

**Na entrevista:**
> "Eu comecei pelo servidor e pelo contrato, não pelo Active Record. Quando o Rails entrar, eu já sei o que ele esconde."

---

## O que o esqueleto já faz

**O que é:**
O mínimo que honra o recorte: processo sobe, `GET /tasks` devolve `[]`.

**Como funciona:**
Em `projects/01-http-api`:

```bash
ruby server.rb
# API em http://127.0.0.1:4567
```

Em outro terminal:

```bash
curl -i http://127.0.0.1:4567/tasks
```

Você quer ver:

```
HTTP/1.1 200 OK
Content-Type: application/json
...

[]
```

Store vazio. Status 200. Content-Type certo. Path que não é `/tasks` → 404 em JSON.

**Quando usar:**
Agora. Antes do POST. Se o GET vazio não passa, o CRUD não importa.

**Exemplo prático:**
O README do projeto tem esse curl. Se o comando do README falha, o capítulo falhou. Não é “quase”. É `[]`.

**Na entrevista:**
> "O servidor sobe. GET /tasks devolve array vazio. Daqui eu acrescento rota, JSON de entrada e o Hash. Não começo pelo POST."

---

## Recapitulando

- Este livro é projeto. Teoria fica no rails-handbook.
- Problema: CRUD de Task em HTTP + JSON.
- Recorte: stdlib, Hash, um recurso, sem auth, sem banco, sem hotel.
- Task: `id`, `title`, `completed`.
- Contrato: GET/POST/PUT/PATCH/DELETE + 400/404/405. O 1.1 começa pelo GET vazio; o resto está no app e nos capítulos seguintes.
- Memória some no restart. Dizer isso.
- Walkthrough em `docs/`. Código em `projects/`.

---

## Exercícios práticos

### Exercício 1: O que você recorta?

**Enunciado:** O entrevistador pede “uma API de tasks com usuário, prazo e tag, em Rails, com Postgres”. Você tem 45 minutos. O que entra neste projeto 1 e o que você devolve para o quadro seguinte?

<details>
<summary>Solução</summary>

Entra: Task com `id`, `title`, `completed`. HTTP na mão. Hash. curl.

Fica para depois: User, prazo, tag, Rails, Postgres.

No quadro você fala o recorte em 20 segundos e começa o servidor. Não discute Devise.

**Pontos-chave:**
- Recorte é resposta, não desculpa
- Um recurso, três campos
- Banco e auth são o projeto 2
</details>

### Exercício 2: Por que não WEBrick?

**Enunciado:** A spec antiga dizia “WEBrick + JSON”. No Ruby 3.3+ o `require "webrick"` quebra. O que você fala e o que você faz?

<details>
<summary>Solução</summary>

WEBrick saiu da stdlib. Instalar a gem resolve o require e quebra o recorte (“sem gem de web”).

No Java o `HttpServer` do JDK ainda existe — o apipura usa isso. No Node, `http` é core. No Ruby 3+ o “já vem” para escutar porta é `socket`.

Você abre um `TCPServer`, lê a request line, devolve HTTP/1.1. `json` continua stdlib.

```ruby
require "socket"
require "json"

server = TCPServer.new("127.0.0.1", 4567)
```

**Pontos-chave:**
- stdlib mudou; o recorte não
- gem de web é exatamente o que este projeto recusa
- o entrevistador quer o protocolo, não o nome WEBrick
</details>

### Exercício 3: O GET vazio vale o quê?

**Enunciado:** O primeiro contrato é `GET /tasks` → `[]`. Um colega diz que isso não é API. O que você responde?

<details>
<summary>Solução</summary>

É o primeiro contrato. Servidor escuta. Path bate. Status 200. Body JSON. Content-Type certo. No Java seria `[]` de um `ArrayList` vazio. No JS, `JSON.stringify([])`. Não é “falta dado”. É o store falando a verdade.

POST, PUT, PATCH, DELETE dependem disso: parse de rota, header, body. Se o GET vazio falha, o resto é teatro.

```bash
curl -s http://127.0.0.1:4567/tasks
# []
```

**Pontos-chave:**
- API começa no GET que existe
- `[]` é payload válido
- CRUD completo está nos capítulos seguintes; o primeiro contrato é o GET vazio
</details>

---

*Parte do [Ruby Projects Handbook](/)*
