# 2.3 Auth com has_secure_password

> **TL;DR**
> A senha nunca vai para o banco. bcrypt gera o hash. A coluna é `password_digest`. `authenticate("senha")` compara. Login grava `session[:user_id]` no cookie. `require_login` no `ApplicationController` fecha o resto. `skip_before_action` só no login e no signup — senão você tranca a porta com a chave do lado de dentro. Devise não entra: a entrevista quer esse fluxo na boca.

## Conteúdo

- [A entrevista quer o fluxo](#a-entrevista-quer-o-fluxo)
- [bcrypt](#bcrypt)
- [password_digest](#password_digest)
- [has_secure_password no User](#has_secure_password-no-user)
- [authenticate](#authenticate)
- [O cookie de session[:user_id]](#o-cookie-de-sessionuser_id)
- [current_user e require_login](#current_user-e-require_login)
- [skip_before_action no login e no signup](#skip_before_action-no-login-e-no-signup)
- [Cadastro já entra logado](#cadastro-já-entra-logado)
- [Logout com reset_session](#logout-com-reset_session)
- [Devise, Laravel Auth, Spring Security](#devise-laravel-auth-spring-security)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## A entrevista quer o fluxo

**O que é:**
Auth deste app é cinco peças no quadro: hash, coluna, `authenticate`, cookie, filtro. Sem Warden. Sem `devise_for :users`. Sem `Auth::attempt` escondido. Você escreve o fluxo e fala o fluxo.

**Como funciona:**
João cadastra. A senha vira digest. João loga. O digest bate. Você grava o `id` na session. O browser manda o cookie de volta. `current_user` lê o `id`. Occupancy, owners, pets, stays só andam se esse `id` existir.

**Quando usar:**
Take-home Rails HTML. Live coding de “monta um login”. Qualquer entrevista que pergunta “como você autentica sem Devise?”.

**Na entrevista:**
> "Devise eu uso em produção. Aqui eu mostro o fluxo: bcrypt, password_digest, authenticate, session[:user_id], require_login. Se eu não sei isso, a gem não me salva."

---

## bcrypt

**O que é:**
Gem de hash de senha. Adaptative. Cada senha ganha salt. Comparar é caro de propósito — brute force dói. Não é MD5. Não é SHA1 do e-mail.

**Como funciona:**
Você manda a senha em claro uma vez: no cadastro, no login. bcrypt devolve um string longo. Esse string vai para `password_digest`. Na comparação, bcrypt pega o claro de novo, aplica o mesmo custo, olha se bate. Você não “descriptografa”. Hash não volta.

No `Gemfile`: `gem "bcrypt"`. Sem essa gem, `has_secure_password` levanta. Rails não inventa o algoritmo.

**Quando usar:**
Sempre que a senha é do usuário. Token de API é outro recorte. Reset por e-mail é outro recorte. Aqui o recorte é login de tela.

**Exemplo prático:**
João digita `senha123`. O banco não guarda `senha123`. Guarda um digest que começa com `$2a$` ou `$2b$`. Maria olha o SQLite. Não loga como João.

**Na entrevista:**
> "bcrypt hasheia. Não cifra. Cifrar volta. Hash não volta. Eu comparo o claro com o digest. Se alguém vazar o banco, a senha em claro não está lá."

---

## password_digest

**O que é:**
A coluna. String, `null: false`. Não existe coluna `password`. Quem procura `users.password` no schema está procurando o erro.

**Como funciona:**
A migration do User:

```ruby
t.string :name, null: false
t.string :email, null: false
t.string :password_digest, null: false
add_index :users, :email, unique: true
```

`has_secure_password` escreve nessa coluna quando você atribui `password=`. O virtual `password` existe no model. Morre no request. O que persiste é o digest. Nome da coluna é contrato: `encrypted_password` é pele do Devise. Trocar o nome quebra o one-liner.

**Exemplo prático:**
Cadastro do João com `password: "senha123"`. `User.last.password` é `nil` depois do reload. `User.last.password_digest` está preenchido. O atributo virtual não sobrevive ao banco.

**Na entrevista:**
> "A coluna é password_digest. password é virtual. Se o entrevistador pedir o schema, eu não desenho password no users."

---

## has_secure_password no User

**O que é:**
O one-liner do Active Model. Liga bcrypt no model. Cria `password`, `password_confirmation`, `authenticate`. Valida presença da senha no create. Compara confirmação.

**Como funciona:**
No `User`:

```ruby
has_secure_password

validates :password, length: { minimum: 8 }, allow_nil: true
```

`allow_nil: true` não é “senha opcional no cadastro”. Cadastro sem senha o próprio `has_secure_password` barra. `allow_nil` é update: João muda o nome do dono, você não exige senha de novo. Sem isso, todo `save` pede 8 caracteres.

E-mail normaliza antes de validar: strip, downcase. Unicidade `case_sensitive: false`. `JOAO@email.com` e `joao@email.com` são o mesmo João.

**Quando usar:**
App HTML com um User e uma senha. Sem OAuth. Sem magic link. Sem 2FA. Recorte da Pousada do Thor.

**Exemplo prático:**
POST `/signup` com senha `curta`. 422. `User.count` continua 0. O spec cobre isso. O model recusou antes do cookie.

**Na entrevista:**
> "has_secure_password é o Active Model falando com o bcrypt. Eu não implemento o hash. Eu implemento o fluxo em volta."

---

## authenticate

**O que é:**
O método que o one-liner te dá. Recebe o claro. Devolve o User se o digest bate. Devolve `false` se não bate.

**Como funciona:**
Login no `SessionsController#create`:

```ruby
email = params[:email].to_s.strip.downcase
user = User.find_by(email: email)

if user&.authenticate(params[:password])
  session[:user_id] = user.id
  redirect_to root_path, notice: "Login feito."
else
  flash.now[:alert] = "E-mail ou senha inválidos."
  render :new, status: :unprocessable_entity
end
```

O `&.` importa. E-mail que não existe: `user` é `nil`. `nil.authenticate` explode. `nil&.authenticate` é `nil`. Cai no else. Mesma mensagem para e-mail errado e senha errada. Você não entrega um oráculo de “esse e-mail existe”. Cadastro não chama `authenticate` — salva e já grava a session.

**Exemplo prático:**
João manda `joao@email.com` / `errada`. `authenticate` devolve `false`. 422. Form de novo. Cookie de sessão não ganha `user_id`.

**Na entrevista:**
> "user&.authenticate. O safe navigation evita o NoMethodError no e-mail inexistente. A mensagem é única de propósito."

---

## O cookie de session[:user_id]

**O que é:**
Depois do `authenticate`, você não manda a senha de volta. Você guarda o `id`. Rails assina o cookie de session. O browser devolve o cookie no próximo request. Isso é “estar logado”.

**Como funciona:**
`session[:user_id] = user.id`. Não é `session[:user] = user`. Não é o digest no cookie. É um inteiro. O servidor lê o inteiro e busca o User.

O cookie viaja. A senha não. Se você colocar o digest no cookie, você copiou o banco para o browser. Se você colocar a senha em claro, a entrevista acabou.

Rails já assina a session. Sem remember-me. Token Bearer é outro recorte. Recorte daqui: cookie de sessão, ponto.

**Exemplo prático:**
João loga. Response seta o cookie. João pede `GET /`. O request já traz o cookie. `current_user` acha o João. A tela de ocupação renderiza.

**Na entrevista:**
> "Eu guardo o id na session. O cookie é o envelope assinado. A senha já morreu no authenticate. Próximo request eu só busco o User pelo id."

---

## current_user e require_login

**O que é:**
Dois métodos no `ApplicationController`. Um lê. Um barra. O resto do app herda.

**Como funciona:**

```ruby
helper_method :current_user, :logged_in?

before_action :require_login

def current_user
  @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
end

def require_login
  return if logged_in?
  redirect_to login_path, alert: "Faça login para continuar."
end
```

`find_by`, não `find`. `find` explode se o id sumiu do banco. `find_by` devolve `nil`. Session zumbi: usuário apagado, cookie ainda lá. Você manda para o login. Sem 500.

`helper_method` libera os dois na view. A navbar pergunta `logged_in?`. Occupancy faz `current_user.stays`. Sem helper, a view não vê o método privado.

`before_action :require_login` é o cadeado no pai. Occupancy não declara nada. Owners não declara nada. O default é fechado.

**Quando usar:**
Sempre que a tela é do hotel. Root incluso. Sem login, `GET /` não mostra ocupação — manda para `/login`.

**Exemplo prático:**
Maria abre `http://127.0.0.1:3000` sem cookie. `require_login` redireciona. Ela não vê Thor, Luna, Bidu. Vê o form.

**Na entrevista:**
> "O cadeado fica no ApplicationController. Default fechado. current_user memoíza. find_by para não 500 em session morta."

---

## skip_before_action no login e no signup

**O que é:**
Furo controlado no cadeado. Login e cadastro precisam ser públicos. Senão o filtro manda o anônimo para o login, o login exige login, e você gira.

**Como funciona:**
Nos dois controllers:

```ruby
skip_before_action :require_login, only: %i[new create]
```

`only:` é a lista. `new` e `create` abrem. `destroy` do logout **não** abre — quem sai já está dentro.

`skip` sem `only` abriria o controller inteiro. Amanhã alguém coloca `UsersController#index` de admin e esquece o filtro. `only:` documenta o furo.

Quem já está logado e bate em `/login` ou `/signup` volta para o root. Não tem por que ver o form de novo.

**Quando usar:**
Nas actions que existem para quem ainda não tem session. Só essas. O resto herda o cadeado.

**Exemplo prático:**
Você esquece o `skip` no `SessionsController`. Abre `/login`. `require_login` manda para `/login`. Redirect loop. O browser desiste. O bug é o filtro, não o form.

**Na entrevista:**
> "require_login no pai. skip só no new e no create de session e de user. Sem o skip, login redireciona para login."

---

## Cadastro já entra logado

**O que é:**
`UsersController#create` salva e já grava `session[:user_id]`. João não cadastra e depois loga. Cadastra e já está dentro.

**Como funciona:**

```ruby
@user = User.new(user_params)

if @user.save
  session[:user_id] = @user.id
  redirect_to root_path, notice: "Cadastro feito. Bem-vindo à Pousada do Thor."
else
  render :new, status: :unprocessable_entity
end
```

Strong params: `name`, `email`, `password`, `password_confirmation`. Sem `password_digest`. O digest o model monta.

Falha de validação: 422, form de novo, sem cookie. Sucesso: cookie + root. Mesmo contrato do login bem-sucedido.

**Quando usar:**
App de um usuário, um hotel. Onboarding de duas etapas (cadastra, confirma e-mail, aí loga) não entra neste recorte.

**Exemplo prático:**
POST `/signup` do João. Redirect para `/`. Occupancy já usa `current_user`. Thor ainda não está no hotel — mas João já é o dono da session.

**Na entrevista:**
> "Create do User já seta a session. É o mesmo session[:user_id] do login. Dois caminhos, um cookie."

---

## Logout com reset_session

**O que é:**
Sair não é “apagar uma chave”. É jogar a session fora.

**Como funciona:**

```ruby
def destroy
  reset_session
  redirect_to login_path, notice: "Você saiu."
end
```

`session.delete(:user_id)` tira o id e deixa o resto. Flash antigo, lixo, fixation. `reset_session` emite um id novo. O cookie velho morre.

Rota: `delete "/logout"`. Não é GET. Prefetch em GET desloga o João sem ele clicar. Este recorte faz `reset_session` na saída. Se o entrevistador puxar fixation no login, você fala o reset no create também — sem inventar o que o código não faz.

**Exemplo prático:**
João clica sair. DELETE `/logout`. Cookie novo, vazio. Próximo `GET /` cai no `require_login`. Tela de login.

**Na entrevista:**
> "Logout é reset_session, não delete da chave. E é DELETE, não GET. Prefetch não pode me deslogar."

---

## Devise, Laravel Auth, Spring Security

**O que é:**
Três peles do mesmo esqueleto. Hash, sessão, filtro. A entrevista não quer o README da gem. Quer saber o que a gem esconde.

**Como funciona:**

| Peça | Este app | Devise | Laravel Auth | Spring Security |
|---|---|---|---|---|
| Hash | bcrypt via `has_secure_password` | `database_authenticatable` | `Hash::make` / `Hash::check` | `BCryptPasswordEncoder` |
| Coluna | `password_digest` | `encrypted_password` | `password` (já hash) | campo no `UserDetails` |
| Comparar | `authenticate` | Warden | `Auth::attempt` | `AuthenticationManager` |
| Sessão | `session[:user_id]` | Warden na session | driver de session | `SecurityContext` |
| Filtro | `before_action :require_login` | `authenticate_user!` | `middleware('auth')` | `SecurityFilterChain` |
| Furo | `skip_before_action` | `skip_before_action :authenticate_user!` | `guest` middleware | `permitAll()` no matcher |

Mesma conversa. Outra pele. Devise empacota módulo, generator, recoverable, rememberable, trackable. Você não escreve o `session[:user_id]`. Por isso a entrevista tira o Devise: quer ouvir as cinco linhas.

Laravel: o `Auth` facade parece mágica se você nunca abriu o guard. Por baixo é hash + session + middleware. Igual.

Spring Security: filter chain na frente de tudo. Mais peça, mais XML na memória de quem sofreu o Boot 1. A ideia não muda: encoder, user details, contexto, matcher público para `/login`.

**Quando usar:**
Na entrevista, quando perguntam “por que não Devise?”. A resposta não é “Devise é ruim”. A resposta é “Devise esconde o fluxo que você está cobrando”.

**Na entrevista:**
> "Devise, Laravel Auth e Spring Security resolvem as mesmas três coisas: hash, sessão, filtro. Neste app eu escrevo as três. Em produção com reset de senha e OAuth eu puxo a gem. Aqui a gem me atrapalha a falar."

---

## Recapitulando

- A senha não vai para o banco. Vai o `password_digest`.
- bcrypt hasheia. Não cifra. Hash não volta.
- `has_secure_password` liga o virtual `password`, a confirmação e o `authenticate`.
- `allow_nil: true` no length é update, não cadastro sem senha.
- Login: `user&.authenticate` — mensagem única, sem oráculo de e-mail.
- Logado é `session[:user_id]` no cookie assinado. Não é a senha no cookie.
- `current_user` usa `find_by`. Session zumbi não vira 500.
- Cadeado no pai: `before_action :require_login`. Furo no filho: `skip` só em `new`/`create`. Sem o skip, `/login` redireciona para `/login`.
- Cadastro já seta a session. Dois caminhos, um cookie.
- Logout é `reset_session` + `DELETE /logout`.
- Devise / Laravel Auth / Spring Security: mesma peça, outra pele. A entrevista quer a peça.

---

## Exercícios práticos

### Exercício 1: O loop do login

**Enunciado:** Você apaga o `skip_before_action` do `SessionsController`. O que acontece em `GET /login`? E se o `skip` ficar, mas sem `only:`?

<details>
<summary>Solução</summary>

Sem o `skip`: `ApplicationController` roda `require_login`. Não tem `current_user`. Redirect para `login_path`. O login é o próprio `/login`. Loop.

Com `skip` sem `only:`: `new`, `create` **e** `destroy` ficam públicos. Logout sem session não quebra o mundo — mas você abriu o controller inteiro. Amanhã entra uma action e herda o furo.

O certo é `only: %i[new create]`. `destroy` continua atrás do cadeado.

**Pontos-chave:**
- Default fechado no pai
- Furo explícito no filho
- `only:` é o recorte do furo
</details>

### Exercício 2: O `&.` e a mensagem única

**Enunciado:** O entrevistador pede duas mensagens: “e-mail não cadastrado” e “senha inválida”. O que você responde? O que quebra se trocar `user&.authenticate` por `user.authenticate`?

<details>
<summary>Solução</summary>

Mensagem única. “E-mail ou senha inválidos.” Separar as duas entrega um oráculo: o atacante descobre quais e-mails existem na Pousada do Thor.

`user.authenticate` sem `&.`: e-mail inexistente → `nil.authenticate` → `NoMethodError` → 500. Você vazou a existência do e-mail **e** derrubou o request.

`user&.authenticate`: `nil` curto-circuita. Cai no else. 422. Form de novo. Mesmo caminho da senha errada.

**Pontos-chave:**
- `&.` não é estética
- 500 em e-mail novo é vazamento
- Uma mensagem, dois erros
</details>

### Exercício 3: Por que não Devise?

**Enunciado:** O entrevistador aponta o `Gemfile` e pergunta por que não tem Devise, se “todo Rails usa”. Resposta de 30 segundos. Depois ele puxa Laravel e Spring. O que você compara?

<details>
<summary>Solução</summary>

30 segundos: “Devise resolve reset, remember, OAuth. Este app tem cadastro, login e logout. A entrevista quer o fluxo: bcrypt, digest, authenticate, session[:user_id], require_login. Devise esconde essas cinco linhas. Eu escrevo as cinco.”

Comparação: Laravel faz a mesma peça com `Hash` + `Auth::attempt` + `middleware('auth')`. Spring faz com encoder + `UserDetails` + filter chain + `permitAll` no `/login`. Nome muda. Esqueleto não.

O que você **não** fala: tutorial de `php artisan make:auth`. Nem `HttpSecurity` linha a linha. Lucidez: três peças, três peles.

**Pontos-chave:**
- Devise não é errado — é o recorte errado desta entrevista
- Hash, sessão, filtro
- Outra linguagem, mesma frase
</details>

---

*Parte do [Ruby Projects Handbook](/)*
