# Guia do handbook

Tom e regras do `projects-ruby-handbook`. Escreve do zero. Não traduz o rails-handbook nem o php-handbook. Copia o **método**: tom, rótulos, piloto, fases.

Este livro é **projeto**. O [rails-handbook](https://github.com/alencarfreire/ruby-handbook) é teoria. Aqui você constrói.

Idioma: **pt-BR de entrevista**. Não é verbete e não é português de manual.

---

## Tom

- **você**, nunca tu
- Frase curta, direta, como no quadro
- Sem “neste presente documento”
- Sem pt-PT: ficheiro, autocarro, descarregar, aplicação (no sentido de app → **app**)
- **Na entrevista** tem que soar falado — o que você diria para o entrevistador

Ruim: “O servidor efetua o despacho das requisições HTTP.”

Bom: “Chegou um POST. Você lê o JSON, guarda no Hash, devolve 201.”

---

## Ponto importante: explicar

Frase curta continua. No ponto que o entrevistador puxa, você abre — não corta.

Uma analogia com Java, PHP, Python ou JS vale. Lucidez, não tutorial de outra linguagem.

Ruim: “Tá em memória.”

Bom: “Tá em memória. No Java do `HttpServer` era um `List` no handler. No PHP o array do script morre no fim do request. No Rails seria a tabela. Aqui é Hash no processo. Mata o servidor, zerou.”

Não alongar o óbvio. Alongar o que confunde: recorte, store, status, PUT vs PATCH, o que some no restart.

---

## Duas pastas, duas funções

| Pasta | O que é | O que não é |
|---|---|---|
| `docs/` | walkthrough em pt-BR de entrevista | dump de pasta, código que “quase roda” |
| `projects/` | código que sobe de verdade | capítulo de teoria |

Em `projects/` só README de como rodar + código. Sem `.md` de conceito.

Uma unidade de walkthrough = um arquivo. ~250–400 linhas. Sem dump.

---

## Formato de cada capítulo de walkthrough

1. Título `# N.N Nome`
2. `> **TL;DR**` — um bloco, frases curtas
3. `## Conteúdo` — TOC interno
4. Corpo com os rótulos abaixo
5. `## Recapitulando`
6. `## Exercícios práticos` com **Enunciado:** e `<details><summary>Solução</summary>`
7. Footer: `*Parte do [Ruby Projects Handbook](/)*`

Não inventar TL;DR se o tema for só exercício (practice).

---

## README de cada projeto

Em `projects/N-.../README.md`, nesta ordem:

1. O que você constrói
2. O que você treina
3. Como rodar (comandos reais)
4. Endpoints / telas
5. O que NÃO entra (de propósito)

---

## Rótulos

Usar sempre estes. Não improvisar sinônimo no meio do livro.

- Resumo / TL;DR
- Conteúdo
- O que é
- Como funciona
- Quando usar
- Exemplo prático
- Na entrevista
- Exercícios práticos
- Exercício N
- Enunciado
- Pontos-chave
- Recapitulando
- Importante na entrevista

Labels em negrito no corpo (`**O que é:**`) usam a mesma tabela.

---

## Termos que ficam em inglês

A comunidade BR já fala assim.

HTTP: request, response, header, body, status, endpoint, payload, Content-Type, Location

Ruby: gem, Hash, Array, block, symbol, stdlib

Rails: Active Record, route, migration, strong params, `has_secure_password`, request spec, session cookie

Padrões: REST, CRUD, MVC

Testes: RSpec, curl, minitest

Primeira ocorrência de termo misto:

`stdlib (biblioteca padrão do Ruby)`

Depois só `stdlib`.

---

## Termos que vão para pt-BR

| Conceito | pt-BR |
|---|---|
| class | classe |
| store (prosa) | store (fica) / “guarda na memória” |
| routing | rotas / roteamento |
| authentication | autenticação |
| authorization | autorização |
| repository (git) | repositório |

- app, não aplicação
- controller, não controlador
- middleware, não “software intermediário”
- endpoint, não “ponto de extremidade”

---

## Código

Comentário e string em pt-BR. Identificador em inglês.

```ruby
def create_task(title)
  { id: @next_id, title: title, completed: false }
end

task = { "title" => "Comprar ração do Thor" }
```

`Task`, `create_task`, `do_GET` ficam. Moeda de exemplo: R$ / centavos / BRL.

Nomes: João, Maria, `joao@email.com`. Pets: Thor, Luna, Bidu. Hotel: “Pousada do Thor”.

---

## Stack

**Projeto 1 — HTTP API pura**

- Ruby 3.3+
- stdlib só: `socket` + `json`
- Sem Rails, sem gem de web, sem banco
- Store: `@tasks = {}` + `@next_id`
- Some quando o processo morre. Dizer isso no README e na entrevista
- Teste: curl documentado (minitest opcional e raso)

WEBrick saiu da stdlib no Ruby 3. Não puxamos gem de web só para manter o nome. O servidor é TCPServer. HTTP na mão.

**Projeto 2 — Pet hotel**

- Rails 7.1+, Ruby 3.3+, SQLite
- `has_secure_password` — não Devise
- Hotwire não entra. Sidekiq não entra
- Telas HTML. Sem API JSON neste projeto
- Teste: RSpec request spec nos fluxos principais. Sem coverage theatre

---

## Critério de arquivo pronto

1. `ruby` / `bin/rails` sobe de verdade
2. README do projeto tem os curls ou os cliques
3. TOC bate com os headings
4. Tom de entrevista, não verbete
5. Zero tu
6. Código do projeto 1 não usa gem de web nem SQL
7. Uma unidade = um arquivo

---

## O que este livro não é

- Não é o rails-handbook de novo
- Não é tradução do php-handbook
- Não é tutorial de gem
- Não ensina Rails 4
- Não mistura domínio: projeto 1 = tasks; projeto 2 = hotel de pets
