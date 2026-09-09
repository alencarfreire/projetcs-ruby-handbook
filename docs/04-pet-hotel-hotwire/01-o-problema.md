# 4.1 O problema e o recorte

> **TL;DR**
> Mesmo hotel HTML do 2. O quadro de ocupação agora é um Turbo Frame. Check-out no quadro troca o HTML do frame — sem recarregar a página. Stream no response deste POST. Outra aba **não** atualiza. Isso não é bug. É o recorte. Cable é o projeto 6. Stimulus não entra.

## Conteúdo

- [Este projeto não é o 2](#este-projeto-não-é-o-2)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [Drive, Frame, Stream](#drive-frame-stream)
- [O que fica de fora](#o-que-fica-de-fora)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Este projeto não é o 2

**O que é:**
O 2 já tem o quadro. Reload inteiro a cada check-out. Este recorte pega **um pedaço** da página e troca só ele.

**Como funciona:**
João está no `/`. Thor na tabela. Clica check-out. O servidor devolve um Turbo Stream. O frame `occupancy` é substituído. A navbar não pisca. O CSS não recarrega.

No 2, `redirect_to @stay` — visita nova. Aqui, se o Accept é `text/vnd.turbo-stream.html`, você renderiza o stream. Sem JS extra: `import "@hotwired/turbo-rails"`.

**Quando usar:**
Vaga que pede Hotwire. Take-home “atualiza a lista sem SPA”. Live coding depois do CRUD HTML.

**Na entrevista:**
> "Eu não montei React. Eu recortei o quadro num Frame e respondi Stream no check-out. O HTML continua a fonte. Turbo é o envelope."

---

## O problema

**O que é:**
A recepção olha o quadro o dia inteiro. Check-out de um pet não precisa recarregar donos, nav, fonte. Precisa tirar a linha.

**Como funciona:**
O quadro vira `turbo_frame_tag "occupancy"`. O botão check-out mora **dentro** do frame. O POST devolve streams: replace occupancy, replace stay (se a stay estiver na página), update flash.

Stay show também: check-in no card. O card é `turbo_frame_tag stay`. Status muda no lugar.

**Exemplo prático:**
Seed: Thor `checked_in`. João clica **Fazer check-out** no `/`. Contador vai a zero. Mensagem “Check-out feito.” no flash. URL continua `/`.

**Na entrevista:**
> "O problema é o quadro, não o site inteiro virar SPA. Eu recorto occupancy. O resto do CRUD ganha Drive de graça."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| `turbo-rails` + importmap | Stimulus |
| Frame no quadro | Cable, `turbo_stream_from` |
| Stream no check-in/out | morphing, lazy frame |
| Drive no resto | React, Vue |
| request spec do stream | system spec Capybara |
| HTML do 2 | API JSON, Sidekiq |

Por que sem Stimulus? Stimulus é JS de sprinkles: menu, debounce. O quadro não precisa. O entrevistador puxa Frame vs Stream vs Cable. Stimulus é outra aula.

Por que sem Cable? Stream no **response** atualiza quem fez o POST. A aba do lado não é esse request. Cable empurra. Projeto 6.

**Na entrevista:**
> "Hotwire neste livro é Drive + Frame + Stream no response. Cable é outro projeto. Se eu misturo, eu não sei o que o WebSocket faz."

---

## Drive, Frame, Stream

**O que é:**
Três camadas. A entrevista quer as três frases.

**Como funciona:**

- **Drive** — click e submit viram fetch. Body inteiro troca, sem reload de CSS. Os forms do 2 já ganham isso quando o JS do Turbo entra.
- **Frame** — um `id` no DOM. Submit **dentro** do frame pede só aquele pedaço. Você também pode responder Stream e `replace` o frame de fora.
- **Stream** — o response é XML de ações: `replace`, `update`, `remove`. Turbo executa no DOM atual.

**Quando usar:**
Drive: o default. Frame: um pedaço. Stream: várias ações no mesmo response (quadro + flash + card).

**Na entrevista:**
> "Drive é a visita. Frame é o recorte. Stream é a lista de mutações. Cable usa Stream por cima do WebSocket — outro cabo."

---

## O que fica de fora

**O que é:**
A lista para falar alto.

**Como funciona:**
Stimulus, Cable, Sidekiq, API, morph (`turbo:morph`), lazy `src:` no frame, pagination. O quadro da Pousada cabe numa tabela.

**Na entrevista:**
> "Se pedirem Stimulus, eu digo: não tem comportamento de cliente neste recorte. O servidor manda HTML."

---

## Como o walkthrough anda

**O que é:**
4.2 as três peças. 4.3 o Frame. 4.4 o Stream. 4.5 o limite (outra aba). 4.6 como rodar. [Código](/docs/04-pet-hotel-hotwire/codigo).

**Na entrevista:**
> "Eu subi, fiz check-out no quadro, a linha sumiu. Abri outra aba: o Thor ainda estava. Aí eu falo do projeto 6."

---

## Recapitulando

- Mesmo HTML do 2, Turbo no quadro
- Frame `occupancy` + Stream no check-out
- Outra aba não atualiza — recorte, não bug
- Sem Stimulus, sem Cable

---

## Exercícios práticos

### Exercício 1: SPA?

**Enunciado:** O entrevistador fala “então é uma SPA”. Você concorda?

<details>
<summary>Solução</summary>

Não. SPA é o JS dono do estado. Aqui o servidor manda HTML. Turbo troca o DOM. Sem Turbo, o `button_to` ainda funciona: visita cheia, redirect, quadro novo. Progressive enhancement. A entrevista quer essa frase.

**Pontos-chave:**
- HTML primeiro
- Turbo é envelope
- sem JS o check-out ainda grava
</details>

### Exercício 2: Por que o quadro e não o CRUD inteiro

**Enunciado:** Por que Frame só na occupancy?

<details>
<summary>Solução</summary>

O quadro é o lugar que a recepção olha em loop. Create de dono pode recarregar. Recorte de entrevista: um Frame que justifica a frase. Frame em tudo é tutorial de gem.

**Pontos-chave:**
- recorte = um problema
- Drive já ajuda o resto
- occupancy é o demo
</details>

---

*Parte do [Ruby Projects Handbook](/)*
