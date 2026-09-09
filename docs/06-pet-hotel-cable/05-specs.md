# 6.5 Specs

> **TL;DR**
> Channel spec: connection rejeita anônimo, identifica o user da session; occupancy confirma o stream. Request spec: check-in `have_broadcasted_to(joao).from_channel(OccupancyChannel)`. Adapter `:test`. Sem Redis. Sem Capybara.

## Conteúdo

- [Connection spec](#connection-spec)
- [Channel spec](#channel-spec)
- [Broadcast no request](#broadcast-no-request)
- [O que não entra](#o-que-não-entra)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Connection spec

**O que é:**
O handshake.

**Como funciona:**

```ruby
connect "/cable", session: { user_id: joao.id }
expect(connection.current_user).to eq(joao)

expect { connect "/cable" }.to have_rejected_connection
```

`type: :channel`. Sem browser. A session do helper é a mesma chave `user_id` do cookie real.

**Na entrevista:**
> "Eu testo o reject. Sem isso o channel spec assume current_user e mente o cadeado."

---

## Channel spec

**O que é:**
O subscribe.

**Como funciona:**

```ruby
stub_connection current_user: joao
subscribe
expect(subscription).to be_confirmed
expect(subscription).to have_stream_for(joao)
```

`stub_connection` pula o handshake — por isso o spec da Connection existe separado.

**Na entrevista:**
> "have_stream_for joao. Se eu stream_from occupancy, este spec vermelho. É o recorte por user."

---

## Broadcast no request

**O que é:**
O POST de check-in emite.

**Como funciona:**

```ruby
expect {
  post check_in_stay_path(stay)
}.to have_broadcasted_to(joao).from_channel(OccupancyChannel)
```

`ActionCable::TestHelper`. Prova o controller, não só o channel isolado. Update false (segunda checked_in) não precisa de example negativo neste recorte — o 2 já cobre a recusa.

**Na entrevista:**
> "have_broadcasted_to no POST. Eu não só unitizo o channel. O fio é o check-in."

---

## O que não entra

**O que é:**
System spec abrindo duas janelas. Selenium no WS. Stub do innerHTML.

**Como funciona:**
A prova das duas janelas é o 6.6, na mão. Spec cobre identidade, stream, emissão. JS de uma linha não ganha Jest neste livro.

**Na entrevista:**
> "Capybara no WebSocket é caro. Eu clico na call. O rspec bate o cabo no servidor."

---

## Recapitulando

- reject + identify
- stream_for
- broadcast no POST
- adapter test
- duas janelas na mão

---

## Exercícios práticos

### Exercício 1: have_broadcasted_to(stay)

**Enunciado:** Você broadcast_to stay e o spec testa o user. Vermelho. Quem está certo?

<details>
<summary>Solução</summary>

O spec. Painel é do user. Stay é o evento. Stream por stay exigiria a página assinar cada stay — o quadro assina uma vez. broadcast_to user.

**Pontos-chave:**
- um stream, um painel
- stay é payload, não stream
- spec documenta o alvo
</details>

### Exercício 2: Spec sem TestHelper

**Enunciado:** `have_broadcasted_to` undefined. O que faltou?

<details>
<summary>Solução</summary>

`config.include ActionCable::TestHelper`. Adapter test no cable.yml. Sem os dois, o matcher não existe ou o broadcast vai para o async real.

**Pontos-chave:**
- helper
- cable.yml test
- igual ActiveJob :test
</details>

---

*Parte do [Ruby Projects Handbook](/)*
