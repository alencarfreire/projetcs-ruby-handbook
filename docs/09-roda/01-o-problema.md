# 9.1 O problema e o recorte

> **TL;DR**
> Trilha nova. Ingressos. Roda. Sem Rails, sem Sequel, sem Rodauth. Você monta uma API de eventos: `title`, `venue`. Rotas numa árvore `route do |r|`. Store em Hash no processo — mata o Puma, zerou. Lote, pedido e webhook não entram. O recorte é o prefixo.

## Conteúdo

- [Esta trilha é outra](#esta-trilha-é-outra)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [O recurso Evento](#o-recurso-evento)
- [Por que some no Ctrl+C](#por-que-some-no-ctrlc)
- [O que fica de fora](#o-que-fica-de-fora)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Esta trilha é outra

**O que é:**
Um livro, duas trilhas. Esta começa no 9. Roda. Domínio de ingressos. Você não precisa ter lido hotel, Hotwire, Sidekiq.

**Como funciona:**
João organiza shows. Neste recorte ele só cadastra o evento. “Sunset Jazz” na “Sala 2”. Sem lote. Sem preço. Sem webhook. O HTTP é Roda. O banco ainda não existe — é Hash.

**Quando usar:**
Quando a pergunta é “Roda”. Take-home curto. Live coding de rota. Qualquer entrevista que pede microframework Ruby fora do Rails.

**Na entrevista:**
> "Roda. Árvore de rotas. Evento no Hash. Eu não começo pelo lote. Eu começo pelo prefixo /eventos."

---

## O problema

**O que é:**
Uma lista de eventos. Criar, listar, buscar. JSON na porta. Cliente: curl.

**Como funciona:**
João manda `POST /eventos` com `{"title":"Sunset Jazz","venue":"Sala 2"}`. Você gera `id`, guarda no Hash, devolve 201. `GET /eventos` devolve o array. `GET /eventos/1` devolve um.

No Express isso é `app.post('/eventos')`. No Flask, `@app.route`. No Sinatra, `post '/eventos'`. No Roda, `r.on "eventos"` e o POST mora **dentro**.

**Quando usar:**
API miúda. Recorte de 45 minutos. Mostrar que você sabe o `r` sem montar o sistema de vendas.

**Exemplo prático:**
O domínio cabe num Hash:

```ruby
event = {
  "id" => 1,
  "title" => "Sunset Jazz",
  "venue" => "Sala 2"
}
```

Três campos. Sem `price_cents`. Sem `lote_id`. Sem `user_id`. Recorte é isso: cabe no quadro.

**Na entrevista:**
> "O problema é CRUD raso de evento. Title e venue. Lote eu nomeio e deixo para o projeto de venda."

---

## O recorte

**O que é:**
O que entra e o que não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Roda, Puma, Rack | Rails, Sinatra |
| `route do \|r\|` | hash_routes |
| Hash no processo | Sequel, SQLite |
| JSON plugin | Rodauth, JWT |
| Evento | Lote, pedido, webhook, compra |

Por que Hash? Porque a fase 2 é Sequel. Se você puxa o banco agora, o entrevistador não vê o `r.on`. Uma coisa por vez.

**Quando usar:**
Sempre que o exercício diz “Roda”. Roda neste capítulo não é “a stack Jeremy Evans inteira”. É a árvore.

**Na entrevista:**
> "Recorte: Roda, JSON, Hash. Sem Sequel. Sem Rodauth. O próximo capítulo de persistência é outra pasta."

---

## O recurso Evento

**O que é:**
`id`, `title`, `venue`. `title` obrigatório. `venue` pode ser nil.

**Como funciona:**
POST sem title: 422. Id que não existe: 404. Create: 201 e `Location: /eventos/1`. Lista: array. Um: objeto.

**Na entrevista:**
> "Evento é o agregado miúdo. Lote depende do evento. Eu não crio lote sem evento. Por isso o recorte começa aqui."

---

## Por que some no Ctrl+C

**O que é:**
`EVENTS = {}` na classe. Memória do processo. Puma morre, Hash morre.

**Como funciona:**
Igual um `Map` no handler Java. Diferente do PHP que já zera a cada request. Diferente da tabela Sequel da fase 2. Dizer isso em voz alta.

**Na entrevista:**
> "Tá no processo. Restart zerou. Não é bug. É o recorte. Sequel entra depois."

---

## O que fica de fora

**O que é:**
A lista para falar alto.

**Como funciona:**
Sequel, Rodauth, hash_routes, dry-rb, lote, webhook, HTML, cookie. O 9.2 fala Rack. O 9.3 fala a árvore. O resto da trilha empilha.

**Na entrevista:**
> "Venda de ingresso é o projeto grande. Aqui eu mostro o r.on."

---

## Como o walkthrough anda

**O que é:**
Nove ponto um até nove ponto seis. Código em `projects/09-roda-routing`.

**Como funciona:**
9.2 Rack. 9.3 a árvore. 9.4 plugins. 9.5 halt e JSON. 9.6 curls. [Código](/docs/09-roda/codigo) cola o `app.rb`.

**Na entrevista:**
> "Eu subi o Puma, criei o Sunset Jazz, matei o processo, a lista voltou []."

---

## Recapitulando

- Trilha nova, ingressos, Roda
- Evento no Hash
- Árvore `r.on "eventos"`
- Sem Sequel, sem lote
- Ctrl+C zera

---

## Exercícios práticos

### Exercício 1: Por que não lote agora

**Enunciado:** O entrevistador pede `POST /eventos/1/lotes` neste recorte. Você faz?

<details>
<summary>Solução</summary>

Não. Lote é quantidade, preço, janela. É o projeto de venda. Neste recorte o ponto é o prefixo. Você fala: “o ramo seria `r.on Integer do |id|` e dentro `r.on 'lotes'`. Eu desenho. Não implemento agora.”

**Pontos-chave:**
- recorte
- o `r.on` aninhado já ensina o caminho
- lote = depois
</details>

### Exercício 2: Hash vs tabela na boca

**Enunciado:** “Por que não SQLite?” Resposta de 15 segundos.

<details>
<summary>Solução</summary>

Porque o ponto é o Roda. Tabela é Sequel, fase seguinte. Hash mostra o processo. Restart some. Se eu puxo o banco agora, a entrevista vira migration.

**Pontos-chave:**
- uma peça
- Hash é didático
- Sequel tem pasta
</details>

---

*Parte do [Ruby Projects Handbook](/)*
