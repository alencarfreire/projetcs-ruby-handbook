# 4.2 Drive vs Frame vs Stream

> **TL;DR**
> Drive intercepta o click. Frame recorta um `id`. Stream é a lista de mutações no response. Os três vêm do mesmo `import "@hotwired/turbo-rails"`. Sem Cable. Sem Stimulus. Se você misturar os nomes na entrevista, o quadro não salva.

## Conteúdo

- [O JS que entra](#o-js-que-entra)
- [Drive](#drive)
- [Frame](#frame)
- [Stream](#stream)
- [Accept e respond_to](#accept-e-respond_to)
- [O HTML continua](#o-html-continua)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O JS que entra

**O que é:**
Duas linhas. Importmap pina o Turbo. `application.js` importa.

**Como funciona:**

```javascript
import "@hotwired/turbo-rails"
```

```ruby
# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
```

Layout: `javascript_importmap_tags`. Sem Webpack. Sem bun. O arquivo `turbo.min.js` vem da gem.

No 2 não tinha JS. Por isso o 2 não “ganha Drive de graça” até você copiar este recorte.

**Quando usar:**
App HTML Rails 7+. Importmap é o default. Recorte: não discute Vite.

**Na entrevista:**
> "Uma linha de import. Turbo registra os adapters. Eu não escrevo fetch na mão."

---

## Drive

**O que é:**
Click em `a` e submit de form viram XHR. Rails devolve o HTML. Turbo troca o body (na prática o documento) sem reload completo.

**Como funciona:**
Os `link_to` e `button_to` do 2 não mudam. Drive pega. `redirect_to` no create de owner continua 302. Turbo segue. Flash aparece. Mais rápido, mesma arquitetura.

`data: { turbo: false }` desliga num link. Recorte: não precisa.

**Quando usar:**
Default. Você não declara Drive no quadro. Você declara quando **não** quer.

**Na entrevista:**
> "Drive é o Turbolinks que cresceu. Visita sem reload de CSS. Não é o Frame."

---

## Frame

**O que é:**
Um pedaço com `id`. Tag `turbo-frame` com `id="occupancy"`. Requests que partem de dentro pedem esse frame. Response precisa devolver um frame com o **mesmo** id.

**Como funciona:**

```erb
<%= turbo_frame_tag "occupancy" do %>
  <%# tabela %>
<% end %>
```

Link para fora do quadro (a stay, a lista de hospedagens) usa `data: { turbo_frame: "_top" }`. Senão o show da stay renderiza **dentro** do quadro. Bug clássico. A entrevista puxa.

**Quando usar:**
Um recorte visual. Inline edit. Quadro. Modal. Aqui: o quadro.

**Na entrevista:**
> "Frame tem id. O response precisa do mesmo id. Link que sai do recorte vai de _top. Senão a stay nasce dentro da tabela."

---

## Stream

**O que é:**
O response não é uma página. É uma lista de ações. `turbo-stream action="replace" target="occupancy"`.

**Como funciona:**
`stays/status_change.turbo_stream.erb`:

```erb
<%= turbo_stream.replace "occupancy" do %>
  <%= render "occupancy/board" %>
<% end %>
<%= turbo_stream.replace @stay do %>
  <%= render "stays/stay", stay: @stay %>
<% end %>
<%= turbo_stream.update "flash-stack" do %>
  <%= render "shared/flash", notice: @flash_notice, alert: @flash_alert %>
<% end %>
```

Três mutações. Quem não tem o target na página ignora. Check-out no quadro: occupancy existe, stay talvez não. Check-in na stay: stay existe, occupancy talvez não.

**Quando usar:**
Um POST que mexe em mais de um pedaço. Frame sozinho devolve um frame. Stream devolve vários.

**Na entrevista:**
> "Stream é o diff. replace occupancy, replace stay, update flash. Target ausente: no-op. Por isso o mesmo template serve as duas telas."

---

## Accept e respond_to

**O que é:**
Turbo pede `text/vnd.turbo-stream.html` no Accept do fetch de form. O controller escolhe.

**Como funciona:**

```ruby
respond_to do |format|
  format.turbo_stream { render :status_change }
  format.html { redirect_to @stay, notice: notice }
end
```

Sem JS: Accept é HTML. Redirect do 2. Spec sem o header Accept de stream: continua testando o redirect. Spec do recorte Hotwire manda o header.

**Exemplo prático:**
`curl` POST check-out sem o Accept de stream: 302 para a stay. O quadro só atualiza no GET seguinte. Com Turbo no browser: stream, quadro atualiza.

**Na entrevista:**
> "respond_to. HTML é o fallback. Stream é o enhancement. Eu não quebro o curl."

---

## O HTML continua

**O que é:**
A frase de progressive enhancement.

**Como funciona:**
`button_to` é um form POST. Sem Turbo, Rails processa, redirect, 200 da stay ou do root. Com Turbo, o mesmo POST, outro format. A regra do model não muda. Duas `checked_in` ainda 422 no HTML (redirect com alert) e stream com flash alert.

**Na entrevista:**
> "A regra não mudou de lugar. Mudou o envelope do response. Model ainda recusa a segunda checked_in."

---

## Recapitulando

- Uma import, três comportamentos
- Drive = visita; Frame = recorte; Stream = mutações
- `_top` para sair do frame
- `respond_to` HTML + turbo_stream
- Sem JS o POST ainda grava

---

## Exercícios práticos

### Exercício 1: Stay dentro do quadro

**Enunciado:** Você esquece `turbo_frame: "_top"` no nome do pet. O que o João vê?

<details>
<summary>Solução</summary>

Clica Thor. O show da stay vem **dentro** do frame occupancy. Navbar some do recorte visual (na verdade a stay substitui a tabela). URL pode até mudar conforme o Drive. Bug de Frame. Conserto: `_top` ou nem linkar de dentro.

**Pontos-chave:**
- frame captura o click
- _top escapa
- id igual no response
</details>

### Exercício 2: Só Frame, sem Stream

**Enunciado:** Dá para fazer o check-out só com Frame, sem template turbo_stream?

<details>
<summary>Solução</summary>

Dá. O POST parte do frame, você `render :index` da occupancy (ou um recorte) devolvendo o `turbo_frame_tag "occupancy"` novo. Um target. Flash fora do frame **não** atualiza. Stream existe para mexer flash + quadro + card juntos.

**Pontos-chave:**
- Frame = um pedaço
- Stream = N pedaços
- flash fora do frame pede Stream
</details>

---

*Parte do [Ruby Projects Handbook](/)*
