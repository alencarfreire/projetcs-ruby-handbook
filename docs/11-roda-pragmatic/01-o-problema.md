# 11.1 Arquitetura A: pragmática

> **TL;DR**
> Roda + Sequel + Rodauth no mesmo app. Um `app.rb`, um `db.rb`. JWT. Dataset Hash. Sem hash_routes. Sem service object. Eventos na tabela. Conta em `accounts`. Lote não entra. Esta é a stack Jeremy Evans pura, recorte de take-home.

## Conteúdo

- [O que é A](#o-que-é-a)
- [O recorte](#o-recorte)
- [Por que um arquivo](#por-que-um-arquivo)
- [Memória e latência](#memória-e-latência)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## O que é A

**O que é:**
A árvore inteira no `route`. A conexão no `db.rb`. Auth no plugin. Persistência no dataset. Zero camada no meio.

**Como funciona:**
João cria conta em `/create-account`. Loga em `/login`. Copia o JWT. Cria “Sunset Jazz” em `/eventos`. O `require_authentication` barra quem não tem o header.

**Quando usar:**
API pequena. 45 minutos. Um domínio. Quando o arquivo ainda cabe no quadro.

**Na entrevista:**
> "A. Tudo no route. Dataset Hash. Rodauth JWT. Sem interactor. Quando o arquivo crescer, eu parto com hash_routes — isso é B."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Roda + Sequel + Rodauth | hash_routes |
| JWT, `json: :only` | cookie, ERB |
| `DB[:eventos]` | `Evento` model obrigatório |
| accounts + eventos | lote, webhook, compra |
| halt 401/422/404 | dry-schema |

**Na entrevista:**
> "Um recorte. A não é C. Se a regra não pode conhecer Roda, isso é hexagonal, capítulo 13."

---

## Por que um arquivo

**O que é:**
O ponto de A. Você vê o fio sem pular pasta.

**Como funciona:**
`r.rodauth` no topo do route. `r.on "eventos"` embaixo. `db.rb` no require. O entrevistador lê de cima a baixo.

**Na entrevista:**
> "app.rb é o quadro. db.rb é o banco. Dois arquivos. Não quinze."

---

## Memória e latência

**O que é:**
Consequência, não slogan. Sem Rails, sem AR, sem middleware de sessão HTML.

**Como funciona:**
Processo magro. JWT stateless: o server não consulta a session store. Consulta a tabela no CRUD. Auth é o token assinado — o account_id vem no payload. Você ainda pode (e no create consulta) o banco do evento.

Números de blog (~36 MB) não são prova neste take-home. Você mede se a vaga pedir. Aqui: menos gem, menos boot.

**Na entrevista:**
> "Magro porque a stack é magra. Eu não vendo benchmark de internet. Eu vendo o Gemfile."

---

## Como o walkthrough anda

**O que é:**
11.2 boot. 11.3 Rodauth JWT. 11.4 CRUD. 11.5 status. 11.6 ponte para B. 11.7 curls. [Código](/docs/11-roda-pragmatic/codigo).

**Na entrevista:**
> "Eu criei a conta, copiei o Authorization, postei o Jazz, sem token 401."

---

## Recapitulando

- A = dois arquivos
- JWT + dataset
- Sem lote
- Sem hash_routes
- Magreza é Gemfile, não slide

---

## Exercícios práticos

### Exercício 1: Por que não Devise

**Enunciado:** “Rodauth é Devise do Roda?” Resposta?

<details>
<summary>Solução</summary>

Não. Devise é Rails/Warden. Rodauth é feature de auth em Roda/Sequel (roda em qualquer Rack). JWT é feature, não gem à parte de sessão. Você habilita o que usa: login, create_account, jwt. Sem recover, sem OmniAuth neste recorte.

**Pontos-chave:**
- feature flag
- json: :only
- não é Devise
</details>

---

*Parte do [Ruby Projects Handbook](/)*
