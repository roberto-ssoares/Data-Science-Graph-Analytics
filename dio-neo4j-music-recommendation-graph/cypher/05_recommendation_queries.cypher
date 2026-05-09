// ============================================================
// 05_recommendation_queries.cypher
// Projeto: Sistema de Recomendação Musical com Neo4j
// Objetivo: Gerar recomendações musicais personalizadas
// Usuário de referência: U001
// ============================================================


// ------------------------------------------------------------
// Recomendação 01 — Por gênero curtido
// Caminho:
// User -> LIKED -> Track -> BELONGS_TO_GENRE -> Genre <- BELONGS_TO_GENRE <- Track
//
// Ideia:
// Recomendar músicas de gêneros que o usuário já curtiu,
// excluindo músicas já escutadas ou curtidas.
// ------------------------------------------------------------

MATCH (u:User {user_id: 'U001'})-[:LIKED]->(:Track)-[:BELONGS_TO_GENRE]->(g:Genre)
WITH u, g, count(*) AS afinidade_genero

MATCH (rec:Track)-[:BELONGS_TO_GENRE]->(g)

WHERE NOT EXISTS {
    MATCH (u)-[:LISTENED|LIKED]->(rec)
}

RETURN
    u.user_name AS usuario,
    rec.track_id AS track_id,
    rec.track_name AS recomendacao,
    g.genre_name AS genero_base,
    rec.popularity AS popularidade,
    afinidade_genero AS forca_afinidade
ORDER BY forca_afinidade DESC, rec.popularity DESC
LIMIT 10;


// ------------------------------------------------------------
// Recomendação 02 — Por artista seguido
// Caminho:
// User -> FOLLOWS -> Artist <- PERFORMED_BY <- Track
//
// Ideia:
// Recomendar músicas de artistas que o usuário segue,
// excluindo músicas já escutadas ou curtidas.
// ------------------------------------------------------------

MATCH (u:User {user_id: 'U001'})-[:FOLLOWS]->(a:Artist)
MATCH (rec:Track)-[:PERFORMED_BY]->(a)

WHERE NOT EXISTS {
    MATCH (u)-[:LISTENED|LIKED]->(rec)
}

RETURN
    u.user_name AS usuario,
    rec.track_id AS track_id,
    rec.track_name AS recomendacao,
    a.artist_name AS artista_base,
    rec.popularity AS popularidade
ORDER BY rec.popularity DESC
LIMIT 10;


// ------------------------------------------------------------
// Recomendação 03 — Por usuários semelhantes
// Caminho:
// User -> LIKED -> Track <- LIKED <- Similar User -> LIKED -> Recommended Track
//
// Ideia:
// Encontrar usuários com curtidas em comum e recomendar
// músicas curtidas por esses usuários semelhantes.
// ------------------------------------------------------------

MATCH (u:User {user_id: 'U001'})-[:LIKED]->(common:Track)<-[:LIKED]-(similar:User)
MATCH (similar)-[:LIKED]->(rec:Track)

WHERE u <> similar
  AND NOT EXISTS {
      MATCH (u)-[:LISTENED|LIKED]->(rec)
  }

RETURN
    u.user_name AS usuario,
    rec.track_id AS track_id,
    rec.track_name AS recomendacao,
    count(DISTINCT common) AS musicas_em_comum,
    count(DISTINCT similar) AS usuarios_semelhantes,
    rec.popularity AS popularidade
ORDER BY musicas_em_comum DESC, usuarios_semelhantes DESC, rec.popularity DESC
LIMIT 10;


// ------------------------------------------------------------
// Recomendação 04 — Ranking híbrido simples
//
// Combina três sinais:
// 1. Similaridade com usuários parecidos
// 2. Popularidade da música
// 3. Reforço por gênero já curtido
//
// Esta consulta cria um score simples e explicável.
// ------------------------------------------------------------

MATCH (u:User {user_id: 'U001'})-[:LIKED]->(common:Track)<-[:LIKED]-(similar:User)
MATCH (similar)-[:LIKED]->(rec:Track)-[:BELONGS_TO_GENRE]->(g:Genre)

WHERE u <> similar
  AND NOT EXISTS {
      MATCH (u)-[:LISTENED|LIKED]->(rec)
  }

OPTIONAL MATCH (u)-[:LIKED]->(:Track)-[:BELONGS_TO_GENRE]->(g)

WITH
    u,
    rec,
    g,
    count(DISTINCT common) AS musicas_em_comum,
    count(DISTINCT similar) AS usuarios_semelhantes,
    count(DISTINCT g) AS reforco_genero

WITH
    u,
    rec,
    g,
    musicas_em_comum,
    usuarios_semelhantes,
    rec.popularity AS popularidade,
    (
        musicas_em_comum * 3
        + usuarios_semelhantes * 2
        + reforco_genero * 2
        + rec.popularity * 0.05
    ) AS score_recomendacao

RETURN
    u.user_name AS usuario,
    rec.track_id AS track_id,
    rec.track_name AS recomendacao,
    g.genre_name AS genero,
    musicas_em_comum,
    usuarios_semelhantes,
    popularidade,
    round(score_recomendacao, 2) AS score_recomendacao
ORDER BY score_recomendacao DESC
LIMIT 10;


// ------------------------------------------------------------
// Recomendação 05 — Evidência visual da recomendação por usuários semelhantes
// Objetivo:
// Gerar uma visualização no Neo4j Browser mostrando o caminho
// que explica a recomendação.
// ------------------------------------------------------------

MATCH path =
    (u:User {user_id: 'U001'})-[:LIKED]->(common:Track)<-[:LIKED]-(similar:User)-[:LIKED]->(rec:Track)

WHERE u <> similar
  AND NOT EXISTS {
      MATCH (u)-[:LISTENED|LIKED]->(rec)
  }

RETURN path
LIMIT 20;


// ------------------------------------------------------------
// Recomendação 06 — Explicação textual da recomendação
// Objetivo:
// Mostrar por que uma música foi recomendada.
// ------------------------------------------------------------

MATCH (u:User {user_id: 'U001'})-[:LIKED]->(common:Track)<-[:LIKED]-(similar:User)
MATCH (similar)-[:LIKED]->(rec:Track)

WHERE u <> similar
  AND NOT EXISTS {
      MATCH (u)-[:LISTENED|LIKED]->(rec)
  }

RETURN
    u.user_name AS usuario,
    rec.track_name AS musica_recomendada,
    collect(DISTINCT common.track_name)[0..5] AS musicas_em_comum,
    collect(DISTINCT similar.user_name)[0..5] AS usuarios_com_gosto_parecido,
    count(DISTINCT common) AS forca_da_recomendacao
ORDER BY forca_da_recomendacao DESC
LIMIT 10;

