# 1.7 Como rodar e testar com curl

> **TL;DR**
> Dois terminais. Um sobe `ruby server.rb`. O outro bate os curls do README. Fonte do app: [código completo](/docs/01-http-api/codigo) — sem sair do handbook. `curl -i` mostra status; `curl -s` mostra o body. POST precisa de `-H Content-Type` e `-d`. DELETE devolve 204 sem body. `Ctrl+C` zera o Hash — não é bug. O teste é o curl. minitest, se vier, é raso. O entrevistador quer ver você rodando, não o Postman.

## Conteúdo

- [Dois terminais](#dois-terminais)
- [Subir o servidor](#subir-o-servidor)
- [curl -i e curl -s](#curl--i-e-curl--s)
- [POST precisa de header e body](#post-precisa-de-header-e-body)
- [Cada curl do README](#cada-curl-do-readme)
- [DELETE 204](#delete-204)
- [Matar o processo zera o Hash](#matar-o-processo-zera-o-hash)
- [curl, não Postman](#curl-não-postman)
- [minitest só de passagem](#minitest-só-de-passagem)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Dois terminais

**O que é:**
O roteiro de entrevista com o terminal aberto. Um processo escuta. O outro manda HTTP. Sem os dois, você não demonstra o contrato.

**Como funciona:**
Terminal 1: o servidor, bloqueado no `accept`. Terminal 2: o cliente. Cada curl é um request. O Hash vive no processo do 1. Fecha o 1 no meio, o 2 fala com a porta morta.

No Java do `HttpServer` é a mesma cena: uma JVM de pé, outro terminal com curl. No PHP do built-in também — com a diferença que o array do script some no fim de cada request. Aqui o processo Ruby segura o Hash entre um curl e outro. Os dois terminais apontam para o **mesmo** `127.0.0.1:4567`.

**Quando usar:**
Live coding. Take-home na hora de gravar o README. Qualquer “mostra rodando”.

**Na entrevista:**
> "Dois terminais. Um é o app. O outro é o curl. Eu não abro Postman na call."

---

## Subir o servidor

**O que é:**
Um comando. Sem `bundle`. Sem Gemfile. Ruby 3.3+ e o arquivo.

**Como funciona:**

```bash
cd projects/01-http-api
ruby server.rb
```

Você quer ver: `API em http://127.0.0.1:4567`. Host e porta são estes. Não é `localhost:3000`. Não é Puma. `Ctrl+C` mata o processo. O Hash some. Isso é o recorte — o README já diz.

Porta ocupada: outro processo ficou de pé. Mata ele. Não muda a porta no meio da entrevista.

**Quando usar:**
Antes do primeiro curl. Se o processo não imprimiu a URL, o resto é teatro.

**Exemplo prático:**
O start está em `projects/01-http-api/server.rb`. `TaskServer.new.start`. Você precisa do processo escutando, não do arquivo aberto.

**Na entrevista:**
> "Ruby server.rb. Sem bundle. Escuta em 127.0.0.1:4567. Ctrl+C zera o store. Combinado."

---

## curl -i e curl -s

**O que é:**
Duas flags que mudam o que você vê — e o que o entrevistador puxa.

**Como funciona:**

| Flag | O que faz | Quando |
|---|---|---|
| `-s` | silent: some a barra de progresso, sobra o body | “mostra o JSON” |
| `-i` | include: status line + headers + body | “mostra o 201”, “mostra o Location” |
| `-s -i` | os dois | curls do README que importam status |

```bash
curl -s http://127.0.0.1:4567/tasks
# []

curl -i http://127.0.0.1:4567/tasks
# HTTP/1.1 200 OK
# Content-Type: application/json
# ...
# []
```

`-s` sozinho esconde o 200. Em lista vazia você até aceita. Em POST, DELETE e erro, sem `-i` você não prova o status. O entrevistador pergunta “e o 201?”. Você roda de novo com `-i`.

No take-home Java é a mesma flag contra o `HttpServer`. No PHP, contra `php -S`. A ferramenta não muda. O que muda é o tempo de vida do store.

**Quando usar:**
`-s` para o payload. `-i` para o contrato: status, `Content-Type`, `Location`, `Allow`.

**Na entrevista:**
> "curl -s é o body. curl -i é o HTTP. No POST eu uso -i porque o ponto é 201 e Location, não só o JSON."

---

## POST precisa de header e body

**O que é:**
GET não manda body. POST manda. Sem `-H` e sem `-d`, você não criou task — mandou um GET disfarçado ou um body vazio.

**Como funciona:**
curl default é GET. `-X POST` troca o método. `-H "Content-Type: application/json"` declara o payload. `-d '...'` é o body.

```bash
curl -s -i -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Comprar ração do Thor"}'
```

Esqueceu `-X POST`: vira GET em `/tasks`. 200. Nenhuma task nova. Esqueceu `-d`: body vazio, parse falha, 400. Esqueceu o header: o entrevistador espera ver `Content-Type` em JSON. Este app lê o body pelo `Content-Length`, mas o contrato do README é header + body. Você honra o contrato.

HTTPie encurta: `http POST :4567/tasks title="Comprar ração do Thor"`. Bonito. Não está na máquina da banca. Insomnia clica. A banca não abre seu workspace. curl cola no README e roda.

**Quando usar:**
Todo POST, PUT e PATCH deste app. Sem body, 400. Sem método, não é create.

**Exemplo prático:**
O payload de criação é só `title`. O servidor preenche `id` e `completed`. Você não manda `id`. Se mandar, o app ignora e usa `@next_id`.

**Na entrevista:**
> "POST é -X, Content-Type e -d. Sem os três eu não criei. O title vem no JSON. Id eu gero."

---

## Cada curl do README

**O que é:**
A sequência que o revisor cola. Comandos iguais aos de `projects/01-http-api/README.md`. Host `127.0.0.1:4567`. Recurso: tasks.

**Como funciona:**

Lista vazia — o store falando a verdade:

```bash
curl -s http://127.0.0.1:4567/tasks
# []
```

Você espera `[]`. 200. Não é “API incompleta”. É `@tasks` vazio.

Cria — o POST da seção anterior. Você espera `HTTP/1.1 201 Created`, `Location: /tasks/1`, body com `id`, `title`, `completed: false`. O que você fala: “201, Location, id 1, completed começa false.”

Busca um e lista de novo:

```bash
curl -s http://127.0.0.1:4567/tasks/1
curl -s http://127.0.0.1:4567/tasks
```

Um JSON. Depois um array com um elemento. Se a lista ainda for `[]`, você matou o processo no meio ou postou em outro host.

Substitui (PUT) — recurso inteiro. Parcial (PATCH) — só o que veio:

```bash
curl -s -X PUT http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Comprar ração do Thor","completed":true}'

curl -s -X PATCH http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":false}'
```

PUT: 200 e `completed: true`. Sem `title` ou sem `completed` → 400. PATCH: 200, title igual, `completed: false`.

Erros:

```bash
curl -s -i http://127.0.0.1:4567/tasks/99
# 404

curl -s -i -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '{quebrado'
# 400

curl -s -i -X POST http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"x"}'
# 405
```

404: id inexistente. 400: JSON inválido. 405: POST no membro — coleção aceita POST, `/tasks/1` não. Header `Allow: GET, PUT, PATCH, DELETE`.

**Quando usar:**
Na ordem. Pular o GET vazio e ir pro POST esconde se o servidor nem subiu.

**Na entrevista:**
> "Eu rodo o README de cima a baixo. GET vazio, POST 201, GET um, lista, PUT, PATCH, DELETE, 404, 400, 405. Se algum curl do README falha, o take-home falhou."

---

## DELETE 204

**O que é:**
Apagou. Sem body. Status 204 No Content.

**Como funciona:**

```bash
curl -s -i -X DELETE http://127.0.0.1:4567/tasks/1
# 204
```

Você espera `HTTP/1.1 204 No Content` e `Content-Length: 0`. Sem `Content-Type`. Sem JSON. `-s` sozinho imprime vazio — parece que “não fez nada”. Por isso o README junta `-s -i`. Depois, `GET /tasks` volta `[]`. `GET /tasks/1` vira 404.

No Rails, `head :no_content`. No Spring, `ResponseEntity.noContent()`. Aqui você monta a status line e `Content-Length: 0` na mão.

**Quando usar:**
Todo DELETE de sucesso deste app. 200 com `{}` também “funciona” — e o entrevistador puxa. 204 é o contrato.

**Importante na entrevista:**
Dizer que 204 não tem body. Quem devolve `{ "ok": true }` no DELETE não leu o README.

**Na entrevista:**
> "DELETE 204, body vazio. curl -i para ver o status. Depois GET 404 nesse id."

---

## Matar o processo zera o Hash

**O que é:**
A prova do recorte. `@tasks` vive no heap do processo. Mata o processo, some.

**Como funciona:**
Terminal 1: `ruby server.rb`. Terminal 2: POST da ração do Thor, GET lista — um item. Terminal 1: `Ctrl+C`, sobe de novo. Terminal 2:

```bash
curl -s http://127.0.0.1:4567/tasks
# []
```

Outro Hash. `@next_id` volta a 1. O próximo POST ganha `id` 1 de novo. Não é persistência quebrada. Não tem arquivo. Não tem SQL.

| Onde | Sobrevive ao próximo curl? | Sobrevive ao restart? |
|---|---|---|
| PHP script + `php -S` | não, a menos que grave | não |
| Java `HttpServer` + `List` | sim | não |
| Este app (Hash no processo) | sim | não |
| Rails / Laravel + SQLite | sim | sim |

Dois curls no mesmo processo veem o mesmo store. Dois processos não compartilham nada.

**Quando usar:**
Quando o entrevistador perguntar “e se cair o servidor?”. Você demonstra. Não explica só.

**Na entrevista:**
> "Tá em memória. Igual o List do handler Java. Diferente do PHP que zera a cada request. Ctrl+C, zerou. Para o exercício serve."

---

## curl, não Postman

**O que é:**
A ferramenta que a banca consegue colar. O entrevistador quer ver você rodando.

**Como funciona:**
curl está no macOS, no Linux da CI, no Git Bash. O README é o teste. Collection do Postman obriga o revisor a importar. Quase ninguém importa. Insomnia: GUI, workspace, clique. HTTPie: terminal e lindo — e não está no notebook da sala.

Take-home Java: curls no `HttpServer`. Take-home PHP: curls no built-in. Este app: curls no `TCPServer`. Mesma família. Você não troca a ferramenta no meio. Na call, compartilhe o terminal. Rode. Leia o status em voz alta.

Insomnia em casa, para explorar, ok. Não substitui o README. A banca não abre seu Insomnia.

**Quando usar:**
Sempre neste projeto.

**Na entrevista:**
> "O teste é o curl do README. Postman eu uso em casa. Aqui eu colo o comando e mostro o 201."

---

## minitest só de passagem

**O que é:**
Opcional. Raso. Não é o teste deste projeto.

**Como funciona:**
GUIDE e README fecham: teste = curl documentado. minitest, se vier, é um arquivo que checa `GET /tasks` → `[]`. Sem coverage theatre. Sem suíte copiando o README para parecer sênior. Em 45 minutos, curl basta. Se pedirem “e teste?”, você fala: “minitest raso no GET vazio; o contrato continua sendo o README.”

**Quando usar:**
Só se pedirem. Não abre o capítulo.

**Na entrevista:**
> "Teste é curl. minitest eu coloco se a vaga pedir arquivo de teste. Não é o recorte."

---

## Recapitulando

- Dois terminais: `ruby server.rb` e curl.
- Host `127.0.0.1:4567`. Comandos iguais ao README.
- `-s` é body. `-i` é status e header.
- POST/PUT/PATCH: `-X`, `-H Content-Type`, `-d`.
- DELETE 204 sem body.
- `Ctrl+C` zera o Hash. Demonstrar.
- curl na call. Postman/Insomnia/HTTPie não substituem o README.
- minitest opcional e raso. Não é o teste.

---

## Exercícios práticos

### Exercício 1: Sequência CRUD da task do Thor

**Enunciado:** Terminal 1 com o servidor no ar. Monte, no terminal 2, a sequência que cria a task “Comprar ração do Thor”, lista, busca o id 1, marca completed com PUT, volta completed com PATCH e apaga. O que você espera em cada passo?

<details>
<summary>Solução</summary>

Os curls do README, na ordem, no mesmo processo:

```bash
curl -s http://127.0.0.1:4567/tasks
# []

curl -s -i -X POST http://127.0.0.1:4567/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Comprar ração do Thor"}'
# 201, Location: /tasks/1

curl -s http://127.0.0.1:4567/tasks/1
curl -s http://127.0.0.1:4567/tasks

curl -s -X PUT http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Comprar ração do Thor","completed":true}'

curl -s -X PATCH http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":false}'

curl -s -i -X DELETE http://127.0.0.1:4567/tasks/1
# 204
```

PUT manda os dois campos. PATCH manda só o que muda. DELETE 204, lista volta `[]`.

**Pontos-chave:**
- Mesmo host, mesmo processo
- PUT substitui; PATCH parcial
- DELETE 204, sem body
</details>

### Exercício 2: Matar o server no meio

**Enunciado:** Você fez o POST da ração do Thor. GET lista mostra um item. No terminal 1 você dá `Ctrl+C`, sobe de novo, e no terminal 2 roda `GET /tasks` e depois outro POST. O que quebra? O que não é bug?

<details>
<summary>Solução</summary>

Quebra a expectativa de persistência. O GET depois do restart devolve `[]`. O POST novo ganha `id` 1 de novo — `@next_id` reiniciou. O `Location: /tasks/1` antigo não aponta para a task velha: ela não existe.

Não quebra o recorte. Hash no processo. Igual o `List` do handler Java. Diferente do PHP que já teria zerado no request seguinte, mesmo sem `Ctrl+C`. Diferente do Rails com SQLite, onde a linha sobrevive.

Se o GET no meio voltou `[]` sem você ter matado: outro processo, outra porta, ou o POST nem passou.

**Pontos-chave:**
- Restart = Hash novo + `next_id` 1
- Dois terminais, um processo
- Dizer isso em voz alta
</details>

### Exercício 3: 405 com POST em /tasks/1

**Enunciado:** O entrevistador pede para você criar a task **já no** `/tasks/1`. Você cola um POST nesse path. O que o curl do README faz, o que você vê, e o que você fala?

<details>
<summary>Solução</summary>

```bash
curl -s -i -X POST http://127.0.0.1:4567/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"x"}'
# 405
```

Path `/tasks/1` é membro: GET, PUT, PATCH, DELETE. POST mora na coleção `/tasks`. Status 405. Header `Allow: GET, PUT, PATCH, DELETE`. Body JSON de erro.

Não é 404 — o path existe como recurso de um id. Não é 201 — você não criou. Id não se escolhe na URL de create; o servidor gera com `@next_id`.

**Pontos-chave:**
- 405 ≠ 404
- POST na coleção, não no membro
- `Allow` na resposta; curl `-i` para ver
</details>

---

*Parte do [Ruby Projects Handbook](/)*
