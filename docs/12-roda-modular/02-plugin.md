# 12.2 Plugin hash_routes

> **TL;DR**
> `plugin :hash_routes`. `hash_branch "eventos"` registra o bloco num Hash. `r.hash_routes` despacha pelo primeiro segmento. A árvore de dentro do ramo não muda.

## Conteúdo

- [plugin](#plugin)
- [hash_branch](#hash_branch)
- [r.hash_routes](#rhash_routes)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## plugin

**O que é:**
Opt-in. A não carrega. B carrega.

**Como funciona:**
`plugin :hash_routes` na classe, **antes** dos `require` dos ramos. O ramo chama `hash_branch` na classe já plugada.

**Na entrevista:**
> "Plugin primeiro. Require do ramo depois. Senão hash_branch não existe."

---

## hash_branch

**O que é:**
O registro. String do prefixo. Bloco com `|r|`.

**Como funciona:**

```ruby
class App
  hash_branch "eventos" do |r|
    rodauth.require_authentication
    r.is { r.get { DB[:eventos].all } }
    # ...
  end
end
```

O `"eventos"` é a chave. `/eventos/1` entra. `/locais` não entra neste bloco.

**Na entrevista:**
> "hash_branch eventos. O path /eventos some do prefixo. Dentro, r.is é a coleção. Igual o on da A."

---

## r.hash_routes

**O que é:**
O despacho. Uma linha no orquestrador.

**Como funciona:**

```ruby
route do |r|
  r.root { { "name" => "ingressos-modular" } }
  r.rodauth
  r.hash_routes
end
```

root e rodauth **antes**. Login não passa pelo Hash de ramos. Eventos e locais passam.

**Na entrevista:**
> "hash_routes no fim do route. Auth routes antes. Root público."

---

## Recapitulando

- plugin antes dos ramos
- branch = chave
- hash_routes despacha
- árvore interna igual A

---

## Exercícios práticos

### Exercício 1: Esquece r.hash_routes

**Enunciado:** Ramos existem. POST /eventos 404. Por quê?

<details>
<summary>Solução</summary>

O route não chama `r.hash_routes`. Registro no Hash não é despacho. Uma linha faltando.

**Pontos-chave:**
- registrar ≠ despachar
- uma linha no orquestrador
</details>

---

*Parte do [Ruby Projects Handbook](/)*
