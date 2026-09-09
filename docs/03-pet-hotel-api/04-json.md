# 3.4 JSON de owners, pets, stays

> **TL;DR**
> Hash explícito no concern `Payloads`. Owner, pet, stay — o cliente recebe chave que você escolheu. Stay leva `nights` e `total_cents`. User no login leva `token`. Nunca `render json: user`. CRUD no namespace. 201 + Location no create. 204 no delete.

## Conteúdo

- [O concern Payloads](#o-concern-payloads)
- [Owner e pet](#owner-e-pet)
- [Stay com virtuais](#stay-com-virtuais)
- [includes para não N+1](#includes-para-não-n1)
- [Create, update, delete](#create-update-delete)
- [strong params iguais ao 2](#strong-params-iguais-ao-2)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O concern Payloads

**O que é:**
Um módulo com quatro métodos. Monta o Hash. Sem gem. Sem partial. O entrevistador lê o Hash e vê o contrato.

**Como funciona:**

```ruby
def stay_payload(stay)
  {
    id: stay.id,
    pet_id: stay.pet_id,
    pet_name: stay.pet&.name,
    owner_id: stay.owner&.id,
    owner_name: stay.owner&.name,
    check_in: stay.check_in,
    check_out: stay.check_out,
    nightly_rate_cents: stay.nightly_rate_cents,
    nights: stay.nights,
    total_cents: stay.total_cents,
    status: stay.status
  }
end
```

`user_payload(user, token: false)` — o flag decide se o token viaja. Occupancy não pede token. Login pede.

**Quando usar:**
Todo `render json:`. Um método por recurso. Se crescer demais, aí sim serializer. Recorte: quatro hashes.

**Na entrevista:**
> "Eu monto o Hash. A gem de serializer esconde a chave. Na entrevista eu quero que o entrevistador veja nights no payload."

---

## Owner e pet

**O que é:**
CRUD raso. Lista do `current_user`. Show de um. Create 201. Update 200. Delete 204.

**Como funciona:**
`OwnersController#index`:

```ruby
owners = current_user.owners.order(:name)
render json: owners.map { |owner| owner_payload(owner) }
```

Pet inclui `owner_name` para o cliente não fazer segundo GET. Recorte: denormaliza o nome, não o dono inteiro.

**Exemplo prático:**
`POST /api/v1/pets` com `owner_id` de outro user. O model valida `owner_belongs_to_same_user`. 422. A API não é furo da regra.

**Na entrevista:**
> "current_user.pets. O recorte por user é o mesmo do HTML. JSON não alarga o domínio."

---

## Stay com virtuais

**O que é:**
`nights` e `total_cents` não são coluna. São método. O JSON os inclui. O cliente não multiplica.

**Como funciona:**
Três diárias, 8000 centavos: `total_cents` 24000. A chave no JSON é integer. Sem `"R$ 240,00"` — formatação é do cliente. A API fala centavos, igual o banco.

`status` sai string `"checked_in"`, não `1`. Enum do Rails. O cliente não decodifica inteiro.

**Quando usar:**
Sempre que o valor é regra de negócio. Dinheiro, diária, status.

**Na entrevista:**
> "nights e total_cents no JSON. Integer. O app não faz conta de diária. Se fizer, erra o fuso."

---

## includes para não N+1

**O que é:**
`stay_payload` lê `stay.pet` e `stay.owner`. Sem `includes`, a lista de stays dispara query por linha.

**Como funciona:**

```ruby
stays = current_user.stays.includes(:pet, :owner).order(check_in: :desc)
```

Occupancy igual, filtrando `checked_in`. O 2 já fazia isso na view. A API esconde menos: o Hash **acessa** a associação na sua cara.

**Quando usar:**
Toda lista que o payload toca associação. Show de um também `includes` no `find` — barato, consistente.

**Na entrevista:**
> "includes no index. O payload lê pet.name. Sem includes é N+1. Bullet gem não entra neste recorte — eu leio o log."

---

## Create, update, delete

**O que é:**
Os três status que o entrevistador puxa. 201 criou. 200 atualizou. 204 apagou.

**Como funciona:**

```ruby
if owner.save
  render json: owner_payload(owner),
         status: :created,
         location: api_v1_owner_url(owner)
else
  render_errors(owner)
end
```

`render_errors` manda `{ errors: record.errors.full_messages }` 422. Array de string, não hash de coluna. O cliente curl lê uma frase.

Delete: `head :no_content`. Body vazio. 204. `GET` depois: 404.

**Exemplo prático:**
POST owner sem nome. 422. `errors` inclui a mensagem em pt-BR do locale. `Owner.count` não sobe.

**Na entrevista:**
> "201 Location no create. 204 sem body no delete. 422 com full_messages. Eu não devolvo 200 para tudo."

---

## strong params iguais ao 2

**O que é:**
A mesma permit list. JSON não é desculpa para aceitar `user_id`.

**Como funciona:**

```ruby
params.require(:stay).permit(:pet_id, :check_in, :check_out, :nightly_rate_cents, :status)
```

Cliente manda `{ "stay": { ... } }`. Sem o wrapper, `require(:stay)` 400. Documente no README.

`user_id` não entra. `current_user.stays.new` puxa o user. Se o JSON mandar outro `user_id`, some no permit.

**Na entrevista:**
> "strong params não mudou. O JSON não autoriza. current_user autoriza."

---

## Recapitulando

- Hash explícito, sem gem
- Stay leva virtuais em integer
- includes nas listas
- 201 / 200 / 204 / 422
- permit list igual ao HTML

---

## Exercícios práticos

### Exercício 1: Cliente multiplica

**Enunciado:** O app mobile calcula `nights` no device e manda `total_cents` no POST. Você aceita a chave?

<details>
<summary>Solução</summary>

Não. `permit` não inclui `total_cents`. Não é coluna. O model calcula. Se você persistir o total, o cliente manda 1 real e você fatura 1 real. Fonte é o servidor.

**Pontos-chave:**
- virtuais não são input
- dinheiro não vem do cliente
- permit é a cerca
</details>

### Exercício 2: Lista sem includes

**Enunciado:** `GET /api/v1/stays` com 30 hospedagens. Log mostra 61 queries. O que aconteceu?

<details>
<summary>Solução</summary>

1 da lista + 30 pets + 30 owners. `stay_payload` lê as duas associações. `includes(:pet, :owner)` — `has_one :owner, through: :pet` já está no model. Uma ou duas queries. Você olha o log, não chuta cache.

**Pontos-chave:**
- payload que lê associação exige includes
- N+1 não é privilégio de ERB
- log > gem neste recorte
</details>

---

*Parte do [Ruby Projects Handbook](/)*
