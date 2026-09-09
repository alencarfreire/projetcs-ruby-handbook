# 10.1 O problema e o recorte

> **TL;DR**
> Sem HTTP. Sem Roda. Sequel. Tabela `eventos` no SQLite. Dataset devolve Hash. Model é opcional. Restart **não** apaga o Sunset Jazz. Lote e webhook não entram.

## Conteúdo

- [Esta pasta não é Roda](#esta-pasta-não-é-roda)
- [O problema](#o-problema)
- [O recorte](#o-recorte)
- [Dataset vs model](#dataset-vs-model)
- [Como o walkthrough anda](#como-o-walkthrough-anda)
- [Recapitulando](#recapitulando)
- [Exercícios práticos](#exercícios-práticos)

---

## Esta pasta não é Roda

**O que é:**
A fase 9 mostrou o `r.on`. Esta mostra a tabela. Independente. Você pode ler só esta pasta.

**Como funciona:**
João persiste “Sunset Jazz”. Sem porta. Sem curl. Script e console. O HTTP volta na fase 11, quando as duas peças se encontram.

**Quando usar:**
Entrevista “Sequel”. Take-home de SQL em Ruby. Qualquer vaga que pede persistência sem Active Record.

**Na entrevista:**
> "Sequel. Dataset. Row é Hash. Eu não subo Puma para inserir uma linha."

---

## O problema

**O que é:**
Guardar eventos. Listar. Inserir. O processo pode morrer.

**Como funciona:**
SQLite num arquivo `storage/app.sqlite3`. `DB[:eventos].insert(...)`. `DB[:eventos].all` devolve array de hashes. Chave symbol `row[:title]`.

No Active Record o default é o objeto. No Sequel o default é o dataset. Model existe — você puxa se quiser.

**Na entrevista:**
> "A tabela sobrevive ao restart. O Hash da fase 9 não. Esse é o ponto desta pasta."

---

## O recorte

**O que é:**
Entra / não entra.

**Como funciona:**

| Entra | Não entra |
|---|---|
| Sequel, SQLite | Roda, Puma |
| `DB[:eventos]` | Rodauth |
| Migration em `migrate/` | `rails g migration` |
| Hash do row | Lote, pedido, webhook |
| Model opcional | Postgres, AR |

**Na entrevista:**
> "Sem HTTP. Se eu misturo Roda agora, a entrevista vira o app inteiro. Uma peça."

---

## Dataset vs model

**O que é:**
Duas APIs. Este recorte mostra as duas. O default que você usa nos scripts é dataset.

**Como funciona:**
Dataset: `DB[:eventos].where(title: "Sunset Jazz").first` → Hash.
Model: `Evento.first.title` → objeto.

Active Record esconde o dataset. Sequel mostra. Por isso a entrevista puxa Sequel quando quer SQL honesto.

**Na entrevista:**
> "Dataset é a tabela. Model é casaco. Eu começo sem casaco."

---

## Como o walkthrough anda

**O que é:**
10.2 conexão. 10.3 migration. 10.4 Hash. 10.5 model. 10.6 como rodar. [Código](/docs/10-sequel/codigo).

**Na entrevista:**
> "Eu rodei bin/seed, list.rb imprimiu Sunset Jazz, matei o terminal, rodei de novo, o Jazz continuava."

---

## Recapitulando

- Sem HTTP
- Dataset → Hash
- SQLite arquivo
- Model opcional
- Sem lote

---

## Exercícios práticos

### Exercício 1: Por que não Roda aqui

**Enunciado:** “É a mesma trilha, junta logo.” Resposta?

<details>
<summary>Solução</summary>

Porque o entrevistador puxa Sequel **ou** Roda. Junto é a fase 11. Se eu misturo, você não sabe se o Hash veio do plugin json ou da tabela.

**Pontos-chave:**
- uma peça
- 11 junta
- recorte
</details>

### Exercício 2: Restart

**Enunciado:** Você mata o console. O Jazz some?

<details>
<summary>Solução</summary>

Não. Arquivo sqlite. Diferente do 9. Se some, você rodou outro path de `storage/` ou esqueceu o seed.

**Pontos-chave:**
- arquivo
- path
- seed é insert
</details>

---

*Parte do [Ruby Projects Handbook](/)*
