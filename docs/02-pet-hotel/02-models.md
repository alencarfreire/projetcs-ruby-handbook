# 2.2 Models e migrations

> **TL;DR**
> No projeto 1 o “model” era um Hash no processo. Aqui é Active Record + SQLite. Quatro tabelas: User, Owner, Pet, Stay. `User has_many` owners, pets e stays. Pet `belongs_to` owner e user. Stay `belongs_to` pet e user. Status é enum inteiro. Diária é `nightly_rate_cents` — Integer, nunca Float. Reiniciou o servidor, Thor continua hospedado.

## Conteúdo

- [Do Hash à tabela](#do-hash-à-tabela)
- [Os quatro models](#os-quatro-models)
- [Associations](#associations)
- [Migrations e indexes](#migrations-e-indexes)
- [Enum status](#enum-status)
- [Centavos, nunca Float](#centavos-nunca-float)
- [schema.rb não se edita](#schemarb-não-se-edita)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Do Hash à tabela

**O que é:**
A troca que o projeto 2 faz de propósito. `@tasks[1] = { "title" => "..." }` vira `Stay.create!(...)`. A linha vive no SQLite. Mata o `rails s`, o Thor continua `checked_in`.

**Como funciona:**

| Onde | O que é o “model” | Quando some |
|---|---|---|
| Projeto 1 (Ruby puro) | Hash na instância | processo morre |
| Java (`HttpServer`) | `List` no handler | JVM morre |
| Eloquent (Laravel) | classe + tabela | não some no restart |
| JPA (`@Entity`) | classe + tabela | não some no restart |
| Aqui | Active Record + SQLite | não some no restart |

Active Record é o ORM do Rails. Você fala em Ruby, ele monta SQL. Eloquent faz o mesmo no Laravel: `$stay->pet`. JPA faz com annotation: `@ManyToOne`. Três nomes, a mesma ideia: objeto na RAM, linha no banco.

No projeto 1 não tinha classe `Task`. O Hash era o recurso. Aqui cada tabela tem uma classe em `app/models/`. Sem classe, sem `has_many`. Sem `has_many`, o controller vira SQL na mão — e a entrevista puxa exatamente isso.

**Quando usar:**
Quando o dado precisa sobreviver ao reboot. Hotel de pet não é live coding de Hash.

**Na entrevista:**
> "No projeto 1 o store era Hash. Aqui é tabela. Active Record, igual Eloquent, igual JPA. Reiniciou, Thor continua no hotel."

---

## Os quatro models

**O que é:**
O domínio da Pousada do Thor. Não é Task. Não é seis models. Quatro.

**Como funciona:**

| Model | Papel | Exemplo |
|---|---|---|
| `User` | quem opera o hotel | João |
| `Owner` | dono do pet (cliente) | Maria |
| `Pet` | o hóspede | Thor, Luna, Bidu |
| `Stay` | a hospedagem | check-in, diária, status |

João faz login. Maria não tem senha neste app — ela é cadastro do João. Thor pertence à Maria. A stay pertence ao Thor e ao João.

`User` ainda carrega `has_secure_password`. A coluna é `password_digest`, não `password`. Auth é o capítulo seguinte. Aqui o ponto é: o tenant de tudo é o `user_id`.

Herdam de `ApplicationRecord`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

No JPA seria `@MappedSuperclass`. No Eloquent, `Model`. Classe abstrata, sem tabela própria.

**Quando usar:**
Recorte de domínio. Entrevistador pede “sistema de hotel”. Você desenha esses quatro no quadro. Não começa por Devise.

**Exemplo prático:**
Seed real em `db/seeds.rb`: João, Maria, Thor/Luna/Bidu. Diária do Thor: `8000` centavos — R$ 80,00.

**Na entrevista:**
> "User opera. Owner é o cliente. Pet é o hóspede. Stay é a reserva. Quatro tabelas. Sem Task neste projeto."

---

## Associations

**O que é:**
O mapa de quem aponta para quem. Sem isso o `current_user.pets` não existe — você faria `Pet.where(user_id: id)` em todo controller.

**Como funciona:**

`User` é a raiz. Três `has_many`, todos com `dependent: :destroy`:

```ruby
class User < ApplicationRecord
  has_many :owners, dependent: :destroy
  has_many :pets, dependent: :destroy
  has_many :stays, dependent: :destroy
end
```

Apagou o João, apagou os donos, os pets e as stays. No Eloquent: `$user->pets()` + `onDelete('cascade')`. No JPA: `@OneToMany(cascade = CascadeType.REMOVE)`. Aqui o `dependent` é Ruby. O `foreign_key` na migration é SQL.

Pet tem dois `belongs_to`. Não é redundância. É isolamento:

```ruby
class Pet < ApplicationRecord
  belongs_to :user
  belongs_to :owner
  has_many :stays, dependent: :destroy
end
```

`owner` diz quem é a Maria. `user` diz que esse pet é do hotel do João. A validação `owner_belongs_to_same_user` impede o João de pendurar o Thor num Owner da Maria de outro User.

Stay aponta para pet e user. O dono vem de graça:

```ruby
class Stay < ApplicationRecord
  belongs_to :user
  belongs_to :pet
  has_one :owner, through: :pet
end
```

`stay.owner` é `stay.pet.owner`. Sem coluna `owner_id` em stays. No JPA seria `@ManyToOne Pet pet` e um getter que navega. No Hash do projeto 1 você duplicava o campo no valor — não tinha association.

**Quando usar:**
Toda query do app. Lista de pets do João: `current_user.pets`. Não `Pet.all`.

**Importante na entrevista:**
`belongs_to :user` em Owner, Pet e Stay. Multi-tenant raso. Sem Pundit. O recorte é: o user logado só vê a linha dele.

**Na entrevista:**
> "User has_many owners, pets e stays. Pet belongs_to owner e user. Stay belongs_to pet e user. Owner da stay é through pet. dependent destroy na raiz."

---

## Migrations e indexes

**O que é:**
O histórico do schema em Ruby. Cada arquivo em `db/migrate/` é um passo. Roda uma vez. O banco muda. O `schema.rb` reflete o resultado.

**Como funciona:**
Quatro migrations, nesta ordem. Users primeiro — o resto referencia `user_id`.

```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
```

Index unique no email. Dois Joãos com o mesmo email não entram. Validação no model é a primeira linha. Unique no banco é a que o entrevistador quer ouvir: duas requests ao mesmo tempo furam o `validates :uniqueness` sozinho.

`t.references :user, null: false, foreign_key: true` cria `user_id`, index e FK. Pets e stays fazem o mesmo:

```ruby
t.references :user, null: false, foreign_key: true
t.references :owner, null: false, foreign_key: true
```

```ruby
t.references :user, null: false, foreign_key: true
t.references :pet, null: false, foreign_key: true
```

No schema isso vira:

```ruby
t.index ["user_id"], name: "index_pets_on_user_id"
t.index ["owner_id"], name: "index_pets_on_owner_id"
add_foreign_key "pets", "owners"
add_foreign_key "pets", "users"
```

Sem index em `user_id`, `current_user.pets` vira full scan. No Postgres dói. No SQLite deste app ainda é o hábito certo. Eloquent: `$table->foreignId('user_id')->constrained()`. JPA: `@JoinColumn(nullable = false)` + index na mão ou no Hibernate.

**Quando usar:**
Antes do model “funcionar de verdade”. Classe sem tabela é teatro. `bin/rails db:migrate` — aí existe coluna.

**Exemplo prático:**
`null: false` nas FKs e no `nightly_rate_cents`. Stay sem pet não existe. Stay sem diária não existe. O banco recusa, não só o `validates`.

**Na entrevista:**
> "Migration cria tabela, index e FK. Unique no email. t.references já faz user_id + index. Validação no model não substitui unique no banco."

---

## Enum status

**O que é:**
Inteiro no SQLite. Nome no Ruby. Stay não guarda a string `"checked_in"`. Guarda `1`.

**Como funciona:**

```ruby
enum :status, { scheduled: 0, checked_in: 1, checked_out: 2 }
```

Na migration:

```ruby
t.integer :status, null: false, default: 0
```

Default `0` = `scheduled`. Predicados de graça: `stay.checked_in?`. Scopes de graça: `Stay.checked_in`. O Hash do projeto 1 não tinha isso — você comparava string no valor.

No JPA: `@Enumerated(EnumType.ORDINAL)` — mesmo perigo, mesmo ganho. String no banco (`EnumType.STRING` / coluna `string` no Rails) é mais legível no SQL cru. Inteiro é o recorte da Pousada: três estados, sem rename no meio do caminho.

A regra de ocupação mora no model, não na view:

```ruby
def only_one_checked_in_stay_per_pet
  return unless checked_in?
  clash = Stay.where(pet_id: pet_id, status: :checked_in)
  clash = clash.where.not(id: id) if persisted?
  return unless clash.exists?
  errors.add(:pet, "já está hospedado — só uma stay checked_in por vez")
end
```

Thor `checked_in` duas vezes: inválido. Luna `scheduled` + Thor `checked_in`: ok. Tela de ocupação lê `Stay.checked_in`. Sem enum, você filtra string e erra o typo.

**Quando usar:**
Conjunto fechado. Três estados. Não use enum para espécie do pet — `cão` / `gato` é string. Status de stay é máquina de estado rasa.

**Na entrevista:**
> "Status é integer 0, 1, 2. enum no model. checked_in? e Stay.checked_in de graça. Um pet, uma stay checked_in. A regra está no model."

---

## Centavos, nunca Float

**O que é:**
Dinheiro como inteiro. `nightly_rate_cents`. R$ 80,00 vira `8000`. Sem `80.0`. Sem `BigDecimal` neste recorte.

**Como funciona:**

```ruby
t.integer :nightly_rate_cents, null: false
```

```ruby
validates :nightly_rate_cents, presence: true,
                               numericality: { only_integer: true, greater_than: 0 }

def nights
  (check_out.to_date - check_in.to_date).to_i
end

def total_cents
  nights * nightly_rate_cents.to_i
end
```

Check-in hoje, check-out daqui a 3 dias: `nights == 3`. `8000 * 3 = 24000`. Integer vezes integer. Float de dinheiro é o bug clássico: `0.1 + 0.2 != 0.3`. Java cai no mesmo com `double`. PHP também. JPA usa `BigDecimal` ou centavos. Eloquent costuma `integer` na coluna. Aqui: coluna integer, método integer, seed integer.

Mínimo uma diária. `check_out > check_in`. Tudo no model. A view só formata.

**Quando usar:**
Qualquer preço. Diária, multa, total. Se a entrevista puxar “por que não decimal?”, você fala Float e para.

**Exemplo prático:**
Seed: Thor `8000`, Luna `7000`. João não digita `80.00`. O form manda centavos. Capítulo de views mostra a tela. Aqui o contrato é: o banco não conhece vírgula.

**Na entrevista:**
> "nightly_rate_cents é integer. total_cents = nights * rate. Nunca Float. 0.1 + 0.2 não é 0.3 — em Ruby, em Java, em PHP."

---

## schema.rb não se edita

**O que é:**
O retrato atual do banco. Rails gera. Você commita. Não escreve na mão.

**Como funciona:**
`db:migrate` aplica o arquivo novo e reescreve `schema.rb`. `db:schema:load` monta o banco do zero a partir desse retrato — mais rápido, sem replay de quatro migrations. Banco novo de teste usa isso.

Olhe o que o retrato garante e o model não inventa:

- `password_digest`, não `password`
- `status` integer, default 0
- `nightly_rate_cents` integer
- indexes em `user_id`, `owner_id`, `pet_id`
- unique em `users.email`
- FKs de owners/pets/stays para users, pets para owners, stays para pets

Se o schema e o model divergem, o schema ganha no `INSERT`. `has_many` sem coluna é NoMethodError bonito. Coluna sem `has_many` ainda funciona — SQL cru. Association é açúcar. Schema é o chão.

**Quando usar:**
Review de PR. Diff de `schema.rb` mostra o que o banco realmente ganhou. Diff só do model não.

**Na entrevista:**
> "schema.rb é gerado. Eu não edito. Unique, FK e integer de centavos estão lá. O model mapeia. O banco manda."

---

## Recapitulando

- Projeto 1: Hash. Projeto 2: Active Record + SQLite. Igual Eloquent, igual JPA. Reiniciou, ficou.
- Quatro models: User, Owner, Pet, Stay.
- `User has_many` owners/pets/stays com `dependent: :destroy`.
- Pet `belongs_to` owner e user. Stay `belongs_to` pet e user. Owner da stay é `through: :pet`.
- Migration cria tabela, `t.references`, unique no email, FK.
- Enum: `scheduled` 0, `checked_in` 1, `checked_out` 2. Um pet, uma stay `checked_in`.
- `nightly_rate_cents` integer. `total_cents` integer. Nunca Float.
- `schema.rb` não se edita. Código em `projects/02-pet-hotel`.

---

## Exercícios práticos

### Exercício 1: Por que Pet tem user_id e owner_id?

**Enunciado:** Um colega diz que `pets.user_id` é redundante — o user já vem de `owner.user_id`. Você tira a coluna. O que quebra na entrevista e no app?

<details>
<summary>Solução</summary>

`current_user.pets` deixa de ser um `has_many` direto. Vira `Pet.joins(:owner).where(owners: { user_id: id })`. Toda lista, todo `includes`, todo `dependent: :destroy` no User complica.

Pior: a validação `owner_belongs_to_same_user` some com a coluna. João pode apontar o Thor para um Owner de outro hotel se o form mandar o `owner_id` errado. Com `user_id` na linha do pet, o tenant está na própria tabela.

No Hash do projeto 1 você duplicava o campo no valor — não tinha join. Aqui duplicar `user_id` é o recorte de isolamento, não denormalização acidental.

**Pontos-chave:**
- `user_id` no Pet é tenant, não cache
- `belongs_to :user` e `:owner` juntos
- validação `owner.user_id == user_id`
</details>

### Exercício 2: A diária veio 80.0

**Enunciado:** O form manda `nightly_rate_cents: 80.0`. A stay tem 3 noites. O colega mudou a coluna para `decimal` e o método para `nights * nightly_rate`. O que você fala e o que você faz?

<details>
<summary>Solução</summary>

Você não aceita. `80.0` não é centavo — é real com Float. `0.1 + 0.2` em Ruby, Java (`double`) e PHP não dá `0.3`. Três noites vezes um float “quase 80” vira centavo errado no total.

A coluna continua integer. O form manda `8000`. `total_cents` continua `nights * nightly_rate_cents.to_i` — `24000`.

```ruby
validates :nightly_rate_cents,
          numericality: { only_integer: true, greater_than: 0 }
```

`only_integer` recusa `80.0`. No JPA a analogia honesta é `long cents` ou `BigDecimal`. Neste app: integer. Sem gem de money.

**Pontos-chave:**
- centavos, não reais
- Integer vezes Integer
- validação `only_integer` + coluna integer
</details>

### Exercício 3: Thor já está checked_in

**Enunciado:** Thor tem stay `checked_in`. João abre outra stay do Thor e manda `status: checked_in`. O que o model faz? Compare com um Hash `{ "status" => "checked_in" }` no projeto 1 e com um `@Enumerated` no JPA.

<details>
<summary>Solução</summary>

`save` falha. `only_one_checked_in_stay_per_pet` busca outra stay do mesmo `pet_id` com `status: :checked_in`. Acha. `errors.add` no pet. A tela mostra o erro. Não entra linha.

No projeto 1 o Hash aceitava o segundo valor. Não tinha uniqueness de domínio. Você mesmo faria o `any?`. Aqui o enum dá `checked_in?` e o `where(status: :checked_in)` usa o inteiro `1`.

JPA: `@Enumerated(ORDINAL)` também guarda 0/1/2. A regra “um checked_in por pet” não vem de graça — vira constraint ou serviço. Rails pôs no model. Recorte: validação na Stay, não na view.

Luna `scheduled` no mesmo fim de semana não bloqueia. Só `checked_in` duplicado.

**Pontos-chave:**
- enum é inteiro + predicado
- a regra vive no model
- Hash do projeto 1 não tinha essa trava
</details>

---

*Parte do [Ruby Projects Handbook](/)*
