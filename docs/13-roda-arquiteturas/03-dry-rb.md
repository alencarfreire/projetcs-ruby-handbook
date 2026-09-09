# 13.3 D: funcional com dry-rb

> **TL;DR**
> Roda recebe. dry-schema valida o input **antes** da regra. Operation devolve `Success(dado)` ou `Failure(erro)`. Roda faz match: 201 ou 422. Popular fora do Rails (Hanami usa a suíte). Sem app dry neste handbook.

## Conteúdo

- [A ideia](#a-ideia)
- [Schema na borda](#schema-na-borda)
- [Operation e Result](#operation-e-result)
- [O match no Roda](#o-match-no-roda)
- [Hanami](#hanami)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A ideia

**O que é:**
Tipos e erros explícitos. Sem exceção para fluxo normal. Failure é valor.

**Como funciona:**
dry-schema / dry-validation no input. dry-monads Result. dry-operation (ou uma classe `call` que devolve Result). O route não `halt` no meio da regra — a regra já veio Failure.

**Na entrevista:**
> "D. Failure é dado. Eu não rescue Validação. Eu faço match no Result."

---

## Schema na borda

**O que é:**
Contrato do JSON. Tipo, presença, formato.

**Como funciona:**
Esqueleto:

```ruby
EventoSchema = Dry::Schema.JSON do
  required(:title).filled(:string)
  optional(:venue).maybe(:string)
end

result = EventoSchema.call(r.params)
r.halt(422, { "errors" => result.errors.to_h }) unless result.success?
```

Webhook no projeto grande: schema da assinatura, do `event_id`, do `status`. Lixo 422 **antes** de mexer no pedido.

**Na entrevista:**
> "Schema primeiro. Regra depois. Payload de webhook podre não chega no estoque."

---

## Operation e Result

**O que é:**
`Success(evento)` / `Failure[:title_blank]`. Monad. Encadeia `bind` se quiser. Recorte de quadro: um call, um match.

**Como funciona:**

```ruby
class CriarEvento
  def call(input)
    return Failure[:title_blank] if input[:title].to_s.empty?
    Success(repo.insert(input))
  end
end
```

C pode usar Result caseiro. D usa a suíte. A diferença é o ecossistema e o schema, não o hexágono — C e D **combinam**.

**Na entrevista:**
> "C e D não são opostos. D é o estilo do Result. C é quem depende de quem. Posso ter os dois."

---

## O match no Roda

**O que é:**
A folha burra.

**Como funciona:**

```ruby
CriarEvento.new.call(input).either(
  ->(evento) { response.status = 201; evento },
  ->(err) { r.halt(422, { "errors" => Array(err) }) }
)
```

Ou `case result`. Sem `if title.empty?` no route — o schema e a operation já viram.

**Na entrevista:**
> "Roda não valida title. Roda traduz Success e Failure. O 422 nasceu no Result."

---

## Hanami

**O que é:**
O primo. Framework que abraça dry-rb. Não é Roda. Roda é a peça HTTP que muita gente usa do lado de fora, com a suíte dry à mão.

**Como funciona:**
Na entrevista: “Hanami faz isso de fábrica. Aqui eu desenho a suíte no Roda. Não é tutorial Hanami.”

**Na entrevista:**
> "dry-rb não é Hanami. Hanami usa dry. Eu posso usar dry no Roda sem trocar de framework."

---

## Recapitulando

- schema na porta
- Success / Failure
- Roda faz match
- combina com C
- Hanami é primo

---

## Exercícios práticos

### Exercício 1: halt na operation

**Enunciado:** A operation chama `r.halt`. Quebrou o quê?

<details>
<summary>Solução</summary>

A operation conheceu Roda. D e C morreram. Failure vira halt. Teste da operation precisa de request. Voltou A com nome chique.

**Pontos-chave:**
- Result ≠ halt
- operation sem r
</details>

---

*Parte do [Ruby Projects Handbook](/)*
