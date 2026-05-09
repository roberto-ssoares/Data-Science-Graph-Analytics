from pathlib import Path
import csv
import random
from datetime import datetime, timedelta

BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)

random.seed(42)


def write_csv(filename, fieldnames, rows):
    path = DATA_DIR / filename
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Arquivo gerado: {path}")


users = [
    {"user_id": "U001", "user_name": "Ana"},
    {"user_id": "U002", "user_name": "Bruno"},
    {"user_id": "U003", "user_name": "Carla"},
    {"user_id": "U004", "user_name": "Diego"},
    {"user_id": "U005", "user_name": "Elisa"},
    {"user_id": "U006", "user_name": "Felipe"},
    {"user_id": "U007", "user_name": "Giovana"},
    {"user_id": "U008", "user_name": "Henrique"},
    {"user_id": "U009", "user_name": "Isabela"},
    {"user_id": "U010", "user_name": "João"},
]

genres = [
    {"genre_id": "G001", "genre_name": "Rock"},
    {"genre_id": "G002", "genre_name": "Pop"},
    {"genre_id": "G003", "genre_name": "Hip Hop"},
    {"genre_id": "G004", "genre_name": "MPB"},
    {"genre_id": "G005", "genre_name": "Electronic"},
    {"genre_id": "G006", "genre_name": "Jazz"},
]

artists = [
    {"artist_id": "A001", "artist_name": "Aurora Drive", "main_genre_id": "G001"},
    {"artist_id": "A002", "artist_name": "Neon Pulse", "main_genre_id": "G005"},
    {"artist_id": "A003", "artist_name": "Luna Pop", "main_genre_id": "G002"},
    {"artist_id": "A004", "artist_name": "Cidade Verso", "main_genre_id": "G004"},
    {"artist_id": "A005", "artist_name": "Beat Street", "main_genre_id": "G003"},
    {"artist_id": "A006", "artist_name": "Blue Notes Lab", "main_genre_id": "G006"},
    {"artist_id": "A007", "artist_name": "Solar Echo", "main_genre_id": "G001"},
    {"artist_id": "A008", "artist_name": "Digital Dreams", "main_genre_id": "G005"},
    {"artist_id": "A009", "artist_name": "Voz do Atlântico", "main_genre_id": "G004"},
    {"artist_id": "A010", "artist_name": "Urban Flow", "main_genre_id": "G003"},
]

track_names = [
    "Midnight Road", "Electric Sky", "Golden Hour", "Cidade Azul", "Street Lines",
    "Late Night Jazz", "Broken Signals", "Future Lights", "Mar Aberto", "Flow State",
    "Silent Thunder", "Neon Heart", "Sunset Dreams", "Praia Distante", "Concrete Beats",
    "Blue Horizon", "Wild Frequency", "Digital Rain", "Vento Norte", "Urban Mirror",
    "Rocking Waves", "Synthetic Love", "Pop Universe", "Raiz Brasileira", "Rap do Amanhã",
    "Smooth Avenue", "Fire Strings", "Cloud Machine", "Café com Lua", "Night Groove",
]

tracks = []
for idx, track_name in enumerate(track_names, start=1):
    artist = artists[(idx - 1) % len(artists)]
    tracks.append(
        {
            "track_id": f"T{idx:03d}",
            "track_name": track_name,
            "artist_id": artist["artist_id"],
            "genre_id": artist["main_genre_id"],
            "duration_seconds": random.randint(150, 320),
            "popularity": random.randint(35, 95),
        }
    )

start_date = datetime(2025, 1, 1)

listened_rows = []
for _ in range(80):
    user = random.choice(users)
    track = random.choice(tracks)
    played_at = start_date + timedelta(days=random.randint(0, 120))

    listened_rows.append(
        {
            "user_id": user["user_id"],
            "track_id": track["track_id"],
            "play_count": random.randint(1, 20),
            "last_played_at": played_at.strftime("%Y-%m-%d"),
        }
    )

liked_pairs = set()
liked_rows = []

while len(liked_rows) < 40:
    user = random.choice(users)
    track = random.choice(tracks)
    pair = (user["user_id"], track["track_id"])

    if pair not in liked_pairs:
        liked_pairs.add(pair)
        liked_at = start_date + timedelta(days=random.randint(0, 120))

        liked_rows.append(
            {
                "user_id": user["user_id"],
                "track_id": track["track_id"],
                "liked_at": liked_at.strftime("%Y-%m-%d"),
            }
        )

follow_pairs = set()
followed_rows = []

while len(followed_rows) < 25:
    user = random.choice(users)
    artist = random.choice(artists)
    pair = (user["user_id"], artist["artist_id"])

    if pair not in follow_pairs:
        follow_pairs.add(pair)
        since = start_date + timedelta(days=random.randint(0, 120))

        followed_rows.append(
            {
                "user_id": user["user_id"],
                "artist_id": artist["artist_id"],
                "since": since.strftime("%Y-%m-%d"),
            }
        )

write_csv("users.csv", ["user_id", "user_name"], users)
write_csv("genres.csv", ["genre_id", "genre_name"], genres)
write_csv("artists.csv", ["artist_id", "artist_name", "main_genre_id"], artists)
write_csv(
    "tracks.csv",
    ["track_id", "track_name", "artist_id", "genre_id", "duration_seconds", "popularity"],
    tracks,
)
write_csv(
    "user_listened_tracks.csv",
    ["user_id", "track_id", "play_count", "last_played_at"],
    listened_rows,
)
write_csv(
    "user_liked_tracks.csv",
    ["user_id", "track_id", "liked_at"],
    liked_rows,
)
write_csv(
    "user_followed_artists.csv",
    ["user_id", "artist_id", "since"],
    followed_rows,
)