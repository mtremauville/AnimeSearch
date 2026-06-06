# AnimeSearch

Base de données d'animes avec recherche full-text instantanée, filtres dynamiques par genre, studio et année — propulsé par la [Jikan API](https://jikan.moe) (MyAnimeList) et [Algolia](https://www.algolia.com).

---

## Stack technique

| Couche | Technologie |
|---|---|
| Backend | Ruby on Rails 7+ |
| Base de données | PostgreSQL |
| Recherche full-text | Algolia (algoliasearch-rails) |
| UI de recherche | InstantSearch.js |
| Interactivité | StimulusJS + Hotwire Turbo |
| Source de données | Jikan API v4 (MyAnimeList) |
| Auth (optionnel) | Devise |
| Pagination | Pagy |

---

## Fonctionnalités

- Recherche instantanée sur titre, titre anglais et synopsis
- Filtres combinables : genre, studio, année, statut (en cours / terminé)
- Tri par pertinence, année ou score
- Highlighting des termes cherchés dans les résultats
- Snippet du synopsis (30 mots)
- Import automatisé depuis la Jikan API avec gestion du rate limiting
- Indexation batch vers Algolia avec ranking custom (score MAL)
- Répliques d'index pour les tris alternatifs
- Partage de recherche via URL (routing InstantSearch)

---

## Prérequis

- Ruby 3.2+
- Rails 7.1+
- PostgreSQL 14+
- Node.js 18+ / Yarn
- Un compte [Algolia](https://www.algolia.com) (tier gratuit suffisant)
- [GitHub CLI](https://cli.github.com) (`gh`) — optionnel

---

## Installation

### 1. Cloner le repo

```bash
git clone https://github.com/TON_USERNAME/AnimeSearch.git
cd AnimeSearch
```

### 2. Installer les dépendances

```bash
bundle install
yarn install
```

### 3. Variables d'environnement

```bash
cp .env.example .env
```

Remplir `.env` avec tes clés :

```env
ALGOLIA_APP_ID=VOTRE_APP_ID
ALGOLIA_API_KEY=VOTRE_ADMIN_KEY
ALGOLIA_SEARCH_ONLY_KEY=VOTRE_SEARCH_ONLY_KEY
DATABASE_URL=postgresql://localhost/anime_search_development
```

Les clés Algolia sont disponibles dans ton dashboard → **API Keys** :
- `Application ID` → `ALGOLIA_APP_ID`
- `Admin API Key` → `ALGOLIA_API_KEY` (serveur uniquement, jamais exposée au client)
- `Search-Only API Key` → `ALGOLIA_SEARCH_ONLY_KEY` (utilisée côté navigateur)

### 4. Base de données

```bash
rails db:create
rails db:migrate
```

### 5. Configuration des répliques Algolia

```bash
rails algolia:setup_replicas
```

---

## Import des données

### Import depuis la Jikan API

```bash
rails jikan:import[5]    # ~125 animes (rapide, pour tester)
rails jikan:import[20]   # ~500 animes (catalogue complet)
```

Chaque page contient 25 animes. L'import gère automatiquement :
- le rate limiting Jikan (60 req/min)
- le retry exponentiel sur les erreurs 429 / 503
- l'upsert (pas de doublons si relancé)

### Indexation Algolia

```bash
rails jikan:reindex
```

Lance un import + reindex en une seule commande :

```bash
rails jikan:sync[10]
```

---

## Lancer l'application

```bash
rails server
```

Ouvre [http://localhost:3000](http://localhost:3000).

---

## Architecture Algolia

### Attributs searchables (par priorité)

| Attribut | Type | Priorité |
|---|---|---|
| `title` | ordered | 1 — match exact en tête |
| `title_english` | ordered | 2 — variante anglaise |
| `synopsis` | unordered | 3 — pertinent, position ignorée |
| `genre_names` | unordered | 4 |
| `studio_names` | unordered | 5 |

### Facettes

| Facette | Type | Usage |
|---|---|---|
| `genre_names` | searchable | checkbox avec recherche dans la liste |
| `studio_names` | searchable | checkbox avec recherche dans la liste |
| `year` | standard | menu déroulant |
| `status` | standard | menu déroulant |

### Ranking custom

```
customRanking: ["desc(score)", "desc(episodes)"]
```

S'applique uniquement pour départager les ex-aequo après les 7 critères sémantiques d'Algolia (typo, words, proximity, etc.). Un anime noté 9.1 ne remonte jamais devant un anime qui matche mieux la requête.

### Index et répliques

| Index | Usage |
|---|---|
| `animes_development` / `animes_production` | Pertinence (défaut) |
| `animes_by_year_desc` | Tri par année décroissante |
| `animes_by_score_asc` | Tri par score croissant |

---

## Structure du projet

```
app/
├── controllers/
│   ├── animes_controller.rb
│   ├── genres_controller.rb
│   ├── studios_controller.rb
│   └── pages_controller.rb
├── models/
│   ├── anime.rb              ← configuration Algolia complète
│   ├── genre.rb
│   ├── studio.rb
│   ├── anime_genre.rb
│   └── anime_studio.rb
├── services/
│   └── jikan_sync_service.rb ← import + rate limiting + retry
├── javascript/controllers/
│   └── instantsearch_controller.js
└── views/
    ├── animes/
    │   ├── index.html.erb    ← widgets InstantSearch
    │   └── show.html.erb
    ├── genres/
    └── studios/
config/
├── credentials.yml.enc
├── initializers/
│   └── algoliasearch.rb
└── routes.rb
lib/tasks/
├── jikan.rake
└── algolia.rake
```

---

## Rake tasks disponibles

```bash
rails jikan:import[N]         # Importe N pages depuis Jikan (1 page = 25 animes)
rails jikan:reindex           # Réindexe tous les animes dans Algolia (batch)
rails jikan:sync[N]           # Import + reindex en une commande

rails algolia:setup_replicas  # Crée et configure les index de tri alternatifs
rails algolia:setup_query_rules # Configure les Query Rules (boost "Currently Airing")
```

---

## Sécurité

- Les secrets (`ALGOLIA_API_KEY`, `DATABASE_URL`) sont dans `.env`, jamais commités
- `.env.example` documente les variables attendues sans aucune valeur
- `config/master.key` est dans `.gitignore`
- La **Search-Only API Key** (publique, côté client) est distincte de l'**Admin API Key** (serveur uniquement)
- L'Admin Key n'est jamais exposée dans les assets JS ni dans les vues

---

## Contribuer

```bash
git checkout -b feat/ma-fonctionnalite
# ... développement ...
git commit -m "feat: description"
git push origin feat/ma-fonctionnalite
gh pr create
```

---

## Licence

MIT
