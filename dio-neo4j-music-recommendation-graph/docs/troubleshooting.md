# Troubleshooting — Sistema de Recomendação Musical com Neo4j

Este documento registra os principais pontos de atenção encontrados durante a construção do projeto, bem como as soluções aplicadas.

A ideia é documentar não apenas o resultado final, mas também as decisões e ajustes necessários para fazer o projeto funcionar corretamente.

---

## 1. Problema: Neo4j não encontrou os arquivos CSV

### Sintoma

Ao executar o comando `LOAD CSV`, o Neo4j retorna erro informando que o arquivo não foi encontrado.

Exemplo:

```text
Couldn't load the external resource at: file:/users.csv
```

### Causa provável

O Neo4j busca arquivos locais na pasta `import` do banco de dados, e não diretamente na pasta `data/` do projeto.

### Solução

Copiar os arquivos CSV da pasta do projeto:

```text
data/
```

Para a pasta `import` do Neo4j.

No Neo4j Desktop, o caminho pode ser acessado por:

```text
Database → Open folder → Import
```

Os arquivos necessários são:

```text
users.csv
tracks.csv
artists.csv
genres.csv
user_listened_tracks.csv
user_liked_tracks.csv
user_followed_artists.csv
```

---

## 2. Problema: Caminho incorreto no `LOAD CSV`

### Sintoma

Mesmo com o arquivo na pasta `import`, a carga falha.

### Causa provável

Uso incorreto do caminho do arquivo.

### Solução

Utilizar o padrão:

```cypher
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
```

Não usar caminhos como:

```cypher
LOAD CSV WITH HEADERS FROM 'data/users.csv' AS row
```

ou:

```cypher
LOAD CSV WITH HEADERS FROM 'C:/meu-projeto/data/users.csv' AS row
```

Para este projeto, todos os scripts foram escritos considerando que os arquivos CSV estão na pasta `import` do Neo4j.

---

## 3. Problema: Campos numéricos carregados como texto

### Sintoma

Campos como `popularity`, `duration_seconds` e `play_count` aparecem como texto em vez de número.

### Causa provável

Ao carregar dados via CSV, os valores são interpretados inicialmente como string.

### Solução

Converter explicitamente os campos durante a carga:

```cypher
toInteger(row.popularity)
```

```cypher
toInteger(row.duration_seconds)
```

```cypher
toInteger(row.play_count)
```

Exemplo aplicado no projeto:

```cypher
SET
    t.duration_seconds = toInteger(row.duration_seconds),
    t.popularity = toInteger(row.popularity)
```

---

## 4. Problema: Datas carregadas como texto

### Sintoma

Campos como `liked_at`, `since` e `last_played_at` ficam armazenados como string.

### Causa provável

Datas vindas de CSV precisam ser convertidas explicitamente no Cypher.

### Solução

Utilizar a função `date()`:

```cypher
date(row.liked_at)
```

Exemplo:

```cypher
SET r.liked_at = date(row.liked_at)
```

---

## 5. Problema: Duplicidade de nós

### Sintoma

O grafo apresenta múltiplos nós para o mesmo usuário, música, artista ou gênero.

### Causa provável

Uso de `CREATE` no lugar de `MERGE`, ou ausência de constraints de unicidade.

### Solução

Criar constraints antes da carga dos dados:

```cypher
CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (u:User)
REQUIRE u.user_id IS UNIQUE;
```

E utilizar `MERGE` na carga:

```cypher
MERGE (u:User {user_id: row.user_id})
```

---

## 6. Problema: Relacionamentos duplicados

### Sintoma

O mesmo usuário aparece com múltiplos relacionamentos repetidos para a mesma música ou artista.

### Causa provável

Uso de `CREATE` para relacionamentos que deveriam ser únicos por par de nós.

### Solução

Usar `MERGE` para criar relacionamentos:

```cypher
MERGE (u)-[r:LIKED]->(t)
```

No caso de escutas, o projeto acumula o `play_count` quando o relacionamento já existe:

```cypher
SET
    r.play_count = coalesce(r.play_count, 0) + toInteger(row.play_count)
```

---

## 7. Problema: Consulta de recomendação retorna poucos resultados

### Sintoma

Uma consulta de recomendação retorna poucos registros ou nenhum resultado.

### Causa provável

Como o dataset é sintético e pequeno, pode ocorrer de alguns usuários já terem escutado ou curtido boa parte das músicas candidatas, especialmente quando usamos filtros para excluir músicas já consumidas.

### Solução

Testar outros usuários além de `U001`, por exemplo:

```cypher
MATCH (u:User)
RETURN u.user_id, u.user_name;
```

Depois substituir o usuário nas queries:

```cypher
MATCH (u:User {user_id: 'U002'})
```

Também é possível aumentar o número de usuários, músicas e interações no script:

```text
scripts/generate_sample_data.py
```

---

## 8. Problema: `CALL db.schema.visualization()` não mostra o modelo esperado

### Sintoma

O comando de visualização do schema retorna poucos elementos ou não mostra todos os relacionamentos.

### Causa provável

O schema visual é baseado no que já existe no banco carregado. Se algum relacionamento não foi criado, ele não aparecerá.

### Solução

Validar a carga com:

```cypher
MATCH (n)
RETURN labels(n) AS label, count(n) AS total
ORDER BY total DESC;
```

E validar relacionamentos com:

```cypher
MATCH ()-[r]->()
RETURN type(r) AS relacionamento, count(r) AS total
ORDER BY total DESC;
```

Se algum relacionamento estiver com total zero, revisar o script:

```text
cypher/03_load_relationships.cypher
```

---

## 9. Problema: Pasta `assets/` não aparece no GitHub

### Sintoma

A pasta `assets/` existe localmente, mas não aparece no GitHub após o push.

### Causa provável

O Git não versiona pastas vazias.

### Solução

Adicionar um arquivo `.gitkeep` dentro da pasta:

```text
assets/.gitkeep
```

Depois executar:

```bash
git add assets/.gitkeep
git commit -m "chore: add assets folder"
git push
```

Quando os prints forem adicionados, o `.gitkeep` pode permanecer ou ser removido.

---

## 10. Problema: Ordem incorreta de execução dos scripts

### Sintoma

As queries de relacionamento falham porque os nós ainda não existem.

### Causa provável

Executar o script de relacionamentos antes da carga dos nós.

### Solução

Executar os scripts nesta ordem:

```text
01_constraints.cypher
02_load_nodes.cypher
03_load_relationships.cypher
04_business_queries.cypher
05_recommendation_queries.cypher
```

---

## 11. Checklist de Validação Final

Antes de considerar o projeto concluído, verificar:

| Item                                         | Validação |
| -------------------------------------------- | --------- |
| CSVs copiados para a pasta `import` do Neo4j | OK        |
| Constraints executadas                       | OK        |
| Nós carregados                               | OK        |
| Relacionamentos criados                      | OK        |
| Queries analíticas executadas                | OK        |
| Queries de recomendação executadas           | OK        |
| Prints salvos na pasta `assets/`             | OK        |
| README atualizado                            | OK        |
| Troubleshooting documentado                  | OK        |
| Projeto publicado no GitHub                  | OK        |

---

## 12. Conclusão do Troubleshooting

Os principais desafios do projeto estiveram relacionados à carga de dados via CSV, conversão de tipos, criação correta dos relacionamentos e validação das recomendações.

A documentação desses pontos é importante porque demonstra domínio prático do fluxo completo:

```text
dataset → modelagem → carga → validação → consulta → recomendação → evidência visual
```

Esse processo aproxima o desafio de uma entrega real de projeto em grafos.
