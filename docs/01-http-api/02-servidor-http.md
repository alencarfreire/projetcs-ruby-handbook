# 1.2 Servidor HTTP com stdlib

> **TL;DR**
> HTTP é texto em cima de TCP. Você abre um `TCPServer`, lê a request line, lê headers até a linha em branco, lê o body pelo `Content-Length`, escreve `HTTP/1.1` de volta. Sem gem. WEBrick saiu da stdlib no Ruby 3 — no Java o `HttpServer` ainda vem no JDK, no Node o `http` ainda é core, no PHP o built-in já parseia. Aqui o “já vem” é `socket`. Rotas, JSON e store ficam para 1.3–1.5.

## Conteúdo

- [HTTP na mão](#http-na-mão)
- [Por que não gem](#por-que-não-gem)
- [TCPServer e o loop](#tcpserver-e-o-loop)
- [Request line](#request-line)
- [Headers até a linha em branco](#headers-até-a-linha-em-branco)
- [Content-Length e o body](#content-length-e-o-body)
- [Montar a resposta HTTP/1.1](#montar-a-resposta-http11)
- [Accept, handle, respond](#accept-handle-respond)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## HTTP na mão

**O que é:**
O protocolo. Não é objeto. Não é annotation. É byte. João manda um texto. Você lê. Você devolve outro texto. Framework esconde isso.

**Como funciona:**
O cliente abre TCP na porta e escreve:

```
GET /tasks HTTP/1.1
Host: 127.0.0.1:4567
Accept: application/json

```

Três partes. Sempre. Request line. Headers. Body — aqui vazio, GET não carrega JSON. A linha em branco no fim dos headers não é enfeite. É o sinal: acabou o envelope, começa o payload.

Esse é o ponto que o entrevistador puxa. No Java do `com.sun.net.httpserver.HttpServer`, o JDK já cortou o texto. Você recebe um `HttpExchange`: `getRequestMethod()`, `getRequestURI()`, `getRequestHeaders()`, `getRequestBody()`. No Node, `http.createServer` entrega `req.method`, `req.url`, `req.headers` — o body ainda vem em stream. No PHP do built-in server, `$_SERVER['REQUEST_METHOD']` e `php://input` já estão prontos: o SAPI comeu o TCP.

No Ruby 3 com `TCPServer`, chega um socket. Ponto. Ninguém parseou. Você faz o trabalho que o `HttpExchange` fazia de graça. Rails faz `render json:`. Spring faz `@RestController`. Puma fala HTTP por você. Aqui o entrevistador vê o que esses nomes escondem.

**Quando usar:**
Take-home “sem framework”. Live coding de protocolo. Qualquer hora que a vaga puxe “o que o servidor faz antes da rota”.

**Exemplo prático:**
Maria manda `GET /tasks`. O socket entrega `"GET /tasks HTTP/1.1\r\n"`. Sem `request.method`. O capítulo transforma isso em method, path, headers, body — e devolve outra string.

**Na entrevista:**
> "HTTP é texto. Request line, headers, linha em branco, body. No Java o HttpExchange já corta. No Node o req já vem parseado. No PHP o built-in preenche o $_SERVER. Aqui eu leio o socket."

---

## Por que não gem

**O que é:**
A decisão do recorte. Não é “gem é feio”. É “gem de web esconde o ponto deste capítulo”.

**Como funciona:**
WEBrick era o `HttpServer` do Ruby. Vinha na stdlib. Servlet, request parseada. Ruby 3 tirou: poucos usavam, manutenção cara, Puma já cobria produção. Por isso a spec antiga quebra — não é o seu Ruby que está errado.

Três saídas:

| Saída | O que acontece |
|---|---|
| `gem install webrick` | `require` volta. Recorte quebra. Você não viu o protocolo. |
| Sinatra / Rails / Puma | App sobe. Entrevista vira tutorial de gem. |
| `TCPServer` | stdlib. Você lê o texto. Este capítulo. |

Java ainda tem `HttpServer` no JDK — o apipura usa isso sem Maven de web. Node ainda tem `http` no core. PHP ainda tem `php -S`. Ruby 3+ não tem mais o atalho parseado na stdlib. O que “já vem” para escutar porta é `socket`. `json` continua stdlib — entra no 1.4.

Instalar WEBrick para “ficar igual à spec” é puxar Spark no Java do apipura. Resolve o nome. Apaga o exercício.

**Quando usar:**
Sempre que alguém disser “só instala a gem”. Você responde o recorte.

**Exemplo prático:**
`require "socket"` e `require "json"`. Os dois da stdlib. `socket` é deste capítulo. `json` espera o 1.4.

**Na entrevista:**
> "WEBrick saiu da stdlib no Ruby 3. Eu não puxo a gem — o ponto é o protocolo. No Java o HttpServer ainda vem no JDK. No Ruby 3 eu abro um TCPServer e leio a request line."

---

## TCPServer e o loop

**O que é:**
O processo de pé na porta. Sem isso não tem API. Tem script que morre.

**Como funciona:**
`TCPServer.new` pede a 4567 ao SO. `accept` bloqueia até um cliente ligar. Cada `accept` devolve o socket daquela conexão. Você trata. Fecha. Volta a esperar.

```ruby
def start
  server = TCPServer.new(@host, @port)
  puts "API em http://#{@host}:#{@port}"
  loop do
    socket = server.accept
    handle(socket)
  end
ensure
  server.close if server && !server.closed?
end
```

Um cliente por vez. Sem thread. João espera Maria terminar. Para o exercício cabe. No Java, `HttpServer.create` + `start()` — o executor atende em paralelo se você deixar. No Node, `server.listen(4567)` aceita sem você escrever `accept`. No PHP, `php -S 127.0.0.1:4567` é o processo; o script só roda o request. Aqui você é o processo e o accept.

**Quando usar:**
Primeira linha que sobe o app. Antes de pensar em rota.

**Exemplo prático:**
`ruby server.rb` imprime `API em http://127.0.0.1:4567`. O processo não termina. `Ctrl+C` mata. O Hash some — o 1.1 já falou. Este capítulo não mexe no store.

**Na entrevista:**
> "TCPServer na 4567. Loop de accept. Um socket por request. Sem thread. Para o live coding basta. Produção eu não sirvo assim."

---

## Request line

**O que é:**
A primeira linha. Só ela. Método, path, versão. Não é header. Não é body.

**Como funciona:**
`socket.gets` lê até o `\n`. Você ganha `"GET /tasks HTTP/1.1\r\n"`. Split no espaço.

```ruby
request_line = socket.gets
return if request_line.nil?

method, raw_path, _ = request_line.split(" ")
path = raw_path.to_s.split("?", 2).first
```

`method` é string: `"GET"`, `"POST"`. `raw_path` pode vir com query — `/tasks?completed=false`. Você corta no `?`. Query não entra neste projeto. `nil` é o cliente que ligou e desligou: fecha e volta ao accept.

Java: `exchange.getRequestMethod()`. Node: `req.method`. PHP: `$_SERVER['REQUEST_METHOD']`. Os três já comeram a request line. Você está um andar abaixo. O path ainda não é rota — quem decide é o 1.3.

**Quando usar:**
Todo request. Sem request line não tem método. Sem método você não responde 405.

**Exemplo prático:**
João manda `GET /tasks HTTP/1.1` → `method == "GET"`, `path == "/tasks"`. Maria manda `POST /tasks`. Mesmo código. O parse não sabe o que é CRUD.

**Na entrevista:**
> "Primeira linha: método, path, versão. Eu faço split. Query eu corto. O Java já me daria getRequestMethod. Aqui eu leio o gets."

---

## Headers até a linha em branco

**O que é:**
O envelope depois da request line. `Host`, `Content-Type`, `Content-Length`. Um por linha. Acaba na linha vazia.

**Como funciona:**
HTTP manda `\r\n` no fim de cada linha. A linha em branco é `\r\n` sozinho — ou `\n`. Você lê até isso. Se continuar, come o body.

```ruby
def read_headers(socket)
  headers = {}
  loop do
    line = socket.gets
    break if line.nil? || line == "\r\n" || line == "\n"

    key, value = line.split(":", 2)
    next if key.nil? || value.nil?

    headers[key.strip.downcase] = value.strip
  end
  headers
end
```

Três detalhes que o entrevistador puxa. `split(":", 2)` — `Host: 127.0.0.1:4567` tem dois dois-pontos; sem o `2`, a porta se perde. `downcase` — nome de header é case-insensitive; sem normalizar, o `read_body` não acha o `Content-Length`. `strip` — você quer `"42"`, não `" 42"`.

No Java, `getRequestHeaders()` já é mapa case-insensitive. No Node, `req.headers` já vem em minúsculo. No PHP, vira `$_SERVER['HTTP_CONTENT_LENGTH']`. Você monta o mapa na mão.

**Quando usar:**
Sempre. Mesmo no GET sem body. Sem headers você não sabe o `Content-Length` do POST da Maria.

**Exemplo prático:**
O curl do João manda `Host`. O POST da Maria manda `Content-Type` e `Content-Length`. Você guarda no Hash. Ainda não parseia JSON. Ainda não cria task.

**Na entrevista:**
> "Headers até a linha em branco. Chave em downcase. Split no primeiro dois-pontos. Content-Length eu preciso para ler o body. O Node já me dá req.headers em minúsculo. Eu monto o Hash."

---

## Content-Length e o body

**O que é:**
O tamanho do payload em bytes. Não é “o resto do socket”. É um número. Você lê exatamente isso.

**Como funciona:**

```ruby
def read_body(socket, headers)
  length = headers["content-length"].to_i
  return "" if length <= 0

  socket.read(length)
end
```

Por que não `read` até EOF? O cliente pode deixar a conexão aberta. Você trava. O accept não volta. O próximo curl do João espera para sempre.

Por que não `gets`? JSON da Maria não termina em newline. Título pode ter `\n`: `"Levar Luna no vet\namanhã"`. `gets` corta cedo.

`to_i` em header ausente vira `0`. GET devolve `""`. `Content-Length` é byte, não caractere — `ã` em UTF-8 são dois bytes. Na leitura o cliente já mandou o número. Na resposta você usa `bytesize`.

Java: `getRequestBody()` já delimitado pelo JDK. Node: `req.on('data')` até `end`. PHP: `php://input` já é o body. Este capítulo para no texto. `JSON.parse` é 1.4. Hash é 1.5. Aqui o body é string — `{"title":"Vacina do Bidu"}` ou lixo. Você ainda não decide.

**Quando usar:**
Todo POST, PUT, PATCH. GET e DELETE deste app não mandam body. Length 0, string vazia.

**Exemplo prático:**
Maria manda `POST /tasks` com `Content-Length: 35` e `{"title":"Comprar ração do Thor"}`. Você lê 35 bytes. Não cria a task. Cria no 1.5.

**Na entrevista:**
> "Body é Content-Length bytes. Não é gets. Não é read até EOF — trava se o cliente não fechar. GET vem vazio. JSON eu parseio depois. Agora é string."

---

## Montar a resposta HTTP/1.1

**O que é:**
O texto que você escreve no mesmo socket. Status line. Headers. Linha em branco. Body. Espelha o request.

**Como funciona:**
O cliente entende isto:

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 2
Connection: close

[]
```

Status line: `HTTP/1.1`, código, reason. Sem isso o curl não mostra status. `Content-Length` em **bytes** — `body.bytesize`, não `body.size` se tiver acento. `Connection: close` — você não implementa keep-alive. Linha em branco: sem ela o cliente acha que o `[]` é header. 204 sem body: `Content-Length: 0`, sem `Content-Type` de JSON.

```ruby
body = JSON.generate(payload)
socket.write(
  "HTTP/1.1 #{status} #{reason}\r\n" \
  "Content-Type: application/json\r\n" \
  "Content-Length: #{body.bytesize}\r\n" \
  "#{format_extra(extra)}" \
  "Connection: close\r\n" \
  "\r\n" \
  "#{body}"
)
```

`\r\n` é o protocolo. `extra` é header a mais: `Location` no 201, `Allow` no 405. O 1.3 e o 1.5 usam. Aqui o ponto: header é linha `Nome: valor\r\n`.

Java: `sendResponseHeaders` + `getResponseBody()`. Node: `res.writeHead` + `res.end`. PHP: `http_response_code` + `header` + `echo`. Os três montam o mesmo texto. Você está vendo o texto.

**Quando usar:**
Todo request. Inclusive o 404 de path errado — ainda é HTTP/1.1.

**Exemplo prático:**
`curl -i http://127.0.0.1:4567/tasks` — o esqueleto do 1.1 vira `200` + `[]`. Sem `HTTP/1.1` na primeira linha, o curl reclama. Sem a linha em branco, o body some no lugar errado.

**Na entrevista:**
> "Eu monto HTTP/1.1 na mão. Status, headers, linha em branco, body. Content-Length em bytesize. 204 sem body. O Node faz writeHead. Eu faço a string."

---

## Accept, handle, respond

**O que é:**
O caminho de um request neste arquivo. Três nomes. Sem middleware. Sem Rack.

**Como funciona:**
`start` aceita. `handle` lê. `dispatch` decide. `respond` escreve. `ensure` fecha o socket.

```ruby
def handle(socket)
  request_line = socket.gets
  return if request_line.nil?

  method, raw_path, _ = request_line.split(" ")
  path = raw_path.to_s.split("?", 2).first
  headers = read_headers(socket)
  body = read_body(socket, headers)

  status, reason, payload, extra = dispatch(method, path, body)
  respond(socket, status, reason, payload, extra)
ensure
  socket.close
end
```

Deste capítulo: request line, headers, body, respond, close. Não deste: `dispatch` (1.3), JSON (1.4), `@tasks` (1.5). O arquivo já tem as três porque o app sobe de verdade. Pular para o `case method` é voltar a “framework na cabeça” — só que o framework é o seu `if`.

`ensure socket.close` importa. Esqueceu, o cliente espera. Java fecha o `HttpExchange` no fim do handler. Node chama `res.end`. PHP termina o script e o built-in fecha. Você fecha na mão. Um `handle` por vez — para curl ok, para mil clientes não. Não fingir que é Puma.

**Quando usar:**
Mapa mental. “Como o servidor funciona?” Você desenha esses três métodos. Não desenha o CRUD.

**Exemplo prático:**
Dois terminais: `ruby server.rb` e `curl -i http://127.0.0.1:4567/tasks`. Fluxo: `accept` → `gets` → headers até `\r\n` → body vazio → `respond` com `200` e `[]` → `close`. O `dispatch` da lista vazia você abre no 1.3.

**Na entrevista:**
> "Accept, handle, respond. Eu leio o texto, devolvo o texto, fecho o socket. Rota é o próximo passo. JSON de entrada depois. Store por último. Não começo pelo Hash."

---

## Recapitulando

- HTTP é texto em TCP. Framework esconde. Este capítulo mostra.
- WEBrick saiu da stdlib. Gem de web quebra o recorte. `TCPServer` é o “já vem”.
- Loop: `accept` → `handle` → `close`. Um request por vez.
- Request line: método + path + versão. Query você corta.
- Headers até linha em branco. Chave em minúsculo. `split(":", 2)`.
- Body = `Content-Length` bytes. Não é EOF. Não é `gets`.
- Resposta: `HTTP/1.1`, headers, `\r\n`, body. `bytesize`. 204 sem payload.
- `dispatch`, `JSON.parse`, `@tasks` não são deste capítulo.

---

## Exercícios práticos

### Exercício 1: O que o Java já fez por você?

**Enunciado:** O entrevistador veio de Java. Ele diz: “no `HttpExchange` eu já tenho método, URI e body. Por que você está no `gets`?”. Responda em voz alta. Compare com Node e PHP.

<details>
<summary>Solução</summary>

O `HttpExchange` é o parse. O JDK leu request line, headers e body. Node faz o mesmo no `http.createServer`. PHP faz no built-in. Ruby 3 não tem esse parse na stdlib. WEBrick tinha. Saiu. Você está um andar abaixo de propósito.

```ruby
request_line = socket.gets
method, raw_path, _ = request_line.split(" ")
headers = read_headers(socket)
body = read_body(socket, headers)
```

Isso é o `getRequestMethod()` + `getRequestHeaders()` + `getRequestBody()`.

**Pontos-chave:**
- HttpExchange / `req` / `$_SERVER` já parsearam
- TCPServer entrega o socket
- O ponto do capítulo é esse andar
</details>

### Exercício 2: Por que não `read` até o fim?

**Enunciado:** Um colega troca `socket.read(length)` por um loop de `gets` até `nil`. O POST da Maria com `{"title":"Levar Luna no vet"}` às vezes trava, às vezes corta. O que você explica?

<details>
<summary>Solução</summary>

Dois erros. `gets` até `nil` espera o cliente fechar — keep-alive, curl persistente. Você trava. O accept não volta. `gets` corta no `\n`. Body JSON não é linha.

O protocolo já mandou o tamanho: `Content-Length`. Você lê exatamente esses bytes. GET sem header → `0` → `""`.

**Pontos-chave:**
- Length é o contrato do body
- EOF trava
- `gets` não é body
</details>

### Exercício 3: A resposta que o curl recusa

**Enunciado:** Você escreve só `[]` no socket. Sem status line. O `curl -i` fica estranho. O que falta e por que `\r\n` aparece quatro vezes na cabeça?

<details>
<summary>Solução</summary>

Falta o envelope. HTTP não é o JSON. HTTP é status line + headers + linha em branco + body.

```
HTTP/1.1 200 OK\r\n
Content-Type: application/json\r\n
Content-Length: 2\r\n
Connection: close\r\n
\r\n
[]
```

Cada header termina em `\r\n`. O último extra é a linha vazia. `Content-Length` é `bytesize`. `"Vacina do Bidu"` em JSON tem mais bytes que letras se entrar acento. Node: `writeHead`. PHP: `header` + `echo`. Java: `sendResponseHeaders`. Mesmo texto.

**Pontos-chave:**
- Status line não é opcional
- Linha em branco separa header de body
- Length em bytes
</details>

---

*Parte do [Ruby Projects Handbook](/)*
