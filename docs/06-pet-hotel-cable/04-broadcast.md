# 6.4 Broadcast no check-in e no check-out

> **TL;DR**
> Depois do `update` true, o controller renderiza o partial do quadro e `OccupancyChannel.broadcast_to(current_user, { html: })`. Não é callback no model. O fio fica no mesmo lugar do redirect. Adapter `async`: só este processo Puma entrega. Redis adapter é o 7/8.

## Conteúdo

- [No controller, não no model](#no-controller-não-no-model)
- [render_to_string](#render_to_string)
- [broadcast_to](#broadcast_to)
- [O div occupancy-live](#o-div-occupancy-live)
- [async vs Redis](#async-vs-redis)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## No controller, não no model

**O que é:**
`after_commit` no Stay também funcionaria. Recorte: controller. Você vê o broadcast ao lado do redirect.

**Como funciona:**

```ruby
def check_in
  if @stay.update(status: :checked_in)
    broadcast_occupancy
    redirect_to @stay, notice: "Check-in feito."
  else
    redirect_to @stay, alert: @stay.errors.full_messages.to_sentence
  end
end
```

Update false: não broadcast. Quadro não mente.

`rails console` `stay.update!(status: :checked_in)` **não** pinta o painel. Entrevista: “console não passa no controller”. Model callback pintaria. Trade-off. Recorte: controller.

**Na entrevista:**
> "Broadcast depois do update true. Console não emite. Se a vaga quiser todo save, eu subo o after_commit."

---

## render_to_string

**O que é:**
O mesmo ERB do GET `/`. Sem layout.

**Como funciona:**

```ruby
def broadcast_occupancy
  stays = current_user.stays.checked_in.includes(:pet, :owner).order(:check_in)
  html = render_to_string(partial: "occupancy/board", locals: { stays: stays }, layout: false)
  OccupancyChannel.broadcast_to(current_user, { html: html })
end
```

`includes` de novo. N+1 no cabo também é N+1.

Partial aceita `stays` local. O index usa `@stays`. Um HTML.

**Na entrevista:**
> "O partial é a fonte. Eu não monto a linha da tabela no Ruby. includes igual o GET."

---

## broadcast_to

**O que é:**
Publica no stream daquele user. Payload Hash. Vira JSON no cabo. JS lê `data.html`.

**Como funciona:**
`broadcast_to(current_user, { html: html })`. Casa com `stream_for current_user`. Ana logada noutra máquina: stream dela, silêncio.

**Na entrevista:**
> "broadcast_to o user, não o stay. O painel é do João. Vários pets, um stream."

---

## O div occupancy-live

**O que é:**
A âncora. O JS não substitui o body.

**Como funciona:**

```erb
<div id="occupancy-live">
  <%= render "occupancy/board" %>
</div>
```

Primeiro paint: GET HTML (funciona sem WS). Depois: innerHTML nos updates. Sem o GET, tela vazia até o primeiro broadcast. Progressive: o quadro existe sem cabo.

**Na entrevista:**
> "GET pinta. Cabo atualiza. Sem JS o GET ainda mostra o Thor. Enhancement."

---

## async vs Redis

**O que é:**
`cable.yml` development/test: `async`. Um processo, memória.

**Como funciona:**
Dois `bin/rails s` (dois Pumas): broadcast no A não chega no B. Redis adapter: pub/sub entre processos. Puma workers > 1 precisa Redis (ou solid cable). Recorte local: um Puma, async. Capítulo 7/8: Redis.

**Na entrevista:**
> "async é um processo. Eu não minto que escala. Redis adapter quando tem worker cluster."

---

## Recapitulando

- Controller depois do save
- Partial + includes
- broadcast_to user
- GET primeiro, cabo depois
- async neste recorte

---

## Exercícios práticos

### Exercício 1: Broadcast no update false

**Enunciado:** Segunda checked_in recusa. Você broadcast mesmo assim. O que a outra aba vê?

<details>
<summary>Solução</summary>

Quadro recarregado do banco — Thor continua uma vez. Não quebra. Request extra inútil. Recorte: só no true. Menos ruído.

**Pontos-chave:**
- save false = domínio igual
- não pinta por pintar
- true only
</details>

### Exercício 2: Payload gigante

**Enunciado:** 200 pets hospedados. HTML do quadro no WS. Problema?

<details>
<summary>Solução</summary>

Payload grande em todo check-in. Recorte da Pousada: cabe. Produção: mandar a linha (`append`/`remove`) em vez do quadro inteiro. Ou morph. Este livro substitui o quadro: simples no quadro da entrevista.

**Pontos-chave:**
- replace all é simples
- delta é o próximo recorte
- Pousada não tem 200
</details>

---

*Parte do [Ruby Projects Handbook](/)*
