# SimpleFlow Web - Plan d'implémentation

> **Document de référence pour l'implémentation de la version web de SimpleFlow**
>
> Application de gestion de finances personnelles avec Vue.js 3 + Nuxt 3 + Supabase

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Stack technique](#2-stack-technique)
3. [Architecture](#3-architecture)
4. [Modèles de données](#4-modèles-de-données)
5. [Règles métier](#5-règles-métier)
6. [Installation et configuration](#6-installation-et-configuration)
7. [Phases d'implémentation](#7-phases-dimplémentation)
8. [Design System](#8-design-system)
9. [Sécurité](#9-sécurité)
10. [Déploiement](#10-déploiement)

---

## 1. Vue d'ensemble

### 1.1 Description du projet

SimpleFlow est une application de gestion de finances personnelles permettant de :
- Gérer plusieurs comptes bancaires (courant, épargne, espèces)
- Enregistrer des transactions (revenus/dépenses) avec catégorisation
- Configurer des transactions récurrentes mensuelles
- Suivre des budgets par catégorie
- Visualiser des statistiques financières
- Chiffrer les données sensibles (vault E2E optionnel)

### 1.2 Fonctionnalités principales

| Module | Fonctionnalités |
|--------|-----------------|
| **Authentification** | Anonyme, Google OAuth |
| **Comptes** | CRUD comptes, types (checking/savings/cash), couleurs |
| **Transactions** | CRUD, catégorisation, notes, filtrage par période/compte |
| **Récurrences** | Transactions mensuelles automatiques, activation/désactivation |
| **Budgets** | Limite par catégorie, suivi progression |
| **Statistiques** | Graphiques cashflow, répartition dépenses, période sélectionnable |
| **Catégories** | Par défaut + personnalisées, icônes, couleurs |
| **Vault** | Chiffrement E2E, biométrie (mobile only) |
| **Paramètres** | Devise, gestion données, à propos |

### 1.3 Backend existant

**Supabase** (PostgreSQL + Auth + Realtime)
- Base de données déjà configurée
- RLS (Row Level Security) par `user_id`
- Authentification (anonyme, OAuth Google)

---

## 2. Stack technique

### 2.1 Stack principale

```
Framework:       Nuxt 3 (Vue 3 + Vite + Nitro)
Language:        TypeScript
State:           Pinia
Backend:         Supabase JS SDK v2
Styling:         Tailwind CSS + HeadlessUI
Charts:          Chart.js + vue-chartjs
Icons:           Heroicons + custom SVG
Crypto:          Web Crypto API (SubtleCrypto)
```

### 2.2 Packages NPM

```json
{
  "dependencies": {
    "nuxt": "^3.14",
    "@nuxtjs/supabase": "^1.4",
    "@pinia/nuxt": "^0.5",
    "pinia": "^2.2",
    "@vueuse/core": "^11.0",
    "@vueuse/nuxt": "^11.0",
    "@headlessui/vue": "^1.7",
    "@heroicons/vue": "^2.1",
    "chart.js": "^4.4",
    "vue-chartjs": "^5.3",
    "date-fns": "^3.6",
    "zod": "^3.23"
  },
  "devDependencies": {
    "@nuxtjs/tailwindcss": "^6.12",
    "@nuxt/devtools": "^1.4",
    "typescript": "^5.5",
    "vue-tsc": "^2.0"
  }
}
```

### 2.3 Justification des choix

| Choix | Raison |
|-------|--------|
| **Nuxt 3** | SSR/SSG, routing automatique, DX excellente, écosystème mature |
| **Pinia** | State management officiel Vue 3, simple, TypeScript natif |
| **@nuxtjs/supabase** | Intégration native, composables auto-importés |
| **Tailwind CSS** | Utility-first, cohérent avec design system, rapide |
| **HeadlessUI** | Composants accessibles, unstyled, Vue 3 natif |
| **Zod** | Validation schemas, TypeScript inference |
| **date-fns** | Manipulation dates, léger, tree-shakeable |
| **Web Crypto API** | Natif navigateur, AES-GCM, PBKDF2 (pas de dépendance externe) |

---

## 3. Architecture

### 3.1 Structure des dossiers

```
simpleflow-web/
├── .nuxt/                    # Build Nuxt (généré)
├── assets/
│   ├── css/
│   │   └── main.css          # Tailwind + custom styles
│   └── icons/                # SVG icons custom
├── components/
│   ├── common/               # Composants réutilisables
│   │   ├── AppButton.vue
│   │   ├── AppInput.vue
│   │   ├── AppModal.vue
│   │   ├── AppCard.vue
│   │   ├── IconContainer.vue
│   │   ├── CategoryIcon.vue
│   │   ├── AccountTypeBadge.vue
│   │   └── LoadingState.vue
│   ├── onboarding/
│   │   ├── AccountCard.vue
│   │   ├── AccountForm.vue
│   ├── dashboard/
│   │   ├── NetWorthCard.vue
│   │   ├── AccountListCard.vue
│   │   ├── ExpenseBreakdownCard.vue
│   │   └── RecentTransactionsCard.vue
│   ├── transactions/
│   │   ├── TransactionForm.vue
│   │   ├── TransactionTile.vue
│   │   ├── AmountInput.vue
│   │   ├── CategoryGrid.vue
│   │   └── SmartNoteField.vue
│   ├── recurring/
│   │   ├── RecurringTile.vue
│   │   └── RecurringForm.vue
│   ├── stats/
│   │   ├── CashflowChart.vue
│   │   ├── BudgetProgressBar.vue
│   │   ├── BudgetList.vue
│   │   └── PeriodSelector.vue
│   ├── settings/
│   │   ├── CategoryListTile.vue
│   │   ├── CategoryFormModal.vue
│   │   ├── IconPicker.vue
│   │   └── ColorPicker.vue
│   └── layout/
│       ├── AppSidebar.vue
│       ├── AppHeader.vue
│       └── AppNavigation.vue
├── composables/
│   ├── useAccounts.ts        # CRUD comptes
│   ├── useTransactions.ts    # CRUD transactions
│   ├── useRecurring.ts       # CRUD récurrences
│   ├── useCategories.ts      # CRUD catégories
│   ├── useBudgets.ts         # CRUD budgets
│   ├── useStatistics.ts      # Calculs stats
│   ├── useVault.ts           # Chiffrement E2E
│   ├── useCurrency.ts        # Formatage devise
│   └── useAuth.ts            # Authentification
├── layouts/
│   ├── default.vue           # Layout principal (sidebar + content)
│   ├── auth.vue              # Layout authentification
│   └── blank.vue             # Layout vide
├── middleware/
│   ├── auth.ts               # Protection routes authentifiées
│   ├── guest.ts              # Protection routes non authentifiées
│   └── onboarding.ts         # Vérification onboarding complété
├── pages/
│   ├── index.vue             # Redirect → /dashboard ou /auth
│   ├── auth/
│   │   ├── index.vue         # Choix auth (login/register)
│   │   ├── login.vue         # Connexion
│   │   ├── register.vue      # Inscription
│   │   └── callback.vue      # OAuth callback
│   ├── onboarding/
│   │   └── index.vue         # Setup initial (compte, devise)
│   ├── dashboard/
│   │   └── index.vue         # Vue d'ensemble
│   ├── transactions/
│   │   ├── index.vue         # Liste transactions
│   │   ├── add.vue           # Ajout transaction
│   │   └── [id].vue          # Édition transaction
│   ├── recurring/
│   │   └── index.vue         # Liste récurrences
│   ├── stats/
│   │   └── index.vue         # Statistiques & budgets
│   └── settings/
│       ├── index.vue         # Menu paramètres
│       ├── categories.vue    # Gestion catégories
│       ├── accounts.vue      # Gestion comptes
│       ├── security.vue      # Vault (si implémenté)
│       ├── data.vue          # Gestion données
│       └── about.vue         # À propos
├── plugins/
│   └── chart.client.ts       # Chart.js (client only)
├── server/
│   └── api/                  # API routes si nécessaire
├── stores/
│   ├── auth.ts               # Store authentification
│   ├── accounts.ts           # Store comptes
│   ├── transactions.ts       # Store transactions
│   ├── categories.ts         # Store catégories
│   ├── recurring.ts          # Store récurrences
│   ├── budgets.ts            # Store budgets
│   ├── settings.ts           # Store paramètres
│   └── vault.ts              # Store vault (chiffrement)
├── types/
│   ├── database.ts           # Types Supabase (générés)
│   ├── models.ts             # Interfaces métier
│   └── enums.ts              # Enums
├── utils/
│   ├── currency.ts           # Formatage devises
│   ├── dates.ts              # Helpers dates
│   ├── icons.ts              # Mapping icônes
│   ├── colors.ts             # Palette couleurs
│   └── crypto.ts             # Helpers chiffrement
├── .env                      # Variables d'environnement
├── .env.example              # Template env
├── nuxt.config.ts            # Configuration Nuxt
├── tailwind.config.ts        # Configuration Tailwind
├── tsconfig.json             # Configuration TypeScript
└── package.json
```

### 3.2 Architecture des données

```
┌─────────────────────────────────────────────────────────────┐
│                        PAGES (Vue)                          │
│  dashboard / transactions / recurring / stats / settings    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              COMPOSABLES (Logique métier)                   │
│  Appels Supabase, gestion erreurs, redirections,            │
│  transformations de données                                 │
│  useAuth / useAccounts / useTransactions / useCategories    │
└─────────────────────────────────────────────────────────────┘
                              │
                       ┌──────┴──────┐
                       ▼             ▼
┌──────────────────────────┐ ┌──────────────────────────────┐
│    STORES (Pinia)        │ │     SUPABASE CLIENT          │
│    État réactif pur      │ │     useSupabaseClient()      │
│    Getters, Mutations    │ │     useSupabaseUser()        │
│    Pas de logique métier │ └──────────────────────────────┘
└──────────────────────────┘              │
                                          ▼
                              ┌──────────────────────────────┐
                              │     SUPABASE BACKEND         │
                              │  PostgreSQL + Auth + RLS     │
                              └──────────────────────────────┘
```

> **Convention** : Les stores ne contiennent **jamais** de logique métier ni d'appels API.
> Ils exposent l'état réactif (state, getters) et des mutations simples (setters).
> Toute la logique (appels Supabase, validation, redirections) vit dans les composables.

### 3.3 Flux de données

```
1. LECTURE (avec Realtime)
   Page → composable.watch() → store.subscribe() → Supabase Realtime
                                                          │
   UI ← computed ← store.state ← callback ←───────────────┘

2. ÉCRITURE
   User Action → composable.create/update/delete()
                         │
                         ▼
                 store.action() → Supabase.from().insert/update/delete()
                         │
                         ▼
                 Realtime broadcast → Tous les clients synchronisés

3. VAULT (si activé)
   Écriture: data → vault.encrypt() → Base64 → Supabase
   Lecture:  Supabase → Base64 → vault.decrypt() → data
```

---

## 4. Modèles de données

### 4.1 Types TypeScript

```typescript
// types/enums.ts
export enum AccountType {
  CHECKING = 'checking',
  SAVINGS = 'savings',
  CASH = 'cash'
}

export enum CategoryType {
  INCOME = 'income',
  EXPENSE = 'expense'
}

export enum SyncStatus {
  PENDING = 'pending',
  SYNCED = 'synced'
}

// types/models.ts
export interface Account {
  id: string
  userId: string
  name: string
  type: AccountType
  balance: number
  currency: string
  color: number
  createdAt: string
  updatedAt: string
}

export interface Category {
  id: string
  userId: string | null  // null = catégorie par défaut
  name: string
  iconKey: string
  color: number
  type: CategoryType
  budgetLimit: number | null
  isDefault: boolean
  createdAt: string
  updatedAt: string
}

export interface Transaction {
  id: string
  userId: string
  accountId: string
  categoryId: string
  amount: number          // Déchiffré
  rawAmount: string       // Brut (chiffré ou non)
  date: string
  note: string | null     // Déchiffré
  rawNote: string | null  // Brut
  recurringId: string | null
  isEncrypted: boolean
  syncStatus: SyncStatus
  createdAt: string
  updatedAt: string
}

export interface TransactionWithDetails extends Transaction {
  account: Account
  category: Category
}

export interface RecurringTransaction {
  id: string
  userId: string
  accountId: string
  categoryId: string
  amount: number
  rawAmount: string
  note: string | null
  rawNote: string | null
  originalDay: number     // Jour du mois (1-31)
  startDate: string
  endDate: string | null
  lastGenerated: string | null
  isActive: boolean
  isEncrypted: boolean
  createdAt: string
  updatedAt: string
}

export interface RecurringWithDetails extends RecurringTransaction {
  account: Account
  category: Category
}

export interface UserBudget {
  id: string
  userId: string
  categoryId: string
  budgetLimit: number
  createdAt: string
  updatedAt: string
}

export interface BudgetProgress {
  budgetId: string
  category: Category
  budgetLimit: number
  monthlyBudgetLimit: number
  currentSpending: number
}

export interface UserSetting {
  userId: string
  key: string
  value: string
}

// Stats
export interface FinancialSummary {
  totalBalance: number
  totalIncome: number
  totalExpense: number
  monthlyIncome: number
  monthlyExpense: number
}

export interface CategoryStatistics {
  categoryId: string
  categoryName: string
  total: number
  count: number
  percentage: number
}

export interface DailyStatistics {
  date: string
  income: number
  expense: number
}

export interface MonthlyStatistics {
  month: number
  year: number
  income: number
  expense: number
}
```

### 4.2 Schéma Supabase existant

```sql
-- Tables principales (déjà existantes)
accounts (id, user_id, name, type, balance, currency, color, created_at, updated_at)
categories (id, user_id, name, icon_key, color, type, budget_limit, is_default, created_at, updated_at)
transactions (id, user_id, account_id, category_id, amount, date, note, recurring_id, is_encrypted, sync_status, created_at, updated_at)
recurring_transactions (id, user_id, account_id, category_id, amount, note, original_day, start_date, end_date, last_generated, is_active, is_encrypted, created_at, updated_at)
user_budgets (id, user_id, category_id, budget_limit, created_at, updated_at)
user_settings (user_id, key, value)

-- RLS activé sur toutes les tables
-- Policies: user_id = auth.uid()
```

---

## 5. Règles métier

### 5.1 Authentification

| Règle | Description |
|-------|-------------|
| **AUTH-01** | Un utilisateur peut commencer en mode anonyme |
| **AUTH-02** | Un compte anonyme peut être upgradé vers Google |
| **AUTH-03** | Le linking Google préserve toutes les données existantes |
| **AUTH-04** | L'onboarding doit être complété avant d'accéder à l'app |
| **AUTH-05** | L'onboarding crée un compte par défaut + configure la devise |

### 5.2 Comptes

| Règle | Description |
|-------|-------------|
| **ACC-01** | Un compte a un type: checking, savings, ou cash |
| **ACC-02** | Le solde initial est défini à la création |
| **ACC-03** | Le solde calculé = solde initial + revenus - dépenses |
| **ACC-04** | Un compte ne peut être supprimé que s'il n'a pas de transactions |
| **ACC-05** | La devise est globale (paramètre utilisateur), pas par compte |

### 5.3 Transactions

| Règle | Description |
|-------|-------------|
| **TRX-01** | Une transaction est liée à un compte ET une catégorie |
| **TRX-02** | Le type (revenu/dépense) est déterminé par la catégorie |
| **TRX-03** | Le montant est toujours positif, le type détermine le signe |
| **TRX-04** | La note est optionnelle |
| **TRX-05** | Une transaction peut être liée à une récurrence (recurring_id) |
| **TRX-06** | Si vault actif: amount et note sont chiffrés en Base64 |

### 5.4 Récurrences

| Règle | Description |
|-------|-------------|
| **REC-01** | Une récurrence génère une transaction par mois |
| **REC-02** | Le jour original (1-31) est conservé même si le mois a moins de jours |
| **REC-03** | Si jour > jours du mois → utiliser le dernier jour (ex: 31 → 28 fév) |
| **REC-04** | La génération se fait au démarrage de l'app et à chaque resume |
| **REC-05** | `last_generated` track la dernière date générée |
| **REC-06** | Une récurrence peut être désactivée sans supprimer l'historique |
| **REC-07** | Supprimer une récurrence détache les transactions (recurring_id = null) |

### 5.5 Budgets

| Règle | Description |
|-------|-------------|
| **BUD-01** | Un budget est défini par catégorie (expense uniquement) |
| **BUD-02** | Le budget est mensuel |
| **BUD-03** | Vue année: budget × 12 pour comparaison |
| **BUD-04** | Un seul budget par catégorie par utilisateur |
| **BUD-05** | Upsert: création ou mise à jour si existe |

### 5.6 Catégories

| Règle | Description |
|-------|-------------|
| **CAT-01** | Catégories par défaut (is_default=true) non modifiables/supprimables |
| **CAT-02** | Catégories personnalisées liées au user_id |
| **CAT-03** | Une catégorie avec transactions ne peut pas être supprimée |
| **CAT-04** | Icône parmi 66 icônes prédéfinies |
| **CAT-05** | Couleur en format entier (hex → int) |

### 5.7 Vault (Chiffrement)

| Règle | Description |
|-------|-------------|
| **VAU-01** | Vault optionnel, activable dans les paramètres |
| **VAU-02** | Master password → PBKDF2 (100k iter) → KEK |
| **VAU-03** | DEK générée aléatoirement, chiffrée par KEK |
| **VAU-04** | DEK stockée en localStorage (chiffrée) |
| **VAU-05** | Transactions chiffrées en AES-256-GCM |
| **VAU-06** | Activation: chiffre toutes les transactions existantes |
| **VAU-07** | Désactivation: déchiffre toutes les transactions |
| **VAU-08** | Web: pas de biométrie (password uniquement) |

---

## 6. Installation et configuration

### 6.1 Prérequis

```bash
Node.js >= 18.0.0
npm >= 9.0.0 ou pnpm >= 8.0.0
Compte Supabase (existant)
```

### 6.2 Création du projet

```bash
# Créer le projet Nuxt
npx nuxi@latest init simpleflow-web
cd simpleflow-web

# Installer les dépendances principales
npm install @nuxtjs/supabase @pinia/nuxt pinia @vueuse/nuxt
npm install @headlessui/vue @heroicons/vue
npm install chart.js vue-chartjs date-fns zod

# Installer les dépendances de développement
npm install -D @nuxtjs/tailwindcss @nuxt/devtools
npm install -D typescript vue-tsc

# Initialiser Tailwind
npx tailwindcss init
```

### 6.3 Configuration Nuxt

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  devtools: { enabled: true },

  modules: [
    '@nuxtjs/supabase',
    '@pinia/nuxt',
    '@nuxtjs/tailwindcss',
    '@vueuse/nuxt',
  ],

  supabase: {
    url: process.env.SUPABASE_URL,
    key: process.env.SUPABASE_ANON_KEY,
    redirectOptions: {
      login: '/auth',
      callback: '/auth/callback',
      exclude: ['/auth/*', '/'],
    },
  },

  pinia: {
    autoImports: ['defineStore', 'storeToRefs'],
  },

  typescript: {
    strict: true,
    typeCheck: true,
  },

  app: {
    head: {
      title: 'SimpleFlow',
      meta: [
        { name: 'description', content: 'Gestion de finances personnelles' },
        { name: 'theme-color', content: '#1B5E5A' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Poppins:wght@500;600;700&display=swap'
        },
      ],
    },
  },

  runtimeConfig: {
    public: {
      supabaseUrl: process.env.SUPABASE_URL,
      supabaseKey: process.env.SUPABASE_ANON_KEY,
    },
  },

  compatibilityDate: '2024-11-01',
})
```

### 6.4 Configuration Tailwind

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

export default {
  content: [
    './components/**/*.{vue,js,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './composables/**/*.{js,ts}',
    './plugins/**/*.{js,ts}',
    './app.vue',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#1B5E5A',
          light: '#4A8B87',
          dark: '#0D3D3A',
        },
        accent: {
          DEFAULT: '#E87B4D',
          light: '#F5A882',
          dark: '#C45A2E',
        },
        surface: {
          light: '#FFFFFF',
          dark: '#1E1E1E',
        },
        background: {
          light: '#E8E8E8',
          dark: '#121212',
        },
        card: {
          light: '#FFFFFF',
          dark: '#2C2C2C',
        },
        success: '#4CAF50',
        warning: '#FF9800',
        error: '#F44336',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        heading: ['Poppins', 'sans-serif'],
      },
      borderRadius: {
        DEFAULT: '12px',
        lg: '16px',
        xl: '20px',
      },
    },
  },
  plugins: [],
} satisfies Config
```

### 6.5 Variables d'environnement

```bash
# .env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# .env.example
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 6.6 Scripts package.json

```json
{
  "scripts": {
    "dev": "nuxt dev",
    "build": "nuxt build",
    "generate": "nuxt generate",
    "preview": "nuxt preview",
    "typecheck": "nuxt typecheck",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  }
}
```

---

## 7. Phases d'implémentation

### Phase 1 : Fondations [FAIT]

#### 1.1 Setup projet
- [ ] Créer le projet Nuxt 3
- [ ] Configurer TypeScript strict
- [ ] Installer et configurer Tailwind CSS
- [ ] Configurer @nuxtjs/supabase
- [ ] Configurer Pinia
- [ ] Créer la structure des dossiers

#### 1.2 Types et utilitaires
- [ ] Créer `types/enums.ts`
- [ ] Créer `types/models.ts`
- [ ] Créer `utils/currency.ts` (formatage devises)
- [ ] Créer `utils/dates.ts` (helpers date-fns)
- [ ] Créer `utils/icons.ts` (mapping 66 icônes)
- [ ] Créer `utils/colors.ts` (palette couleurs)

#### 1.3 Composants de base
- [ ] `AppButton.vue` (primary, secondary, danger, sizes)
- [ ] `AppInput.vue` (text, email, password, number)
- [ ] `AppModal.vue` (dialog avec HeadlessUI)
- [ ] `AppCard.vue` (conteneur stylisé)
- [ ] `LoadingState.vue` (spinner, skeleton)
- [ ] `IconContainer.vue` (wrapper icône avec fond)

#### 1.4 Layouts
- [ ] `layouts/blank.vue` (layout vide)
- [ ] `layouts/auth.vue` (centré, logo)
- [ ] `layouts/default.vue` (sidebar + header + content)

**Livrable Phase 1** : Projet configuré, composants de base fonctionnels

---

### Phase 2 : Authentification [FAIT]

#### 2.1 Store authentification (état pur, pas de logique métier)
- [x] Créer `stores/auth.ts`
  - State: user (via useSupabaseUser), isLoading, error
  - Getters: isAuthenticated, isAnonymous, userId, userEmail, hasGoogleProvider
    - Mutations: setLoading, setError, clearError

#### 2.2 Composable auth (logique métier, appels Supabase, redirections)
- [x] Créer `composables/useAuth.ts`
  - signInAnonymous → supabase.auth.signInAnonymously() + redirect /onboarding
  - signInGoogle → supabase.auth.signInWithOAuth() + redirect Google
  - linkGoogle → supabase.auth.linkIdentity() (AUTH-02, AUTH-03)
  - signOut → supabase.auth.signOut() + redirect /auth
  - Gestion erreurs → store.setError()
  - Gestion loading → store.setLoading()
  - Expose computed readonly depuis le store

#### 2.3 Middleware
- [x] `middleware/guest.ts` (redirige vers /dashboard si déjà authentifié)
- [x] `middleware/onboarding.global.ts` (vérifie user_settings.onboarding_completed, cache via useState)
- Protection auth gérée par le module @nuxtjs/supabase (redirectOptions dans nuxt.config.ts)

#### 2.4 Pages authentification
- [x] `pages/index.vue` (redirect intelligent auth/dashboard)
- [x] `pages/auth/index.vue` (choix: anonyme ou Google, middleware guest)
- [x] `pages/auth/callback.vue` (OAuth callback, invalide cache onboarding, redirect /dashboard)

**Livrable Phase 2** : Authentification complète (anonyme, Google)

---

### Phase 3 : Onboarding & Comptes [FAIT]

#### 3.1 Store settings (état pur)
- [ ] Créer `stores/settings.ts`
  - State: currency, onboardingCompleted, primaryAccountId, isLoading
  - Getters: formattedCurrency
  - Mutations: setCurrency, setOnboardingCompleted, setPrimaryAccountId, setLoading

#### 3.2 Store comptes (état pur)
- [ ] Créer `stores/accounts.ts`
  - State: accounts, selectedAccountId, isLoading, error
  - Getters: totalBalance, accountById, sortedAccounts
  - Mutations: setAccounts, addAccount, updateAccount, removeAccount, setSelectedAccountId, setLoading, setError

#### 3.3 Composables (logique métier, appels Supabase)
- [ ] Créer `composables/useSettings.ts`
  - loadSettings() → supabase.from('user_settings') + store.set*()
  - updateSetting() → supabase.from('user_settings').upsert() + store.set*()
  - completeOnboarding() → updateSetting('onboarding_completed', 'true')
- [ ] Créer `composables/useAccounts.ts`
  - fetchAccounts() → supabase.from('accounts') + store.setAccounts()
  - createAccount() → supabase.from('accounts').insert() + store.addAccount()
  - updateAccount() → supabase.from('accounts').update() + store.updateAccount()
  - deleteAccount() → supabase.from('accounts').delete() + store.removeAccount()
  - Realtime subscription → supabase.channel().on() + mutations store
- [ ] Créer `composables/useCurrency.ts`

#### 3.4 Pages onboarding
- [ ] `pages/onboarding/index.vue`
  - Step 1: Choix devise
  - Step 2: Création premier compte
  - Step 3: Confirmation

#### 3.5 Composants comptes
- [ ] `AccountTypeBadge.vue`
- [ ] `AccountCard.vue`
- [ ] `AccountForm.vue`

**Livrable Phase 3** : Onboarding fonctionnel, CRUD comptes

---

### Phase 4 : Catégories

#### 4.1 Store catégories (état pur)
- [ ] Créer `stores/categories.ts`
  - State: categories, isLoading, error
  - Getters: expenseCategories, incomeCategories, categoryById
  - Mutations: setCategories, addCategory, updateCategory, removeCategory, setLoading, setError

#### 4.2 Composable (logique métier, appels Supabase)
- [ ] Créer `composables/useCategories.ts`
  - fetchCategories() → supabase.from('categories') + store.setCategories()
  - createCategory() → supabase.from('categories').insert() + store.addCategory()
  - updateCategory() → supabase.from('categories').update() + store.updateCategory()
  - deleteCategory() → supabase.from('categories').delete() + store.removeCategory()
  - Realtime subscription

#### 4.3 Composants
- [ ] `CategoryIcon.vue` (icône + couleur)
- [ ] `CategoryGrid.vue` (grille sélection)
- [ ] `CategoryListTile.vue` (tuile avec actions)
- [ ] `CategoryFormModal.vue` (création/édition)
- [ ] `IconPicker.vue` (sélecteur 66 icônes)
- [ ] `ColorPicker.vue` (palette couleurs)

#### 4.4 Page settings/categories
- [ ] `pages/settings/categories.vue`
  - Tabs: Dépenses / Revenus
  - Liste catégories
  - Bouton ajout
  - Protection suppression si transactions liées

**Livrable Phase 4** : CRUD catégories complet

---

### Phase 5 : Transactions

#### 5.1 Store transactions (état pur)
- [ ] Créer `stores/transactions.ts`
  - State: transactions, isLoading, error, pagination
  - Getters: recentTransactions, transactionsByAccount, transactionsByPeriod
  - Mutations: setTransactions, addTransaction, updateTransaction, removeTransaction, setLoading, setError

#### 5.2 Composable (logique métier, appels Supabase)
- [ ] Créer `composables/useTransactions.ts`
  - fetchTransactions() → supabase.from('transactions') + store.setTransactions()
  - createTransaction() → supabase.from('transactions').insert() + store.addTransaction()
  - updateTransaction() → supabase.from('transactions').update() + store.updateTransaction()
  - deleteTransaction() → supabase.from('transactions').delete() + store.removeTransaction()
  - Filtrage, pagination, recherche
  - Realtime subscription
  - Support chiffrement (si vault actif)

#### 5.3 Composants transactions
- [ ] `TransactionTile.vue` (affichage transaction)
- [ ] `TransactionForm.vue` (formulaire complet)
- [ ] `AmountInput.vue` (saisie montant formaté)
- [ ] `SmartNoteField.vue` (autocomplétion notes)
- [ ] `TransactionFilters.vue` (filtres période/compte)

#### 5.4 Pages transactions
- [ ] `pages/transactions/index.vue` (liste avec filtres)
- [ ] `pages/transactions/add.vue` (ajout modal ou page)
- [ ] `pages/transactions/[id].vue` (édition)

**Livrable Phase 5** : CRUD transactions complet avec filtres

---

### Phase 6 : Dashboard

#### 6.1 Composable statistiques (logique métier, calculs)
- [ ] Créer `composables/useStatistics.ts`
  - calculateFinancialSummary() → lecture depuis stores accounts/transactions
  - calculateCategoryStats()
  - calculateMonthlyStats()
  - calculateDailyStats()

#### 6.2 Composants dashboard
- [ ] `NetWorthCard.vue` (solde total)
- [ ] `AccountListCard.vue` (liste comptes avec soldes)
- [ ] `AccountSelector.vue` (dropdown filtre)
- [ ] `ExpenseBreakdownCard.vue` (pie chart)
- [ ] `RecentTransactionsCard.vue` (5 dernières)
- [ ] `QuickAddButton.vue` (FAB ajout rapide)

#### 6.3 Page dashboard
- [ ] `pages/dashboard/index.vue`
  - Layout responsive (grid)
  - Toutes les cards
  - Sélecteur de compte
  - Navigation vers détails

**Livrable Phase 6** : Dashboard fonctionnel avec stats

---

### Phase 7 : Récurrences

#### 7.1 Store récurrences (état pur)
- [ ] Créer `stores/recurring.ts`
  - State: recurrings, isLoading, error
  - Getters: activeRecurrings, inactiveRecurrings
  - Mutations: setRecurrings, addRecurring, updateRecurring, removeRecurring, setLoading, setError

#### 7.2 Composable (logique métier, appels Supabase, génération)
- [ ] Créer `composables/useRecurring.ts`
  - fetchRecurrings() → supabase + store.setRecurrings()
  - createRecurring() → supabase + store.addRecurring()
  - updateRecurring() → supabase + store.updateRecurring()
  - deleteRecurring() → supabase + store.removeRecurring()
  - toggleActive() → supabase + store.updateRecurring()
  - generatePendingTransactions() → logique de génération + appels Supabase
  - calculateNextDate()
  - Gestion jours > jours du mois
  - Realtime subscription

#### 7.3 Composants
- [ ] `RecurringTile.vue` (affichage récurrence)
- [ ] `RecurringForm.vue` (création/édition)
- [ ] `RecurringDetailModal.vue` (détails + actions)
- [ ] `NextDateBadge.vue` (prochaine génération)

#### 7.4 Page récurrences
- [ ] `pages/recurring/index.vue`
  - Sections: Actives / Inactives
  - Toggle activation
  - CRUD complet

#### 7.5 Intégration
- [ ] Hook au démarrage app pour générer transactions pending
- [ ] Notification si transactions générées

**Livrable Phase 7** : Récurrences fonctionnelles avec génération auto

---

### Phase 8 : Statistiques & Budgets

#### 8.1 Store budgets (état pur)
- [ ] Créer `stores/budgets.ts`
  - State: budgets, isLoading, error
  - Getters: budgetByCategory, budgetProgress
  - Mutations: setBudgets, upsertBudget, removeBudget, setLoading, setError

#### 8.2 Composables (logique métier, appels Supabase)
- [ ] Créer `composables/useBudgets.ts`
  - fetchBudgets() → supabase + store.setBudgets()
  - upsertBudget() → supabase.from('user_budgets').upsert() + store.upsertBudget()
  - deleteBudget() → supabase + store.removeBudget()
- [ ] Enrichir `composables/useStatistics.ts`

#### 8.3 Composants stats
- [ ] `PeriodSelector.vue` (mois/trimestre/année)
- [ ] `CashflowChart.vue` (bar chart revenus/dépenses)
- [ ] `BudgetProgressBar.vue` (barre progression)
- [ ] `BudgetList.vue` (liste budgets)
- [ ] `BudgetFormModal.vue` (création/édition)
- [ ] `BudgetDetailModal.vue` (détails + transactions)

#### 8.4 Page stats
- [ ] `pages/stats/index.vue`
  - Sélecteur période
  - Graphique cashflow
  - Liste budgets avec progression
  - Drill-down par catégorie

**Livrable Phase 8** : Stats et budgets complets

---

### Phase 9 : Paramètres

#### 9.1 Pages settings
- [ ] `pages/settings/index.vue` (menu principal)
- [ ] `pages/settings/accounts.vue` (gestion comptes + devise)
- [ ] `pages/settings/data.vue` (suppression données)
- [ ] `pages/settings/about.vue` (version, crédits, liens)

#### 9.2 Composable data management (logique métier)
- [ ] Créer `composables/useDataManagement.ts`
  - deleteTransactions() → supabase + invalidation store
  - deleteRecurrings() → supabase + invalidation store
  - deleteBudgets() → supabase + invalidation store
  - deleteAllData() → supabase + reset tous les stores
  - Confirmation "SUPPRIMER" gérée côté page

#### 9.3 Page about
- [ ] Logo et version
- [ ] Crédits développeur
- [ ] Liens légaux (CGU, confidentialité)
- [ ] Contact

**Livrable Phase 9** : Paramètres complets

---

### Phase 10 : Vault / Chiffrement

#### 10.1 Utilitaires crypto
- [ ] Créer `utils/crypto.ts`
  - deriveMasterKey() - PBKDF2
  - generateDEK() - random 256 bits
  - encryptDEK() / decryptDEK()
  - encryptData() / decryptData() - AES-GCM

#### 10.2 Store vault (état pur)
- [ ] Créer `stores/vault.ts`
  - State: isEnabled, isLocked, isLoading, error
  - Getters: isUnlocked
  - Mutations: setEnabled, setLocked, setLoading, setError
  - DEK en mémoire (ref volatile, pas persisté)

#### 10.3 Composable (logique métier, crypto, appels Supabase)
- [ ] Créer `composables/useVault.ts`
  - setup() → dérivation KEK + génération DEK + store mutations
  - unlock() → dérivation KEK + déchiffrement DEK + store.setLocked(false)
  - lock() → clear DEK mémoire + store.setLocked(true)
  - changePassword() → re-dérivation KEK + re-chiffrement DEK
  - disable() → déchiffrement toutes les transactions + store.setEnabled(false)
  - encryptTransaction() / decryptTransaction()
  - encryptAllTransactions() / decryptAllTransactions()

#### 10.4 Intégration
- [ ] Composables transactions/recurring appellent useVault si chiffrement actif
- [ ] Page `settings/security.vue`
- [ ] Lock screen au démarrage si vault actif

**Livrable Phase 10** : Chiffrement E2E fonctionnel (sans biométrie)

---

### Phase 11 : Polish & Optimisations

#### 11.1 UX/UI
- [ ] Dark mode toggle
- [ ] Animations transitions pages
- [ ] Skeleton loaders
- [ ] Toast notifications
- [ ] Empty states illustrés
- [ ] Responsive mobile-first

#### 11.2 Performance
- [ ] Lazy loading pages
- [ ] Optimisation images
- [ ] Pagination infinie transactions
- [ ] Debounce recherches
- [ ] Memoization calculs stats

#### 11.4 Tests
- [ ] Tests unitaires composables
- [ ] Tests composants (Vitest + Vue Test Utils)
- [ ] Tests E2E critiques (Playwright)

#### 11.5 Documentation
- [ ] README.md
- [ ] Guide contribution
- [ ] Documentation API composables

**Livrable Phase 11** : Application production-ready

---

## 8. Design System

### 8.1 Couleurs

```css
/* Couleurs principales */
--color-primary: #1B5E5A;
--color-primary-light: #4A8B87;
--color-primary-dark: #0D3D3A;
--color-accent: #E87B4D;

/* Backgrounds */
--color-bg-light: #E8E8E8;
--color-bg-dark: #121212;
--color-surface-light: #FFFFFF;
--color-surface-dark: #1E1E1E;
--color-card-light: #FFFFFF;
--color-card-dark: #2C2C2C;

/* Text */
--color-text-primary-light: #212121;
--color-text-primary-dark: #FFFFFF;
--color-text-secondary-light: #757575;
--color-text-secondary-dark: #B3B3B3;

/* Status */
--color-success: #4CAF50;
--color-warning: #FF9800;
--color-error: #F44336;
```

### 8.2 Typographie

```css
/* Headings - Poppins */
.text-h1 { font-family: 'Poppins'; font-size: 32px; font-weight: 700; }
.text-h2 { font-family: 'Poppins'; font-size: 24px; font-weight: 600; }
.text-h3 { font-family: 'Poppins'; font-size: 20px; font-weight: 600; }
.text-h4 { font-family: 'Poppins'; font-size: 18px; font-weight: 500; }

/* Body - Inter */
.text-body-lg { font-family: 'Inter'; font-size: 16px; font-weight: 400; }
.text-body-md { font-family: 'Inter'; font-size: 14px; font-weight: 400; }
.text-body-sm { font-family: 'Inter'; font-size: 12px; font-weight: 400; }

/* Labels - Inter */
.text-label-lg { font-family: 'Inter'; font-size: 16px; font-weight: 600; }
.text-label-md { font-family: 'Inter'; font-size: 14px; font-weight: 500; }
.text-label-sm { font-family: 'Inter'; font-size: 12px; font-weight: 500; }
```

### 8.3 Spacing & Sizing

```css
/* Spacing scale */
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-5: 20px;
--space-6: 24px;
--space-8: 32px;
--space-10: 40px;

/* Border radius */
--radius-sm: 8px;
--radius-md: 12px;
--radius-lg: 16px;
--radius-xl: 20px;
--radius-full: 9999px;

/* Shadows */
--shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
--shadow-md: 0 4px 6px rgba(0,0,0,0.1);
--shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
```

### 8.4 Icônes disponibles

```typescript
// 66 icônes mappées (identiques à Flutter)
const ICON_KEYS = [
  // Dépenses
  'shopping_cart', 'restaurant', 'local_gas_station', 'directions_car',
  'home', 'power', 'wifi', 'phone_android', 'movie', 'sports_esports',
  'fitness_center', 'medical_services', 'school', 'child_care',
  'pets', 'flight', 'hotel', 'beach_access', 'card_giftcard',
  'checkroom', 'content_cut', 'local_laundry_service', 'build',
  'store', 'local_grocery_store', 'local_cafe', 'local_bar',
  'fastfood', 'icecream', 'cake',

  // Revenus
  'work', 'attach_money', 'account_balance', 'trending_up',
  'card_membership', 'redeem', 'savings',

  // Comptes
  'account_balance_wallet', 'credit_card', 'payments',

  // Autres
  'category', 'more_horiz', 'star', 'favorite', 'bookmark',
  'flag', 'label', 'lightbulb', 'extension', 'widgets',
  'auto_awesome', 'psychology', 'self_improvement', 'spa',
  'volunteer_activism', 'celebration', 'emoji_events',
  'military_tech', 'workspace_premium', 'diamond',
  'rocket_launch', 'science', 'biotech', 'memory', 'token', 'bolt',
]
```

---

## 9. Sécurité

### 9.1 Authentification

- Supabase Auth avec JWT
- Tokens stockés en httpOnly cookies (géré par @nuxtjs/supabase)
- Refresh automatique des tokens
- Déconnexion sur expiration

### 9.2 Autorisation

- RLS Supabase sur toutes les tables
- Policies: `user_id = auth.uid()`
- Pas d'accès direct aux données autres utilisateurs

### 9.3 Chiffrement (Vault)

```
Web Crypto API (natif navigateur)
├── PBKDF2-SHA256 (100k itérations) pour dérivation
├── AES-256-GCM pour chiffrement
├── Salt: 32 bytes random (crypto.getRandomValues)
└── IV/Nonce: 12 bytes random par opération

Stockage:
├── KEK Salt: localStorage
├── Encrypted DEK: localStorage
└── DEK (déchiffrée): mémoire uniquement (volatile)
```

### 9.4 Bonnes pratiques

- [ ] Validation entrées avec Zod (côté client)
- [ ] Sanitization avant affichage
- [ ] HTTPS obligatoire en production
- [ ] CSP headers configurés
- [ ] Pas de secrets dans le code source
- [ ] Variables d'environnement pour config sensible

---

## 10. Déploiement

### 10.1 Options recommandées

| Plateforme | Avantages | Config |
|------------|-----------|--------|
| **Vercel** | Gratuit, simple, preview branches | `nuxt build` |
| **Netlify** | Gratuit, forms, functions | `nuxt generate` |
| **Cloudflare Pages** | Edge, rapide, gratuit | `nuxt build --preset=cloudflare_pages` |

### 10.2 Déploiement Vercel (recommandé)

```bash
# 1. Installer Vercel CLI
npm i -g vercel

# 2. Login
vercel login

# 3. Déployer
vercel

# 4. Configurer variables d'environnement
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY

# 5. Déployer en production
vercel --prod
```

### 10.4 CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run typecheck
      - run: npm run build
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

---

## Annexes

### A. Commandes utiles

```bash
# Développement
npm run dev                 # Démarrer serveur dev
npm run build              # Build production
npm run preview            # Preview build local
npm run typecheck          # Vérifier types

# Supabase
npx supabase gen types typescript --project-id=xxx > types/database.ts
```

### B. Ressources

- [Documentation Nuxt 3](https://nuxt.com/docs)
- [Documentation Vue 3](https://vuejs.org/guide)
- [Documentation Supabase](https://supabase.com/docs)
- [Documentation Pinia](https://pinia.vuejs.org/)
- [Documentation Tailwind CSS](https://tailwindcss.com/docs)
- [HeadlessUI Vue](https://headlessui.com/vue)
- [Heroicons](https://heroicons.com/)

---

> **Document créé le**: $(date +%Y-%m-%d)
> **Version**: 1.0
> **Projet source**: SimpleFlow Flutter
