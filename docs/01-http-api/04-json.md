# 1.4 JSON request/response

> **TL;DR**
> Body chega string. `JSON.parse` vira Hash. Hash sai com `JSON.generate`. `{quebrado` é 400, não 500. Lista é Array; um recurso é Hash. Chave string — JSON não tem Symbol. `Content-Type: application/json`. `Content-Length` com `bytesize` (UTF-8). 204 não leva JSON. Title e completed você valida depois do parse; o store é o 1.5.

## Conteúdo

- [O JSON na porta](#o-json-na-porta)
- [Parse do body](#parse-do-body)
- [Generate da resposta](#generate-da-resposta)
- [Por que JSON inválido é 400](#por-que-json-inválido-é-400)
- [Hash é objeto, Array é lista](#hash-é-objeto-array-é-lista)
- [JSON não tem Symbol](#json-não-tem-symbol)
- [UTF-8 e bytesize](#utf-8-e-bytesize)
- [204 não leva JSON](#204-não-leva-json)
- [Depois do parse](#depois-do-parse)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O JSON na porta

**O que é:**
O contrato de bytes entre o cliente e o app. Não é o Hash do Ruby. Não é o POJO do Java. É texto UTF-8 no body, com `Content-Type: application/json`.

**Como funciona:**
João manda `POST /tasks` com `{"title":"Comprar ração do Thor"}`. Você lê a string. `JSON.parse` devolve Hash. Você devolve outra string: `JSON.generate`. O fio só vê texto.

No PHP isso é `json_decode` / `json_encode`. No JS, `JSON.parse` / `JSON.stringify`. No Java, Jackson (`ObjectMapper.readValue` / `writeValueAsString`) ou Gson (`fromJson` / `toJson`). Mesma porta, quatro bibliotecas.

O apipura, no Java cru, às vezes concatenava string: `"{\"title\":\"" + title + "\"}"`. Title com aspas quebra. Acento some. Você não faz isso. `JSON.generate` escapa. Jackson escapa. `json_encode` escapa.

**Quando usar:**
POST, PUT, PATCH na entrada. Toda response com payload na saída. 204 fica de fora.

**Na entrevista:**
> "JSON na porta é string. Eu parseio o body, trabalho Hash, gero de novo. Não monto JSON na mão."

---

## Parse do body

**O que é:**
Transformar o body em Hash. Se não der, 400. O método no servidor é `parse_object`.

**Como funciona:**

```ruby
def parse_object(body)
  raise JSON::ParserError if body.nil? || body.strip.empty?

  data = JSON.parse(body)
  raise JSON::ParserError unless data.is_a?(Hash)

  data
end
```

Três recusas, um status:

| Body | O que acontece |
|---|---|
| `{"title":"Comprar ração do Thor"}` | Hash. Segue. |
| `""` ou só espaço | `JSON::ParserError` → 400 |
| `{quebrado` | `JSON.parse` estoura → 400 |
| `["uma lista"]` | parseia, mas não é Hash → 400 |

`require "json"` é stdlib (biblioteca padrão do Ruby). Sem gem. Igual `json_decode($body, true)` no PHP — o `true` pede array associativo. Aqui o default do `JSON.parse` já é Hash com chave string.

Body vazio não é “sem campo”. É JSON inválido para este contrato. POST sem body não cria task.

**Quando usar:**
POST, PUT, PATCH. GET e DELETE não parseiam objeto de entrada.

**Exemplo prático:**

```bash
curl -s -i http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Levar Luna no vet"}'
```

Isso parseia. O `create_task` pega `data["title"]`. O store entra no 1.5.

**Na entrevista:**
> "Eu não chamo JSON.parse no dispatch. parse_object: vazio é erro, não-Hash é erro, quebrado é erro. Um rescue, 400."

---

## Generate da resposta

**O que é:**
O caminho inverso. Hash ou Array vira string. Essa string é o body. E leva `Content-Type: application/json`.

**Como funciona:**

```ruby
body = JSON.generate(payload)
socket.write(
  "HTTP/1.1 #{status} #{reason}\r\n" \
  "Content-Type: application/json\r\n" \
  "Content-Length: #{body.bytesize}\r\n" \
  # ...
  "#{body}"
)
```

Cliente lê JSON. Não lê Ruby. `JSON.generate([])` é `[]` — lista vazia é payload válido, o 1.1 já mostrou.

Erro também é JSON: `{"error":"JSON inválido"}`. 404 em JSON. 405 em JSON. Não misture `text/plain` no erro e JSON no sucesso. curl `-s` esconde o header; o entrevistador olha o `-i`.

Este recorte não recusa POST sem `Content-Type` na entrada — você parseia o body mesmo assim. 415 fica para API de verdade. Aqui o ponto é parse + generate.

**Quando usar:**
200, 201, 400, 404, 405. Sempre que tem payload.

**Exemplo prático:**
GET `/tasks` devolve Array. GET `/tasks/1` devolve Hash. POST devolve o Hash criado. Quatro formas, um `JSON.generate`.

**Na entrevista:**
> "A response eu gero com JSON.generate. Content-Type application/json — erro também. Content-Length é bytesize. 204 eu pulo esse bloco."

---

## Por que JSON inválido é 400

**O que é:**
O ponto que o entrevistador puxa. Cliente mandou lixo. Você não explodiu. 400 é “o request está errado”. 500 é “eu quebrei”.

**Como funciona:**
`handle` envolve o dispatch:

```ruby
status, reason, payload, extra = dispatch(method, path, body)
respond(socket, status, reason, payload, extra)
rescue JSON::ParserError
  respond(socket, 400, "Bad Request", { "error" => "JSON inválido" })
```

`{quebrado` não é bug do servidor. É body que `JSON.parse` recusa. Sem o `rescue`, a exception sobe: 500, conexão morta, ou o processo cai. Quem devolve 500 em JSON quebrado não separou erro de cliente de erro de servidor.

PHP: `json_decode` devolve `null` e você olha `json_last_error()`. Fácil esquecer e seguir com `null` — o 500 aparece depois, no `title` inexistente. JS: `JSON.parse` joga `SyntaxError`. Jackson: `JsonParseException`. Mesma regra: captura, 400.

Body vazio entra no mesmo balde. `raise JSON::ParserError if body.strip.empty?`. Neste recorte você não distingue “não veio nada” de “veio lixo”. Os dois são 400 com `JSON inválido`.

**Quando usar:**
Sempre que o body precisa ser objeto. 422 não entra aqui — 422 seria validação de negócio. 400 é “isso nem é JSON objeto”.

**Importante na entrevista:**
400 = cliente. 500 = você. `{quebrado` é 400. `NoMethodError` no meio do `create_task` é 500. Se você misturar os dois, o cliente não sabe se pode reenviar.

**Na entrevista:**
> "JSON quebrado é 400. Eu rescue JSON::ParserError. Se eu deixar estourar, vira 500 e parece que o servidor quebrou. Não quebrou. O body que chegou não é JSON."

---

## Hash é objeto, Array é lista

**O que é:**
JSON tem dois containers. Objeto `{}` vira Hash. Lista `[]` vira Array. POST de task é objeto. GET `/tasks` é lista.

**Como funciona:**

```ruby
JSON.parse('{"title":"Comprar ração do Thor"}')  # Hash
JSON.parse('[{"title":"Comprar ração do Thor"}]') # Array
JSON.parse("[]")                                  # []
```

`parse_object` exige Hash. Mandou array no POST? 400. Não é “quase um objeto”. Jackson num `Task.class` recusa array do mesmo jeito. Gson também. PHP `json_decode` de array vira `[0 => ...]`; se você espera `"title"`, silêncio — por isso o `is_a?(Hash)` existe.

Na saída, `@tasks.values` é Array de Hash. `JSON.generate` produz `[{...}]`. Store vazio: `[]`.

**Quando usar:**
Entrada de um recurso: objeto. Coleção: array. Não inverta.

**Exemplo prático:**

```bash
curl -s -i http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '[{"title":"Comprar ração do Thor"}]'
# 400 — array no POST
```

**Na entrevista:**
> "POST eu exijo Hash. Array no body é 400. GET da coleção eu devolvo Array. Um recurso, Hash."

---

## JSON não tem Symbol

**O que é:**
Ruby ama `:title`. JSON não conhece Symbol. Na porta a chave é string.

**Como funciona:**

```ruby
JSON.parse('{"title":"Comprar ração do Thor"}')
# => {"title"=>"Comprar ração do Thor"}

data["title"]   # certo
data[:title]    # nil — a chave não é Symbol
```

`JSON.generate({ title: "Vacina do Bidu" })` aceita Symbol no Ruby e vira string na porta. Na parse, não volta Symbol. Quem mistura `data[:title]` leva `nil`, recusa title — e o curl estava certo.

PHP não tem esse buraco: array associativo já é string. JS, objeto com chave string. Java, campo do POJO. A pegadinha é de quem veio de Rails: `params[:title]` converte. Aqui não tem `params`. Aqui tem `JSON.parse`.

O store deste app já guarda `"id"`, `"title"`, `"completed"` — string, igual a porta. Detalhe do Hash em memória é 1.5.

**Quando usar:**
Sempre `data["title"]` depois do parse. `symbolize_names: true` existe. Este projeto não usa.

**Na entrevista:**
> "JSON não tem Symbol. Parse devolve string. Eu acesso data['title']. Se eu usar :title, dá nil e eu acuso o cliente à toa."

---

## UTF-8 e bytesize

**O que é:**
`Content-Length` conta bytes, não caracteres. Ruby `String#length` conta caracteres. `String#bytesize` conta bytes. HTTP quer o segundo.

**Como funciona:**
“ração” tem ã. Em UTF-8, ã são dois bytes:

```ruby
s = "Comprar ração do Thor"
s.length    # 22 — caracteres
s.bytesize  # 23 — o que o header quer
```

Se você mandar `Content-Length: #{body.length}` com ã no JSON, o cliente corta um byte. Body truncado. JSON quebra do outro lado — e o servidor “está certo”.

PHP `strlen` em UTF-8 também é bytes (se não for multibyte consciente). JS `Buffer.byteLength(s, "utf8")`, não `s.length`. Jackson conta bytes do charset. Mesma armadilha, quatro linguagens.

O 400 em português também: `"JSON inválido"` tem acento. `bytesize` nisso também.

**Quando usar:**
Toda response com body. A string do `JSON.generate` e o header têm que contar a mesma coisa.

**Importante na entrevista:**
Quem fala “length do Ruby” sem falar UTF-8 perde o ponto. Content-Length é o RFC: octetos.

**Na entrevista:**
> "Content-Length é bytesize. length conta caractere. ração tem ã — dois bytes. Se eu usar length, o cliente lê JSON cortado."

---

## 204 não leva JSON

**O que é:**
DELETE bem-sucedido: 204, body vazio. Sem `JSON.generate`. Sem `Content-Type: application/json`. O detalhe de status é o 1.6; aqui só o encaixe.

**Como funciona:**
`payload.nil?` → `Content-Length: 0`, sem body. `delete_task` devolve `[204, "No Content", nil, {}]`. `nil` é o sinal. Não é `{}` — `JSON.generate({})` seria `{}`, body onde não devia.

Não achou o id: 404 com JSON. Aí sim tem body.

**Na entrevista:**
> "204 eu não gero JSON. Payload nil, Content-Length 0. O 1.6 fecha a tabela de status."

---

## Depois do parse

**O que é:**
JSON válido ainda pode ser recurso inválido. Title ausente. Completed que não é boolean. Isso é 400 também, mas outra mensagem. Não é `JSON::ParserError`.

**Como funciona:**
`parse_object` passou. Aí `require_title` e `optional_completed`. `{"title":""}` é JSON objeto. Parse ok. Title não. `{"completed":"sim"}` é JSON. Boolean não.

Você não mistura os dois no mesmo `rescue`. Parse quebra → `"JSON inválido"`. Campo quebra → `"title é obrigatório"` / `"completed deve ser boolean"`. O entrevistador pergunta a diferença. Você aponta o momento: antes ou depois do Hash existir.

O store — `@tasks`, `@next_id`, POST que grava — é o 1.5. Este capítulo para no fio: string → Hash → string.

**Na entrevista:**
> "Primeiro eu pergunto se é JSON objeto. Depois se title e completed prestam. Store é o próximo capítulo."

---

## Recapitulando

- Body é string. `JSON.parse` → Hash. `JSON.generate` → string.
- Vazio, quebrado ou array no POST: 400 via `JSON::ParserError`.
- `{quebrado` é 400, não 500. 500 é bug seu.
- Coleção na saída: Array. Recurso: Hash.
- JSON não tem Symbol. Use `data["title"]`.
- `Content-Length` com `bytesize`. UTF-8: ã são dois bytes.
- Payload: `Content-Type: application/json`.
- 204: sem JSON. Detalhe no 1.6.
- Title/completed: depois do parse. Store: 1.5.

---

## Exercícios práticos

### Exercício 1: `{quebrado` vira o quê?

**Enunciado:** O cliente manda `POST /tasks` com body `{quebrado`. Sem `rescue`. O que o entrevistador vê? O que você muda? Por que não é 500?

<details>
<summary>Solução</summary>

Sem `rescue`, `JSON.parse` joga `JSON::ParserError`. O `handle` não responde. Vira 500, conexão morta, ou o processo cai. Parece que o app quebrou.

Com o `rescue` no `handle`, você responde 400 e `{"error":"JSON inválido"}`. Cliente errou o JSON. Servidor está íntegro.

Body vazio cai no mesmo raise de `parse_object`. Array no POST também: parseia, `is_a?(Hash)` falha, mesmo status.

```ruby
rescue JSON::ParserError
  respond(socket, 400, "Bad Request", { "error" => "JSON inválido" })
```

PHP: `json_decode` + `json_last_error()`. JS: `catch` do `JSON.parse`. Jackson: `JsonParseException` → 400. Concatenar string no apipura nem chega aqui: você gera JSON inválido na saída e o cliente quebra.

**Pontos-chave:**
- 400 é o body. 500 é você
- Um rescue cobre vazio, lixo e não-Hash
- Não deixe a exception virar 500
</details>

### Exercício 2: `length` ou `bytesize`?

**Enunciado:** A task é `"Comprar ração do Thor"`. Você gera o JSON e seta `Content-Length` com `body.length`. O que quebra? O que você fala na entrevista?

<details>
<summary>Solução</summary>

`ã` em UTF-8 são dois bytes. `length` conta 1 caractere. `Content-Length` fica curto. O cliente lê um byte a menos. JSON inválido do lado dele — e o servidor “está certo”.

```ruby
s = "Comprar ração do Thor"
s.length    # caracteres
s.bytesize  # o que o HTTP quer
```

A response usa a string do `JSON.generate`. O header conta essa string em bytes, inclusive aspas e acentos.

PHP `strlen`, JS `Buffer.byteLength`, Jackson no charset — mesma conta. Não é pegadinha de Ruby. É RFC.

**Pontos-chave:**
- Content-Length = octetos
- `bytesize`, não `length`
- Title com acento é o teste, não o caso feliz em ASCII
</details>

### Exercício 3: `:title` ou `"title"`?

**Enunciado:** O POST veio `{"title":"Vacina do Bidu"}`. Você fez `data[:title]`. O parse passou. O create recusou title. Por quê? Como você explica Hash vs Array e Symbol vs string?

<details>
<summary>Solução</summary>

`JSON.parse` devolve `{"title"=>"Vacina do Bidu"}`. `:title` não está lá. `nil`. `require_title` acha que faltou campo. 400 mentiroso.

JSON não tem Symbol. PHP array, JS object, Java POJO — chave string ou campo. Rails `params[:title]` mascara isso. Aqui não tem `params`.

POST com `[{"title":"..."}]` é o outro lado: parseia Array, `parse_object` recusa. Lista é GET `/tasks`. Um recurso é objeto.

```ruby
data = JSON.parse('{"title":"Vacina do Bidu"}')
data["title"]  # "Vacina do Bidu"
data[:title]   # nil
```

**Pontos-chave:**
- Parse → chave string
- Array não é objeto de task
- 400 de title depois do parse não é 400 de JSON inválido
</details>

---

*Parte do [Ruby Projects Handbook](/)*
