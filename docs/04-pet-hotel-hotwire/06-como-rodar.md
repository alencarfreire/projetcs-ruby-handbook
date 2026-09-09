# 4.6 Como rodar

> **TL;DR**
> `cd projects/04-pet-hotel-hotwire`. `bundle install`. `bin/rails db:prepare`. `bin/rails s`. Login `joao@email.com` / `senha123`. Quadro: Thor hospedado. Check-out no botão da linha. A linha some sem reload. Outra aba não some. Specs: `bundle exec rspec`. Fonte: [código](/docs/04-pet-hotel-hotwire/codigo).

## Conteúdo

- [bundle e db:prepare](#bundle-e-dbprepare)
- [Roteiro de cliques](#roteiro-de-cliques)
- [Duas abas](#duas-abas)
- [Sem JS](#sem-js)
- [bundle exec rspec](#bundle-exec-rspec)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## bundle e db:prepare

**O que é:**
Igual o 2, com duas gems a mais: `turbo-rails`, `importmap-rails`.

**Como funciona:**

```bash
cd projects/04-pet-hotel-hotwire
bundle install
bin/rails db:prepare
bin/rails s
```

Porta 3000. Mata o 2 se estiver no ar. SQLite próprio em `storage/`.

**Na entrevista:**
> "Mesmo seed. Thor checked_in. A diferença é o JS do Turbo no layout."

---

## Roteiro de cliques

**O que é:**
A prova do Frame.

**Como funciona:**
1. Login.
2. `/` — Thor na tabela, botão **Fazer check-out**.
3. Clique. Linha some. Flash “Check-out feito.” URL continua `/`.
4. Hospedagens → stay da Luna (scheduled) → **Fazer check-in**. Card atualiza o status no lugar. `/` agora lista a Luna.

Network: POST `check_out` 200, content-type `text/vnd.turbo-stream.html`. Não é 302.

**Na entrevista:**
> "Eu mostrei o mime turbo-stream no Network. Não é redirect."

---

## Duas abas

**O que é:**
A prova do 4.5.

**Como funciona:**
Duplica `/` com o Thor. Check-out numa. A outra fica. F5 nela: atualiza. Você fala o 6.

**Na entrevista:**
> "Duas abas. Uma clica. A outra não. Stream não é Cable."

---

## Sem JS

**O que é:**
DevTools, disable JS. Check-out ainda grava.

**Como funciona:**
POST, 302 para a stay, HTML cheio. Thor `checked_out`. Volta no `/` — quadro vazio. Enhancement, não requisito.

**Na entrevista:**
> "Sem JS o form POST vive. Turbo é o envelope. A regra está no model."

---

## bundle exec rspec

**O que é:**
Os examples do 2 mais um: o stream.

**Como funciona:**

```bash
bundle exec rspec
```

O example novo manda o Accept. Sem Chrome. Sem Redis.

**Na entrevista:**
> "Oito examples. O oitavo lê o target occupancy no XML. Não é Capybara."

---

## Recapitulando

- Sobe igual o 2
- Check-out no quadro, sem reload
- Network mostra turbo-stream
- Outra aba stale
- rspec sem browser

---

## Exercícios práticos

### Exercício 1: Porta e o 2

**Enunciado:** Você sobe o 4 e ainda vê o quadro **sem** botão de check-out. O que aconteceu?

<details>
<summary>Solução</summary>

O processo na 3000 ainda é o 2. Mata e sobe o 4. Ou `bin/rails s -p 3001`. O HTML do 2 não tem o botão na occupancy. Não é o Turbo “falhando”. É o app errado.

**Pontos-chave:**
- um processo por recorte
- olhar a pasta no prompt
- o botão é o sinal
</details>

### Exercício 2: importmap 404

**Enunciado:** Console do browser: falha ao carregar `turbo.min.js`. Check-out recarrega a página inteira. O que olhar?

<details>
<summary>Solução</summary>

`javascript_importmap_tags` no layout. Pin em `config/importmap.rb` para `turbo.min.js`. Gem `turbo-rails` no bundle. Sem o JS, Drive/Stream não existem — fallback HTML. O app não quebra. Só não é o recorte.

**Pontos-chave:**
- sem JS = projeto 2
- pin + gem
- Network da folha JS
</details>

---

*Parte do [Ruby Projects Handbook](/)*
