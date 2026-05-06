// ============================================================
// 01_constraints.cypher
// Projeto: Sistema de Recomendação Musical com Neo4j
// Objetivo: Criar constraints de unicidade para evitar duplicidade
// ============================================================

// Usuários
CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (u:User)
REQUIRE u.user_id IS UNIQUE;

// Músicas
CREATE CONSTRAINT track_id_unique IF NOT EXISTS
FOR (t:Track)
REQUIRE t.track_id IS UNIQUE;

// Artistas
CREATE CONSTRAINT artist_id_unique IF NOT EXISTS
FOR (a:Artist)
REQUIRE a.artist_id IS UNIQUE;

// Gêneros
CREATE CONSTRAINT genre_id_unique IF NOT EXISTS
FOR (g:Genre)
REQUIRE g.genre_id IS UNIQUE;

