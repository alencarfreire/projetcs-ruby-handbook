# 11.3 Rodauth e JWT

> **TL;DR**
> `plugin :rodauth, json: :only`. `enable :create_account, :login, :logout, :jwt`. `r.rodauth` monta `/create-account`, `/login`, `/logout`. Token no header `Authorization`. `rodauth.require_authentication` no ramo `/eventos`. JWT não revoga de graça.

## Conteúdo

- [json: :only](#json--only)
- [enable](#enable)
- [r.rodauth](#rrodauth)
- [O header](#o-header)
- [require_authentication](#require_authentication)
- [Logout e revogação](#logout-e-revogação)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## json: :only

**O que é:**
Rodauth sem HTML, sem CSRF, sem flash de view. API JSON.

**Como funciona:**

```ruby
plugin :rodauth, json: :only do
  enable :create_account, :login, :logout, :jwt
  hmac_secret SECRET
  jwt_secret SECRET
  account_password_hash_column :password_hash
  require_password_confirmation? false
  require_login_confirmation? false
end
```

`login` no JSON é o e-mail. Campo `login`, não `email`. Path com hífen: `/create-account`.

**Na entrevista:**
> "json: :only. Sem form. login é o campo. create-account é o path. Eu não invento POST /signup."

---

## enable

**O que é:**
Feature. Só o que o recorte usa.

**Como funciona:**
Sem `verify_account`: a conta já entra verificada (status 2 na migration default). Sem reset_password. Sem OTP. Recorte de porta.

**Na entrevista:**
> "Eu habilito login, create, logout, jwt. Recover não entra. Se a vaga pedir e-mail, eu falo o feature."

---

## r.rodauth

**O que é:**
O dispatcher das rotas de auth. Tem que vir **antes** do cadeado do restante.

**Como funciona:**

```ruby
route do |r|
  r.root { { "name" => "ingressos-pragmatic" } }
  r.rodauth
  r.on "eventos" do
    rodauth.require_authentication
    # ...
  end
end
```

Sem `r.rodauth`, `/login` 404. Root fica público de propósito.

**Na entrevista:**
> "r.rodauth no route. Antes do require. Senão o login pede login."

---

## O header

**O que é:**
A response do login traz `Authorization: eyJ...`. O cliente cola no próximo request. Não é `Bearer ` obrigatório neste default — o valor **é** o JWT. O curl do README cola o header inteiro como veio.

**Como funciona:**
`HTTP_AUTHORIZATION` no Rack. Rodauth JWT lê. Payload tem `account_id`. Sem consultar session cookie.

**Na entrevista:**
> "O token volta no Authorization. Eu copio o header. Não é cookie. Não é a coluna api_token de outro recorte."

---

## require_authentication

**O que é:**
O cadeado. Sem JWT válido: 401 JSON.

**Como funciona:**
No ramo `eventos`. Root e `r.rodauth` ficam de fora. 401 `{ "error": "Please login to continue" }` — mensagem default do Rodauth, inglês. Recorte: não traduz agora. Você fala que dá para configurar.

**Na entrevista:**
> "require_authentication no ramo. 401. A mensagem default é inglês. Eu não minto que está em pt-BR."

---

## Logout e revogação

**O que é:**
A pergunta. JWT assinado vale até `exp`. Logout no server **não** apaga o token no cliente. Sem denylist, o Bearer antigo ainda passa.

**Como funciona:**
Neste recorte: logout é o endpoint do Rodauth. O cliente descarta o header. O server não guarda denylist. Você **diz** isso. Tabela de refresh (jwt_refresh) é outro feature. Não entra.

**Na entrevista:**
> "JWT não revoga de graça. Logout é o cliente jogar o token fora. Se a vaga precisa matar agora, denylist ou token na tabela. Eu não escondo."

---

## Recapitulando

- json: :only + jwt
- paths create-account / login
- Authorization é o JWT
- require no ramo eventos
- revogação é o recorte honesto

---

## Exercícios práticos

### Exercício 1: campo email no JSON

**Enunciado:** `{"email":"joao@...","password":"..."}`. Login falha. Por quê?

<details>
<summary>Solução</summary>

Campo é `login`. Rodauth default. email no JSON some. 401. README usa `login`.

**Pontos-chave:**
- login ≠ email no JSON
- path hífen
- README
</details>

### Exercício 2: Bearer prefix

**Enunciado:** Você cola `Bearer eyJ`. Quebra?

<details>
<summary>Solução</summary>

Depende do parser JWT do Rodauth. O recorte cola o valor **como a response mandou**. Se a response não tem a palavra Bearer, você não inventa. Olha o `-D -` do curl.

**Pontos-chave:**
- copiar o header
- não inventar esquema
- -D para ver
</details>

---

*Parte do [Ruby Projects Handbook](/)*
