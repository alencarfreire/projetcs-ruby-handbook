# 3.5 Check-in, check-out e 4xx

> **TL;DR**
> Check-in e check-out são POST no membro, igual o 2. A resposta é o Stay em JSON, não redirect. 422 se o model recusar — duas `checked_in` no mesmo pet. 401 sem token. 404 se o id não é do João. 200 no sucesso. O status HTTP é o flash desta API.

## Conteúdo

- [POST no membro](#post-no-membro)
- [200 e o payload](#200-e-o-payload)
- [422 da regra](#422-da-regra)
- [O helper render_errors](#o-helper-render_errors)
- [Check-out](#check-out)
- [O que não é 500](#o-que-não-é-500)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## POST no membro

**O que é:**
Ação. Não é PATCH de `status`. É `POST /api/v1/stays/:id/check_in`. O cliente diz a intenção. O servidor aplica a regra.

**Como funciona:**
Rotas:

```ruby
resources :stays do
  member do
    post :check_in
    post :check_out
  end
end
```

Igual o HTML. O entrevistador já viu o path no 2. Aqui some o `button_to`. Fica o curl.

PATCH genérico de status deixaria o cliente mandar `checked_out` sem passar na action. Recorte: as duas actions existem. `status` no create ainda aceita `scheduled` — abertura da estadia, não o check-in do dia.

**Quando usar:**
Transição com regra. Check-in tem “só uma por pet”. PATCH cru fura.

**Na entrevista:**
> "POST check_in no membro. Não é PATCH status. A intenção fica no path. A regra fica no model."

---

## 200 e o payload

**O que é:**
Deu certo. Body é o Stay depois da transição. O cliente atualiza a tela sem GET extra.

**Como funciona:**

```ruby
def check_in
  if @stay.update(status: :checked_in)
    render json: stay_payload(@stay)
  else
    render_errors(@stay)
  end
end
```

200 default. Não é 201 — o recurso já existia. Não é 204 — o cliente quer o status novo.

Occupancy depois: `GET /api/v1/occupancy` inclui o Thor.

**Exemplo prático:**
Stay scheduled do Thor. POST check_in. JSON `"status":"checked_in"`. GET occupancy. `pet_name` Thor.

**Na entrevista:**
> "200 com o stay. 201 é create. Check-in não cria. Eu devolvo o body para o cliente não chutar o status."

---

## 422 da regra

**O que é:**
O model recusou. Duas `checked_in` no mesmo pet. Check-out antes do check-in. Diária zero. A API não inventa mensagem — pega `full_messages`.

**Como funciona:**
O spec manda a segunda stay já `checked_in`. 422. `Stay.checked_in.where(pet: thor).count` continua 1.

A regra mora no model. O controller só pergunta `update`. Se você validar só no controller, o `rails console` fura. Entrevista puxa isso.

**Quando usar:**
Qualquer recusa de negócio. 422, não 400. 400 é params malformado (`require` explode). 422 é o recurso entendido e recusado.

**Na entrevista:**
> "422 é a regra. 400 é o parse. Duas checked_in no Thor: 422. JSON sem stay: 400."

---

## O helper render_errors

**O que é:**
Um método no pai. Padroniza o body.

**Como funciona:**

```ruby
def render_errors(record, status: :unprocessable_entity)
  render json: { errors: record.errors.full_messages }, status: status
end
```

Sempre array em `errors`. Login sem senha certa também usa array — outra mensagem, mesmo formato. O cliente trata um shape.

**Exemplo prático:**
`{ "errors": ["Pet já está hospedado — só uma stay checked_in por vez"] }`. pt-BR. O locale do 2 continua.

**Na entrevista:**
> "Um shape de erro. errors é array de string. Eu não misturo { email: [] } com { errors: [] } neste recorte."

---

## Check-out

**O que é:**
A saída. Thor some da occupancy. Stay fica `checked_out`. Total não muda — as diárias já estavam nas datas.

**Como funciona:**
`update(status: :checked_out)`. A validação `only_one_checked_in_stay_per_pet` só corre quando `checked_in?`. Check-out não esbarra nela.

Check-out de stay `scheduled`? O model deixa, neste recorte. Se a vaga pedir “só checked_in faz check-out”, você adiciona. Não inventa agora.

**Na entrevista:**
> "Check-out é status. As datas não se mexem. Occupancy filtra checked_in, então o Thor sai da lista."

---

## O que não é 500

**O que é:**
A lista do que o entrevistador tenta explodir.

**Como funciona:**

| Situação | Status |
|---|---|
| Sem header | 401 |
| Bearer lixo | 401 |
| id inexistente | 404 |
| id de outro user | 404 |
| regra do model | 422 |
| JSON sem wrapper | 400 |
| create ok | 201 |
| check-in ok | 200 |
| delete ok | 204 |

`rescue_from ActiveRecord::RecordNotFound` cobre o `find`. Sem o rescue, 500 com stack. O cliente JSON não quer stack.

**Na entrevista:**
> "Eu mapeio RecordNotFound para 404 JSON. 500 é bug meu, não token errado."

---

## Recapitulando

- POST check_in / check_out no membro
- 200 com payload; 422 com errors
- Regra no model, controller só pergunta
- 401 identidade, 404 recurso, 422 regra
- Sem 500 para find que errou o id

---

## Exercícios práticos

### Exercício 1: PATCH status

**Enunciado:** O entrevistador pede para você aceitar `PATCH /stays/:id` com `{ "stay": { "status": "checked_in" } }` no lugar do POST de ação. Você troca?

<details>
<summary>Solução</summary>

O update já permite `:status` no permit — o recorte HTML deixou. A action `check_in` existe para o fluxo da recepção. Os dois caminhos batem no mesmo model, então a regra segura. Na entrevista: “o PATCH genérico existe; o POST nomeia a intenção. Eu uso o POST no quadro.”

**Pontos-chave:**
- model é a cerca de verdade
- path de ação documenta
- permit :status é herança do 2
</details>

### Exercício 2: Segunda checked_in via check_in

**Enunciado:** Thor já está hospedado. Você abre outra stay scheduled e manda POST check_in. Qual status? O que o body traz?

<details>
<summary>Solução</summary>

422. `only_one_checked_in_stay_per_pet`. `errors` com a frase do model. Occupancy continua com um Thor. A stay scheduled permanece scheduled — o `update` falhou, não mudou.

**Pontos-chave:**
- update false não persiste
- 422 não é 409 neste recorte (poderia ser; você fala 422)
- occupancy prova o efeito
</details>

---

*Parte do [Ruby Projects Handbook](/)*
