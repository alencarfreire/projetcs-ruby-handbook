# 2.6 Validações que o entrevistador puxa

> **TL;DR**
> A regra mora no model. A view só ajuda o humano. `check_out > check_in`, no mínimo 1 diária, uma stay `checked_in` por pet (query + `validate` custom), pet e owner do mesmo user, dinheiro em centavos (integer), email único, senha com 8. Sem isso o HTML mente e o `rails console` fura. Bean Validation vive na entidade. Laravel `FormRequest` vive no request — o Tinker passa reto.

## Conteúdo

- [Por que no model, não só na view](#por-que-no-model-não-só-na-view)
- [check_out depois do check_in](#check_out-depois-do-check-in)
- [No mínimo uma diária](#no-mínimo-uma-diária)
- [Uma stay checked_in por pet](#uma-stay-checked_in-por-pet)
- [Pet e owner do mesmo user](#pet-e-owner-do-mesmo-user)
- [Dinheiro em centavos](#dinheiro-em-centavos)
- [Email único e senha mínima](#email-único-e-senha-mínima)
- [Bean Validation e FormRequest](#bean-validation-e-formrequest)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Por que no model, não só na view

**O que é:** o Active Record é o portão. Form HTML, `required`, `min`, `type="date"` — isso é UX. O model vale para o form, o console, o seed, o job e a API que ainda não existe.

**Como funciona:** `stay.save` roda `valid?`. Se alguma `validates` ou `validate` falha, não grava. `errors` enche. A view só imprime. Você não confia no browser.

João abre o DevTools, tira o `min` do date, manda `check_out` antes do `check_in`. Sem model, o SQLite aceita. Com model, `false` e flash.

No Java do Spring, `@Valid` no controller não segura o service se alguém chama o repositório direto. No Laravel, `FormRequest` some no `php artisan tinker`. No Rails o atalho é o mesmo: quem passa do model passa do domínio.

**Quando usar:** regra de negócio. Presença, formato, cruzamento de campo, unicidade, “não pode dois check-ins”. A view replica o que dá — nunca substitui.

**Na entrevista:**
> "Validação na view é cortesia. A regra fica no model porque console, seed e o próximo endpoint também passam por ele."

---

## check_out depois do check_in

**O que é:** a stay da Pousada do Thor não termina no mesmo instante em que começa. `check_out` tem que ser **depois** de `check_in`.

**Como funciona:** presença nos dois campos. Depois um `validate` custom — `validates` sozinho não compara dois atributos.

```ruby
validates :check_in, presence: true
validates :check_out, presence: true
validate :check_out_after_check_in

def check_out_after_check_in
  return if check_in.blank? || check_out.blank?
  return if check_out > check_in

  errors.add(:check_out, "deve ser depois do check-in")
end
```

`return` cedo se falta data. Sem isso você compara `nil` e ganha ruído em cima do `presence`. Uma mensagem por vez.

`>` e não `>=`. Mesmo dia, mesma hora: recusa. Diária zero não é hospedagem.

**Quando usar:** qualquer par início/fim. Reserva, contrato, vigência. O entrevistador puxa “dois campos, uma regra”.

**Exemplo prático:** Thor entra `2026-08-25`. Sai `2026-08-24`. `stay.valid?` → `false`. `errors[:check_out]` fala. O form devolve o João para a mesma tela.

**Na entrevista:**
> "Presence nos dois. Depois um validate custom. validates não compara atributo com atributo. return cedo se blank — senão eu empilho erro em cima de nil."

---

## No mínimo uma diária

**O que é:** `nights >= 1`. Hospedagem de zero noite não cobra e não ocupa. A Pousada não é sala de espera.

**Como funciona:** `nights` é método, não coluna. Datas viram integer. Sem Float.

```ruby
def nights
  return 0 if check_in.blank? || check_out.blank?

  (check_out.to_date - check_in.to_date).to_i
end

def minimum_one_night
  return if check_in.blank? || check_out.blank?
  return if nights >= 1

  errors.add(:base, "a hospedagem precisa ter no mínimo 1 diária")
end
```

Subtração de `Date` no Ruby devolve `Rational`. `.to_i` fecha. 25 para 26 = 1. 25 para 25 = 0 → erro em `base`. Não é de um campo só: é da stay inteira.

Se as colunas forem datetime e o checkout for mais tarde **no mesmo dia**, `check_out > check_in` passa e `nights` zera. Por isso as duas regras existem. Uma não cobre a outra.

**Quando usar:** depois que as datas existem. Antes disso, `presence` já falou.

**Na entrevista:**
> "nights é método. Date menos Date, to_i. Zero diária cai em errors[:base]. check_out > check_in não basta se os dois caem no mesmo dia."

---

## Uma stay checked_in por pet

**O que é:** Thor não está em dois quartos ao mesmo tempo. Uma stay `checked_in` por `pet_id`. `scheduled` e `checked_out` não entram na conta.

**Como funciona:** `validate` custom + query. Não é `validates :status, uniqueness:`. Unicidade cega no status bloquearia dois `scheduled` — e isso o hotel aceita.

```ruby
def only_one_checked_in_stay_per_pet
  return unless checked_in?
  return if pet_id.blank?

  clash = Stay.where(pet_id: pet_id, status: :checked_in)
  clash = clash.where.not(id: id) if persisted?
  return unless clash.exists?

  errors.add(:pet, "já está hospedado — só uma stay checked_in por vez")
end
```

Três detalhes que o entrevistador puxa:

1. `return unless checked_in?` — criar `scheduled` não consulta nada.
2. `where.not(id: id) if persisted?` — senão o update da própria stay “choca” com ela mesma.
3. `.exists?` — para no primeiro hit. Não carrega Array.

A view esconde o botão. O model recusa o POST. Dois requests no mesmo segundo podem passar os dois no `exists?`. A correia do banco é um unique index parcial em `(pet_id)` onde `status = 1`. Recorte deste app: a regra no model. O índice é a frase seguinte, se puxarem.

**Quando usar:** invariante que olha **outras linhas**. Unicidade condicional. `validates uniqueness` não expressa “só neste status”.

**Exemplo prático:** Thor já está `checked_in`. Maria tenta check-in de outra stay do mesmo pet. `save` devolve `false`. Occupancy não duplica o Thor.

**Na entrevista:**
> "Custom validate mais query. Excluo o próprio id se já persistiu. exists?, não load. Uniqueness no status quebraria dois scheduled. View não segura race — model é a primeira linha."

---

## Pet e owner do mesmo user

**O que é:** o tenant. João não amarra o Bidu da Maria. `pet.user_id` = `stay.user_id`. No Pet, `owner.user_id` = `pet.user_id`.

**Como funciona:**

```ruby
# Stay
def pet_belongs_to_same_user
  return if pet.blank? || user.blank?
  return if pet.user_id == user_id

  errors.add(:pet, "deve pertencer ao mesmo usuário")
end

# Pet
def owner_belongs_to_same_user
  return if owner.blank? || user.blank?
  return if owner.user_id == user_id

  errors.add(:owner, "deve pertencer ao mesmo usuário")
end
```

O controller já filtra `current_user.pets`. Isso é autorização de lista. A validação é o cinto quando o `pet_id` veio forjado no form. Sem ela, um `belongs_to` solto grava o cruzamento.

Owner não replica a regra de stay. Owner só exige `name` e `email` presentes. O recorte para no elo `user`.

**Quando usar:** todo `belongs_to` que atravessa tenant. Não delegue só ao `where(user_id:)`.

**Na entrevista:**
> "Controller filtra a lista. Model recusa o pet_id de outro user. São duas camadas. Eu não escolho uma."

---

## Dinheiro em centavos

**O que é:** `nightly_rate_cents` é integer > 0. `total_cents` é `nights * nightly_rate_cents`. Nunca Float. Nunca `BigDecimal` neste app. R$ 80,00 = `8000`.

**Como funciona:**

```ruby
validates :nightly_rate_cents, presence: true,
                               numericality: { only_integer: true, greater_than: 0 }

def total_cents
  nights * nightly_rate_cents.to_i
end
```

`total_cents` não é coluna. Calcula na hora. Você não valida o total — valida a taxa e as datas. O produto segue.

Float de dinheiro é entrevista clássica. `19.90 * 3` no IEEE não fecha. Centavo integer fecha. Java faria `long cents` ou `Money`. PHP, `int` ou brick/money. Aqui: coluna integer, método integer.

**Quando usar:** todo valor em BRL deste projeto. Diária, total, seed.

**Exemplo prático:** 3 noites, `8000` centavos. Total `24000`. A view divide por 100 só na hora de escrever “R$ 240,00”.

**Na entrevista:**
> "Dinheiro em centavos, integer. total_cents é nights vezes a diária. Float eu nem deixo entrar no model."

---

## Email único e senha mínima

**O que é:** `User` é a porta. Email normalizado, único sem case. Senha com 8. `has_secure_password` guarda `password_digest`, nunca a senha.

**Como funciona:**

```ruby
before_validation :normalize_email

validates :email, presence: true,
                  uniqueness: { case_sensitive: false },
                  format: { with: URI::MailTo::EMAIL_REGEXP }
validates :password, length: { minimum: 8 }, allow_nil: true

def normalize_email
  self.email = email.to_s.strip.downcase.presence
end
```

`normalize_email` roda **antes**. `Joao@email.com` e `joao@email.com` viram a mesma string. Uniqueness case-insensitive no SQLite ainda depende de collation — o downcase tira a discussão.

`allow_nil: true` na senha: update de nome não exige senha de novo. Create sem senha ainda cai no `has_secure_password`. Mínimo 8 é o recorte. Não é NIST. É o que o take-home pede.

Owner tem `validates :email, presence: true` e para. Email de dono não é login. Não invente uniqueness lá.

**Quando usar:** credencial. User. Não copie o bloco para Owner.

**Na entrevista:**
> "Downcase antes de validar. uniqueness case_sensitive: false. Senha mínimo 8 com allow_nil no update. has_secure_password — sem Devise."

---

## Bean Validation e FormRequest

**O que é:** a mesma pergunta em três peles. Onde a regra vive quando o HTTP não é o único cliente.

**Como funciona:**

| Stack | Camada HTTP | Camada de domínio |
|---|---|---|
| Rails (este app) | strong params + form | Active Record `validates` / `validate` |
| Java / Spring | `@Valid` no DTO | Bean Validation na entidade, `@AssertTrue`, `ConstraintValidator` |
| Laravel | `FormRequest` (`rules`, `withValidator`) | model / Form object — o Tinker não passa no Request |

Bean Validation parece o Rails: annotation na classe, `validator.validate(stay)`. Cruzar duas datas é `@AssertTrue` ou validator custom. “Um check-in por pet” é query no `ConstraintValidator` — o mesmo desenho do `only_one_checked_in_stay_per_pet`.

`FormRequest` parece strong params com validação. Bom para formato e presença do payload. Ruim como único dono da regra de ocupação: job, seed e `User::create` não passam pelo HTTP kernel.

**Quando usar:** a analogia, quando o entrevistador veio de Java ou PHP. Uma frase. Sem tutorial da outra stack.

**Importante na entrevista:** se só a view valida, o browser é o banco. Se só o `FormRequest` valida, o Tinker é o banco. Model (ou entidade) é o que resta quando não há request.

**Na entrevista:**
> "No Spring eu poria Bean Validation na entidade, não só no DTO. No Laravel, FormRequest não segura o Tinker. Aqui a stay recusa sozinha."

---

## Recapitulando

- View é UX. Model é regra. Console e seed também passam.
- `check_out > check_in`: `validate` custom. `validates` não compara dois campos.
- `nights >= 1`: método com `Date`, `.to_i`. Erro em `base`. Não é a mesma regra do `>`.
- Uma stay `checked_in` por pet: query + `exists?`. Exclui o próprio `id`. Não é `uniqueness` no status.
- Pet e owner do mesmo `user_id`. Controller filtra. Model recusa o id forjado.
- Centavos integer. `total_cents = nights * nightly_rate_cents`. Sem Float.
- Email: downcase + uniqueness. Senha: 8, `allow_nil` no update. `has_secure_password`.
- Bean Validation ≈ model. `FormRequest` ≈ request. O domínio não pode morar só no HTTP.

## Exercícios práticos

### Exercício 1: As duas datas

**Enunciado:** João marca check-in e check-out no dia `2026-08-25`. O form HTML deixou. O que o `Stay` faz — e por que uma regra só não chega?

<details>
<summary>Solução</summary>

Se as colunas são date, `check_out > check_in` já recusa igualdade. Se forem datetime com hora maior no mesmo dia, essa regra passa e `nights` devolve 0. Aí `minimum_one_night` adiciona em `base`.

As duas existem porque medem coisas diferentes: ordem do instante versus quantidade de diárias. `nights` nunca é Float. `(check_out.to_date - check_in.to_date).to_i`.

**Pontos-chave:**
- `>` não é `nights >= 1`
- `return` cedo se blank
- Diária é integer
</details>

### Exercício 2: Segundo check-in do Thor

**Enunciado:** Thor já tem stay `checked_in`. Maria abre outra stay `scheduled` do Thor e manda check-in. Escreva a query mental — e o que acontece no `update` da stay que já está dentro.

<details>
<summary>Solução</summary>

O método só roda se `checked_in?`. Monta `Stay.where(pet_id: thor.id, status: :checked_in)`. Se a stay é persistida, `where.not(id: id)`. `exists?`.

A stay nova acha a antiga → erro em `errors[:pet]`. A stay antiga, no update dela mesma, se exclui da query → passa. Sem o `where.not`, o hotel não consegue nem editar a diária do hóspede atual.

`validates :status, uniqueness: { scope: :pet_id }` quebraria dois `scheduled`. Não é essa regra.

**Pontos-chave:**
- Query condicional, não uniqueness cega
- Excluir `self` no update
- `exists?`, não `load`
</details>

### Exercício 3: View, FormRequest, model

**Enunciado:** Um colega Java quer `@NotNull` só no DTO. Um colega PHP quer a regra só no `FormRequest`. Você tem um `input type="date"` no form. O entrevistador pergunta onde mora `check_out > check_in`. Responda em quatro frases.

<details>
<summary>Solução</summary>

No model `Stay`, método `check_out_after_check_in`. A view impede o clique errado — não impede o POST forjado. Bean Validation na entidade (não só no DTO) é o par Java. `FormRequest` é par do strong params: o `artisan tinker` não passa por ele. Por isso a Pousada do Thor recusa no Active Record.

**Pontos-chave:**
- HTTP não é o único cliente
- DTO / FormRequest / HTML = borda
- Entidade / model = domínio
</details>

---

*Parte do [Ruby Projects Handbook](/)*
