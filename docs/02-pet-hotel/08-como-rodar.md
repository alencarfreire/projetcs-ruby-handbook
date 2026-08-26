# 2.8 Como rodar

> **TL;DR**
> `cd projects/02-pet-hotel`. `bundle install`. `bin/rails db:prepare`. `bin/rails s`. Abre `http://127.0.0.1:3000`. Login seed: `joao@email.com` / `senha123`. Clica ocupação, donos, pets, hospedagens, check-in. Teste: `bundle exec rspec`. Seeds: João, Maria, Thor, Luna, Bidu. Fonte: [código](/docs/02-pet-hotel/codigo) e [projetos](/projetos) — sem sair do handbook. SQLite sobrevive ao `Ctrl+C`. Diferente do Hash do projeto 1. O entrevistador quer ver você clicando, não o slide.

## Conteúdo

- [Fonte no handbook](#fonte-no-handbook)
- [bundle install](#bundle-install)
- [db:prepare](#dbprepare)
- [bin/rails s](#binrails-s)
- [Login seed](#login-seed)
- [Roteiro de cliques](#roteiro-de-cliques)
- [Check-in](#check-in)
- [Seeds](#seeds)
- [bundle exec rspec](#bundle-exec-rspec)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Fonte no handbook

**O que é:**
O app inteiro está neste livro. Você não precisa do GitHub para ler o código.

**Como funciona:**
Walkthrough é `docs/02-pet-hotel/`. Código que sobe é `projects/02-pet-hotel/`. A página [código (models e auth)](/docs/02-pet-hotel/codigo) cola a fonte. [Projetos](/projetos) tem a pasta e o comando. A [página de código](/docs/02-pet-hotel/codigo) traz o roteiro de cliques.

No projeto 1 você lia `server.rb` na página de código e rodava `ruby server.rb`. Aqui é a mesma ideia com Rails: lê no handbook, sobe com `bin/rails s`. GitHub existe. Não é o único caminho. Na call, abre o handbook e o terminal.

**Quando usar:**
Antes de `bundle`. Se você só manda o link do repositório, o revisor que não clona não vê nada.

**Na entrevista:**
> "O código está no handbook. models e auth na página de código. Pasta em projetos. Eu não dependo do GitHub para mostrar a fonte."

---

## bundle install

**O que é:**
Instala as gems. Rails 8.1, SQLite, bcrypt, RSpec. Sem `bundle`, não tem `bin/rails`.

**Como funciona:**

```bash
cd projects/02-pet-hotel
bundle install
```

Você quer ver o Gemfile.lock atualizado e o caminho das gems. Ruby 3.3+. bcrypt entra por causa do `has_secure_password`. sqlite3 é o banco. rspec-rails mora no group `:development, :test`. Sem Devise. Sem Hotwire. Sem Sidekiq. O Gemfile já recorta.

No projeto 1 não tinha Gemfile. `ruby server.rb` bastava. Aqui tem gem. Por isso o primeiro comando é `bundle`. No PHP do Composer é o mesmo gesto: instala dependência, depois sobe o server. No Maven do Spring, `mvn`. Aqui, Bundler.

Porta o `bundle check` se já instalou. Falhou? Ruby errado ou gem nativa (sqlite3) sem toolchain. Não troca de banco no meio da entrevista.

**Quando usar:**
Máquina nova, clone novo, Gemfile mudou. Toda vez que o `bin/rails` reclamar de gem.

**Na entrevista:**
> "Bundle primeiro. Rails 8, SQLite, bcrypt. Sem Devise. Sem Turbo. O recorte está no Gemfile."

---

## db:prepare

**O que é:**
Um comando. Cria o SQLite, roda migrations, dispara seeds no development.

**Como funciona:**

```bash
bin/rails db:prepare
```

`storage/development.sqlite3` aparece. Tabelas: users, owners, pets, stays. Seeds: João, Maria, Thor, Luna, Bidu. O README fecha: `db:prepare` cria, migra e semeia. Você não encadeia `db:create`, `db:migrate`, `db:seed` na call — a menos que o entrevistador peça o passo a passo.

`db:migrate` só aplica migration. Banco novo sem create falha. `db:seed` sozinho assume tabela pronta. `db:reset` dropa e recomeça — some o que você clicou. `db:prepare` é o idempotente do README.

Teste tem banco próprio: `storage/test.sqlite3`. RSpec não lê o seed do development. Cada spec cria João de novo. Dois arquivos, dois mundos. Igual o `phpunit.xml` apontando para outro schema. Diferente do Hash do projeto 1, que era um processo só.

**Quando usar:**
Primeira subida. Depois de puxar migration nova. Quando o login seed falhar porque o banco está vazio.

**Exemplo prático:**
Rodou `bin/rails s` sem `db:prepare`. Tela de login sobe. `joao@email.com` não autentica. Users vazio. Não é bcrypt quebrado. É seed que não rodou.

**Na entrevista:**
> "db:prepare. Cria, migra, seed. Development. Teste é outro SQLite. RSpec não usa o João do seed."

---

## bin/rails s

**O que é:**
Puma. HTML. Porta 3000.

**Como funciona:**

```bash
bin/rails s
```

Você quer ver: `Listening on http://127.0.0.1:3000`. Abre no browser. Sem login, `GET /` redireciona para `/login`. Isso é o `require_login`, não bug.

`Ctrl+C` mata o Puma. O SQLite fica. Sobe de novo, João continua. No projeto 1, `Ctrl+C` zerava o Hash. Aqui a linha sobrevive. No Laravel com SQLite é a mesma persistência. No `HttpServer` Java com `List`, não.

Porta ocupada: outro `rails s` ficou de pé. Mata ele. Não muda a porta na entrevista. `bin/dev` existe no `bin/setup`. O README é `bin/rails s`. Você honra o README.

**Quando usar:**
Depois do `db:prepare`. Antes do primeiro clique.

**Na entrevista:**
> "bin/rails s. 3000. HTML, não JSON. Ctrl+C não apaga o João. SQLite, não Hash."

---

## Login seed

**O que é:**
O usuário que o README te entrega. João opera a Pousada do Thor.

**Como funciona:**
Abre `http://127.0.0.1:3000`. Cai em `/login`. E-mail `joao@email.com`. Senha `senha123`. Entrar. Flash: "Login feito." Root: "Quem está no hotel agora."

Cookie de sessão. `has_secure_password` + `session[:user_id]`. Sem Devise. Sem JWT. Sem API. Sem login, CRUD redireciona para `/login`. É o spec de autenticação falando.

Senha errada: 422, "E-mail ou senha inválidos." Cadastro é `/signup` — não precisa se o seed rodou. Na call você loga o João. Não cria outro user só para parecer completo.

**Quando usar:**
Primeiro clique depois do server no ar. Se o seed não entrou, volte no `db:prepare`.

**Importante na entrevista:**
Decorar o par. `joao@email.com` / `senha123`. Pedir para o revisor adivinhar senha é teatro.

**Na entrevista:**
> "Login seed: joao@email.com, senha123. Sessão no cookie. Sem Devise. Cai na ocupação."

---

## Roteiro de cliques

**O que é:**
O curl do projeto 2. Você clica o que o README lista. Nav logada: Quem está no hotel, Donos, Pets, Hospedagens.

**Como funciona:**

Ocupação (`/`): tabela de stays `checked_in`. Seed coloca o Thor hospedado. Você vê Thor, Maria, check-in hoje, check-out em 3 dias, total `R$ 240,00` (3 × 8000 centavos). Luna está `scheduled` — **não** aparece. Bidu não tem stay. A tela mente se listar os três.

Donos (`/owners`): Maria, `maria@email.com`, `(11) 99999-0000`. Clica o nome, show. "Novo dono" existe. Na demo do seed, você mostra a Maria. Não cadastra um quarto dono sem o entrevistador pedir.

Pets (`/pets`): Thor (cão), Luna (gato), Bidu (cão). Os três da Maria. Dono na coluna. Show do Thor aponta para a Maria.

Hospedagens (`/stays`): Thor `Hospedado`, Luna `Agendada`. Totais em `R$`. Link no nome do pet abre o show. É aí que mora o botão de check-in.

Ordem importa. Ocupação primeiro prova o seed. Donos e pets provam o CRUD do user logado. Stays provam o `enum`. Pular a ocupação e ir para o form esconde se o João nem logou.

**Quando usar:**
Live coding. Take-home na hora de gravar. Qualquer "mostra rodando".

**Exemplo prático:**
Nav: **Quem está no hotel** → Thor só. **Donos** → Maria. **Pets** → Thor, Luna, Bidu. **Hospedagens** → Thor hospedado, Luna agendada. Quatro cliques. Um minuto.

**Na entrevista:**
> "Eu clico o README. Ocupação tem o Thor. Luna não. Donos, pets, stays. Se a ocupação listar a Luna, o recorte quebrou."

---

## Check-in

**O que é:**
POST no membro. Status `scheduled` → `checked_in`. Botão no show da stay.

**Como funciona:**
Hospedagens → Luna → **Fazer check-in**. Flash: "Check-in feito." Status vira `Hospedado`. Volta em **Quem está no hotel**: Thor e Luna. Bidu continua fora.

Thor já está `checked_in`. O botão dele é **Fazer check-out**, não check-in de novo. Dois `checked_in` no mesmo pet a validação barra — 422 no create, alert no POST de check-in. Você não demonstra o caminho feliz forçando o Thor de novo.

Check-out tira da ocupação. Luna `scheduled` some da root. A ocupação não é a lista de stays. É o recorte `checked_in` com `includes(:pet, :owner)`.

No Spring seria `POST /stays/{id}/check-in`. No Laravel, rota member. Aqui: `post :check_in` no `resources :stays`. Sem Turbo. Form HTML. `button_to` com POST.

**Quando usar:**
Depois de mostrar a ocupação só com o Thor. O segundo clique que prova o `enum`.

**Na entrevista:**
> "Stay da Luna, Fazer check-in. Ocupação passa a ter Thor e Luna. Bidu não. Check-in não é editar a stay no form — é o POST do member."

---

## Seeds

**O que é:**
`db/seeds.rb`. Idempotente. O hotel de demo.

**Como funciona:**
João (`joao@email.com` / `senha123`) opera. Maria é dona. Pets: Thor cão, Luna gato, Bidu cão. Stay do Thor: `checked_in`, 3 noites, 8000. Stay da Luna: `scheduled`, daqui a 5 dias, 7000. Bidu sem stay — para a ocupação não mentir.

`find_or_initialize_by` + `save!`. Rodar `db:seed` duas vezes não duplica o João. Senha é reatribuída. Datas usam `Date.current`, então a ocupação do Thor continua "agora" amanhã.

RSpec **não** carrega esse arquivo. Spec cria o hotel na mão. Seed é development. Confundir os dois: "o teste falhou porque apaguei o João" — apagou no SQLite errado.

**Quando usar:**
Demo. Screenshot. Primeira aula. Não é fixture de spec.

**Na entrevista:**
> "Seed: João loga, Maria é dona, Thor hospedado, Luna agendada, Bidu sem stay. Idempotente. Teste não usa seed."

---

## bundle exec rspec

**O que é:**
Request spec dos fluxos. Sem coverage theatre. Sem Capybara neste recorte.

**Como funciona:**

```bash
bundle exec rspec
```

Três arquivos em `spec/requests/`:

| Arquivo | O que prova |
|---|---|
| `authentication_spec.rb` | signup, login, logout, senha curta |
| `crud_spec.rb` | sem login redireciona; João cria dono, pet, stay |
| `stays_and_occupancy_spec.rb` | um `checked_in` por pet; ocupação só Thor; `total_cents` |

Você espera pontos verdes. Não abre SimpleCov. Não conta 100%. GUIDE: fluxos principais. O entrevistador pergunta "e teste?". Você roda o RSpec e aponta o spec da ocupação — Luna não entra no body.

Cliques na call. RSpec no CI e quando pedirem arquivo. Os dois cobrem o mesmo recorte. Clique não substitui o spec. Spec não substitui você logando o João na tela.

**Quando usar:**
Antes de gravar o take-home. Quando o check-in "não aparece" — o spec da ocupação diz se o filtro quebrou.

**Na entrevista:**
> "bundle exec rspec. Request spec. Auth, CRUD, ocupação. Sem coverage theatre. Na call eu clico; o arquivo é o rspec."

---

## Recapitulando

- Fonte: [código](/docs/02-pet-hotel/codigo) e [projetos](/projetos). Sem depender só do GitHub.
- `bundle install` → `bin/rails db:prepare` → `bin/rails s`.
- Login: `joao@email.com` / `senha123`.
- Cliques: ocupação (Thor), donos (Maria), pets (Thor, Luna, Bidu), stays, check-in da Luna.
- Seeds no development. Idempotente. Teste não lê seed.
- `bundle exec rspec` nos fluxos. Sem coverage theatre.
- `Ctrl+C` não zera o SQLite. Diferente do Hash do projeto 1.

---

## Exercícios práticos

### Exercício 1: Subir do zero

**Enunciado:** Máquina com o clone. Sem banco. Sem gems na pasta. Quais três comandos você roda, o que cada um deixa pronto, e o que você espera no browser antes do login?

<details>
<summary>Solução</summary>

```bash
cd projects/02-pet-hotel
bundle install
bin/rails db:prepare
bin/rails s
```

`bundle` instala Rails, sqlite3, bcrypt, rspec-rails. `db:prepare` cria `storage/development.sqlite3`, migra, semeia João. `bin/rails s` escuta em `http://127.0.0.1:3000`.

Sem sessão: `GET /` redireciona para `/login`. Não é 404. Não é API JSON. Tela HTML de login. O seed já está no banco — você ainda não autenticou.

**Pontos-chave:**
- Ordem do README, não `db:migrate` solto
- 3000, não 4567
- Redirect para login prova o `require_login`
</details>

### Exercício 2: Do login ao check-in da Luna

**Enunciado:** Server no ar, seed rodado. Você loga o João. Descreva os cliques até a ocupação mostrar Thor **e** Luna. O que não pode aparecer em cada tela?

<details>
<summary>Solução</summary>

1. `/login` → `joao@email.com` / `senha123` → flash "Login feito."
2. Root: **Quem está no hotel agora**. Thor sim. Luna não. Bidu não. Total do Thor `R$ 240,00`.
3. **Donos**: só Maria.
4. **Pets**: Thor, Luna, Bidu — os três da Maria.
5. **Hospedagens**: Thor `Hospedado`, Luna `Agendada`.
6. Clica Luna → **Fazer check-in** → "Check-in feito."
7. **Quem está no hotel**: Thor e Luna. Bidu continua fora.

Se a ocupação já listava a Luna no passo 2, o seed não está `scheduled` ou o `checked_in` vazou. Se o Bidu aparecer na ocupação, alguém criou stay `checked_in` para ele.

**Pontos-chave:**
- Ocupação ≠ lista de stays
- Check-in é o botão do show, POST member
- Bidu existe para a ocupação poder ficar vazia dele
</details>

### Exercício 3: RSpec e o SQLite errado

**Enunciado:** Você apaga o João no `rails console` de development, roda `bundle exec rspec`, e os specs passam. Depois abre o browser e o login seed falha. O que quebrou? O que não quebrou? Como você recupera a demo sem resetar o teste?

<details>
<summary>Solução</summary>

Dois bancos. Development: `storage/development.sqlite3`. Teste: `storage/test.sqlite3`. RSpec cria João no test, isolado, sem seed. Apagar o João no console não toca o test. Specs verdes. Browser no 3000 lê development vazio — `senha123` não autentica.

Não quebrou o recorte de teste. Quebrou a demo. Recupera:

```bash
bin/rails db:seed
```

Ou `db:prepare` de novo. Não rode `RAILS_ENV=test db:seed`. Não aponte o test para o arquivo de development.

No projeto 1 não existia essa cisão: um processo, um Hash. Aqui Active Record tem env. Dizer isso em voz alta.

**Pontos-chave:**
- Seed ≠ spec
- Dois SQLite
- `db:seed` devolve o João da call
</details>

---

*Parte do [Ruby Projects Handbook](/)*
