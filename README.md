# Monasafe

Application de gestion de finances personnelles multi-plateforme avec **Supabase** comme backend.

## Fonctionnalites

- **Comptes** : CRUD, types (courant/epargne/especes), couleurs, soldes calcules
- **Transactions** : CRUD, categorisation, notes avec autocompletion intelligente
- **Recurrences** : Transactions mensuelles auto-generees, activation/desactivation
- **Budgets** : Limite par categorie, suivi progression, vue mensuelle/annuelle
- **Statistiques** : Graphiques cashflow, repartition depenses, selecteur de periode
- **Vault** : Chiffrement E2E optionnel, verrouillage par biometrie/PIN (mobile) ou mot de passe maitre (web)
- **Dark mode** : Clair / Sombre / Systeme
- **Authentification** : Anonyme (local only) ou Google OAuth avec synchronisation cloud

## Architecture

```
monasafe/
├── mobile/     # Application Flutter (iOS, Android)
├── web/        # Application Nuxt 3 (navigateur)
└── README.md
```

Les deux clients partagent le meme backend **Supabase** (PostgreSQL, Auth, Row Level Security).

## Plateformes

### Mobile (Flutter)

| Outil | Usage |
|-------|-------|
| **Flutter** | Framework UI cross-platform |
| **Riverpod** | State management reactif |
| **go_router** | Navigation declarative |
| **Supabase Flutter** | Backend (Auth, DB, Realtime) |
| **fl_chart** | Graphiques |
| **cryptography + flutter_secure_storage + local_auth** | Vault (E2EE, biometrie) |

> Documentation complete : [`mobile/README.md`](mobile/README.md)

### Web (Nuxt 3)

| Outil | Usage |
|-------|-------|
| **Nuxt 3** | Framework (Vue 3 + Vite + Nitro) |
| **TypeScript** | Typage strict |
| **Pinia** | State management |
| **Supabase** | Backend (Auth, DB, Realtime) |
| **Tailwind CSS** | Styling utility-first |
| **Chart.js** | Graphiques |
| **Web Crypto API** | Vault (AES-256-GCM, PBKDF2) |

> Documentation complete : [`web/README.md`](web/README.md)

## Demarrage rapide

### Mobile

```bash
cd mobile
flutter pub get
cp .env.example .env
# Remplir les variables Supabase dans .env
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Web

```bash
cd web
npm install
cp .env.example .env
# Remplir SUPABASE_URL et SUPABASE_ANON_KEY dans .env
npm run dev
```

## Backend (Supabase)

Les deux clients se connectent au meme projet Supabase. Le schema inclut les tables suivantes :

| Table | Description |
|-------|-------------|
| `accounts` | Comptes bancaires de l'utilisateur |
| `categories` | Categories de transactions (defaut + custom) |
| `transactions` | Transactions financieres |
| `recurring_transactions` | Paiements recurrents |
| `user_budgets` | Budgets par categorie |
| `user_settings` | Parametres utilisateur (cle-valeur) |

Toutes les tables ont **Row Level Security** active : chaque utilisateur ne voit que ses propres donnees.

> Schema complet et migrations SQL : [`mobile/README.md`](mobile/README.md#base-de-données-supabase-postgresql)

## Contribution

Voir [`CONTRIBUTING.md`](CONTRIBUTING.md) pour les conventions, le workflow et les instructions par plateforme.
