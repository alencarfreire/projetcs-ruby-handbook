# 3.3 Token: has_secure_token + Bearer

> **TL;DR**
> A senha autentica uma vez. O token autentica o resto. `has_secure_token :api_token` gera um string aleatório na coluna. Login devolve. O cliente cola em `Authorization: Bearer`. Logout chama `regenerate_api_token` — o Bearer antigo 401. Não é JWT. Não é o cookie do projeto 2 com outro nome.

## Conteúdo

- [Duas peças, dois tempos](#duas-peças-dois-tempos)
- [has_secure_token](#has_secure_token)
- [A coluna api_token](#a-coluna-api_token)
- [O header Authorization](#o-header-authorization)
- [current_user lê o Bearer](#current_user-lê-o-bearer)
- [Login devolve, logout regenera](#login-devolve-logout-regenera)
- [Por que não JWT](#por-que-não-jwt)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Duas peças, dois tempos

**O que é:**
Cadastro/login ainda usam `has_secure_password`. O token não substitui a senha. Substitui o cookie.

**Como funciona:**
João manda e-mail e senha **uma vez**. `authenticate` bate. Você devolve o `api_token`. Daí em diante a senha não viaja. Viaja o Bearer. Se o token vazar, você regenera. Se a senha vazar, você troca o digest — outro recorte.

**Quando usar:**
API com um User. Sem refresh token. Sem OAuth. Recorte da Pousada.

**Na entrevista:**
> "A senha entra no login. O token entra no resto. Eu não mando senha em todo request. Eu também não mando o digest."

---

## has_secure_token

**O que é:**
One-liner do Active Record. Gera um string aleatório (hex) na coluna. `regenerate_api_token` gera de novo e salva.

**Como funciona:**
No `User`:

```ruby
has_secure_password
has_secure_token :api_token
```

No create, o token nasce sozinho. Você não pede `api_token` no strong params. Cliente não escolhe o token. Igual o `id`.

Não é bcrypt. Token não é senha. É um segredo aleatório que você compara por igualdade. Índice unique. `find_by(api_token: token)`.

**Quando usar:**
Um token por user. Vários devices compartilham o mesmo string — recorte. Se a vaga pede um token por device, vira tabela `api_tokens`. Fora.

**Na entrevista:**
> "has_secure_token gera. has_secure_password hasheia. Token eu comparo. Senha eu não comparo em claro."

---

## A coluna api_token

**O que é:**
String, unique. Pode nascer nil na migration e ganhar valor no create. Seed chama `regenerate_api_token` se vier em branco.

**Como funciona:**
Migration:

```ruby
add_column :users, :api_token, :string
add_index :users, :api_token, unique: true
```

Sem unique, dois users podem colidir. Raro. Na entrevista você põe o índice.

O log filtra `:token` no `filter_parameter_logging`. O digest já era filtrado via `:passw`. Token no log é vazamento.

**Exemplo prático:**
`User.last.api_token` é um hex. `User.last.password` é nil. Os dois não se misturam no JSON.

**Na entrevista:**
> "Coluna api_token, índice unique. Eu não indexo senha. Eu não log o Bearer."

---

## O header Authorization

**O que é:**
O envelope HTTP. Esquema `Bearer`, espaço, o string. Sem isso, `require_login` 401.

**Como funciona:**

```
Authorization: Bearer 7k2...
```

O controller parte o header:

```ruby
def bearer_token
  header = request.headers["Authorization"].to_s
  scheme, token = header.split(" ", 2)
  return unless scheme&.casecmp("Bearer")&.zero?
  token.presence
end
```

`Token 7k2` sem a palavra Bearer: 401. `Bearer` com case diferente: passa — `casecmp`. Espaço importa. Query string `?token=` não entra neste recorte: o token ia para o access log do proxy.

**Quando usar:**
Todo endpoint depois do login. Signup e login pulam o filtro.

**Na entrevista:**
> "Bearer no Authorization. Token na query string vaza no log do nginx. Header não vai na URL."

---

## current_user lê o Bearer

**O que é:**
A mesma ideia do projeto 2. Troca `session[:user_id]` por `find_by(api_token:)`.

**Como funciona:**

```ruby
def current_user
  return @current_user if defined?(@current_user)
  token = bearer_token
  @current_user = token.present? ? User.find_by(api_token: token) : nil
end

def require_login
  return if logged_in?
  render json: { errors: ["token ausente ou inválido"] }, status: :unauthorized
end
```

`defined?(@current_user)` memoíza inclusive `nil`. Sem isso, um 401 bate o banco duas vezes e ainda parece logado. `find_by`, não `find`: token lixo devolve `nil`, não 404. 404 é recurso. 401 é identidade.

Mensagem única: “ausente ou inválido”. Você não entrega oráculo de “esse token existiu”.

**Exemplo prático:**
Header vazio: 401. Token da Ana: `current_user` é a Ana. Owner do João: `current_user.owners.find` 404.

**Na entrevista:**
> "find_by no token. 401 se nil. 404 se o recurso não é do current_user. Eu não misturo os dois."

---

## Login devolve, logout regenera

**O que é:**
O ciclo de vida. Login mostra o token atual. Logout mata o atual.

**Como funciona:**
Login:

```ruby
if user&.authenticate(params[:password])
  user.regenerate_api_token if user.api_token.blank?
  render json: user_payload(user, token: true)
end
```

Logout (já autenticado):

```ruby
current_user.regenerate_api_token
head :no_content
```

O spec cobre: signup → token T1 → logout → T1 dá 401 → login → T2 diferente de T1 → occupancy 200.

Login **não** regenera. Dois curls de login seguidos veem o mesmo token. Logout é o kill. Recorte: um token por user. “Sair no celular mata o Insomnia” — você fala isso.

**Quando usar:**
Take-home. Refresh token e allowlist são o próximo quadro, não este.

**Na entrevista:**
> "Logout regenera. O Bearer antigo morre na hora. JWT precisaria de denylist para o mesmo efeito."

---

## Por que não JWT

**O que é:**
A pergunta. JWT é um payload assinado. O servidor não precisa da tabela para crer no `user_id`. Logout não existe de graça.

**Como funciona:**
Neste recorte o servidor **consulta** a tabela. Token revogado some. Custo: um `find_by` por request. A Pousada aguenta.

JWT brilha quando o resource server não é o auth server. Microserviço. Recorte daqui: um Rails.

**Na entrevista:**
> "JWT eu uso quando o validador não tem a tabela. Aqui eu tenho. Token na coluna, logout é regenerate. Se a vaga for distribuída, eu desenho o JWT e o exp."

---

## Recapitulando

- Senha no login, token no resto
- `has_secure_token` gera, unique index segura
- Bearer no header, nunca na query
- `find_by` → 401; recurso alheio → 404
- Logout regenera

---

## Exercícios práticos

### Exercício 1: Token na query string

**Enunciado:** O cliente mobile quer `GET /api/v1/occupancy?token=...` porque montar header é chato. Você aceita?

<details>
<summary>Solução</summary>

Não neste recorte. URL vai para log, history, Referer. Header não. Você explica e mantém `Authorization`. Se o entrevistador insistir em WebSocket (projeto 6), o token às vezes entra no subprotocolo — outro recorte.

**Pontos-chave:**
- Query string vaza
- Header é o lugar
- Não misturar com Cable ainda
</details>

### Exercício 2: Login regenera sempre

**Enunciado:** Você muda o login para `regenerate_api_token` em todo authenticate. O que quebra?

<details>
<summary>Solução</summary>

Cada login mata o token anterior. Dois clientes (curl e Insomnia) não convivem. Recorte atual já é “um token”. A diferença: agora **login** mata, não só logout. Surpresa. O spec de “login duas vezes, mesmo token” quebraria. Fale o trade-off: mais seguro, menos amigável. Este livro regenera no logout.

**Pontos-chave:**
- Um token por user já é recorte
- Onde regenera muda o produto
- Spec documenta a escolha
</details>

---

*Parte do [Ruby Projects Handbook](/)*
