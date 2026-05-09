# Perguntas de Negócio

Este projeto foi construído para responder perguntas analíticas e gerar recomendações musicais com base em conexões no grafo.

---

## 

## 1. Perguntas Analíticas

### 1.1 Quais músicas foram mais escutadas?

Objetivo: identificar as faixas com maior volume de execução.

Arquivo relacionado:

cypher/04_business_queries.cypher

---

### 1.2 Quais músicas foram mais curtidas?

Objetivo: identificar as músicas com maior aprovação explícita dos usuários.

---

### 1.3 Quais artistas possuem mais seguidores?

Objetivo: identificar artistas com maior base de interesse direto.

---

### 1.4 Quais gêneros concentram mais escutas?

Objetivo: entender a distribuição de consumo musical por gênero.

---

### 1.5 Qual é o perfil musical de um usuário?

Objetivo: analisar os gêneros e artistas mais consumidos por um usuário específico.

---

## 

## 2. Perguntas de Recomendação

### 2.1 Que músicas recomendar com base nos gêneros curtidos pelo usuário?

Caminho no grafo:

```
User → LIKED → Track → Genre → Track
```

---

### 2.2 Que músicas recomendar com base nos artistas seguidos?

Caminho no grafo:

```
User → FOLLOWS → Artist → Track
```

---

### 2.3 Que músicas recomendar com base em usuários semelhantes?

Caminho no grafo:

```
User → LIKED → Track ← LIKED ← Similar User → LIKED → Track
```

---

### 2.4 Como explicar uma recomendação?

Objetivo: mostrar quais usuários ou músicas em comum justificam a recomendação.

---



## 3. Valor Analítico

O grafo permite que as recomendações sejam explicáveis, pois cada sugestão pode ser rastreada por um caminho de relacionamento.

Exemplo:

```text
Ana curtiu uma música que Bruno também curtiu.
Bruno curtiu outra música que Ana ainda não ouviu.
Logo, essa música pode ser recomendada para Ana.
```

---


