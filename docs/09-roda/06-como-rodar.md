# 9.6 Como rodar

> **TL;DR**
> `cd projects/09-roda-routing`. `bundle install`. `bundle exec puma`. Porta 9292. `GET /` devolve o name. POST cria Sunset Jazz. `Ctrl+C` zera o Hash. Fonte: [código](/docs/09-roda/codigo).

## Conteúdo

- [bundle](#bundle)
- [puma](#puma)
- [Roteiro de curls](#roteiro-de-curls)
- [Restart](#restart)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## bundle

**O que é:**
Duas gems: `roda`, `puma`.

**Como funciona:**

```bash
cd projects/09-roda-routing
bundle install
```

Sem Sequel. Sem Rodauth. Gemfile curto de propósito.

**Na entrevista:**
> "Duas gems. Roda e Puma. Eu não puxo a stack inteira para mostrar o r.on."

---

## puma

**O que é:**
O processo.

**Como funciona:**

```bash
bundle exec puma
```

`http://127.0.0.1:9292`. `config.ru` já aponta. Mata com `Ctrl+C`.

**Na entrevista:**
> "Puma na 9292. O route não sabe a porta."

---

## Roteiro de curls

**O que é:**
A prova.

**Como funciona:**

```bash
curl -s http://127.0.0.1:9292/
# {"name":"ingressos-routing"}

curl -s http://127.0.0.1:9292/eventos
# []

curl -s -i -X POST http://127.0.0.1:9292/eventos \
  -H "Content-Type: application/json" \
  -d '{"title":"Sunset Jazz","venue":"Sala 2"}'
# 201, Location: /eventos/1

curl -s http://127.0.0.1:9292/eventos/1
curl -s http://127.0.0.1:9292/eventos/9
# 404
```

Header JSON no POST. Sem ele, 422 de title.

**Na entrevista:**
> "Eu criei o Sunset Jazz. Location /eventos/1. GET bateu. 9 deu 404."

---

## Restart

**O que é:**
A prova do Hash.

**Como funciona:**
Cria o evento. `Ctrl+C`. Sobe de novo. `GET /eventos` → `[]`. O id volta a 1 no próximo POST. Não é bug.

**Na entrevista:**
> "Restart zerou. Hash no processo. Sequel é a próxima pasta."

---

## Recapitulando

- bundle + puma
- 9292
- Content-Type no POST
- Ctrl+C apaga o Jazz

---

## Exercícios práticos

### Exercício 1: Porta ocupada

**Enunciado:** 9292 já tem alguém. O que você faz na call?

<details>
<summary>Solução</summary>

`bundle exec puma -p 9293` e ajusta o curl. Ou mata o outro. Não briga com o bind.

**Pontos-chave:**
- porta é Puma
- curl segue a porta
</details>

### Exercício 2: 422 inesperado

**Enunciado:** Title está no body. 422. Primeira suspeita?

<details>
<summary>Solução</summary>

`Content-Type`. json_parser não correu. params vazio. Segunda: JSON com aspas erradas no shell.

**Pontos-chave:**
- header
- parser
- não culpar o Hash primeiro
</details>

---

*Parte do [Ruby Projects Handbook](/)*
