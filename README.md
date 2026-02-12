# Monasafe

Application open-source de gestion de finances personnelles. Multi-plateforme (Android + Web), backend Supabase.

**Web** : [monasafe.com](https://monasafe.com) | **Android** : Play Store (bientot)

## Fonctionnalites

- **Comptes** — Courant, epargne, especes. Soldes calcules en temps reel.
- **Transactions** — Categorisation, notes avec autocompletion intelligente.
- **Recurrences** — Paiements mensuels automatiques (loyer, abonnements...).
- **Budgets** — Limite par categorie, suivi de progression.
- **Statistiques** — Graphiques cashflow, repartition des depenses par categorie.
- **Vault** — Chiffrement E2E optionnel (AES-256-GCM). Verrouillage biometrie/PIN (mobile) ou mot de passe maitre (web).
- **Authentification** — Mode anonyme (local) ou Google OAuth avec synchronisation cloud.
- **Dark mode** — Clair / Sombre / Systeme.

## Architecture

```
monasafe/
├── mobile/          # Flutter (Android, iOS)
├── web/             # Nuxt 3 (Vue 3 + TypeScript)
├── CONTRIBUTING.md
└── README.md
```

Les deux clients partagent le meme backend **Supabase** (PostgreSQL, Auth, Row Level Security).

### Stack

| | Mobile | Web |
|---|---|---|
| **Framework** | Flutter 3.38 | Nuxt 3 (Vue 3) |
| **State** | Riverpod + code generation | Pinia + composables |
| **Backend** | Supabase Flutter | @nuxtjs/supabase |
| **Graphiques** | fl_chart | Chart.js |
| **Vault** | cryptography + flutter_secure_storage + local_auth | Web Crypto API (AES-256-GCM, PBKDF2) |
| **Styling** | Material Design custom | Tailwind CSS |

## Demarrage rapide

### Prerequis

- Un projet [Supabase](https://supabase.com) avec les tables configurees (voir [schema](#base-de-donnees))
- **Mobile** : Flutter SDK >= 3.10.7
- **Web** : Node.js >= 18

### Mobile

```bash
cd mobile
flutter pub get
cp .env.example .env          # Remplir SUPABASE_URL et SUPABASE_ANON_KEY
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Web

```bash
cd web
npm install
cp .env.example .env          # Remplir SUPABASE_URL et SUPABASE_ANON_KEY
npm run dev
```

> Documentation detaillee : [`mobile/README.md`](mobile/README.md) | [`web/README.md`](web/README.md)

## Base de donnees

Les deux clients se connectent au meme projet Supabase. Toutes les tables ont **Row Level Security** active.

| Table | Description |
|-------|-------------|
| `accounts` | Comptes bancaires (type, devise, couleur, solde) |
| `categories` | Categories de transactions (defaut + custom, type income/expense) |
| `transactions` | Transactions financieres (montant chiffre si Vault actif) |
| `recurring_transactions` | Paiements recurrents mensuels |
| `user_budgets` | Budgets par categorie (`UNIQUE(user_id, category_id)`) |
| `user_settings` | Parametres utilisateur (cle-valeur : devise, onboarding, etc.) |

Chaque table a les colonnes `user_id`, `created_at`, `updated_at`. Les politiques RLS garantissent que chaque utilisateur ne voit que ses propres donnees :

```sql
CREATE POLICY "Users can view own data" ON table_name
  FOR SELECT USING (auth.uid() = user_id);
```

> Schema complet avec index et migrations SQL : [`mobile/README.md`](mobile/README.md#base-de-donnees)

## Contribution

Voir [`CONTRIBUTING.md`](CONTRIBUTING.md) pour les conventions, le workflow de developpement et les instructions par plateforme.

## Licence

[MIT](LICENSE)
