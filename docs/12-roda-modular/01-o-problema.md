# 12.1 Arquitetura B: monólito modular

> **TL;DR**
> O `app.rb` único da A não aguenta dezenas de prefixos. B parte em `hash_branch`. Orquestrador magro. Ramos `eventos` e `locais`. Mesmo JWT. Sem lote. Cada arquivo um ciclo: cadeado, GET, POST, 404.

## Conteúdo

- [O que é B](#o-que-é-b)
- [O recorte](#o-recorte)
- [Por que locais](#por-que-locais)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que é B

**O que é:**
Um processo. Vários arquivos de rota. Hash no prefixo. Não é microsserviço. Não é hexagonal.

**Como funciona:**
`r.hash_routes` olha o primeiro segmento. Acha `eventos` ou `locais` num Hash. Entra no bloco daquele arquivo. O resto da árvore (`r.is`, `Integer`) continua igual à A.

**Quando usar:**
Dois ou mais domínios no mesmo app. Time que briga no mesmo `app.rb`. Ingressos quando aparecer lote/pedido — cada um um ramo. Aqui só dois, para caber no quadro.

**Na entrevista:**
> "B é monólito partido. Um Puma. Vários hash_branch. Eu não abro um server por módulo."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| hash_routes | um route de 400 linhas |
| eventos + locais | lote, webhook, compra |
| JWT igual A | cookie |
| cadeado no ramo | Pundit |

**Na entrevista:**
> "Dois ramos para provar o plugin. Lote é o projeto grande. Eu não adianto estoque."

---

## Por que locais

**O que é:**
Segundo domínio de bolso **dentro de ingressos**. Venue virou cadastro. “Sala 2” tem `id` e `name`. Evento ainda guarda `venue` string — sem FK neste recorte. O ponto é o ramo, não o join.

**Como funciona:**
João POST `/locais` { name }. POST `/eventos` { title, venue }. Independentes. Join é o projeto depois.

**Na entrevista:**
> "Locais é o segundo prefixo. Sem FK de propósito. Eu mostro o branch, não o schema de produção."

---

## Como o walkthrough anda

**O que é:**
12.2 plugin. 12.3 app magro. 12.4 ramos. 12.5 O(1). 12.6 como rodar. [Código](/docs/12-roda-modular/codigo).

**Na entrevista:**
> "app.rb cabe numa tela. eventos.rb e locais.rb são os galhos."

---

## Recapitulando

- B = hash_branch
- dois prefixos
- JWT igual
- sem lote
- um processo

---

## Exercícios práticos

### Exercício 1: Microsserviço de locais

**Enunciado:** O entrevistador pede um Puma só para locais. Você compra?

<details>
<summary>Solução</summary>

Não neste recorte. Dois deploys, dois JWT secrets, duas tabelas sqlite. B existe para **não** fazer isso cedo. Quando o time e o deploy forçarem, aí sim. Agora: ramo.

**Pontos-chave:**
- um processo
- ramo ≠ serviço
- deploy é o gatilho
</details>

---

*Parte do [Ruby Projects Handbook](/)*
