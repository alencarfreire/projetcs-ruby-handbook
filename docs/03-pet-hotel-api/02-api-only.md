# 3.2 api_only e o que o 2 escondia no ERB

> **TL;DR**
> `config.api_only = true`. `ApplicationController < ActionController::API`. Sem cookie de sessão, sem CSRF, sem layout. O controller devolve Hash. O 2 escondia o body no ERB e o 401 no redirect para `/login`. Aqui o body é o contrato e o 401 é JSON.

## Conteúdo

- [O que api_only corta](#o-que-api_only-corta)
- [ActionController::API](#actioncontrollerapi)
- [Sem redirect, sem flash](#sem-redirect-sem-flash)
- [O namespace /api/v1](#o-namespace-apiv1)
- [Content-Type](#content-type)
- [O que o ERB escondia](#o-que-o-erb-escondia)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que api_only corta

**O que é:**
Um flag no `application.rb`. Rails não monta middleware de session, CSRF, flash, cookies de jeito útil para HTML. Você fica com o stack de API.

**Como funciona:**

```ruby
config.api_only = true
```

O pai dos controllers passa a ser `ActionController::API`, não `ActionController::Base`. Sem `helper_method` para view — não tem view. Sem `protect_from_forgery` — não tem form do browser.

No Spring, `@RestController` em vez de `@Controller`. No Laravel, um controller que não devolve Blade. O nome muda. O corte é o mesmo: some a tela.

**Quando usar:**
App que só fala JSON. Se você precisa de uma tela admin no mesmo processo, `api_only` atrapalha — você volta o middleware. Recorte daqui: só API.

**Na entrevista:**
> "api_only tira o HTML do caminho. Eu não desabilito view na mão. Eu escolho o modo do Rails."

---

## ActionController::API

**O que é:**
A classe magra. Tem `render json:`, strong params, callbacks. Não tem `render :new`, não tem `redirect_to` como fluxo principal.

**Como funciona:**
O `ApplicationController` deste projeto:

```ruby
class ApplicationController < ActionController::API
  include Payloads
  before_action :require_login
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
end
```

`require_login` agora renderiza 401 JSON, não redireciona. `RecordNotFound` vira 404 JSON. No 2, o `find` no `current_user.owners` explodia em 404 HTML. Aqui o cliente precisa de body.

**Exemplo prático:**
`GET /api/v1/occupancy` sem header. 401. Body `{"errors":["token ausente ou inválido"]}`. Curl `-i` mostra o status. Sem `-i` você só vê o JSON e acha que “funcionou vazio”.

**Na entrevista:**
> "O cadeado continua no pai. A reação mudou: 401 JSON no lugar do redirect. O cliente não segue Location de login."

---

## Sem redirect, sem flash

**O que é:**
HTML vive de POST-redirect-GET. API vive de status. 201 criou. 204 apagou. 422 recusou. 200 devolveu o recurso.

**Como funciona:**
Create de owner: `render json: owner_payload(owner), status: :created, location: api_v1_owner_url(owner)`. Delete: `head :no_content`. Sem `notice:`.

Flash é sessão. Sessão saiu. Mensagem de erro vai no array `errors`.

**Quando usar:**
Sempre neste projeto. Se você `redirect_to` numa API, o curl segue o 302 e você perde o status que o entrevistador queria ver.

**Na entrevista:**
> "201 e Location no create. 204 no delete. 422 com errors. Eu não redireciono o cliente JSON."

---

## O namespace /api/v1

**O que é:**
Prefixo no path. Versão no URL. Feio para purista de header. Claro no curl e no quadro.

**Como funciona:**

```ruby
namespace :api do
  namespace :v1 do
    post "/login", to: "sessions#create"
    resources :owners
    resources :stays do
      member do
        post :check_in
        post :check_out
      end
    end
  end
end
```

Controllers em `Api::V1::`. Path `/api/v1/owners`. v2, se um dia existir, é outra pasta. Recorte: uma versão.

**Quando usar:**
Take-home. Header `Accept: application/vnd.hotel.v1+json` é conversa de plataforma. Aqui o path ensina.

**Na entrevista:**
> "v1 no path. O entrevistador lê o curl sem olhar o header Accept. Se a vaga versiona por media type, eu falo o trade-off."

---

## Content-Type

**O que é:**
O cliente tem que dizer que o body é JSON. Sem `Content-Type: application/json`, o Rails não parseia o Hash. `params[:email]` vem vazio. Login 401. Você acha que a senha está errada.

**Como funciona:**
curl:

```bash
curl -s -X POST http://127.0.0.1:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@email.com","password":"senha123"}'
```

Spec: `as: :json`. Isso seta o header e serializa o Hash. Sem `as: :json`, o request spec manda form-encoded — funciona por acidente no Rails e mente no contrato.

**Exemplo prático:**
Você esquece o header no POST de owner. `params.require(:owner)` explode 400. Não é 422 de validação. É parse.

**Na entrevista:**
> "Content-Type application/json. Sem isso o Rails não monta o params. Eu não debugo senha antes de olhar o header."

---

## O que o ERB escondia

**O que é:**
No 2, `nights` e `total_cents` apareciam na view. O HTML era o contrato invisível. Aqui, se o Hash não tiver a chave, o cliente não vê.

**Como funciona:**
O concern `Payloads` monta o Hash. Stay leva `nights` e `total_cents`. User no login leva `token`. User no login **não** leva `password_digest`.

O 2 podia vazar digest na view se você desse `debug @user`. A API vaza se você fizer `render json: user`. `as_json` default inclui colunas. Por isso o Hash explícito: você escolhe a chave.

**Quando usar:**
Todo `render json:`. Nunca `render json: @user` cru neste recorte.

**Na entrevista:**
> "Eu monto o Hash. render json: user manda password_digest. Hash explícito é o strong params da resposta."

---

## Recapitulando

- `api_only` corta HTML, cookie, CSRF
- Pai é `ActionController::API`
- Status no lugar de redirect
- `/api/v1` no path
- `Content-Type` não é enfeite
- Hash explícito para não vazar coluna

---

## Exercícios práticos

### Exercício 1: Create sem Location

**Enunciado:** Você devolve 201 sem header `Location`. O que o entrevistador puxa?

<details>
<summary>Solução</summary>

REST: create devolve onde o recurso nasceu. `Location: /api/v1/owners/2`. O cliente não precisa adivinhar o id no body — mas o body também tem o id. Os dois. 201 sem Location passa em muita API da vida. Na entrevista, você menciona o header.

**Pontos-chave:**
- 201 ≠ 200
- Location aponta para o membro
- Body ainda leva o payload
</details>

### Exercício 2: render json: user

**Enunciado:** No login você escreveu `render json: user`. O que vaza? Como você conserta no quadro?

<details>
<summary>Solução</summary>

Vaza `password_digest`, `api_token` em todo endpoint que renderiza o User, timestamps, o que a coluna tiver. Conserta com Hash: `id`, `name`, `email`, e `token` **só** no login/signup. Occupancy não devolve token.

**Pontos-chave:**
- as_json default é a tabela
- token no login, não no GET /owners
- digest nunca
</details>

---

*Parte do [Ruby Projects Handbook](/)*
