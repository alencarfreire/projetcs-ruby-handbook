# 6.6 Como rodar

> **TL;DR**
> `cd projects/06-pet-hotel-cable`. `bundle install`. `bin/rails db:prepare`. `bin/rails s`. Login seed. Duas janelas no `/`. Check-in da Luna na hospedagem. A janela do quadro ganha a Luna sem F5. Sem Redis. Specs: `bundle exec rspec`. Fonte: [código](/docs/06-pet-hotel-cable/codigo).

## Conteúdo

- [bundle e db:prepare](#bundle-e-dbprepare)
- [Duas janelas](#duas-janelas)
- [Network WS](#network-ws)
- [Sem JS](#sem-js)
- [bundle exec rspec](#bundle-exec-rspec)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## bundle e db:prepare

**O que é:**
Igual o 2, com importmap e Cable ligados.

**Como funciona:**

```bash
cd projects/06-pet-hotel-cable
bundle install
bin/rails db:prepare
bin/rails s
```

Porta 3000. Mata o 4 se estiver no ar — o 4 também pinta o quadro, mas **não** a outra aba.

**Na entrevista:**
> "Um Puma. async adapter. Eu não subo Redis neste recorte."

---

## Duas janelas

**O que é:**
A prova.

**Como funciona:**
1. Login. Janela A: `/`.
2. Janela B: hospedagens → Luna scheduled → check-in.
3. Janela A: Luna aparece. Sem F5.
4. Check-out da Luna na B (ou na stay). A some.

Mesmo user. Janela anônima não conecta o cabo (redirect login).

**Na entrevista:**
> "Duas janelas, um login. A que não clicou pintou. Isso o 4 não faz."

---

## Network WS

**O que é:**
DevTools → Network → WS → `/cable`. Frames.

**Como funciona:**
Subscribe, depois mensagens com o HTML. Não é `text/vnd.turbo-stream.html`. É o cabo.

**Na entrevista:**
> "Eu mostro o WS. Se o entrevistador ver turbo-stream, eu estou no app 4."

---

## Sem JS

**O que é:**
Disable JS. GET `/` ainda lista o Thor. Check-in na outra janela **não** pinta. F5 pinta. Enhancement.

**Na entrevista:**
> "Sem JS o GET vive. O cabo é extra. Igual o 4, outro extra."

---

## bundle exec rspec

**O que é:**
Onze examples. Connection, channel, broadcast, o resto do 2.

**Como funciona:**

```bash
bundle exec rspec
```

Sem Redis. Sem Chrome.

**Na entrevista:**
> "Onze examples. O cabo no servidor. As duas janelas eu clico."

---

## Recapitulando

- Um Puma, sem Redis
- Duas janelas, um user
- Network = WS
- GET sem JS
- rspec no servidor

---

## Exercícios práticos

### Exercício 1: Pintou no 4, não no 6

**Enunciado:** Você abriu duas abas e só a que clicou atualizou. App errado?

<details>
<summary>Solução</summary>

Provavelmente o 4 na 3000. O 4 Stream no response. Mata, sobe o 6, olha o lede da página: “Painel ao vivo”.

**Pontos-chave:**
- lede
- WS vs turbo-stream
- pasta no prompt
</details>

### Exercício 2: Console WS 404

**Enunciado:** `/cable` 404. O quadro não atualiza. Onde olhar?

<details>
<summary>Solução</summary>

`require "action_cable/engine"` no application.rb. `mount ActionCable.server => "/cable"`. Sem os dois, importmap carrega o JS, o socket 404, received nunca roda.

**Pontos-chave:**
- engine
- mount
- 404 ≠ reject (reject é 401 do cabo)
</details>

---

*Parte do [Ruby Projects Handbook](/)*
