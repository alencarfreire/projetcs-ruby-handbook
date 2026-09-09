# 10.5 Sequel::Model

> **TL;DR**
> Casaco. `class Evento < Sequel::Model`. `Evento.first.title` agora é método. Dataset continua embaixo: `Evento.dataset`. Neste recorte o model é opcional. A fase 11 usa dataset no `route`. Você sabe que o casaco existe.

## Conteúdo

- [A classe](#a-classe)
- [Quando vale](#quando-vale)
- [Quando não](#quando-não)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A classe

**O que é:**
`lib/evento.rb`. Tabela `eventos`. Inflection Sequel: `Evento` → `eventos` se o db padrão está setado.

**Como funciona:**

```ruby
class Evento < Sequel::Model(DB[:eventos])
end

Evento.first.title
Evento.where(title: "Sunset Jazz").first
```

Passamos o dataset explícito: `Sequel::Model(DB[:eventos])`. Sem adivinhar constante `DB` global do Model. Recorte honesto.

**Na entrevista:**
> "Model é dataset com objeto. first.title funciona. O SQL ainda é o dataset."

---

## Quando vale

**O que é:**
Associações, validações no objeto, hooks. O projeto grande de ingressos pode vestir o casaco.

**Como funciona:**
Lote `many_to_one :evento`. Aí o model paga. Agora não tem lote. O casaco é demo.

**Na entrevista:**
> "Quando a associação aparece, eu visto o model. Agora a tabela é uma. Dataset chega."

---

## Quando não

**O que é:**
Report, insert miúdo, o `route` da fase 11 pragmática.

**Como funciona:**
Arquitetura A do plano: Hash do dataset no `render`. Zero camada. Model no A seria já um passo. Recorte A: dataset. Recorte C (hexagonal): model ou repository em volta. Você escolhe depois.

**Na entrevista:**
> "A pragmática devolve Hash. Model não é obrigatório para o CRUD de evento."

---

## Recapitulando

- Model opcional
- title vira método
- dataset embaixo
- A fase 11 não depende disto

---

## Exercícios práticos

### Exercício 1: Trocar tudo para Model agora

**Enunciado:** O entrevistador pede. Você troca os examples?

<details>
<summary>Solução</summary>

Pode. Recorte deste capítulo é mostrar os dois. Trocar os examples esconde o Hash. Eu mantenho list.rb em dataset. Console mostra Evento. Os dois no quadro.

**Pontos-chave:**
- dois modos
- examples em Hash
- model no console
</details>

---

*Parte do [Ruby Projects Handbook](/)*
