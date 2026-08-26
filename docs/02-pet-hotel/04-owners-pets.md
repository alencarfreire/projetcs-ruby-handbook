# 2.4 Owners e pets

> **TL;DR**
> João opera a Pousada do Thor. Maria é dona. Thor, Luna e Bidu são pets dela. CRUD HTML, scoped em `current_user`. Pet só entra se o owner for do mesmo user. `includes(:owner)` no index. Strong params sem `user_id`. Formulário, não JSON.

## Conteúdo

- [Dois recursos, um hotel](#dois-recursos-um-hotel)
- [Maria é dona. João opera](#maria-é-dona-joão-opera)
- [Associações](#associações)
- [CRUD no current_user](#crud-no-current_user)
- [Strong params](#strong-params)
- [Pet e owner do mesmo user](#pet-e-owner-do-mesmo-user)
- [includes para não N+1](#includes-para-não-n1)
- [Formulário HTML](#formulário-html)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Dois recursos, um hotel

**O que é:**
Owner e Pet. Dois CRUDs. Telas HTML. Sem API JSON neste projeto. Sem estadia ainda — stay é o capítulo seguinte.

**Como funciona:**
`resources :owners` e `resources :pets` em `config/routes.rb`. Sete rotas cada. Index, show, new, create, edit, update, destroy. O browser manda form. O controller grava. O SQLite fica.

No projeto 1 a task era Hash. Aqui a linha é Active Record. Reiniciou o `bin/rails`, Maria continua. Thor continua.

**Quando usar:**
Quando o entrevistador pede “CRUD de dois modelos com dono”. Recorte de hotel, não de task.

**Na entrevista:**
> "Dois resources. Owner e Pet. HTML. Scoped no user logado. Pet aponta para um owner do mesmo user."

---

## Maria é dona. João opera

**O que é:**
`User` não é o dono do cão. `User` é quem opera o hotel. Owner é o cliente. Pet é o animal que dorme na pousada.

**Como funciona:**
Seed: João (`joao@email.com`) entra no app. Cadastra Maria. Cadastra Thor, Luna e Bidu com `owner: maria`. João não é pai do Thor. João é a recepção.

Confundir os dois é o bug de modelagem que o entrevistador planta. “O user_id do pet é o João, então o dono é o João.” Não. `user_id` é o recorte de quem vê o cadastro. `owner_id` é a Maria.

| Papel | Quem | Tabela |
|---|---|---|
| Opera o hotel | João | `users` |
| Dona dos pets | Maria | `owners` |
| Hóspedes | Thor, Luna, Bidu | `pets` |

**Exemplo prático:**
Maria tem e-mail e telefone. Thor tem nome e espécie (`cão`). Luna é `gato`. Bidu é `cão`. Os três apontam para a mesma Maria. A Maria aponta para o João.

**Na entrevista:**
> "User é a recepção. Owner é o cliente. Pet é o animal. Thor pertence à Maria, e o cadastro inteiro pertence ao João."

---

## Associações

**O que é:**
O mapa que o Active Record usa para você não escrever JOIN na mão.

**Como funciona:**

```ruby
class User < ApplicationRecord
  has_many :owners, dependent: :destroy
  has_many :pets, dependent: :destroy
end

class Owner < ApplicationRecord
  belongs_to :user
  has_many :pets, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
end

class Pet < ApplicationRecord
  belongs_to :user
  belongs_to :owner
  has_many :stays, dependent: :destroy

  validates :name, presence: true
  validates :species, presence: true
  validate :owner_belongs_to_same_user
end
```

Pet tem dois `belongs_to`. `user` para o scope. `owner` para o cliente. Não é duplicata à toa. `current_user.pets` não precisa passar por owner. A validação customizada segura os dois `user_id` iguais.

`dependent: :destroy`: apagou a Maria, Thor, Luna e Bidu saem. Apagou o João, o cadastro inteiro da pousada sai. Stay some com o pet — próximo capítulo.

**Quando usar:**
Sempre que a pergunta for “quem pertence a quem”. No quadro: User → Owner → Pet. User → Pet também, por atalho.

**Na entrevista:**
> "Pet belongs_to user e belongs_to owner. O user_id é o recorte. O owner_id é a Maria. dependent destroy no owner leva os pets."

---

## CRUD no current_user

**O que é:**
Toda leitura e toda escrita passam por `current_user`. Não existe `Owner.find(params[:id])` neste app. Existe `current_user.owners.find(params[:id])`.

**Como funciona:**

```ruby
class OwnersController < ApplicationController
  before_action :set_owner, only: %i[show edit update destroy]

  def index
    @owners = current_user.owners.order(:name)
  end

  def create
    @owner = current_user.owners.new(owner_params)

    if @owner.save
      redirect_to @owner, notice: "Dono cadastrado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_owner
    @owner = current_user.owners.find(params[:id])
  end
end
```

PetsController é o mesmo desenho. `current_user.pets.new`. `current_user.pets.find`. Index ordena por nome.

`find` no association: o id existe no banco, mas é de outro user? `ActiveRecord::RecordNotFound`. Rails vira 404. Você não devolve 403 com o nome da Maria do hotel vizinho. 404 é o recorte certo — o recurso, para este user, não existe.

`new` na association já preenche `user_id`. O form não manda. O params não precisa. Em PHP seria um `user_id` no INSERT que você esquece e o colega cola no POST. Em Java, o service pega o principal do Spring Security. Aqui a association faz o papel.

`require_login` no `ApplicationController` já mandou quem não logou para `/login`. Este capítulo assume sessão. Sem João na session, nem chega no CRUD.

**Quando usar:**
Todo controller que lista coisa de gente logada. Padrão de entrevista. Se você escrever `Owner.all`, o entrevistador fecha o notebook.

**Importante na entrevista:**
IDOR. João autenticado. Ele chuta `/owners/99`. Se 99 é a Maria de outro hotel, `current_user.owners.find` não acha. `Owner.find` acharia. A diferença é autorização, não autenticação. Login prova quem você é. Scope prova o que você vê.

**Na entrevista:**
> "Eu nunca faço Owner.find. É current_user.owners.find. 404 se não for meu. user_id vem da association, não do form."

---

## Strong params

**O que é:**
A lista branca do que o form pode gravar. O resto do POST o Rails descarta.

**Como funciona:**

```ruby
def owner_params
  params.require(:owner).permit(:name, :email, :phone)
end

def pet_params
  params.require(:pet).permit(:name, :species, :owner_id)
end
```

Owner: nome, e-mail, telefone. Pet: nome, espécie, `owner_id`. Sem `user_id`. Sem `id`. Sem `created_at`.

O colega permit `:user_id`. O cliente manda `pet[user_id]=2` no POST. O pet nasce no hotel do vizinho — ou pior, nasce no seu index e some no dele. Association + strong params: cinto e cinto. Os dois.

`require(:owner)` explode se o POST não veio namespaced. `form_with model: owner` manda `owner[name]`. É o contrato do helper.

Validação falhou: `render :new, status: :unprocessable_entity`. 422. Form reaparece com os erros do `shared/errors`. Redirect no erro perde o objeto e o flash de validação. Entrevistador puxa isso.

**Quando usar:**
Todo create e todo update. Sem exceção. Scaffold já gera. Você precisa saber o que ficou de fora.

**Na entrevista:**
> "permit name, email, phone no owner. No pet, name, species, owner_id. user_id não entra. A association preenche."

---

## Pet e owner do mesmo user

**O que é:**
A regra de ouro do cadastro. Thor só pode ter a Maria se a Maria for do João. Owner de outro hotel não cola.

**Como funciona:**

```ruby
validate :owner_belongs_to_same_user

def owner_belongs_to_same_user
  return if owner.blank? || user.blank?
  return if owner.user_id == user_id

  errors.add(:owner, "deve pertencer ao mesmo usuário")
end
```

O form já ajuda: `collection_select` lista `current_user.owners`. João só vê a Maria. Isso é UI. UI não é autorização. O POST ainda aceita `owner_id` de outro user se alguém forjar o payload. A validação no model é o que segura.

`belongs_to :owner` já exige owner presente. `blank?` cobre o caso do select vazio — você não soma erro de user em cima do “owner é obrigatório”.

Dois `user_id` iguais. Não é “mesmo objeto”. É o integer. Maria.user_id == Thor.user_id. Os dois apontam para o João.

**Exemplo prático:**
João logado. POST `/pets` com name Thor, species cão, owner_id da Maria. Save. Ok.

Mesmo João. POST com owner_id de um owner que o seed do colega criou noutro user. `save` falha. `@pet.errors[:owner]` tem a mensagem. 422. Form de novo.

**Quando usar:**
Toda vez que um recurso aponta para outro e os dois têm `user_id`. Sem essa validação, o scope do index esconde o buraco — o pet “é seu”, o owner não.

**Na entrevista:**
> "O select só mostra meus owners. Isso é tela. A validação no Pet compara owner.user_id com user_id. Sem isso, um POST forjado amarra o Thor na Maria de outro hotel."

---

## includes para não N+1

**O que é:**
Uma query a mais no index, em vez de uma por linha. A view pede `pet.owner.name`. Sem `includes`, cada pet dispara um SELECT em owners.

**Como funciona:**

```ruby
def index
  @pets = current_user.pets.includes(:owner).order(:name)
end
```

Três pets. Sem includes: 1 query nos pets + 3 nos owners. Com includes: 1 nos pets + 1 nos owners (`WHERE id IN (...)`). João tem 200 cães no fim do mês. A conta muda.

A view não mente:

```erb
<% @pets.each do |pet| %>
  <td><%= link_to pet.name, pet %></td>
  <td><%= pet.species %></td>
  <td><%= pet.owner.name %></td>
<% end %>
```

`pet.owner` sem preload é preguiça que funciona em desenvolvimento. Em produção o log do Active Record denuncia. Bullet, se o time usa. O entrevistador pergunta “quantas queries?”. Você conta em voz alta.

Owners index não precisa de includes. A tabela mostra name, email, phone. Tudo na própria linha. Show do pet pede um owner — `find` já carregou um pet; um `belongs_to` extra não é N+1 de lista.

**Quando usar:**
Index ou qualquer loop que toca association. Show de um registro, relaxa.

**Na entrevista:**
> "Index de pets faz includes owner. A coluna dono lê pet.owner.name. Sem includes, N+1. Três pets, quatro queries. Duzentos pets, duzentas e uma."

---

## Formulário HTML

**O que é:**
`form_with` + partial. New e edit compartilham `_form.html.erb`. Sem JSON. Sem Stimulus. Sem Hotwire neste projeto.

**Como funciona:**
Owner:

```erb
<%= form_with model: owner do |f| %>
  <%= render "shared/errors", record: owner %>
  <%= f.label :name %>
  <%= f.text_field :name, required: true %>
  <%= f.label :email %>
  <%= f.email_field :email, required: true %>
  <%= f.label :phone %>
  <%= f.telephone_field :phone %>
  <%= f.submit %>
<% end %>
```

Pet acrescenta o dono:

```erb
<%= f.collection_select :owner_id, current_user.owners.order(:name), :id, :name,
                        { prompt: "Escolha o dono" } %>
```

`form_with model:` decide a rota. Owner novo → POST `/owners`. Owner persistido → PATCH `/owners/:id`. Você não escreve a URL na mão. O helper lê `persisted?`.

`required: true` no input é HTML5. O browser para antes do POST. O model também valida presence. Os dois. O browser do entrevistador com curl não tem HTML5. A validação do Active Record é a que conta.

`button_to "Remover", owner, method: :delete` no index. POST com `_method=delete`. Sem Turbo neste recorte — o form de dono ainda manda `data: { turbo: false }` no destroy. Pet index usa `button_to` simples. Os dois batem no `destroy` do controller.

Index vazio: “Nenhum dono cadastrado.” / “Nenhum pet cadastrado.” Show da Maria: e-mail, telefone, link para editar. Show do Thor: espécie, link para a Maria.

**Quando usar:**
CRUD de tela. Take-home Rails que pede HTML, não API.

**Na entrevista:**
> "form_with no model. Partial compartilhado. collection_select só com current_user.owners. Validação no model, required no input. Sem JSON neste projeto."

---

## Recapitulando

- User opera. Owner é cliente. Pet é o animal. João / Maria / Thor-Luna-Bidu.
- `current_user.owners` e `current_user.pets` em todo CRUD. `find` no association. 404 se não for seu.
- `new` na association preenche `user_id`. Strong params não permit `user_id`.
- Owner: `name`, `email`, `phone`. Pet: `name`, `species`, `owner_id`.
- Pet valida `owner.user_id == user_id`. Select é UI. Model é a regra.
- `includes(:owner)` no index de pets. `pet.owner.name` na tabela. Sem isso, N+1.
- `form_with` + `_form`. New e edit. 422 no erro. HTML, não JSON.
- `dependent: :destroy` no owner leva os pets.

---

## Exercícios práticos

### Exercício 1: O id da Maria do outro hotel

**Enunciado:** João está logado. Existe um owner id 99 no banco, cadastrado por outro `User`. João abre `/owners/99`. O controller tem `set_owner` com `current_user.owners.find(params[:id])`. O que acontece? E se um colega tivesse escrito `Owner.find(params[:id])`?

<details>
<summary>Solução</summary>

`current_user.owners.find(99)` dispara `ActiveRecord::RecordNotFound`. Rails responde 404. João não vê nome, e-mail, telefone da Maria alheia.

`Owner.find(99)` acharia. Show renderiza. IDOR. Autenticação passou — João está logado. Autorização falhou — o registro não é dele.

O mesmo buraco existe em edit, update e destroy. Por isso o `before_action :set_owner` centraliza o `find`. Um lugar. Quatro actions.

**Pontos-chave:**
- Scope no association, não `Model.find`
- 404, não 403 com payload
- Login ≠ autorização
</details>

### Exercício 2: POST com owner_id de outro user

**Enunciado:** João logado. Ele forja o POST `/pets` com `name=Thor`, `species=cão` e `owner_id` de um owner que não é dele. O `collection_select` não mostrava esse id. O `pet_params` permit `:owner_id`. O model tem `owner_belongs_to_same_user`. O pet grava?

<details>
<summary>Solução</summary>

Não. `current_user.pets.new(pet_params)` preenche `user_id` do João e `owner_id` forjado. No `save`, `owner.user_id` não bate com `user_id`. `errors.add(:owner, "deve pertencer ao mesmo usuário")`. Controller renderiza `:new` com 422.

O select mentiu por omissão: a opção não estava na tela. O POST não precisa da tela. Strong params deixou `owner_id` entrar — precisa, senão o João não amarra a Maria verdadeira. Quem fecha a porta é o `validate`.

Se a validação não existisse, o Thor nasceria “do João” no index e apontaria para um owner invisível. Show quebraria ou vazaria o nome. Os dois `user_id` divergentes.

**Pontos-chave:**
- UI não autoriza
- `owner_id` no permit é necessário e perigoso
- A comparação é `owner.user_id == user_id`
</details>

### Exercício 3: Index de pets sem includes

**Enunciado:** O index de pets lista nome, espécie e `pet.owner.name`. João tem Thor, Luna e Bidu. O action está `@pets = current_user.pets.order(:name)` — sem `includes`. Quantas queries no request? Como você corrige? Owners index precisa do mesmo?

<details>
<summary>Solução</summary>

Quatro. Uma em `pets` (`WHERE user_id = João`). Três em `owners`, uma por `pet.owner` no loop. N+1 clássico: 1 + N.

Correção:

```ruby
@pets = current_user.pets.includes(:owner).order(:name)
```

Duas queries. Pets do João. Owners cujo id está nesse conjunto. A view continua `pet.owner.name`. Não muda ERB. Muda o preload.

Owners index não precisa. A tabela lê colunas do próprio owner. Sem association no loop, não há N+1 para includes matar.

**Pontos-chave:**
- Contar queries em voz alta
- `includes` no index que toca association
- Show de um pet não é N+1 de lista
</details>

---

*Parte do [Ruby Projects Handbook](/)*
