# 13.1 Mapa A / B / C / D

> **TL;DR**
> Quatro desenhos. A e B você já subiu. C e D cabem no quadro — não sobem neste handbook. A pergunta é: quem manda, e a regra conhece Roda?

## Conteúdo

- [A tabela](#a-tabela)
- [Quem já corre](#quem-já-corre)
- [Quem é só quadro](#quem-é-só-quadro)
- [Ingressos no mapa](#ingressos-no-mapa)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A tabela

**O que é:**
O quadro inteiro numa vista.

**Como funciona:**

| | Quem é a porta HTTP | Onde mora a regra | Persistência | Quando |
|---|---|---|---|---|
| **A** pragmática | `route` num arquivo | no próprio `r.post` | `DB[:eventos]` | um domínio, 45 min |
| **B** modular | `hash_routes` | no arquivo do ramo | dataset no ramo | dezenas de prefixos |
| **C** hexagonal | Roda só adapta | `CriarEvento.new.call` | repository Sequel | regra sem web/banco |
| **D** dry-rb | Roda faz match do Result | Operation | o que a Operation chamar | tipos, Failure explícito |

**Na entrevista:**
> "Quatro nomes. Eu não misturo hexagonal com hash_routes. B parte arquivo. C parte dependência."

---

## Quem já corre

**O que é:**
A em `projects/11-roda-pragmatic`. B em `projects/12-roda-modular`.

**Como funciona:**
Você aponta. Curl. JWT. Evento. B ainda tem locais. C e D não têm pasta `projects/`.

**Na entrevista:**
> "A e B eu subi. C e D eu desenho. Se a vaga quiser C de verdade, eu extraio o call."

---

## Quem é só quadro

**O que é:**
C e D. Igual o system design da outra trilha: prática, sem app.

**Como funciona:**
Esqueleto no markdown. Sem Gemfile dry-rb neste recorte. Sem pasta de interactors que mente que sobe.

**Na entrevista:**
> "Eu não finjo um app hexagonal. Eu desenho a seta. Roda na borda. Caso de uso no centro."

---

## Ingressos no mapa

**O que é:**
O domínio desta trilha. Evento agora. Lote e webhook no exercício 13.5.

**Como funciona:**
A/B hoje: cadastro. C: `ReservarLote` sem importar Roda. D: schema do POST do webhook. O produto grande junta isso — fase depois.

**Na entrevista:**
> "Evento é A/B. Estoque do lote é o caso que puxa C. Webhook payload é o caso que puxa D."

---

## Recapitulando

- A arquivo, B ramo, C dependência, D Result
- A/B correm
- C/D quadro
- ingressos atravessa os quatro

---

## Exercícios práticos

### Exercício 1: B é hexagonal?

**Enunciado:** hash_routes = ports and adapters?

<details>
<summary>Solução</summary>

Não. B ainda chama `DB[:eventos]` no ramo. O ramo conhece Sequel e Roda. C o caso de uso não `require "roda"`. Partir arquivo ≠ partir dependência.

**Pontos-chave:**
- arquivo vs dependência
- B ≠ C
</details>

---

*Parte do [Ruby Projects Handbook](/)*
