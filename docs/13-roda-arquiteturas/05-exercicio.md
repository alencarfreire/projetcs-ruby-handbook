# 13.5 Exercício de desenho (ingressos)

Prática. Sem TL;DR. Papel. Lote e webhook **não** têm pasta. Você desenha o que o projeto grande vai ser.

## Conteúdo

- [Exercício 1](#exercício-1)
- [Exercício 2](#exercício-2)
- [Exercício 3](#exercício-3)

---

## Exercício 1

**Enunciado:** 15 minutos. Evento já existe (B). Entra **lote**: `price_cents`, `quantity`, janela de venda. Entra **POST /webhooks/pagamento`** com JSON do provedor (`pedido_id`, `status`, `sig`). Desenhe caixas: Roda, ramos, o que é call puro, o que é schema. Onde o JWT entra e onde não entra.

<details>
<summary>Solução</summary>

**Ramos B:** `eventos`, `lotes`, `webhooks` (e auth via `r.rodauth`).

**JWT:** ramos eventos e lotes. **Não** no webhook — assinatura HMAC do provedor.

**C:** `ReservarLote` / `ConfirmarPagamento`. Sem `require "roda"`. Decremento de quantity atômico (unique/where quantity > 0). Teste com repo fake.

**D:** schema do webhook **antes** do call. Failure 422 se faltar `pedido_id`. Success segue o `ConfirmarPagamento`.

**GET lotes:** dataset no ramo. Sem call.

**Pontos-chave:**
- JWT ≠ HMAC
- estoque = C
- payload = D
- CRUD lote = B
</details>

---

## Exercício 2

**Enunciado:** Dois POSTs no mesmo lote, último ingresso. Onde a cerca vive se você ficou só na A (tudo no `r.post`)?

<details>
<summary>Solução</summary>

A cerca no `r.post` com `DB[:lotes].where { quantity > 0 }.update(quantity: quantity - 1)` pode funcionar se o UPDATE é condicional e você olha o rowcount. Isso ainda é SQL no route — A. C extrai o mesmo SQL para o repo e testa o call com fake que simula rowcount 0 → Failure[:esgotado]. A entrevista quer o **update condicional**, não o `quantity -= 1` em Ruby depois de um `first`.

**Pontos-chave:**
- UPDATE where quantity > 0
- rowcount
- Ruby no Hash race
- C testa a política
</details>

---

## Exercício 3

**Enunciado:** Take-home 60 min: “API de eventos com login JWT”. Você abre C e D?

<details>
<summary>Solução</summary>

Não. A. create-account, login, CRUD eventos. No final, 2 minutos: “lote seria hash_branch; estoque seria call; webhook seria schema.” Entregar A verde. Não entregar hexágono vazio.

**Pontos-chave:**
- relógio
- A sobe
- C/D narrados
</details>

---

*Parte do [Ruby Projects Handbook](/)*
