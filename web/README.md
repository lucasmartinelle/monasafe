# Monasafe Web

Application Nuxt 3 de gestion de finances personnelles avec Supabase.

**Production** : [monasafe.com](https://monasafe.com) | **Staging** : [staging.monasafe.com](https://staging.monasafe.com)

## Installation

```bash
npm install
cp .env.example .env
# Remplir SUPABASE_URL et SUPABASE_ANON_KEY
npm run dev
```

### Variables d'environnement

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | URL du projet Supabase |
| `SUPABASE_ANON_KEY` | Cle publique (anon) Supabase |

### Commandes

```bash
npm run dev            # Serveur de dev (localhost:3000)
npm run typecheck      # Verification TypeScript
npm run lint           # ESLint
npm run test:coverage  # Tests avec couverture
npm run build          # Build production
npm run preview        # Preview du build
```

## Architecture

```
web/
├── assets/css/          # Tailwind + styles custom (text-h1, text-body-md...)
├── components/
│   ├── common/          # Reutilisables : AppButton, AppInput, AppModal, CategoryGrid...
│   ├── dashboard/       # NetWorthCard, ExpenseBreakdown, RecentTransactions
│   ├── onboarding/      # Steps onboarding
│   ├── recurring/       # RecurringTile, RecurringForm
│   ├── settings/        # CategoryForm, AccountForm, BudgetForm
│   ├── stats/           # CashflowChart, BudgetProgress
│   ├── transactions/    # TransactionForm, AmountInput, SmartNoteField
│   └── vault/           # LockScreen, SetupModal
├── composables/         # Logique metier + appels Supabase
├── layouts/             # default (sidebar), auth (centre), landing (public), blank
├── middleware/           # guest, onboarding.global
├── pages/               # Routes Nuxt
├── plugins/             # Chart.js (client only)
├── stores/              # Pinia stores (etat reactif pur)
├── types/               # Models, enums, types Supabase
└── utils/               # Helpers purs (crypto, dates, currency, colors, icons)
```

### Flux de donnees

```
Pages
  → Composables (logique metier, appels Supabase, validation, chiffrement)
    → Stores (etat reactif pur, getters, mutations simples)
    → Supabase Client
```

Les **stores** ne contiennent jamais de logique metier ni d'appels API. Toute la logique passe par les **composables**.

### Pages publiques

Les pages suivantes sont accessibles sans authentification :

- `/` — Landing page
- `/auth` — Connexion (anonyme ou Google)
- `/terms` — Conditions d'utilisation
- `/privacy` — Politique de confidentialite

Toutes les autres routes redirigent vers `/auth` si non connecte (gere par `@nuxtjs/supabase`).

## Conventions

### Nommage

| Element | Convention | Exemple |
|---------|-----------|---------|
| Composables | `use` + PascalCase | `useTransactions`, `useVault` |
| Stores | `use` + PascalCase + `Store` | `useAccountsStore` |
| Composants | PascalCase | `TransactionForm.vue`, `BudgetProgressTile.vue` |
| Pages | kebab-case | `settings/categories.vue` |
| Utils | camelCase | `formatMonthYear`, `encryptData` |

### Auto-import des composants

Nuxt auto-importe les composants avec le prefixe de leur dossier parent :

| Dossier | Prefixe | Exemple |
|---------|---------|---------|
| `components/common/` | `Common` | `CommonAppButton`, `CommonAppInput`, `CommonAppModal` |
| `components/vault/` | `Vault` | `VaultSetupModal`, `VaultLockScreen` |
| `components/dashboard/` | `Dashboard` | `DashboardNetWorthCard` |
| `components/transactions/` | `Transactions` | `TransactionsAmountInput` |

Ne jamais utiliser le nom sans prefixe (`AppButton` ne fonctionnera pas, utiliser `CommonAppButton`).

### Validation

Les formulaires utilisent **Zod** pour la validation cote client :

```typescript
const schema = z.object({
  accountId: z.string().min(1, 'Choisissez un compte'),
  categoryId: z.string().min(1, 'Choisissez une categorie'),
  amount: z.number().positive('Le montant doit etre positif'),
})
```

Pour les champs nullable (ex: `categoryId` initialise a `null`), toujours convertir avant validation : `categoryId: categoryId.value ?? ''`.

### Tailwind

Les couleurs et polices custom sont definies dans `tailwind.config.ts` :

| Token | Valeur | Usage |
|-------|--------|-------|
| `primary` | `#1B5E5A` | Boutons principaux, navigation |
| `accent` | `#E87B4D` | CTA, elements d'action |
| `success` | `#4CAF50` | Revenus, budgets OK |
| `error` | `#F44336` | Depenses, budgets depasses |
| `background-light/dark` | `#E8E8E8` / `#121212` | Fond de l'app |
| `card-light/dark` | `#FFFFFF` / `#2C2C2C` | Fond des cartes |

Polices : **Inter** (corps de texte), **Poppins** (titres).

## Deploiement

Le deploiement est gere par GitHub Actions (`.github/workflows/web-ci-cd.yml`) :

| Branche | Action |
|---------|--------|
| PR vers `main` ou `develop` | Typecheck + lint + tests + build |
| Push sur `develop` | Deploy preview sur staging.monasafe.com |
| Push sur `main` | Deploy production sur monasafe.com |

Le deploiement utilise Vercel via `npx vercel` avec token.

## Documentation

- [API des composables](docs/composables.md)
- [Guide de contribution](../CONTRIBUTING.md)
