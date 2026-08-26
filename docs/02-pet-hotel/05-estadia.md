# 2.5 Estadia: entrada, saída, noites, total

> **TL;DR**
> Stay é a hospedagem. `check_in` e `check_out` são datas. `nights` é a diferença em dias — integer, mínimo 1. `total_cents = nights * nightly_rate_cents`. Sempre centavos. Nunca Float. Status é enum: `scheduled`, `checked_in`, `checked_out`. Check-in e check-out são member actions (`POST /stays/:id/check_in`). Occupancy = stays `checked_in` agora. Tela mostra `R$` com `format_money`. No Java seria `BigDecimal`. No PHP, integer cents. Aqui, integer cents.

## Conteúdo

- [A estadia](#a-estadia)
- [check_in e check_out](#check_in-e-check_out)
- [nights: diferença de datas, mínimo 1](#nights-diferença-de-datas-mínimo-1)
- [total_cents: noites vezes diária](#total_cents-noites-vezes-diária)
- [Nunca Float](#nunca-float)
- [enum status](#enum-status)
- [Member actions: check_in e check_out](#member-actions-check_in-e-check_out)
- [Occupancy: quem está agora](#occupancy-quem-está-agora)
- [format_money: reais sem Float](#format_money-reais-sem-float)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A estadia

**O que é:**
A linha que o hotel cobra. Pet, dono, entrada, saída, diária em centavos, status. Não é o pet. Não é o dono. É a reserva que vira hospedagem.

**Como funciona:**
João cadastra o Thor. Agenda a Pousada do Thor de sexta a domingo. Diária R$ 80,00 — no banco, `8000`. Duas noites. Total `16000`. Status começa `scheduled`. No dia, você faz check-in. Thor aparece em occupancy. No domingo, check-out.

O model `Stay` vive em `app/models/stay.rb`. Pertence ao `user` e ao `pet`. Dono vem `through: :pet`:

```ruby
belongs_to :user
belongs_to :pet
has_one :owner, through: :pet
```

Você não guarda `owner_id` na stay. O pet já aponta. Show liga pet, dono, datas, diárias, total, status. CRUD em `StaysController`. Occupancy é outro controller — só quem está dentro.

**Quando usar:**
Toda vez que o Thor dorme no hotel. Sem stay, não tem conta.

**Na entrevista:**
> "Stay é a hospedagem. Datas, diária em centavos, status. Total é método, não coluna. Occupancy lê quem está checked_in."

---

## check_in e check_out

**O que é:**
Duas colunas `date`. Entrada e saída. Presença obrigatória. Saída depois da entrada. O form usa `date_field`.

**Como funciona:**
`check_out > check_in` — não `>=`. Mesmo dia falha. Noite zero não é hospedagem neste app.

```ruby
def check_out_after_check_in
  return if check_in.blank? || check_out.blank?
  return if check_out > check_in

  errors.add(:check_out, "deve ser depois do check-in")
end
```

Strong params: `pet_id`, `check_in`, `check_out`, `nightly_rate_cents`, `status`. Pet do mesmo `user` — `pet_belongs_to_same_user`. Você não agenda o Bidu da Maria na conta do João.

**Quando usar:**
Create e update. O botão de check-in não troca a data. Troca o status.

**Na entrevista:**
> "check_in e check_out são date. Saída estritamente depois. Mesmo dia não passa. A data não muda no botão — o que muda é o status."

---

## nights: diferença de datas, mínimo 1

**O que é:**
Quantas diárias. Integer. Diferença de datas. Não é Float. Não é `max(1, diff)` no método. O mínimo 1 é validação.

**Como funciona:**

```ruby
def nights
  return 0 if check_in.blank? || check_out.blank?

  (check_out.to_date - check_in.to_date).to_i
end
```

Sexta → domingo: `2`. `Date` menos `Date` no Ruby vira `Rational`. `.to_i` corta para integer.

```ruby
def minimum_one_night
  return if check_in.blank? || check_out.blank?
  return if nights >= 1

  errors.add(:base, "a hospedagem precisa ter no mínimo 1 diária")
end
```

Datas faltando: `nights` devolve 0, presença pega. Diferença 0: a stay não salva.

**Exemplo prático:**
Thor entra 25/08, sai 27/08. `nights` = 2. Entra e sai 25/08: `nights` = 0, erro no `base`.

**Quando usar:**
Show, index, occupancy, total. Sempre o método. Não tem coluna `nights`.

**Na entrevista:**
> "nights é check_out menos check_in em dias. Integer. Mínimo 1 na validação, não no cálculo. Se eu clampasse no método, a stay inválida mentiria 1 diária."

---

## total_cents: noites vezes diária

**O que é:**
O que o João paga. `nights * nightly_rate_cents`. Integer. Não persiste. Método.

**Como funciona:**

```ruby
def total_cents
  nights * nightly_rate_cents.to_i
end
```

Diária `8000`. Duas noites. `16000`. A view chama `format_money(@stay.total_cents)` → `R$ 160,00`.

`nightly_rate_cents` é coluna integer, `greater_than: 0`, `only_integer`. O form avisa: `8000 = R$ 80,00`. Step 1. Sem ponto. Multiplicação de integer. Sem arredondar no fim.

**Quando usar:**
Index, show, occupancy. Nunca `stay.total` em reais.

**Na entrevista:**
> "total_cents = nights vezes nightly_rate_cents. Coluna é a diária. Total é método. Tudo centavos."

---

## Nunca Float

**O que é:**
A regra de dinheiro deste app. Banco, model, helper: integer. `0.1 + 0.2` não entra na Pousada do Thor.

**Como funciona:**
No Java de entrevista você fala `BigDecimal`. `new BigDecimal("80.10")`. Nunca `double` para BRL. No PHP, o caminho limpo é o mesmo daqui: centavos `int`. `8010`, não `80.10`.

Ruby tem `BigDecimal` na stdlib. Este projeto não usa. Recorte: centavos.

| Mundo | Dinheiro |
|---|---|
| Java | `BigDecimal` (ou `long` cents) |
| PHP | integer cents (ou BCMath) |
| Este Rails | integer cents |

Float mente. `80.10 * 3` no IEEE vira lixo na casa do centavo. `8010 * 3` = `24030`. Sempre.

**Importante na entrevista:**
“Eu guardo centavos. No Java eu usaria BigDecimal. Float eu não uso para dinheiro.” Se puxarem `BigDecimal` no Rails: “dá. Neste app o recorte é cents, igual PHP.”

**Na entrevista:**
> "Nunca Float. Centavos integer. Java BigDecimal. PHP integer cents. Aqui nightly_rate_cents e total_cents."

---

## enum status

**O que é:**
Três estados. Inteiro no SQLite. Symbol no Ruby. Predicados de graça.

**Como funciona:**

```ruby
enum :status, { scheduled: 0, checked_in: 1, checked_out: 2 }
```

Coluna integer, default 0. Active Record gera `scheduled?`, `checked_in?`, `checked_out?` e o scope `Stay.checked_in`. Occupancy usa o scope.

`stay_status_label` traduz na tela: Agendada, Hospedado, Check-out. Banco fala 1. Ruby fala `checked_in`. Humano fala “Hospedado”.

Um pet, uma stay `checked_in` por vez:

```ruby
def only_one_checked_in_stay_per_pet
  return unless checked_in?
  clash = Stay.where(pet_id: pet_id, status: :checked_in)
  clash = clash.where.not(id: id) if persisted?
  errors.add(:pet, "já está hospedado — só uma stay checked_in por vez") if clash.exists?
end
```

Thor pode ter dez stays `checked_out`. Não pode ter duas `checked_in`. A view esconde o botão. O model recusa mesmo assim.

**Quando usar:**
Agendada → hospedado → check-out. Occupancy filtra `checked_in`.

**Na entrevista:**
> "enum integer no SQLite. Predicados no Ruby. Um pet, uma checked_in. Validação no model, não só no botão."

---

## Member actions: check_in e check_out

**O que é:**
POST em um recurso que já existe. Não é create. Não é update genérico da ficha. É transição de status.

**Como funciona:**

```ruby
resources :stays do
  member do
    post :check_in
    post :check_out
  end
end
```

`POST /stays/:id/check_in`. Member = tem `:id`. Collection seria a lista.

```ruby
def check_in
  if @stay.update(status: :checked_in)
    redirect_to @stay, notice: "Check-in feito."
  else
    redirect_to @stay, alert: @stay.errors.full_messages.to_sentence
  end
end
```

`check_out` é o mesmo, com `status: :checked_out`. `set_stay` é `current_user.stays.find(params[:id])`. Stay da Maria na sessão do João: 404.

Show: se `scheduled?`, botão check-in. Se `checked_in?`, botão check-out. Já saiu: nenhum. O `update` dispara `only_one_checked_in_stay_per_pet`. Falhou? `alert` com a frase do model.

**Quando usar:**
O dia que o Thor chega e o dia que vai. Datas já estavam na reserva.

**Na entrevista:**
> "Member action. POST no id. Muda status. Se o pet já está checked_in, o model recusa e o controller devolve o erro no alert."

---

## Occupancy: quem está agora

**O que é:**
A recepção. Quem está no hotel agora. Não é a lista de reservas. Não é “datas que cobrem hoje”. É status `checked_in`.

**Como funciona:**
Root aponta para occupancy. Controller:

```ruby
@stays = current_user.stays.checked_in.includes(:pet, :owner).order(:check_in)
```

Scope do enum. `includes(:pet, :owner)` — owner via `has_one :owner, through: :pet`. Sem isso, N+1 na tabela.

Stay `scheduled` com check-in hoje **não** aparece. Stay `checked_out` **não** aparece. Occupancy é o agora operacional, não o calendário. A view lista pet, dono, datas, total com `format_money`. Check-in é na show da stay.

**Quando usar:**
Tela inicial depois do login. Vazio: “Nenhum pet hospedado no momento.”

**Na entrevista:**
> "Occupancy é checked_in. Não é overlap de datas com Date.current. Status, não calendário."

---

## format_money: reais sem Float

**O que é:**
Helper. Centavos integer → `"R$ 80,00"`. Sem Float. Sem `number_to_currency` neste recorte.

**Como funciona:**

```ruby
def format_money(cents)
  cents = cents.to_i
  sign = cents.negative? ? "-" : ""
  cents = cents.abs
  reais = cents / 100
  centavos = cents % 100
  "#{sign}R$ #{reais},#{format('%02d', centavos)}"
end
```

`8000 / 100` = `80`. `8000 % 100` = `0`. Integer division. `16000` → `R$ 160,00`. `8010` → `R$ 80,10`. Vírgula BR.

Index, show, occupancy chamam o helper. Diária e total. Thor, 2 noites, `8000`: “Diárias: 2”. “Diária: R$ 80,00”. “Total: R$ 160,00”.

**Quando usar:**
Toda vez que centavos viram texto para humano.

**Na entrevista:**
> "format_money divide por 100 com integer. R$ e vírgula. Sem Float. O valor já chegou em cents."

---

## Recapitulando

- Stay: pet, user, `check_in`, `check_out`, `nightly_rate_cents`, `status`.
- Datas: saída depois da entrada. Mesmo dia não passa.
- `nights` = diferença de datas em integer. Mínimo 1 na validação.
- `total_cents = nights * nightly_rate_cents`. Método, não coluna.
- Nunca Float. Java `BigDecimal`. PHP integer cents. Aqui integer cents.
- enum `scheduled` / `checked_in` / `checked_out`. Inteiro no SQLite.
- Um pet, uma `checked_in`. Regra no model.
- Member actions: `POST` check_in e check_out. Scoped em `current_user.stays`.
- Occupancy = `checked_in` agora. Root. `includes` para não N+1.
- `format_money` vira `R$ 80,00` com `/ 100` e `% 100`.

---

## Exercícios práticos

### Exercício 1: Mesmo dia

**Enunciado:** João agenda o Thor com `check_in` e `check_out` em 25/08. Diária `8000`. O que o model faz? Quanto vale `nights` se você chamar o método antes do save? O total “seria” quanto — e por que isso não grava?

<details>
<summary>Solução</summary>

`nights` devolve `0`. `total_cents` = `0`. O save falha: `check_out` tem que ser depois, e `minimum_one_night` exige `nights >= 1`. Occupancy não muda.

O método não inventa 1 diária. Se inventasse, a stay inválida mostraria `R$ 80,00` na tela de erro. Mentira. Cálculo honesto. Validação no `base` / em `check_out`.

**Pontos-chave:**
- Diferença 0 não vira 1 no método
- Mínimo 1 é validação
- Total 0 não chega a gravar
</details>

### Exercício 2: A diária veio 80.10

**Enunciado:** A diária do Bidu é R$ 80,10. Três noites. Um colega quer gravar `80.10` em Float e multiplicar. O que você grava? Qual o `total_cents`? Compare com Java `BigDecimal` e PHP integer cents.

<details>
<summary>Solução</summary>

Você grava `8010`. `nights` = 3. `total_cents` = `24030`. Tela: `R$ 240,30`.

Float: `80.10 * 3` no IEEE não é exatamente 240.30. Java: `new BigDecimal("80.10").multiply(new BigDecimal("3"))` — string no construtor, não `double`. Ou `8010L * 3`. PHP: integer cents, `24030`. Este Rails: cents. Sem `BigDecimal`, sem Float.

O form tem `step: 1`. Campo é centavos. Oitenta reais e dez = `8010`, não `80.10`.

**Pontos-chave:**
- 8010, não 80.10
- 3 * 8010 = 24030
- Float não. Java BigDecimal. PHP cents. Aqui cents
</details>

### Exercício 3: Occupancy e o segundo check-in

**Enunciado:** Luna está `checked_in` na stay 1. Stay 2 da Luna está `scheduled`. João abre occupancy. Depois clica check-in na stay 2. O que a tela mostra antes? O que o `update` faz depois? Occupancy mudaria se fosse “check_in <= hoje <= check_out”?

<details>
<summary>Solução</summary>

Antes: occupancy lista só a stay 1. Scope `checked_in`. Stay 2 scheduled não entra, mesmo que as datas cubram hoje.

Check-in da stay 2 falha. `only_one_checked_in_stay_per_pet`. Alert: “já está hospedado”. Stay 2 continua `scheduled`. Occupancy continua só a stay 1.

Se occupancy fosse overlap de datas, as duas apareciam — duas Lunas no quarto. O recorte é status. Check-out da stay 1, aí o botão da stay 2 passa.

**Pontos-chave:**
- Occupancy = checked_in, não Date.current
- Segunda checked_in morre no model
- View esconde botão; model é a trava
</details>

---

*Parte do [Ruby Projects Handbook](/)*
