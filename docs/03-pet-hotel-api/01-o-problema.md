# 3.1 O problema e o recorte

> **TL;DR**
> Mesmo hotel. Outra porta. O projeto 2 era HTML, cookie, form. Este é JSON, Bearer, curl. Rails `api_only`. Token na tabela, não JWT. João loga, ganha um string, manda no header. Occupancy, owners, pets, stays — o mesmo domínio, sem ERB. Recorte: mostrar o fio que o `render json:` esconde.

## Conteúdo

- [Este projeto não é o 2](#este-projeto-não-é-o-2)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [Cookie vs Bearer](#cookie-vs-bearer)
- [O mesmo domínio](#o-mesmo-domínio)
- [O que fica de fora](#o-que-fica-de-fora)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Este projeto não é o 2

**O que é:**
O projeto 2 mostrou tela, sessão e tabela. Este mostra o mesmo hotel falando JSON. O entrevistador mudou a pergunta: “agora o cliente é o app do celular”. Você não redesenha Owner, Pet, Stay. Você troca o envelope.

**Como funciona:**
No 2, o browser mandava o cookie sozinho. Aqui o cliente é burro de propósito: curl. Sem cookie. Sem CSRF. Sem `redirect_to`. Cada request carrega `Authorization: Bearer …` ou leva 401.

No Java isso vira `@RestController` + filtro. No PHP, um front controller que devolve `json_encode`. No Rails, `config.api_only = true` e `ActionController::API`.

**Quando usar:**
Vaga que pede API. Take-home “expõe o CRUD em JSON”. Live coding depois do HTML.

**Na entrevista:**
> "O domínio eu já modelei no HTML. Aqui eu tiro o ERB, coloco token no header e monto o JSON na mão. Não começo pelo JWT."

---

## O problema

**O que é:**
A recepção precisa de um cliente que não é o browser da Pousada. App, Insomnia, outro serviço. O contrato é HTTP + JSON. João autentica com e-mail e senha, recebe um token, e daí em diante o token é a identidade.

**Como funciona:**
João faz `POST /api/v1/login` com `{"email":"joao@email.com","password":"senha123"}`. Você devolve o User e o `token`. João pede `GET /api/v1/occupancy` com o header. Você lista o Thor. Sem header, 401. Token da Ana no owner do João: 404 — você não confirma que o recurso existe no outro user.

**Quando usar:**
Quando a pergunta é “API do mesmo app”. Não quando a pergunta é tela. Tela ficou no 2.

**Exemplo prático:**
O seed continua a história:

```
João  → User + api_token
Maria → Owner
Thor  → Stay checked_in
Luna  → Stay scheduled
Bidu  → sem Stay
```

Três pets. Dois stays. Um token. Cabe no quadro.

**Na entrevista:**
> "O problema é a mesma recepção, agora JSON. Eu não invento um segundo domínio. Eu invento o contrato: login devolve token, o resto exige Bearer."

---

## O recorte

**O que é:**
A lista do que entra e a lista do que não entra. Sem recorte você instala JWT, knock, Jbuilder, CORS, versionamento em header, e em 45 minutos não tem occupancy.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Rails 8.1 `api_only`, SQLite | HTML, ERB, cookie de sessão |
| `has_secure_token :api_token` | JWT, Devise, knock |
| `Authorization: Bearer` | session cookie, CSRF |
| Hash explícito no `render json:` | Jbuilder, Alba, AMS |
| `/api/v1` no path | versionamento por header |
| 401 / 404 / 422 / 201 / 204 | Pundit, 403 fino |
| request spec com `as: :json` | coverage theatre, FactoryBot |

Por que token na tabela e não JWT? JWT é um formato assinado. Você não precisa de formato para um take-home de um user. `has_secure_token` gera um string aleatório, grava na coluna, compara no `find_by`. Logout regenera — o Bearer antigo morre. No JWT “logout” é denylist ou esperar o `exp`. O entrevistador puxa isso. Você fala.

Por que não cookie na API? Porque o cliente não é o browser da recepção. Mobile não manda cookie de session sozinho. Você pede o header. O fio aparece.

**Quando usar:**
Sempre que o exercício diz “API Rails”. API neste livro não é “todas as gems da vaga”. É JSON + token raso + o domínio que você já tem.

**Na entrevista:**
> "Recorte: api_only, token na tabela, Hash no render. Sem JWT. Se pedirem JWT, eu explico o trade-off: stateless, exp, e o logout vira outro problema."

---

## Cookie vs Bearer

**O que é:**
A diferença que o entrevistador puxa quando você fala os projetos 2 e 3. No 2, o browser guarda o cookie. No 3, o cliente guarda o token e cola no header.

**Como funciona:**
Cookie: o servidor seta, o browser devolve. CSRF existe porque o browser é obediente. Bearer: o cliente só manda se o seu código mandar. CSRF some. XSS no token vira outro ataque — o JS malicioso lê o storage. Recorte: curl, não SPA.

**Exemplo prático:**
Projeto 2: `session[:user_id] = user.id`. Projeto 3: `{ token: user.api_token }` no body. Próximo request: `Authorization: Bearer …`. Sem `Set-Cookie`.

**Na entrevista:**
> "Cookie o browser carrega sozinho. Bearer eu carrego. Por isso a API não tem CSRF e tem 401 no lugar do redirect para /login."

---

## O mesmo domínio

**O que é:**
User, Owner, Pet, Stay. Enum `scheduled` / `checked_in` / `checked_out`. Centavos integer. `nights` e `total_cents` virtuais. A regra “um pet, uma checked_in” continua no model.

**Como funciona:**
Os models vieram do 2. A API não reimplementa diária. O JSON **expõe** `nights` e `total_cents` — o cliente não multiplica. Se o cliente multiplicar, ele erra no fuso. O servidor é a fonte.

**Quando usar:**
Sempre. API que deixa o cliente calcular dinheiro é entrevista perdida.

**Na entrevista:**
> "O model não mudou. O JSON inclui nights e total_cents. Eu não devolvo só as datas e peço para o app fazer conta."

---

## O que fica de fora

**O que é:**
A lista para falar em voz alta quando o entrevistador perguntar “e JWT? e CORS?”.

**Como funciona:**
JWT, Devise, Jbuilder, HTML, Hotwire, Sidekiq, Cable, `rack-cors`. CORS entra quando o front é outro origin no browser. Aqui o cliente é curl. Pagination não entra: a Pousada cabe num array.

Hotwire é o projeto 4. Sidekiq é o 5. Cable é o 6.

**Na entrevista:**
> "CORS eu coloco quando o browser de outro host chama. Neste recorte o cliente é curl. JWT é o próximo recorte se a vaga for auth distribuída."

---

## Como o walkthrough anda

**O que é:**
Oito capítulos. Código em `projects/03-pet-hotel-api`. Texto aqui.

**Como funciona:**
3.2 `api_only`. 3.3 o token. 3.4 o JSON. 3.5 check-in e 4xx. 3.6 401 vs 404. 3.7 specs. 3.8 curls. [Código](/docs/03-pet-hotel-api/codigo) cola o que o entrevistador puxa.

**Na entrevista:**
> "Eu subi a API, bati o login, copiei o token, listei a ocupação. O resto é o mesmo hotel."

---

## Recapitulando

- Mesmo domínio do 2, envelope JSON
- Token na tabela, Bearer no header, sem cookie
- Sem JWT, sem Jbuilder, sem ERB
- 401 sem token; 404 no recurso alheio
- `nights` e `total_cents` saem do servidor

---

## Exercícios práticos

### Exercício 1: O que muda no quadro

**Enunciado:** O entrevistador desenhou o fluxo do projeto 2: form → cookie → `current_user`. Pede para você riscar e substituir para a API. O que some, o que entra?

<details>
<summary>Solução</summary>

Some: ERB, `redirect_to`, flash, cookie, CSRF, `session[:user_id]`.

Entra: `POST /api/v1/login` devolvendo `{ token }`, header `Authorization: Bearer`, `find_by(api_token:)`, `render json:`.

O model Stay não some. A regra da diária não some. Some o envelope.

**Pontos-chave:**
- Domínio fica
- Envelope troca
- Token não é cookie com outro nome — o cliente cola
</details>

### Exercício 2: Por que não JWT neste recorte

**Enunciado:** O entrevistador fala “em produção a gente usa JWT”. Você concorda em silêncio ou recorta?

<details>
<summary>Solução</summary>

Recorta e fala o trade-off. JWT: o servidor não consulta a tabela no request. Logout vira denylist ou TTL. Token na tabela: logout regenera, o Bearer antigo 401 na hora. Para um User e um take-home, a tabela ganha. Em produção distribuída, JWT (ou session no Redis) entra — e você diz isso.

**Pontos-chave:**
- JWT não é sinônimo de API
- Logout é a pergunta que desmonta o “é só assinar”
- has_secure_token é o bcrypt do token
</details>

---

*Parte do [Ruby Projects Handbook](/)*
