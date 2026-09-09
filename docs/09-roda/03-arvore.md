# 9.3 route do |r|: a árvore

> **TL;DR**
> `r.on` corta um prefixo e desce. `r.is` casa o que sobrou vazio. `r.get` / `r.post` olham o método. `r.on Integer` captura o id. Não é lista de rotas. É árvore. `/eventos/1` não passa no `r.is` da coleção.

## Conteúdo

- [O bloco route](#o-bloco-route)
- [r.on](#ron)
- [r.is](#ris)
- [r.get e r.post](#rget-e-rpost)
- [r.on Integer](#ron-integer)
- [A ordem importa](#a-ordem-importa)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O bloco route

**O que é:**
Um método de classe. Um bloco. O `r` é o request.

**Como funciona:**

```ruby
route do |r|
  r.root do
    { "name" => "ingressos-routing" }
  end

  r.on "eventos" do
    # ...
  end
end
```

Tudo que o HTTP pede passa aqui. Sem `routes.rb` ao lado. Sem DSL de `resources`. A árvore **é** o roteamento.

Sinatra: várias `get '/eventos'`. Rails: `resources :eventos`. Roda: um `r.on "eventos"` e os verbos dentro.

**Quando usar:**
O app inteiro neste recorte. Depois o hash_routes parte a árvore em arquivos. A ideia não muda.

**Na entrevista:**
> "Um route. O r é o request. Eu desço o path. Não varro uma lista de regex."

---

## r.on

**O que é:**
“Se o próximo segmento casa, come o segmento e entra no bloco.”

**Como funciona:**
`PATH_INFO` `/eventos/1`. `r.on "eventos"` casa `eventos`. Sobra `/1`. O bloco de dentro vê `/1`.

`r.on` **não** exige que o path acabe. É ramo. Coleção e membro cabem dentro.

**Exemplo prático:**
`GET /eventos` — entra no `r.on "eventos"`, sobra `/` ou vazio, o `r.is` pega. `GET /eventos/1` — mesmo `r.on`, sobra `/1`, o `Integer` pega.

**Na entrevista:**
> "on é prefixo. Não é o fim. is é o fim. Eu não troco os dois nomes."

---

## r.is

**O que é:**
“O que sobrou do path está vazio. Este é o fim.”

**Como funciona:**

```ruby
r.on "eventos" do
  r.is do
    r.get { EVENTS.values }
    r.post { /* cria */ }
  end
end
```

`GET /eventos` casa `r.is`. `GET /eventos/1` **não** casa `r.is` — ainda tem `/1`. Cai no próximo matcher, o `Integer`.

**Quando usar:**
Coleção. Login. Health. Qualquer path que não tem segmento extra.

**Na entrevista:**
> "is é a folha. on é o galho. /eventos é is. /eventos/1 não é."

---

## r.get e r.post

**O que é:**
Matcher de método. Sem bloco, devolve boolean. Com bloco, entra se o método casa.

**Como funciona:**
Dentro do `r.is`: `r.get` lista. `r.post` cria. `PUT` neste recorte não existe — Roda devolve 404 (path/método não casou). Recorte: sem `all_verbs`, sem PATCH.

**Na entrevista:**
> "get e post são o verbo. O path já foi cortado. Eu não escrevo get '/eventos' com a string inteira de novo."

---

## r.on Integer

**O que é:**
Matcher de classe. Segmento só dígitos. Yield do valor **já Integer**.

**Como funciona:**

```ruby
r.on Integer do |id|
  event = EVENTS[id]
  r.halt(404, { "errors" => ["não encontrado"] }) unless event
  r.get { event }
end
```

`/eventos/abc` não casa Integer. Não entra. 404.

Chave do Hash é Integer. `EVENTS[id]` com string `"1"` erraria. O matcher já converte.

**Na entrevista:**
> "Integer no path. O id já é número. Eu não faço to_i na mão."

---

## A ordem importa

**O que é:**
A árvore é top-down. O primeiro que casa, come.

**Como funciona:**
`r.is` **antes** do `Integer`. Se você inverter e um dia tiver `r.on String`, pode engolir demais. Neste recorte: coleção primeiro, membro depois. Clássico.

`r.root` no topo. `/` não é `/eventos`.

**Na entrevista:**
> "Ordem. Coleção, depois id. Igual você lê a URL da esquerda para a direita."

---

## Recapitulando

- `on` prefixo, `is` fim, verbo depois
- Integer captura id
- Um `route`, árvore
- Ordem: coleção → membro
- Path restante muda quando você desce

---

## Exercícios práticos

### Exercício 1: POST /eventos/1

**Enunciado:** João posta no membro. O que acontece?

<details>
<summary>Solução</summary>

Entra em `r.on "eventos"`. `r.is` não casa — tem `/1`. `r.on Integer` casa. Não há `r.post` no membro. Roda não acha folha. 404. Não é 405 neste recorte (você não ligou o plugin que devolve Allow). Na entrevista: “eu não implementei POST no id. Create é a coleção.”

**Pontos-chave:**
- POST na coleção
- membro só GET
- 404 ≠ 405 aqui
</details>

### Exercício 2: r.on vs r.is no quadro

**Enunciado:** Desenhe `/eventos` e `/eventos/1` com duas caixas.

<details>
<summary>Solução</summary>

Caixa 1: `on "eventos"`. De lá saem duas: `is` (GET/POST coleção) e `on Integer` (GET membro). Uma entrada, dois fins. Não duas rotas soltas no mesmo nível do root.

**Pontos-chave:**
- um galho
- duas folhas
- path compartilhado
</details>

---

*Parte do [Ruby Projects Handbook](/)*
