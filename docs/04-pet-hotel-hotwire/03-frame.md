# 4.3 Frame da ocupação

> **TL;DR**
> `turbo_frame_tag "occupancy"` envolve o quadro. O partial `_board.html.erb` é o frame. Check-out mora dentro. Links que saem usam `data-turbo-frame="_top"`. O id `occupancy` é contrato: o Stream do 4.4 dá `replace` nesse id.

## Conteúdo

- [O tag](#o-tag)
- [O partial](#o-partial)
- [O botão dentro](#o-botão-dentro)
- [_top](#_top)
- [O frame da stay](#o-frame-da-stay)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O tag

**O que é:**
Helper que emite um `turbo-frame` com `id="occupancy"`. O id é o alvo.

**Como funciona:**

```erb
<%= turbo_frame_tag "occupancy" do %>
  <section class="occupancy-board">
    <%# ... %>
  </section>
<% end %>
```

String `"occupancy"`, não `dom_id`. É um quadro, não um record. Stay usa `turbo_frame_tag stay` → `id="stay_12"`. Dois estilos, dois papéis.

**Quando usar:**
Pedaço estável da página. Um quadro. Não um id por linha neste recorte — Stream substitui o quadro inteiro.

**Na entrevista:**
> "id occupancy. Estável. Eu não gero occupancy com timestamp. O Stream precisa achar o mesmo id."

---

## O partial

**O que é:**
`occupancy/_board.html.erb`. O index só renderiza o partial. O Stream também. Um HTML, dois lugares.

**Como funciona:**
`index.html.erb`:

```erb
<% content_for :title, "Quem está no hotel agora — Pousada do Thor" %>
<%= render "occupancy/board" %>
```

O Stream:

```erb
<%= turbo_stream.replace "occupancy" do %>
  <%= render "occupancy/board" %>
<% end %>
```

O partial **já traz** o `turbo_frame_tag`. `replace` troca o frame inteiro por um frame com o mesmo id. Certo.

Se o partial não tivesse o tag, o replace jogaria um `section` no lugar do `turbo-frame` e o próximo Stream não acharia o id.

**Na entrevista:**
> "O partial inclui o frame. Replace devolve o frame. Senão eu perco o id no segundo click."

---

## O botão dentro

**O que é:**
`button_to "Fazer check-out"` na linha. POST `check_out_stay_path(stay)`. Dentro do frame.

**Como funciona:**
João não vai na stay para tirar o Thor. O quadro é a recepção. Occupancy só lista `checked_in` — então o botão é check-out, não check-in. Check-in mora na stay (status `scheduled`).

Sem JS: o form POST ainda funciona. `format.html` redirect para a stay.

**Exemplo prático:**
Thor na tabela. Um botão. Luna scheduled não está no quadro. Bidu tampouco.

**Na entrevista:**
> "O botão mora no frame. Occupancy é checked_in, então a ação é check-out. Check-in é na stay."

---

## _top

**O que é:**
Fuga. O click não fica preso no frame.

**Como funciona:**

```erb
<%= link_to stay.pet.name, stay, data: { turbo_frame: "_top" } %>
<%= link_to "Ver hospedagens", stays_path, data: { turbo_frame: "_top" } %>
```

Sem isso, “Ver hospedagens” pinta o index de stays **dentro** do quadro. Navbar da app continua, meio da página vira outra tela. Estranho. `_top` é o documento.

**Quando usar:**
Todo link que não é “atualizar este recorte”.

**Na entrevista:**
> "_top. Eu falo isso. É o bug número um de Frame."

---

## O frame da stay

**O que é:**
O card em `/stays/:id`. `turbo_frame_tag stay`. O Stream `replace @stay` usa `dom_id` — o mesmo id.

**Como funciona:**
Partial `stays/_stay.html.erb` envolve o article. Check-in/out no card. Status muda no lugar. Header da página (h1, editar) fica fora do frame — não precisa piscar.

**Na entrevista:**
> "Record usa dom_id. Quadro usa string. Os dois são id no DOM. Stream replace @stay acerta o card."

---

## Recapitulando

- Frame `occupancy` no partial
- Botão check-out dentro
- `_top` para sair
- Frame da stay com `dom_id`
- Partial compartilhado com o Stream

---

## Exercícios práticos

### Exercício 1: Replace sem o tag no partial

**Enunciado:** Você move o `turbo_frame_tag` para o index e tira do partial. O primeiro check-out funciona?

<details>
<summary>Solução</summary>

O index tem o frame. O primeiro Stream replace manda o partial **sem** o tag. O frame some do DOM. Segundo check-out: target `occupancy` não existe. No-op. João clica e nada. O id precisa voltar em todo replace.

**Pontos-chave:**
- replace substitui o elemento
- o novo HTML tem que trazer o id
- partial único evita o deslize
</details>

### Exercício 2: Frame por linha

**Enunciado:** O entrevistador pede `turbo_frame_tag stay` em cada linha da tabela. Você troca o quadro?

<details>
<summary>Solução</summary>

Dá. Check-out `remove` a linha. Contador no header fica stale — está fora da linha. Aí você Stream-update o contador também. Mais peças. Recorte deste livro: um frame, tabela inteira. Simples no quadro.

**Pontos-chave:**
- frame por record é válido
- header/count pedem outro target
- um frame só para o take-home
</details>

---

*Parte do [Ruby Projects Handbook](/)*
