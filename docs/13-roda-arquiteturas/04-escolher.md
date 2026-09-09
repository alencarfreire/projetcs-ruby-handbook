# 13.4 Como escolher

> **TL;DR**
> 45 min, um recurso: A. Vários prefixos no mesmo Puma: B. Regra que não pode conhecer HTTP nem SQL: C. Input sujo e erros como valor: D. Ingressos: cadastro A/B; estoque do lote C; webhook D. Não empilha os quatro no take-home.

## Conteúdo

- [A pergunta](#a-pergunta)
- [Take-home](#take-home)
- [Time](#time)
- [O produto de ingressos](#o-produto-de-ingressos)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A pergunta

**O que é:**
“Quem pode importar o quê?” e “quantos arquivos o quadro aguenta?”

**Como funciona:**
Se o `route` pode conhecer `DB[:eventos]`, A ou B. Se não pode, C. Se o JSON do cliente é o risco, D na borda — mesmo em A.

**Na entrevista:**
> "Eu escolho pela dependência e pelo tamanho. Não pela moda do último talk."

---

## Take-home

**O que é:**
Relógio. 45–90 min.

**Como funciona:**
A. JWT + um CRUD. B só se o enunciado já pede dois recursos. C/D no papel se sobrar tempo: “eu extraio isto”. Entregar hexagonal incompleto perde para A que sobe.

**Na entrevista:**
> "Take-home eu entrego A rodando. C eu narro. Não entrego pasta vazia de interactor."

---

## Time

**O que é:**
Conflito no git. Onboarding. Barreira de webhook.

**Como funciona:**
B quando o `app.rb` vira campo de batalha. Cadeado diferente por ramo (JWT vs assinatura HMAC do webhook) é o gatilho clássico.

**Na entrevista:**
> "Webhook não usa o JWT do João. Ramo próprio, barreira própria. Isso já é B. A regra do estoque dentro pode ser C."

---

## O produto de ingressos

**O que é:**
O mapa. O código que sobe está no [14](/docs/14-ingressos/01-o-problema).

**Como funciona:**

| Peça | Arquitetura |
|---|---|
| login / eventos / locais | A, depois B |
| lote (CRUD) | B, ramo `lotes` |
| reservar estoque | C (`ReservarLote`) |
| POST webhook pagamento | B ramo + D schema |
| GET lista | A/B dataset |

**Na entrevista:**
> "Eu não ponho C no GET. Eu ponho C no estoque. Webhook valida schema antes de tocar o pedido."

---

## Recapitulando

- relógio → A
- prefixos → B
- dependência → C
- input/Result → D
- ingressos mistura com critério

---

## Exercícios práticos

### Exercício 1: Tudo C

**Enunciado:** Interactor para o GET /eventos. Vale?

<details>
<summary>Solução</summary>

Teatro. `ListarEventos` que só chama `repo.all` sem regra. Custo sem ganho. GET fica no ramo. Call para regra.

**Pontos-chave:**
- regra pede C
- lista não pede
- honesto
</details>

---

*Parte do [Ruby Projects Handbook](/)*
