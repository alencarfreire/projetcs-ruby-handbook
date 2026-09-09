# 13.2 C: hexagonal (ports & adapters)

> **TL;DR**
> Roda é a porta de entrada HTTP. O domínio é classe Ruby pura: `CriarEvento.new.call(input)`. Sequel é a porta de saída. O caso de uso não dá `require "roda"`. Não sobe app neste capítulo.

## Conteúdo

- [A ideia](#a-ideia)
- [Roda na borda](#roda-na-borda)
- [O caso de uso](#o-caso-de-uso)
- [Sequel no outro lado](#sequel-no-outro-lado)
- [Quando usar](#quando-usar)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A ideia

**O que é:**
O hexágono. Centro: regra. Bordas: I/O. HTTP de um lado. Banco do outro. Testa o centro sem Puma.

**Como funciona:**
Outros nomes: ports and adapters, clean architecture. O port é a interface. O adapter é Roda ou Sequel. Você não precisa de gem `dry-system` para desenhar.

**Na entrevista:**
> "C. A regra não importa Roda. Eu testo CriarEvento com um fake de repositório. Sem rack."

---

## Roda na borda

**O que é:**
Driving adapter. Lê params. Chama. Traduz o retorno em status.

**Como funciona:**
Esqueleto no papel:

```ruby
r.post do
  result = CriarEvento.new(repo: EventoRepo).call(
    title: r.params["title"],
    venue: r.params["venue"]
  )
  r.halt(422, { "errors" => result.errors }) unless result.ok?
  response.status = 201
  result.evento
end
```

O `route` ficou burro de propósito. A magia saiu.

**Na entrevista:**
> "Roda traduz HTTP. Não valida regra de negócio além do que o caso de uso manda."

---

## O caso de uso

**O que é:**
`CriarEvento`. Ruby puro. Input in, result out.

**Como funciona:**

```ruby
class CriarEvento
  def initialize(repo:)
    @repo = repo
  end

  def call(title:, venue:)
    return Err["title em branco"] if title.to_s.strip.empty?
    evento = @repo.insert(title: title.strip, venue: venue)
    Ok[evento]
  end
end
```

`Err`/`Ok` aqui são structs no quadro. Não é dry-monads ainda — isso é D. C pode devolver um Result caseiro.

**Na entrevista:**
> "call. Sem env. Sem r.params. Hash de entrada. Result de saída."

---

## Sequel no outro lado

**O que é:**
Driven adapter. `EventoRepo#insert` fala `DB[:eventos]`. O caso de uso fala `@repo.insert`.

**Como funciona:**
No teste, o repo é um Hash. Em produção, Sequel. Trocar SQLite por Postgres não mexe no `CriarEvento`.

**Na entrevista:**
> "O repo esconde o dataset. O call não sabe SQLite. Isso é C. A o route sabe DB[:eventos]."

---

## Quando usar

**O que é:**
Regra que vai viver mais que o framework. Estoque de lote com concorrência. Política de reembolso. Não o GET da lista.

**Como funciona:**
GET `/eventos` em C puro é teatro. CRUD raso fica em A/B. O `ReservarLote` (projeto grande) é o candidato a C: não pode importar Roda, não pode ficar só no dataset do ramo.

**Na entrevista:**
> "C no coração. A/B na borda boba. Eu não hexagonalizo o health check."

---

## Recapitulando

- Roda = adapter HTTP
- call puro
- repo = Sequel
- GET raso não pede C
- lote/estoque pede

---

## Exercícios práticos

### Exercício 1: Testar sem Puma

**Enunciado:** Como você prova CriarEvento na call?

<details>
<summary>Solução</summary>

Repo fake: array. `call(title: "")` Err. `call(title: "Jazz")` Ok com id. Zero Rack. Isso é o ganho. Se o teste precisa de Puma, você não fez C — fez request spec da A.

**Pontos-chave:**
- fake repo
- sem env
- o ganho é o teste
</details>

---

*Parte do [Ruby Projects Handbook](/)*
