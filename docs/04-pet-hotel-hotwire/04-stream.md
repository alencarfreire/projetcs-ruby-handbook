# 4.4 Stream no check-in e no check-out

> **TL;DR**
> `change_status` no `StaysController`. `respond_to`: Stream renderiza `status_change.turbo_stream.erb`; HTML redireciona igual o 2. Três ações: replace occupancy, replace stay, update flash. Request spec manda `Accept: text/vnd.turbo-stream.html` e lê o XML.

## Conteúdo

- [change_status](#change_status)
- [O template](#o-template)
- [flash sem redirect](#flash-sem-redirect)
- [O spec do stream](#o-spec-do-stream)
- [A regra não mudou](#a-regra-não-mudou)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## change_status

**O que é:**
Check-in e check-out iguais. Só mudam o enum e a frase.

**Como funciona:**

```ruby
def check_in
  change_status(:checked_in, "Check-in feito.")
end

def check_out
  change_status(:checked_out, "Check-out feito.")
end

def respond_status_change(notice: nil, alert: nil)
  respond_to do |format|
    format.turbo_stream do
      @stays = current_user.stays.checked_in.includes(:pet, :owner).order(:check_in)
      @flash_notice = notice
      @flash_alert = alert
      render :status_change
    end
    format.html { redirect_to @stay, notice: notice, alert: alert }
  end
end
```

O Stream precisa da lista `@stays` — o partial do quadro lê isso. Sem essa query, o replace manda occupancy nula. `includes` continua. N+1 não ganhou desculpa no Hotwire.

**Quando usar:**
Ação que já existia no 2 e agora tem dois formatos.

**Na entrevista:**
> "O update é o mesmo. respond_to escolhe o envelope. Eu recarrego @stays checked_in para o partial."

---

## O template

**O que é:**
`status_change.turbo_stream.erb`. Um arquivo para sucesso e falha. Flash leva notice ou alert.

**Como funciona:**
`turbo_stream.replace "occupancy"` — string do quadro.
`turbo_stream.replace @stay` — `dom_id`, o card.
`turbo_stream.update "flash-stack"` — o div no layout **sempre existe**, mesmo vazio. Sem o div, o primeiro Stream não tem onde pingar o flash.

Layout:

```erb
<div id="flash-stack" class="flash-stack">
  <%= render "shared/flash" %>
</div>
```

`update` troca o **conteúdo** do div. `replace` no flash-stack trocaria o próprio div — também dá, mas o id precisa voltar. Recorte: update no container.

**Na entrevista:**
> "Três streams. occupancy string, stay dom_id, flash update. O div do flash já está no layout vazio."

---

## flash sem redirect

**O que é:**
`redirect_to ..., notice:` usa `flash` na **próxima** visita. Stream **não** redireciona. `flash[:notice]` na mesma request pode não pintar. Por isso `@flash_notice` explícito.

**Como funciona:**
O partial `shared/_flash` aceita locals:

```erb
<% n = local_assigns[:notice] || flash[:notice] %>
```

HTML redirect: flash. Stream: locals. Um partial.

**Quando usar:**
Todo Stream que quer mensagem. Não misture com `flash.now` se você já tem o instance variable. Recorte: ivar.

**Na entrevista:**
> "Stream não faz redirect. notice: no redirect não aparece neste response. Eu passo o texto no render."

---

## O spec do stream

**O que é:**
Um example. Header Accept. Lê o body como texto.

**Como funciona:**

```ruby
post check_out_stay_path(stay), headers: { "Accept" => "text/vnd.turbo-stream.html" }

expect(response.media_type).to eq(Mime[:turbo_stream])
expect(response.body).to include('turbo-stream action="replace" target="occupancy"')
expect(response.body).to include("Nenhum pet hospedado")
expect(stay.reload).to be_checked_out
```

Sem Capybara. Sem Chrome. Você prova o envelope e o efeito no model. O DOM real o Turbo monta no browser — o 4.6 você clica.

Não asserta ausência de “Thor” no body: o stream da stay ainda cita o Thor no card.

**Na entrevista:**
> "Request spec do mime turbo_stream. Eu leio o target occupancy. System spec não entra neste recorte."

---

## A regra não mudou

**O que é:**
Duas `checked_in` no mesmo pet. 422 HTML no 2. Aqui o `update` falha, Stream pinta alert, occupancy **não** tira o Thor que já estava (a stay nova recusou). Check-out que falha (raro) idem.

**Como funciona:**
`change_status` no else chama o mesmo `respond_status_change` com `alert:`. Quadro recarregado do banco. Verdade no servidor.

**Na entrevista:**
> "Hotwire não autoriza. Model autoriza. Stream só pinta o que o update fez."

---

## Recapitulando

- `respond_to` stream + html
- `@stays` recarregado para o partial
- flash via ivar, não via redirect
- spec do mime e do target
- regra no model

---

## Exercícios práticos

### Exercício 1: format.html some

**Enunciado:** Você deixa só `format.turbo_stream`. O que o curl vê?

<details>
<summary>Solução</summary>

406 Not Acceptable. Ou um fallback 204 vazio, dependendo do Rails. O POST gravou ou não — mas o cliente HTML sem Turbo quebra. `format.html` é o recorte de enhancement. Não apague.

**Pontos-chave:**
- Turbo é Accept
- HTML é o default
- curl prova o fallback
</details>

### Exercício 2: @stays esquecido

**Enunciado:** O Stream renderiza `_board` sem setar `@stays`. O que explode?

<details>
<summary>Solução</summary>

`@stays.size` no partial. nil. 500. O index setava `@stays` no OccupancyController. O Stream roda no StaysController. Você busca de novo. Duas actions, uma query cada.

**Pontos-chave:**
- partial assume @stays
- controller da stay não é o da occupancy
- includes de novo
</details>

---

*Parte do [Ruby Projects Handbook](/)*
