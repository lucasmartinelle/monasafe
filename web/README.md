# SimpleFlow Web

Application de gestion de finances personnelles. Version web construite avec Nuxt 3.

## Stack technique

| Outil | Usage |
|-------|-------|
| **Nuxt 3** | Framework (Vue 3 + Vite + Nitro) |
| **TypeScript** | Typage strict |
| **Pinia** | State management |
| **Supabase** | Backend (PostgreSQL + Auth + Realtime) |
| **Tailwind CSS** | Styling utility-first |
| **HeadlessUI** | Composants accessibles (modals, dialogs) |
| **Chart.js** | Graphiques (vue-chartjs) |
| **Web Crypto API** | Chiffrement E2E (AES-256-GCM, PBKDF2) |

## Installation

```bash
# Cloner le projet
git clone <repo-url>
cd simpleflow/web

# Installer les dependances
npm install

# Configurer les variables d'environnement
cp .env.example .env
# Remplir SUPABASE_URL et SUPABASE_ANON_KEY
```

## Developpement

```bash
# Serveur de dev
npm run dev

# Verifier les types
npm run typecheck

# Build production
npm run build

# Preview du build
npm run preview
```

## Structure du projet

```
web/
├── assets/css/          # Tailwind + styles custom
├── components/
│   ├── common/          # Composants reutilisables (AppButton, AppInput, AppModal...)
│   ├── dashboard/       # Cards du dashboard
│   ├── onboarding/      # Formulaires onboarding
│   ├── recurring/       # Tuiles et formulaires recurrences
│   ├── settings/        # Gestion categories, comptes
│   ├── stats/           # Graphiques, budgets
│   ├── transactions/    # Tuiles, formulaires, saisie montant
│   └── vault/           # Lock screen, setup modal
├── composables/         # Logique metier (useAccounts, useTransactions, useVault...)
├── layouts/             # default (sidebar), auth (centre), blank
├── middleware/           # guest, onboarding.global
├── pages/               # Routes (dashboard, transactions, recurring, stats, settings)
├── plugins/             # Chart.js (client only)
├── stores/              # Pinia stores (etat reactif pur)
├── types/               # Models, enums, types Supabase
└── utils/               # Helpers (crypto, dates, currency, colors, icons)
```

## Architecture

```
Pages → Composables (logique metier + appels Supabase) → Stores (etat reactif)
                                                       → Supabase Client
```

- **Stores** : etat pur, getters, mutations simples. Jamais de logique metier.
- **Composables** : appels API, validation, chiffrement, gestion d'erreurs.
- **Pages** : orchestration, UI, computed derives des stores.

## Fonctionnalites

- **Comptes** : CRUD, types (courant/epargne/especes), couleurs, soldes calcules
- **Transactions** : CRUD, categorisation, notes avec autocompletion, pagination infinie
- **Recurrences** : Transactions mensuelles auto-generees, activation/desactivation
- **Budgets** : Limite par categorie, suivi progression, vue mensuelle/annuelle
- **Statistiques** : Graphiques cashflow, repartition depenses, selecteur de periode
- **Vault** : Chiffrement E2E optionnel (AES-256-GCM), mot de passe maitre, lock screen
- **Dark mode** : Clair / Sombre / Systeme
- **Authentification** : Anonyme ou Google OAuth, onboarding guide

## Variables d'environnement

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | URL du projet Supabase |
| `SUPABASE_ANON_KEY` | Cle publique (anon) Supabase |

## Documentation

- [API des composables](docs/composables.md)
- [Guide de contribution](CONTRIBUTING.md)
