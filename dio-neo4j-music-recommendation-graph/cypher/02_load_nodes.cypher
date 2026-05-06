// ============================================================
// 02_load_nodes.cypher
// Projeto: Sistema de Recomendação Musical com Neo4j
// Objetivo: Carregar os nós principais do grafo
// Labels: User, Track, Artist, Genre
// ============================================================

// ------------------------------------------------------------
// Carrega usuários
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {user_id: row.user_id})
SET
    u.user_name = row.user_name;


// ------------------------------------------------------------
// Carrega gêneros musicais
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///genres.csv' AS row
MERGE (g:Genre {genre_id: row.genre_id})
SET
    g.genre_name = row.genre_name;


// ------------------------------------------------------------
// Carrega artistas
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///artists.csv' AS row
MERGE (a:Artist {artist_id: row.artist_id})
SET
    a.artist_name = row.artist_name,
    a.main_genre_id = row.main_genre_id;


// ------------------------------------------------------------
// Carrega músicas/faixas
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///tracks.csv' AS row
MERGE (t:Track {track_id: row.track_id})
SET
    t.track_name = row.track_name,
    t.duration_seconds = toInteger(row.duration_seconds),
    t.popularity = toInteger(row.popularity),
    t.source_artist_id = row.artist_id,
    t.source_genre_id = row.genre_id;