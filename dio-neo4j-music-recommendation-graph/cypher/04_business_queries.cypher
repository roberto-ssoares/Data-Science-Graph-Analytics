// ============================================================
// 04_business_queries.cypher
// Projeto: Sistema de Recomendação Musical com Neo4j
// Objetivo: Executar consultas analíticas para entender o grafo
// ============================================================


// ------------------------------------------------------------
// Query 01 — Quantidade de nós por label
// Objetivo: Validar se os principais nós foram carregados
// ------------------------------------------------------------

MATCH (n)
RETURN
    labels(n) AS label,
    count(n) AS total
ORDER BY total DESC;


// ------------------------------------------------------------
// Query 02 — Quantidade de relacionamentos por tipo
// Objetivo: Validar se as interações e conexões foram criadas
// ------------------------------------------------------------

MATCH ()-[r]->()
RETURN
    type(r) AS relacionamento,
    count(r) AS total
ORDER BY total DESC;


// ------------------------------------------------------------
// Query 03 — Músicas mais escutadas
// Objetivo: Identificar faixas com maior volume de escuta
// ------------------------------------------------------------

MATCH (:User)-[r:LISTENED]->(t:Track)
RETURN
    t.track_id AS track_id,
    t.track_name AS musica,
    sum(r.play_count) AS total_execucoes,
    count(r) AS usuarios_que_escutaram
ORDER BY total_execucoes DESC
LIMIT 10;


// ------------------------------------------------------------
// Query 04 — Músicas mais curtidas
// Objetivo: Identificar faixas com maior aprovação explícita
// ------------------------------------------------------------

MATCH (:User)-[r:LIKED]->(t:Track)
RETURN
    t.track_id AS track_id,
    t.track_name AS musica,
    count(r) AS total_curtidas
ORDER BY total_curtidas DESC
LIMIT 10;


// ------------------------------------------------------------
// Query 05 — Artistas mais seguidos
// Objetivo: Identificar artistas com maior base de seguidores
// ------------------------------------------------------------

MATCH (:User)-[r:FOLLOWS]->(a:Artist)
RETURN
    a.artist_id AS artist_id,
    a.artist_name AS artista,
    count(r) AS total_seguidores
ORDER BY total_seguidores DESC
LIMIT 10;


// ------------------------------------------------------------
// Query 06 — Gêneros com maior volume de escuta
// Objetivo: Entender quais gêneros concentram mais plays
// ------------------------------------------------------------

MATCH (:User)-[r:LISTENED]->(t:Track)-[:BELONGS_TO_GENRE]->(g:Genre)
RETURN
    g.genre_id AS genre_id,
    g.genre_name AS genero,
    sum(r.play_count) AS total_execucoes,
    count(DISTINCT t) AS musicas_distintas,
    count(DISTINCT r) AS interacoes
ORDER BY total_execucoes DESC;


// ------------------------------------------------------------
// Query 07 — Perfil musical de um usuário
// Objetivo: Entender os gêneros mais consumidos por um usuário específico
// Usuário exemplo: U001
// ------------------------------------------------------------

MATCH (u:User {user_id: 'U001'})-[r:LISTENED]->(t:Track)-[:BELONGS_TO_GENRE]->(g:Genre)
RETURN
    u.user_name AS usuario,
    g.genre_name AS genero,
    sum(r.play_count) AS total_execucoes,
    count(DISTINCT t) AS musicas_escutadas
ORDER BY total_execucoes DESC;


// ------------------------------------------------------------
// Query 08 — Artistas mais presentes nas músicas escutadas por U001
// Objetivo: Identificar preferência por artistas
// ------------------------------------------------------------

MATCH (u:User {user_id: 'U001'})-[r:LISTENED]->(t:Track)-[:PERFORMED_BY]->(a:Artist)
RETURN
    u.user_name AS usuario,
    a.artist_name AS artista,
    sum(r.play_count) AS total_execucoes,
    count(DISTINCT t) AS musicas_escutadas
ORDER BY total_execucoes DESC;


// ------------------------------------------------------------
// Query 09 — Visão de grafo: usuários e músicas escutadas
// Objetivo: Gerar visualização inicial no Neo4j Browser
// ------------------------------------------------------------

MATCH (u:User)-[r:LISTENED]->(t:Track)
RETURN u, r, t
LIMIT 50;


// ------------------------------------------------------------
// Query 10 — Visão de grafo: usuário, música, artista e gênero
// Objetivo: Gerar evidência visual mais rica para o README
// ------------------------------------------------------------

MATCH (u:User {user_id: 'U001'})-[r:LISTENED]->(t:Track)-[:PERFORMED_BY]->(a:Artist),
      (t)-[:BELONGS_TO_GENRE]->(g:Genre)
RETURN u, r, t, a, g
LIMIT 50;


// ------------------------------------------------------------
// Query 11 — Visualização do schema do banco
// Objetivo: Gerar imagem do modelo de grafo
// ------------------------------------------------------------

CALL db.schema.visualization();
