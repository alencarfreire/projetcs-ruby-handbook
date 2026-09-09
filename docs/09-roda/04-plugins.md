# 9.4 Plugins

> **TL;DR**
> Plugin no Roda é módulo que o app carrega. Três neste recorte: `json` (Hash vira body), `json_parser` (body vira `r.params`), `halt` (sai na hora com status). Sem gem extra. Sem middleware à mão. Plugin ≠ “instala um Rails”.

## Conteúdo

- [O que é um plugin](#o-que-é-um-plugin)
- [json](#json)
- [json_parser](#json_parser)
- [halt](#halt)
- [A ordem json + halt](#a-ordem-json--halt)
- [O que não carregamos](#o-que-não-carregamos)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que é um plugin

**O que é:**
Extensão oficial do Roda. `plugin :nome`. Mexe no request, na response, nos matchers.

**Como funciona:**

```ruby
class App < Roda
  plugin :json
  plugin :json_parser
  plugin :halt
end
```

Cada um é um arquivo na gem. Você escolhe. O core do Roda é magro de propósito. Rails traz a casa. Roda traz o terreno.

**Quando usar:**
Quando o core não faz. JSON não é core. Halt não é core. Árvore é core.

**Na entrevista:**
> "Plugin é opt-in. Eu não ganho sessão, view, mail. Eu peço json. O resto fica de fora."

---

## json

**O que é:**
O bloco do route pode **devolver Hash ou Array**. O plugin serializa. Seta `Content-Type: application/json`.

**Como funciona:**

```ruby
r.get { EVENTS.values }
```

Sem o plugin, devolver Hash explode: Roda só aceita String no body por default. Você teria que `response.write(JSON.generate(...))`.

**Exemplo prático:**
`GET /` devolve `{ "name" => "ingressos-routing" }`. O curl vê JSON. Sem `to_json` na sua mão.

**Na entrevista:**
> "Eu retorno o Hash. O plugin vira JSON. Eu não chamo JSON.generate em toda folha."

---

## json_parser

**O que é:**
Lê o body se o `Content-Type` tem `json`. Joga em `r.POST` / `r.params`.

**Como funciona:**
`POST` com `-H "Content-Type: application/json"` e `{"title":"Sunset Jazz"}`. `r.params["title"]` é a string.

Sem o header, o parser não corre. `title` vem vazio. 422. O README do curl **tem** o header. Esquecer o header é o bug número um.

**Quando usar:**
API JSON. Sem form HTML neste recorte.

**Na entrevista:**
> "json_parser olha o Content-Type. Sem application/json o params não ganha o title. Eu olho o header antes da senha — aqui, antes do title."

---

## halt

**O que é:**
Para agora. Status e body. Não continua o bloco.

**Como funciona:**

```ruby
r.halt(422, { "errors" => ["title não pode ficar em branco"] })
r.halt(404, { "errors" => ["não encontrado"] })
```

Com o plugin `json`, o Hash do segundo argumento vira JSON. Guard clause. Sem `if/else` enorme.

**Na entrevista:**
> "halt é o return da árvore. 422 no title. 404 no id. O create nem roda."

---

## A ordem json + halt

**O que é:**
Os dois juntos. Halt com Hash precisa do json plugin para serializar.

**Como funciona:**
Neste app os três estão no topo da classe. Recorte suficiente. Sem `status_handler`. Sem `error_handler` custom no parser — JSON lixo cai no default 400 do plugin.

**Na entrevista:**
> "json, json_parser, halt. Três. Eu não carrego o catálogo."

---

## O que não carregamos

**O que é:**
A lista.

**Como funciona:**
`hash_routes` — fase 4. `sessions` — não. `render` — não tem ERB. `rodauth` — fase 3. `all_verbs` — PUT/PATCH ficam de fora. Recorte GET/POST.

**Na entrevista:**
> "Plugin que eu não preciso eu não carrego. Roda não pune por ser magro. Pune por ser surpresa."

---

## Recapitulando

- Plugin é opt-in
- json serializa o Hash
- json_parser lê o body
- halt sai com status
- Content-Type no POST

---

## Exercícios práticos

### Exercício 1: POST sem Content-Type

**Enunciado:** Body JSON, header `text/plain`. O que o app faz?

<details>
<summary>Solução</summary>

Parser não corre. `r.params["title"]` vazio. 422 title em branco. João acha que o title foi. Você olha o `-H`. Não debuga o Hash.

**Pontos-chave:**
- parser é o header
- 422 ≠ JSON inválido
- curl sempre com Content-Type
</details>

### Exercício 2: Devolver Hash sem plugin json

**Enunciado:** Você comenta `plugin :json`. `GET /` explode. Por quê?

<details>
<summary>Solução</summary>

Roda não sabe o que fazer com Hash no return. O plugin ensina. Sem ele, String. Você `JSON.generate` na mão ou religa o plugin.

**Pontos-chave:**
- return Hash é o plugin
- core é String
- um plugin, um comportamento
</details>

---

*Parte do [Ruby Projects Handbook](/)*
