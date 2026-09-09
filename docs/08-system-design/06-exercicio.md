# 8.6 Exercício de desenho

Prática. Sem TL;DR. Você desenha no papel. Depois abre a solução.

## Conteúdo

- [Exercício 1](#exercício-1)
- [Exercício 2](#exercício-2)
- [Exercício 3](#exercício-3)

---

## Exercício 1

**Enunciado:** 15 minutos. Desenhe a Pousada com: 3 recepcionistas no HTML, 1 app interno JSON, quadro na TV da entrada, lembrete de check-out, relatório 7h. Caixas, setas, onde mora a regra da única `checked_in`. O que acontece se o Redis cair no meio do check-in.

<details>
<summary>Solução</summary>

**Caixas:** Browser ×3 → Web Rails. App → Web `/api/v1`. TV → Web (HTML + WS). Web → Postgres. Web → Redis (fila + pub/sub). Worker → Redis, Postgres, SMTP.

**Regra:** unique partial index em `stays(pet_id) WHERE status = checked_in`. Model valida. Check-in é request.

**TV:** Cable `stream_for account`. Broadcast depois do commit. Stale ok.

**Redis down no check-in:** Stay commitada. Enqueue falha. Operador pode ver 500. Thor está no banco. Quadro GET ainda mostra se o GET não depende do Redis. Lembrete: rake de reconciliação ou outbox. TV: sem push até o Redis voltar; F5 no GET funciona.

**Pontos-chave:**
- um Rails
- write síncrono
- Redis derivado
- GET é a verdade do quadro
</details>

---

## Exercício 2

**Enunciado:** O app mobile precisa deslogar só aquele aparelho. O HTML da recepção continua cookie. Desenhe auth. O que o logout de cada um mata.

<details>
<summary>Solução</summary>

HTML: session cookie, `reset_session`. Não mexe nos tokens da API.

API: tabela `api_tokens` (user_id, token_digest, device, revoked_at). Login cria linha, devolve o token. Logout Bearer revoga **essa** linha. `has_secure_token` no User (projeto 3) morre: um token só derrubava o Insomnia junto.

Handshake Cable do **browser**: cookie, igual o 6. Mobile se um dia tiver WS: token no connect, lookup na tabela.

**Pontos-chave:**
- dois mecanismos, dois clientes
- logout local
- digest do token, não o claro no banco
</details>

---

## Exercício 3

**Enunciado:** Black Friday canina. 200 check-ins/hora. Um worker. Relatório das 7h atrasou para 12h. Lembretes das 8h saíram 10h. O que você escala primeiro e o que você **não** mexe.

<details>
<summary>Solução</summary>

200/hora é pouco para Postgres e para um Puma. O atraso é o **worker único** + SMTP lento. Escala worker (replicas no compose/K8s). Fila `mailers` separada da `default` — já está no yml.

Não mexe: unique index, integer, check-in síncrono, SQLite→Postgres só se o disco/lock do SQLite aparecer (dois writers no 7 já são o cheiro — Postgres entra antes dos 200/h se você já tem web+worker).

Não introduz Kafka. Não transforma check-in em job.

Métrica: lag do scheduled set. Alerta se lembrete > 30 min.

**Pontos-chave:**
- escala o gargalo (SMTP/worker)
- não escala o que não dói
- check-in fica request
</details>

---

*Parte do [Ruby Projects Handbook](/)*
