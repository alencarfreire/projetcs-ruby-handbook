# 2.7 Request specs

> **TL;DR**
> Três arquivos em `spec/requests/`. Cada um bate HTTP de verdade: rota, session, controller, model, HTML. Não é model spec. Não é Capybara. Auth, CRUD do João, duas `checked_in` no mesmo pet, ocupação, `total_cents`. Sem FactoryBot. Sem coverage theatre. No PHP isso é Feature test. No Spring é MockMvc.

## Conteúdo

- [Request spec, model spec, system spec](#request-spec-model-spec-system-spec)
- [Por que estes fluxos](#por-que-estes-fluxos)
- [rails_helper e login_as](#rails_helper-e-login_as)
- [Sem FactoryBot](#sem-factorybot)
- [Sem coverage theatre](#sem-coverage-theatre)
- [Auth: cadastro, login, logout](#auth-cadastro-login-logout)
- [CRUD autenticado e recorte](#crud-autenticado-e-recorte)
- [Duas checked_in no mesmo pet](#duas-checked_in-no-mesmo-pet)
- [Ocupação só quem está no hotel](#ocupação-só-quem-está-no-hotel)
- [total_cents em centavos](#total_cents-em-centavos)
- [PHP Feature tests e MockMvc](#php-feature-tests-e-mockmvc)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Request spec, model spec, system spec

**O que é:** três camadas. O hotel usa uma. As outras duas existem — e neste recorte ficam de fora.

**Como funciona:**

| Tipo | O que bate | O que não bate | Neste hotel |
|---|---|---|---|
| Model spec | `Stay` sozinho: validação, `nights`, `total_cents` | rota, session, HTML | não entra |
| Request spec | HTTP: `get`, `post`, cookie, redirect, body | browser, JS | os três arquivos |
| System spec | Capybara, clique, JS | barato | Hotwire não entra — spec também não |

Request spec sobe o stack Rails. Você manda `POST /stays`. O router acha o controller. A session decide se João está logado. O model valida. A view devolve HTML ou o controller redireciona. Sem abrir Chrome.

Model spec é o `StayTest` do JUnit: `new Stay(...)`, `valid?`, ponto. Rápido. Não prova que o form chega no model. System spec é o Cypress da casa: clique no botão, espera o DOM. Sem Hotwire, sem Stimulus, o clique não adiciona regra. Custa boot. Fica de fora.

**Quando usar:** fluxo que atravessa HTTP. Login. Recorte por user. Regra que o controller pode furar se só o model souber.

**Na entrevista:**
> "Model spec testa o Stay. Request spec testa o POST. System spec testa o clique. Aqui eu tenho request spec nos fluxos. Sem Capybara — não tem JS."

---

## Por que estes fluxos

**O que é:** o recorte do GUIDE. “RSpec request spec nos fluxos principais.” Não é “um spec por action”.

**Como funciona:** cinco coisas quebram o hotel se falharem.

1. Auth — cadastro, login, logout, senha curta.
2. CRUD sem login — guest não cria dono, pet, stay.
3. CRUD do João — owner, pet e stay nascem no `user` dele. `total_cents` fecha.
4. Duas `checked_in` no mesmo pet — 422. Continua uma.
5. Ocupação — Thor `checked_in` aparece. Luna `scheduled` não.

Se o cadastro aceita `"curta"`, o bcrypt não vale. Se o guest POST em `/owners` grava, a session é teatro. Se Thor entra duas vezes, a tela mente. Se Luna `scheduled` aparece em `/`, o index não filtra. Se 3 diárias a R$ 80 viram `240.0`, você misturou Float.

O resto é ruído. `GET /owners/new` devolve 200? O form existe. Não é regra de negócio.

**Quando usar:** quando o entrevistador perguntar “o que você testa?”. Você lista os cinco. Não lista o coverage.

**Na entrevista:**
> "Eu testo o que quebra o hotel. Auth, recorte do user, uma checked_in por pet, ocupação, centavos. Não testo o new do form."

---

## rails_helper e login_as

**O que é:** o boot do RSpec Rails. `spec/rails_helper.rb` carrega o app, trava o schema, inclui um helper só no `type: :request`.

**Como funciona:** `require "rails_helper"` em cada arquivo. `RAILS_ENV=test`. `ActiveRecord::Migration.maintain_test_schema!` — migration pendente aborta, não passa no silêncio. `use_transactional_fixtures = true` — cada example abre transação e dá rollback. Igual `RefreshDatabase` no Laravel. Banco limpo sem truncate a cada `it`.

`infer_spec_type_from_file_location!` está comentado. O tipo não vem da pasta. Você escreve `type: :request`. Explícito. O mixin `get` / `post` / `delete` só entra com esse metadata.

`login_as` mora no helper:

```ruby
def login_as(user, password: "senha123")
  post login_path, params: { email: user.email, password: password }
end
```

POST de verdade. Cookie de sessão. Não é `sign_in` do Devise. Não é stub de `current_user`. No PHP: `$this->actingAs($user)` — atalho que injeta o user. Aqui o caminho é o mesmo do browser: form, session, `require_login`.

**Quando usar:** todo example que precisa de João logado. Auth em si não chama `login_as` no começo — o fluxo *é* o login.

**Exemplo prático:** `crud_spec.rb` cria o João com `User.create!` e chama `login_as(joao)`. Os POSTs seguintes já vão com cookie.

**Na entrevista:**
> "login_as é um POST em /login. Mesmo caminho do form. Não mocko current_user. Transactional fixtures limpam o banco no fim do example."

---

## Sem FactoryBot

**O que é:** decisão. A gem não está no Gemfile. Os specs usam `create!` e associação.

**Como funciona:**

```ruby
joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
maria = joao.owners.create!(name: "Maria", email: "maria@email.com", phone: "(11) 99999-0000")
thor = joao.pets.create!(name: "Thor", species: "cão", owner: maria)
```

Você lê o setup e sabe o que está no banco. FactoryBot esconde atributo. `create(:stay)` — qual status? Qual `user`? Qual pet? O próximo dev muda o default, o spec verde mente.

No Laravel a tentação é `User::factory()->create()`. No Spring, `@Autowired TestEntityManager` + builder. Os dois servem quando o grafo é enorme. Aqui o grafo é João, Maria, Thor, Luna. Quatro linhas.

`create_hotel` em `stays_and_occupancy_spec.rb` não é factory. É um método do arquivo. Devolve o array. Sem gem. Sem `spec/factories`.

**Quando usar:** sempre neste projeto. Factory entra quando o setup vira parágrafo — e mesmo aí, o default tem que ser óbvio.

**Importante na entrevista:** “não uso FactoryBot” não é purismo. É o recorte. Você sabe o que a gem faz. Escolheu não puxar.

**Na entrevista:**
> "Sem FactoryBot. User.create! com os campos na cara. O entrevistador lê o spec e sabe o hotel."

---

## Sem coverage theatre

**O que é:** spec que existe para o percentual subir. Não para uma regra.

**Como funciona:** coverage theatre é `it "GET /pets/new devolve 200"` cinco vezes. É testar `nights` no model, no request, no helper e no view. É um arquivo por controller action porque o gerador criou.

Três arquivos. Sete examples. Auth tem dois: fluxo feliz e senha curta. CRUD tem dois: guest bloqueado e João cria o grafo. Stays tem três: conflito, ocupação, dinheiro.

O que não está:

- spec de `OwnersController#edit`
- spec de strong params isolado
- spec de `nights` sem HTTP — isso é model, e o request já fecha `3 * 8000 = 24_000`
- SimpleCov no README para parecer sênior

O projeto 1 testa com curl. Este testa com RSpec porque tem session, recorte e validação que o curl do README não segura na CI. Ainda assim: raso no que é óbvio, fundo no que mente.

**Quando usar:** quando alguém pedir “sobe o coverage para 90”. Você pergunta qual fluxo falta. Se não falta fluxo, não falta spec.

**Na entrevista:**
> "Sete examples. Os fluxos. Coverage theatre é spec de new e de getter. Eu não escrevo."

---

## Auth: cadastro, login, logout

**O que é:** `spec/requests/authentication_spec.rb`. O user existe. A session liga e desliga. Senha curta não grava.

**Como funciona:** um `it` anda o caminho inteiro. `GET signup_path` → 200. `POST` com João, `joao@email.com`, `senha123`. Redirect para `root_path`. `follow_redirect!` — o body tem “Quem está no hotel agora”. Cadastrou e já entrou.

`DELETE logout_path` → `login_path`. `POST login_path` de novo → `root_path`. Cookie foi, cookie voltou.

O segundo `it` manda `"curta"`. Status 422. `User.count` é 0. `has_secure_password` + validação. Sem user fantasma no banco.

**Quando usar:** regressão de auth. Mudou o `SessionsController`, este arquivo quebra.

**Exemplo prático:** o spec não checa o HTML do form campo a campo. Checa status, redirect e um texto da ocupação. Prova que a session sobreviveu ao cadastro.

**Na entrevista:**
> "Um example faz signup, vê a home, logout, login de novo. Outro recusa senha curta e conta User = 0. Não testo o label do form."

---

## CRUD autenticado e recorte

**O que é:** `spec/requests/crud_spec.rb`. Guest não passa. João cria dono, pet e stay — e o stay fecha a conta.

**Como funciona:** primeiro `it`: sem login. `GET /`, `GET/POST /owners`, `GET/POST /pets`, `GET/POST /stays`. Tudo `redirect_to(login_path)`. É o `before_action :require_login`. Um example, vários verbos. Não é um arquivo por resource.

Segundo `it`: `login_as(joao)`. POST Maria. `Owner.last.user` é o João. POST Thor com `owner_id` da Maria. POST stay: check-in hoje, check-out +3, `nightly_rate_cents: 8000`, `scheduled`. `stay.nights == 3`. `stay.total_cents == 24_000`.

O recorte está na associação. `maria.user == joao`. Não é Pundit. É `current_user.owners.create`. Se o controller fizer `Owner.create` sem user, o spec cai.

**Quando usar:** quando alguém “só para testar” tirar o `require_login`. Verde some.

**Na entrevista:**
> "Guest leva redirect no CRUD. João logado cria Maria, Thor e uma stay de 3 diárias a 8000 centavos. 24000. O owner.user é o João."

---

## Duas checked_in no mesmo pet

**O que é:** a regra do model atravessando o POST. Thor não dorme em dois quartos.

**Como funciona:** `create_hotel` monta João, Maria, Thor, Luna. Login. Uma stay `checked_in` do Thor já no banco — `joao.stays.create!`. Aí o spec manda outro `POST /stays` com o mesmo pet, mesmo status.

422. `Stay.checked_in.where(pet: thor).count` continua 1.

Se a validação existir só na view, o POST passa. Se existir só no model e o controller fizer `save!` sem tratar, o spec ainda pega o 422 — ou o 500, e você vê. O ponto: a regra não mora no HTML.

Luna existe no setup e não entra neste `it`. Setup compartilhado. Asserção estreita.

**Quando usar:** regra de domínio que o form consegue furar. Status, unicidade, recorte de pet.

**Na entrevista:**
> "Eu crio uma checked_in do Thor e POST outra. 422. Count continua 1. A regra está no model. O request prova que o controller não ignora."

---

## Ocupação só quem está no hotel

**O que é:** `GET /`. A query do `OccupancyController`: `current_user.stays.checked_in`.

**Como funciona:** Thor `checked_in`. Luna `scheduled`. GET na raiz. Body tem “Thor” e “Maria”. Não tem “Luna”.

Não é `expect(assigns(:stays))`. Isso é controller spec antigo. Você lê o HTML que o João vê. A tela mente? O spec pega.

Maria aparece porque a ocupação mostra o dono. Luna some porque `scheduled` não é “no hotel agora”. Dois asserts positivos, um negativo. O negativo é o que vale: filtro.

**Quando usar:** index com escopo. Qualquer tela que “lista os ativos”.

**Na entrevista:**
> "Ocupação é GET /. Thor checked_in aparece. Luna scheduled não. Eu leio o body. Não inspeciono a variável do controller."

---

## total_cents em centavos

**O que é:** dinheiro integer. 3 noites × 8000 = 24000. Na tela: `R$ 240,00`.

**Como funciona:** stay de 25/08/2026 a 28/08/2026. Datas fixas. Sem `Date.current` neste example — amanhã o relógio não muda a conta. `nights` 3. `total_cents` 24_000.

Aí o spec loga e faz `GET stay_path(stay)`. Body inclui `"R$ 240,00"`. Model e view no mesmo fluxo. Sem Float. Sem `80.0 * 3`.

O CRUD já tinha 3 × 8000 no POST. Aqui a data é cravada e a view entra. Não é duplicata: um prova create, o outro prova a página do stay.

**Quando usar:** qualquer campo calculado que a view formata. Centavos. Nunca `BigDecimal` escondido em string.

**Na entrevista:**
> "Centavos. 8000 vezes 3 é 24000. A página mostra R$ 240,00. Eu não uso Float em dinheiro."

---

## PHP Feature tests e MockMvc

**O que é:** o mesmo teste em três stacks. HTTP in, app, assert na response.

**Como funciona:**

| Stack | Como você bate | Auth | Isolamento |
|---|---|---|---|
| RSpec request | `get` / `post` / `delete`, `type: :request` | `login_as` = POST | transactional fixtures |
| Laravel Feature | `$this->get()`, `$this->post()` | `actingAs($user)` | `RefreshDatabase` |
| Spring MockMvc | `mockMvc.perform(post("/login"))` | `@WithMockUser` ou form | `@Transactional` |

Laravel Feature test é o primo. `assertRedirect('/login')` = `redirect_to(login_path)`. `assertSee('Thor')` = `response.body).to include("Thor")`. `assertStatus(422)` = `have_http_status(422)`. `actingAs` é mais grosso: não passa no form. Útil. Esconde o cookie. Aqui o cookie é o ponto — `has_secure_password`, sem Devise.

MockMvc é o primo Java. `status().isUnprocessableEntity()`. `content().string(containsString("Thor"))`. `@WithMockUser` também pula o login. `SecurityMockMvcRequestPostProcessors` chega mais perto do POST.

Nenhum dos três é system test. Nenhum abre browser. Os três passam do router ao banco.

**Quando usar:** quando a vaga é PHP ou Java e perguntam “você testa como no Rails?”. Você mapeia. Não traduz verbete.

**Na entrevista:**
> "Request spec é Feature test do Laravel. É MockMvc. HTTP, banco, response. actingAs e WithMockUser pulam o login. Eu faço o POST — neste app o login é regra."

---

## Recapitulando

- Request spec bate HTTP. Model spec não. System spec é browser — fora.
- Cinco fluxos: auth, guest bloqueado, CRUD do João, uma `checked_in` por pet, ocupação + centavos.
- `rails_helper`: transação por example, `type: :request` explícito, `login_as` é POST.
- Sem FactoryBot. `create!` na cara. `create_hotel` é método, não gem.
- Sem coverage theatre. Sete examples. Sem spec de `new`.
- Auth: signup entra, logout sai, senha curta não grava.
- CRUD: redirect no guest; João dono do owner, pet e stay.
- Segunda `checked_in` do Thor: 422, count 1.
- `/` mostra Thor, não Luna.
- `total_cents` integer. Tela `R$ 240,00`.
- PHP Feature / MockMvc = a mesma ideia. `actingAs` não substitui o POST da session.

---

## Exercícios práticos

### Exercício 1: Guest no check-in

**Enunciado:** O `crud_spec` bloqueia GET/POST de owners, pets e stays. O hotel também tem `POST /stays/:id/check_in`. Sem olhar o controller: o guest consegue check-in? O que você acrescenta no spec, e o que você espera?

<details>
<summary>Solução</summary>

Não consegue. `require_login` está no `ApplicationController`. `StaysController` herda. Guest em `POST stay_check_in_path(stay)` — ou o path que `bin/rails routes` mostrar — leva `redirect_to(login_path)`. Stay no banco nem precisa existir para o before_action disparar; se existir, o status não muda.

Um `it` novo no `crud_spec` (ou uma linha no example do guest) basta. Não abre arquivo novo. Não é coverage theatre: check-in muda dinheiro e ocupação. É fluxo.

**Pontos-chave:**
- `before_action` vale para collection e member
- Redirect, não 401 — HTML, não API
- Confira a rota com `bin/rails routes`
</details>

### Exercício 2: FactoryBot “só no stay”

**Enunciado:** Um colega quer `factory :stay` porque o setup de `create_hotel` “está verboso”. Ele promete não usar factory em User. Você aceita? O que quebra na leitura do spec de ocupação?

<details>
<summary>Solução</summary>

Não aceita neste recorte. O stay carrega pet, owner, user, datas, `nightly_rate_cents`, status. O default da factory vira a regra escondida. O spec de ocupação precisa Thor `checked_in` e Luna `scheduled`. Dois defaults, ou `create(:stay, :checked_in)` — e o trait vira o ponto que o entrevistador não lê.

Verboso aqui são quatro linhas. Factory justifica grafo de quinze associações. Não justifica esconder o status que a ocupação filtra.

**Pontos-chave:**
- Status e `user` não podem ser default opaco
- `create_hotel` já é o helper
- Gem nova = recorte novo. GUIDE não pede
</details>

### Exercício 3: Do Feature test para o request spec

**Enunciado:** No Laravel você escreveria:

```php
$user = User::factory()->create();
$this->actingAs($user)
    ->post('/stays', [/* ... status => checked_in */])
    ->assertStatus(422);
```

Há já uma stay `checked_in` do mesmo pet. Traduza para o hotel. O que muda no arrange? O que você não copia do `actingAs`?

<details>
<summary>Solução</summary>

Arrange sem factory: `create_hotel`, `login_as(joao)`, `joao.stays.create!(..., status: :checked_in)`. Act: `post stays_path, params: { stay: { pet_id: thor.id, ..., status: "checked_in" } }`. Assert: `have_http_status(422)` e `Stay.checked_in.where(pet: thor).count == 1`.

Você não copia `actingAs`. `login_as` passa no `SessionsController`. Cookie igual ao browser. `actingAs` injetaria o user e deixaria o login sem prova — ok no Laravel quando o guard não é o ponto; aqui o ponto do projeto 2 *é* a session.

Status 422 é o mesmo número. Assert de banco no RSpec é query, não `assertDatabaseHas` — a ideia é a mesma.

**Pontos-chave:**
- Mesmo fluxo, outro helper de auth
- Count no banco, não só o status HTTP
- Factory do PHP não vem junto na tradução
</details>

---

*Parte do [Ruby Projects Handbook](/)*
