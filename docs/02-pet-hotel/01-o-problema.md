# 2.1 O problema e o recorte

> **TL;DR**
> Você vai construir o app da Pousada do Thor. Rails, HTML, SQLite. João loga, cadastra Maria, hospeda Thor, Luna e Bidu. No projeto 1 o store era Hash: mata o processo, zerou. Aqui a tabela sobrevive ao reboot. Auth é `has_secure_password` + cookie — não Devise. Sem Hotwire, sem Sidekiq, sem API JSON. Dinheiro em centavos, integer. Recurso: User, Owner, Pet, Stay.

## Conteúdo

- [Este projeto não é o 1](#este-projeto-não-é-o-1)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [Hash vs tabela](#hash-vs-tabela)
- [User, Owner, Pet, Stay](#user-owner-pet-stay)
- [Dinheiro em centavos](#dinheiro-em-centavos)
- [O que fica de fora](#o-que-fica-de-fora)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Este projeto não é o 1

**O que é:**
O projeto 1 foi HTTP na mão. Task no Hash. JSON na porta. Este é o segundo app do livro: um hotel de pets em Rails, com tela e banco. Mesmo handbook. Outro recorte.

**Como funciona:**
Você leu o 1.1 e montou o TCPServer. Agora o entrevistador pede tela, login, persistência. Rails entra porque o ponto mudou: não é mais “você monta o `HTTP/1.1`”. É “você modela o domínio e não deixa o framework esconder a regra”.

**Quando usar:**
Quando a vaga é Rails. O projeto 1 ainda vale — mostra o que o `routes.rb` esconde. Este mostra o que o Devise e o `rails g scaffold` escondem.

**Na entrevista:**
> "No primeiro exercício eu fiz HTTP puro, Hash na memória. Aqui eu subi Rails, SQLite, HTML. O protocolo eu já mostrei. Agora eu mostro model, sessão e dinheiro em integer."

---

## O problema

**O que é:**
A Pousada do Thor precisa de um app para a recepção. João opera o hotel. Maria é cliente: dona do Thor, da Luna e do Bidu. João cadastra dono, cadastra pet, abre hospedagem, faz check-in, faz check-out. No fim do dia ele olha quem está `checked_in` agora.

Não é marketplace. Não é app do dono no celular. É o balcão. Um User logado vê os próprios Owners, Pets e Stays.

**Como funciona:**
João abre o browser, loga com `joao@email.com`. Cria Maria. Cria Thor (cão), Luna (gato), Bidu (cão). Abre uma Stay do Thor: check-in hoje, check-out daqui a três dias, diária R$ 80,00 — no banco isso é `8000` centavos. Status começa `scheduled`. No dia, João manda check-in. A tela de ocupação lista o Thor. Check-out tira da lista.

No Java isso vira um CRUD Thymeleaf + Spring Security. No PHP, Blade + `password_hash` + session. Aqui vira Rails HTML: form, redirect, flash, cookie de sessão.

**Quando usar:**
Take-home de Rails. Live coding de model + auth. Qualquer entrevista que pede “um CRUD de verdade”, não um JSON na memória.

**Exemplo prático:**
O seed já conta a história:

```
João  → User (recepção)
Maria → Owner (cliente)
Thor, Luna, Bidu → Pets da Maria
Thor  → Stay checked_in, 3 diárias, 8000 centavos
Luna  → Stay scheduled
Bidu  → ainda sem Stay
```

Três pets. Dois stays. Um login. Cabe no quadro.

**Na entrevista:**
> "O problema é a recepção de um hotel de pets. User loga, Owner é o cliente, Pet pertence ao Owner, Stay é a hospedagem. Eu não começo pelo Devise. Eu começo pelo recorte e pelos quatro models."

---

## O recorte

**O que é:**
A lista do que entra e a lista do que não entra. Sem recorte você gera Devise, instala Turbo, sobe Sidekiq e em 45 minutos não tem tela de ocupação. Recorte é a resposta de entrevista: o que cabe no quadro.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Rails 7.1+, Ruby 3.3+, SQLite | Postgres, Redis, Elasticsearch |
| HTML, form, flash, redirect | API JSON, JWT |
| `has_secure_password` + session cookie | Devise, OmniAuth |
| `resources` REST de Owner, Pet, Stay | Hotwire (Turbo / Stimulus) |
| `enum` de status no Stay | Sidekiq, Active Job, e-mail |
| integer em centavos | Float, `BigDecimal` de preço |
| request spec dos fluxos | coverage theatre, Pundit |

Por que HTML e não JSON? Porque o projeto 1 já foi JSON. Aqui o entrevistador quer ver form, strong params, `redirect_to`, flash. Spring faz isso com `@Controller` + template. Laravel faz com Blade. Rails faz com ERB. Sem `render json:`.

Por que `has_secure_password` e não Devise? Devise é o Spring Security auto-config: User, recover, confirmable, lockable, OmniAuth, 40 rotas que você não sabe desenhar. `has_secure_password` é bcrypt no model — `password_digest` no SQLite, `authenticate("senha")` na hora do login. No PHP você faria `password_hash` / `password_verify` e gravaria o id na `$_SESSION`. No Java, `BCryptPasswordEncoder` + cookie. A sessão você mesmo põe no cookie. É o ponto: mostrar o fio.

**Quando usar:**
Sempre que o exercício diz “Rails”. Rails neste livro não é “todas as gems da vaga”. É MVC HTML + Active Record + auth raso.

Se a vaga pede Devise no dia a dia, você fala: “em produção eu usaria Devise ou Rodauth. Neste exercício eu quero que o entrevistador veja o `authenticate` e o `session[:user_id]`.”

**Exemplo prático:**
O User cabe nisto:

```ruby
class User < ApplicationRecord
  has_secure_password
  has_many :owners, dependent: :destroy
  has_many :pets, dependent: :destroy
  has_many :stays, dependent: :destroy
end
```

Sem `devise :database_authenticatable`. Sem `recoverable`. Sem mailer. Senha nunca vai para o banco — só o digest.

**Na entrevista:**
> "Recorte: Rails HTML, SQLite, has_secure_password. Sem Devise, sem Hotwire, sem Sidekiq, sem JSON. O projeto 1 já mostrou API. Este mostra tela, sessão e tabela. Se pedirem Devise, eu explico o trade-off e sigo no bcrypt."

---

## Hash vs tabela

**O que é:**
A diferença que o entrevistador puxa quando você fala os dois projetos. No 1, `@tasks` era o banco. Aqui o banco é SQLite. Restart não apaga o Thor.

**Como funciona:**
Quatro tempos de vida — o mesmo quadro do 1.1, agora com a linha que faltava:

| Onde | Onde vive o dado | Quando some |
|---|---|---|
| PHP (script + built-in server) | array no request | no fim de cada request |
| Java (`HttpServer` + handler) | `List` no objeto | quando a JVM morre |
| Ruby no projeto 1 | Hash na instância | quando o processo Ruby morre |
| Rails neste projeto | tabela no SQLite | não some no reboot |

No projeto 1 você dizia isso em voz alta: mata o servidor, zerou. Aqui o ponto inverte. `bin/rails s` cai, você sobe de novo, João ainda loga, Thor ainda está `checked_in`. Porque o Hash virou `INSERT`. O `@next_id` virou `id INTEGER PRIMARY KEY`. O processo não é mais o store.

PHP engana de novo, do outro lado: quem vem de Laravel já espera tabela. Quem vem do script puro espera array. Rails neste projeto se parece com Laravel + Eloquent, não com o `$_POST` do arquivo único. Java com Spring Data JPA é o primo: entidade, tabela, reboot seguro.

**Quando usar:**
Quando o entrevistador pergunta “por que agora tem banco?”. Porque o domínio tem Stay que precisa sobreviver. Porque login sem tabela é teatro: o User morreria no `Ctrl+C`.

**Quando não usar:**
Live coding de 20 minutos só de HTTP. Aí o Hash do projeto 1 continua certo. Banco no quadro errado vira migration no meio do TCPServer.

**Exemplo prático:**

```ruby
# projeto 1 — processo 2, outro Hash
@tasks
# {}

# projeto 2 — processo 2, mesma tabela
Stay.find_by(status: :checked_in).pet.name
# "Thor"
```

**Importante na entrevista:**
Não fale “agora tem persistência” e pare. Fale o contraste: Hash no heap vs linha no SQLite. Quem só diz “usei Rails” parece que trocou de tutorial. Quem diz “o store mudou de lugar” parece que recortou os dois.

**Na entrevista:**
> "No projeto 1 o Hash morria com o processo, igual o List do handler Java, diferente do PHP que zera a cada request. Aqui a Stay está na tabela. Reiniciou, o Thor continua checked_in. Por isso SQLite entra neste e não naquele."

---

## User, Owner, Pet, Stay

**O que é:**
Quatro models. Não seis. User é quem opera o app. Owner é o cliente do hotel. Pet pertence ao Owner. Stay é a hospedagem do Pet. Quem mistura User com Owner na entrevista já embaralhou o domínio.

**Como funciona:**

```
User (João)
  └── Owner (Maria)
        └── Pet (Thor, Luna, Bidu)
              └── Stay (check_in, check_out, nightly_rate_cents, status)
```

Todo mundo `belongs_to :user`. Não é multi-tenant de SaaS. É o recorte: CRUD só do user logado. João não vê o hotel da outra recepcionista. No Laravel você faria `auth()->id()` em todo query. No Spring, `Authentication` + `userId` no spec. Aqui, `current_user.owners` — o capítulo de auth amarra o cookie nisso.

Stay tem `enum :status`: `scheduled` / `checked_in` / `checked_out`. Inteiro no SQLite, predicado no Ruby (`checked_in?`). Um pet só tem uma Stay `checked_in` por vez — regra no model, não só na view. Check-out tem que ser depois do check-in. Mínimo uma diária.

**Quando usar:**
Entrevista de modelagem. Quatro tabelas, três associações, um enum. Cabe no quadro. Não começa por `Room` e `Invoice`.

**Exemplo prático:**
Thor está hospedado. Luna está agendada. Bidu ainda não tem Stay. A tela `/` lista só `checked_in` — hoje, o Thor.

```ruby
enum :status, { scheduled: 0, checked_in: 1, checked_out: 2 }
```

Zero, um, dois no banco. Na view você não mostra `1`. Mostra o nome.

**Na entrevista:**
> "User é o João da recepção. Owner é a Maria, cliente. Pet pertence à Maria. Stay é a hospedagem, com status scheduled, checked_in, checked_out. Um pet não fica checked_in duas vezes. Se o entrevistador misturar User e Owner, eu desenho as quatro caixas no quadro."

---

## Dinheiro em centavos

**O que é:**
`nightly_rate_cents` é integer. `total_cents` é `nights * nightly_rate_cents`. Nunca Float. Nunca `80.00` no banco.

**Como funciona:**
R$ 80,00 vira `8000`. R$ 70,00 vira `7000`. Diárias são dias corridos: `(check_out.to_date - check_in.to_date).to_i`. Thor: 3 noites × 8000 = 24000 centavos. A view formata. O model conta.

Por que não Float? Porque `0.1 + 0.2` no IEEE vira `0.30000000000000004`. JS faz isso. PHP faz isso. Java `double` faz isso. Entrevista de pagamento puxa exatamente isso. A resposta curta: “eu guardo centavos em integer”. A resposta longa: “BigDecimal também serve — no Java é o caminho usual — mas integer de centavos não arredonda no meio da conta e o SQLite não precisa de tipo decimal”.

**Quando usar:**
Qualquer preço, diária, total. Sempre que o campo parece dinheiro.

**Exemplo prático:**

```ruby
def nights
  (check_out.to_date - check_in.to_date).to_i
end

def total_cents
  nights * nightly_rate_cents.to_i
end
```

Thor no seed: check-in hoje, check-out hoje+3, `nightly_rate_cents = 8000`. Três diárias. Vinte e quatro mil centavos. Não `72.0`.

**Na entrevista:**
> "Dinheiro em centavos, integer. Diária 8000 é R$ 80. Total é nights vezes a diária. Float eu não uso em dinheiro — 0.1 + 0.2 não é 0.3. No Java eu usaria BigDecimal ou long de centavos. Aqui é integer."

---

## O que fica de fora

**O que é:**
A lista do que você recusa no quadro, de propósito. Não é esquecimento.

**Como funciona:**

- **Devise.** Auth neste app é `has_secure_password` + `session[:user_id]`. Recover, confirmable, OmniAuth — fora.
- **Hotwire.** Sem Turbo, sem Stimulus. Form HTML, POST, redirect. Igual Blade, igual Thymeleaf. O ponto é o ciclo request/response, não o morph.
- **Sidekiq.** Sem fila. Check-in é request síncrono. E-mail de “Thor chegou” não entra.
- **API JSON.** Sem `accept: application/json`. O projeto 1 já foi isso. Este é browser.
- **Pundit / policy.** Autorização raso: o registro é do `current_user` ou 404. Sem role admin.
- **Postgres, Redis.** SQLite honra o recorte de um processo, um arquivo.
- **Coverage theatre.** Request spec dos fluxos. Sem badge de 100%.

**Quando usar:**
Toda vez que o entrevistador puxar “e o Devise?”. Você aponta o recorte. Não instala a gem no meio da Stay.

**Na entrevista:**
> "Devise, Hotwire, Sidekiq e JSON ficam de fora de propósito. Auth eu mostro no bcrypt e no cookie. Tela é HTML cheio. Fila não tem o que processar. API eu já fiz no projeto 1."

---

## Como o walkthrough anda

**O que é:**
Este é o 2.1 — problema e recorte. O código já está em `projects/02-pet-hotel`. O walkthrough aponta. Não cola a pasta no Markdown.

**Como funciona:**
Você lê o recorte. Sobe o app. Loga com o seed. Os capítulos seguintes desmontam a peça: sessão, model, form, ocupação, spec. Ordem importa. Pular o recorte e ir pro `rails g` é voltar a “gem na cabeça”.

```bash
cd projects/02-pet-hotel
bundle install
bin/rails db:prepare
bin/rails s
```

Abre `http://127.0.0.1:3000`. Login: `joao@email.com` / `senha123`. A ocupação mostra o Thor. Isso honra o recorte: processo sobe, tabela tem dado, tela HTML, user logado.

**Quando usar:**
Agora. Antes de discutir Devise. Se o login do seed não passa, o CRUD não importa.

**Na entrevista:**
> "Eu recorto, subo o Rails, loga o João, o Thor está checked_in. Daqui eu explico has_secure_password, o enum e o integer de centavos. Não começo pela gem."

---

## Recapitulando

- Projeto 1: HTTP + JSON + Hash. Projeto 2: Rails + HTML + SQLite.
- Problema: recepção da Pousada do Thor.
- Recorte: `has_secure_password`, form HTML, sem Devise, sem Hotwire, sem Sidekiq, sem API JSON.
- Hash morre com o processo. Tabela não. Dizer o contraste.
- User é João. Owner é Maria. Pets: Thor, Luna, Bidu. Stay tem status e diária em centavos.
- Dinheiro é integer. Nunca Float.
- Walkthrough em `docs/02-pet-hotel`. Código em `projects/02-pet-hotel`.

---

## Exercícios práticos

### Exercício 1: O que você recorta?

**Enunciado:** O entrevistador pede “um hotel de pets em Rails, com Devise, Turbo, API JSON, Sidekiq no check-in e Postgres”. Você tem 45 minutos. O que entra neste projeto 2 e o que você devolve para o quadro seguinte?

<details>
<summary>Solução</summary>

Entra: User com `has_secure_password`, Owner, Pet, Stay. HTML, form, flash. SQLite. Enum de status. Centavos em integer. Tela de ocupação. Request spec raso.

Fica para depois: Devise, Hotwire, JSON, Sidekiq, Postgres.

No quadro você fala o recorte em 20 segundos e abre o model Stay. Não discute OmniAuth. API JSON você aponta para o projeto 1.

**Pontos-chave:**
- Recorte é resposta, não desculpa
- Quatro models, um auth raso
- Devise na vaga de verdade; bcrypt no exercício
</details>

### Exercício 2: Por que agora tem tabela?

**Enunciado:** No projeto 1 você defendeu Hash na memória. Agora o mesmo handbook pede SQLite. Um colega diz que você se contradisse. O que você responde?

<details>
<summary>Solução</summary>

Não contradisse. O ponto mudou.

Projeto 1: o ponto era HTTP. Persistência atrapalhava. Hash no processo, igual `List` no handler Java. PHP script zeraria a cada curl — por isso o Ruby-de-pé se parecia com Java, não com Laravel.

Projeto 2: o ponto é domínio + login + Stay que sobrevive. User sem tabela é teatro. Thor `checked_in` tem que estar lá depois do reboot. Aí a linha vai para o SQLite, igual Eloquent, igual JPA.

```ruby
# projeto 1
@tasks[1] # morre no Ctrl+C

# projeto 2
Stay.find_by(status: :checked_in) # sobrevive
```

**Pontos-chave:**
- Store muda de lugar quando o ponto muda
- Dizer Hash vs tabela em voz alta
- Banco no projeto 1 quebraria o recorte; Hash neste quebraria o login
</details>

### Exercício 3: Por que não Devise — e por que centavos?

**Enunciado:** Dois puxões clássicos: “por que não Devise?” e “por que a diária não é decimal?”. Responda os dois em tom de entrevista, sem verbete.

<details>
<summary>Solução</summary>

Devise esconde o fio. Vem User, rotas, recover, confirmable. É o Spring Security auto-config, o Breeze do Laravel. Em produção, ok. Em 45 minutos, o entrevistador não vê o `authenticate` nem o cookie. `has_secure_password` grava `password_digest`, compara bcrypt, você põe `session[:user_id]`. No PHP: `password_hash` + `$_SESSION`. No Java: `BCryptPasswordEncoder` + session cookie.

Diária em decimal/Float é armadilha. `0.1 + 0.2 !== 0.3` em JS, PHP e `double` Java. Centavos em integer: R$ 80,00 → `8000`. `nights * nightly_rate_cents`. A view formata. O banco não arredonda.

```ruby
thor.nightly_rate_cents  # 8000
thor.nights              # 3
thor.total_cents         # 24000
```

**Pontos-chave:**
- Devise é gem de produto; bcrypt é o exercício
- Float não guarda dinheiro
- Integer de centavos é a resposta curta que o entrevistador quer ouvir
</details>

---

*Parte do [Ruby Projects Handbook](/)*
