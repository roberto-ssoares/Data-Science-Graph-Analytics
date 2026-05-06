// ============================================================
// 03_load_relationships.cypher
// Projeto: Sistema de Recomendação Musical com Neo4j
// Objetivo: Criar os relacionamentos entre usuários, músicas,
// artistas e gêneros
// ============================================================

// ------------------------------------------------------------
// Relacionamento: Track -> Artist
// Uma música é interpretada por um artista
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///tracks.csv' AS row
MATCH (t:Track {track_id: row.track_id})
MATCH (a:Artist {artist_id: row.artist_id})
MERGE (t)-[:PERFORMED_BY]->(a);


// ------------------------------------------------------------
// Relacionamento: Track -> Genre
// Uma música pertence a um gênero musical
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///tracks.csv' AS row
MATCH (t:Track {track_id: row.track_id})
MATCH (g:Genre {genre_id: row.genre_id})
MERGE (t)-[:BELONGS_TO_GENRE]->(g);


// ------------------------------------------------------------
// Relacionamento: Artist -> Genre
// Um artista está associado ao seu gênero principal
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///artists.csv' AS row
MATCH (a:Artist {artist_id: row.artist_id})
MATCH (g:Genre {genre_id: row.main_genre_id})
MERGE (a)-[:ASSOCIATED_WITH]->(g);


// ------------------------------------------------------------
// Relacionamento: User -> Track
// Um usuário escutou uma música
// Propriedades da aresta:
// - play_count
// - last_played_at
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///user_listened_tracks.csv' AS row
MATCH (u:User {user_id: row.user_id})
MATCH (t:Track {track_id: row.track_id})
MERGE (u)-[r:LISTENED]->(t)
SET
    r.play_count = coalesce(r.play_count, 0) + toInteger(row.play_count),
    r.last_played_at =
        CASE
            WHEN r.last_played_at IS NULL THEN date(row.last_played_at)
            WHEN date(row.last_played_at) > r.last_played_at THEN date(row.last_played_at)
            ELSE r.last_played_at
        END;


// ------------------------------------------------------------
// Relacionamento: User -> Track
// Um usuário curtiu uma música
// Propriedade da aresta:
// - liked_at
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///user_liked_tracks.csv' AS row
MATCH (u:User {user_id: row.user_id})
MATCH (t:Track {track_id: row.track_id})
MERGE (u)-[r:LIKED]->(t)
SET
    r.liked_at = date(row.liked_at);


// ------------------------------------------------------------
// Relacionamento: User -> Artist
// Um usuário segue um artista
// Propriedade da aresta:
// - since
// ------------------------------------------------------------

LOAD CSV WITH HEADERS FROM 'file:///user_followed_artists.csv' AS row
MATCH (u:User {user_id: row.user_id})
MATCH (a:Artist {artist_id: row.artist_id})
MERGE (u)-[r:FOLLOWS]->(a)
SET
    r.since = date(row.since);