# 3.7 Request specs

> **TL;DR**
> Três arquivos em `spec/requests/`. HTTP de verdade, `as: :json`, header Bearer. Não é model spec. Não é Capybara. Auth, CRUD do João, 404 da Ana, duas `checked_in`, occupancy, `total_cents`. Sem FactoryBot. Sem coverage theatre. O 2 testava redirect. Este testa status e chave do JSON.

## Conteúdo

- [O que muda em relação ao 2](#o-que-muda-em-relação-ao-2)
- [as: :json](#as-json)
- [auth_headers](#auth_headers)
- [Os três arquivos](#os-três-arquivos)
- [Sem FactoryBot](#sem-factorybot)
- [O que não entra](#o-que-não-entra)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que muda em relação ao 2

**O que é:**
A mesma camada. Request spec. Troca o assert.

**Como funciona:**

| 2 (HTML) | 3 (JSON) |
|---|---|
| `post login_path` | `post "/api/v1/login", as: :json` |
| cookie de session | `Authorization: Bearer` |
| `redirect_to` | `have_http_status(:created)` |
| `response.body.include?("Thor")` | `json_body["pet_name"]` |
| 422 no form | 422 com `errors` |

Ainda sobe o stack Rails. Ainda não abre Chrome.

**Quando usar:**
Fluxo que atravessa HTTP. Login. Recorte por user. JSON que o payload pode esquecer.

**Na entrevista:**
> "Request spec. Eu bato o header e leio o JSON. Não é model spec do token. Não é system spec — não tem tela."

---

## as: :json

**O que é:**
O helper do RSpec Rails. Seta `Content-Type` e serializa o Hash em JSON.

**Como funciona:**

```ruby
post "/api/v1/login",
     params: { email: "joao@email.com", password: "senha123" },
     as: :json
```

Sem `as: :json`, o spec manda form. O controller pode até funcionar. O contrato do README é JSON. O spec tem que mentir menos que o curl.

**Quando usar:**
Todo post/patch deste app. GET também aceita, seta `Accept`.

**Na entrevista:**
> "as: :json. Senão eu testo form-encoded e vendo API."

---

## auth_headers

**O que é:**
Helper no `rails_helper`. Monta o Bearer. No 2 era `login_as` que dava POST no login.

**Como funciona:**

```ruby
def auth_headers(user)
  { "Authorization" => "Bearer #{user.api_token}" }
end

def json_body
  JSON.parse(response.body)
end
```

`User.create!` já gera o token. Você não precisa logar para testar occupancy — cola o token. O spec de auth testa o login de verdade. Os outros assumem o token. Recorte: não repetir o POST de login em todo example.

**Exemplo prático:**
`get "/api/v1/occupancy", headers: auth_headers(joao), as: :json`.

**Na entrevista:**
> "O spec de auth bate o login. O spec de CRUD cola o Bearer. Eu não pago um POST extra em todo example."

---

## Os três arquivos

**O que é:**
Os mesmos três temas do 2. Envelope diferente.

**Como funciona:**

`authentication_spec.rb` — signup 201 com token, senha curta 422, logout 204 e token velho 401, login devolve token novo, occupancy 200 `[]`. Senha errada 401.

`crud_spec.rb` — sem token 401 nos GETs. João cria owner, pet, stay. Location no create. `nights` 3, `total_cents` 24000. Ana pede o owner do João: 404.

`stays_and_occupancy_spec.rb` — duas `checked_in` 422. Occupancy só Thor, não Luna. Show da stay traz virtuais. check_in / check_out mudam `status` no JSON.

**Quando usar:**
Estes fluxos. Não um spec por action.

**Na entrevista:**
> "Três arquivos. Auth, CRUD, regra de stay. Coverage theatre seria um describe por coluna."

---

## Sem FactoryBot

**O que é:**
`User.create!` no example. Igual o 2. A história cabe em quatro linhas.

**Como funciona:**

```ruby
def create_hotel
  joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
  maria = joao.owners.create!(name: "Maria", email: "maria@email.com", phone: "(11) 99999-0000")
  thor = joao.pets.create!(name: "Thor", species: "cão", owner: maria)
  luna = joao.pets.create!(name: "Luna", species: "gato", owner: maria)
  [joao, maria, thor, luna]
end
```

Factory de Stay com trait `:checked_in` esconderia o enum. Aqui o enum aparece.

**Na entrevista:**
> "Sem FactoryBot. O create! mostra a associação. O entrevistador lê o spec e vê o domínio."

---

## O que não entra

**O que é:**
A lista. Request spec não é tudo.

**Como funciona:**
Model spec do `nights` — o 2 já justificou ficar de fora; o JSON spec cobre o valor no body. System spec — sem tela. Request spec de 404 de toda action — um example da Ana no owner chega.

Schema matcher, swagger, rswag: gem. Recorte: três arquivos.

**Na entrevista:**
> "Eu testo o contrato que o curl usa. Não gero OpenAPI neste take-home."

---

## Recapitulando

- Request spec, `as: :json`, Bearer
- Três arquivos, mesmos fluxos do 2
- `json_body` em vez de HTML
- Sem FactoryBot, sem Capybara
- Auth testa login; o resto cola o token

---

## Exercícios práticos

### Exercício 1: Spec sem as: :json

**Enunciado:** O create de owner passa no spec e falha no curl. Primeira suspeita?

<details>
<summary>Solução</summary>

Spec mandou form-encoded. Controller leu `params[:owner]`. curl mandou JSON sem o Rails parsear igual. `as: :json` alinha os dois. Segunda suspeita: `Content-Type` no README.

**Pontos-chave:**
- spec tem que falar a mesma língua do curl
- form ≠ JSON
- 400 no curl, 201 no spec = header
</details>

### Exercício 2: Token hard-coded

**Enunciado:** Você colou `Bearer abc` no spec porque o seed sempre gera o mesmo? O que quebra?

<details>
<summary>Solução</summary>

`has_secure_token` gera aleatório. Seed regenera. Spec que depende de string fixa flicker. `auth_headers(user)` lê `user.api_token` depois do `create!`. Sem seed no test — transactional fixtures, banco limpo.

**Pontos-chave:**
- token não é senha123
- create! já preenche
- test não usa o sqlite do development
</details>

---

*Parte do [Ruby Projects Handbook](/)*
