# Monasafe Mobile

Application Flutter de gestion de finances personnelles avec Supabase.

## Installation

```bash
flutter pub get
cp .env.example .env
# Remplir les variables :
#   SUPABASE_URL, SUPABASE_ANON_KEY
#   TERMS_URL, PRIVACY_URL

flutter packages pub run build_runner build --delete-conflicting-outputs
flutter run
```

> `dart run build_runner` echoue silencieusement (exit 255) — toujours utiliser `flutter packages pub run build_runner`.

### Variables d'environnement

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | URL du projet Supabase |
| `SUPABASE_ANON_KEY` | Cle publique (anon) Supabase |
| `TERMS_URL` | URL des conditions d'utilisation |
| `PRIVACY_URL` | URL de la politique de confidentialite |

## Architecture

```
lib/
├── main.dart                    # Entrypoint, MonasafeApp
└── src/
    ├── core/
    │   ├── config/              # Supabase init, env
    │   ├── constants/           # Constantes globales
    │   ├── services/            # Services metier (encryption, recurrence)
    │   ├── theme/               # AppColors, AppTextStyles, AppTheme
    │   └── utils/               # CurrencyFormatter, IconMapper, Logger
    ├── common_widgets/          # Composants UI reutilisables
    ├── data/
    │   ├── models/              # Account, Transaction, Category, enums...
    │   ├── services/            # CRUD Supabase (un service par table)
    │   ├── repositories/        # Couche abstraction avec Either (fpdart)
    │   └── providers/           # Providers Supabase + services
    └── features/                # Ecrans, organises par domaine
        ├── app_shell/           # Shell principal (IndexedStack + bottom nav)
        ├── dashboard/           # Soldes, graphique depenses, transactions recentes
        ├── transactions/        # Ajout/edition avec clavier numerique custom
        ├── recurring/           # Paiements recurrents
        ├── stats/               # Graphiques cashflow, budgets
        ├── vault/               # Chiffrement E2E, lock screen, biometrie
        ├── onboarding/          # Flow 3 etapes (devise, compte, auth)
        ├── accounts/            # CRUD comptes bancaires
        └── settings/            # Profil, categories, securite, donnees, a propos
```

### Flux de donnees

```
Widget (ConsumerWidget)
  → ref.watch(provider)        # Lecture reactive
  → Repository                 # Abstraction avec Either<Failure, T>
    → Service                  # Appels Supabase directs
      → Supabase Client
```

### Navigation

```
MonasafeApp
  └── Onboarding non fait ? → OnboardingFlow (Welcome → Setup → AuthChoice)
  └── Onboarding fait ?
      └── Vault active et verrouille ? → LockScreen
      └── Sinon → AppShell (IndexedStack)
          ├── Dashboard
          ├── Stats
          ├── Recurrences
          └── Reglages
          + FAB central → AddTransactionScreen
```

## Conventions

### Riverpod

- `@riverpod` pour les providers auto-dispose (par defaut)
- `@Riverpod(keepAlive: true)` pour les providers persistants (auth, settings)
- Les fichiers `.g.dart` sont generes — ne pas les modifier manuellement
- Regenerer apres modification : `flutter packages pub run build_runner build --delete-conflicting-outputs`

### Nommage

| Element | Convention | Exemple |
|---------|-----------|---------|
| Dossiers features | `snake_case` | `transactions/`, `recurring/` |
| Widgets | `PascalCase` | `TransactionTile`, `BudgetProgressTile` |
| Providers | `camelCase` + annotation | `@riverpod Stream<List<Account>> accountsStream(...)` |
| Models | `PascalCase` | `TransactionWithDetails`, `RecurringTransaction` |
| Services | `PascalCase` + suffixe `Service` | `TransactionService`, `AuthService` |
| Repositories | `PascalCase` + suffixe `Repository` | `AccountRepository` |

### Organisation des features

Chaque feature suit la structure :

```
feature_name/
├── data/                  # (optionnel) Services specifiques a la feature
└── presentation/
    ├── feature_providers.dart
    ├── feature_state.dart # (optionnel) State immutable avec copyWith
    ├── screens/
    └── widgets/
```

### UI

- `AppColors.error` pour les depenses, `AppColors.success` pour les revenus
- `CurrencyFormatter.format(amount)` pour l'affichage des montants
- Barrel exports : `import 'package:monasafe/src/data/data.dart'` pour toute la couche data
- Composants reutilisables dans `common_widgets/` : `AppButton`, `GlassCard`, `CategoryIcon`, etc.

### Typographie

| Police | Usage |
|--------|-------|
| **Inter** | Corps de texte, labels, boutons |
| **Poppins** | Titres, montants |

## Developpement

```bash
# Lancer l'application
flutter run

# Regenerer le code (apres modification des providers)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Mode watch (regeneration automatique)
flutter packages pub run build_runner watch --delete-conflicting-outputs

# Verifier les erreurs de compilation
flutter analyze

# Lancer les tests
flutter test

# Regenerer les icones d'app
flutter pub run flutter_launcher_icons

# Regenerer le splash screen
flutter pub run flutter_native_splash:create
```

## Base de donnees

Les migrations se font dans le SQL Editor de Supabase. Schema complet ci-dessous.

### Tables

#### `accounts`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Auto-genere |
| `user_id` | UUID (FK → auth.users) | Proprietaire |
| `name` | TEXT | Nom du compte |
| `type` | TEXT | `checking`, `savings`, `cash` |
| `balance` | DECIMAL(12,2) | Solde initial |
| `currency` | TEXT(3) | Code ISO 4217 |
| `color` | INT | Couleur ARGB |

#### `categories`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Auto-genere |
| `user_id` | UUID (FK) | NULL = categorie par defaut |
| `name` | TEXT | Nom |
| `icon_key` | TEXT | Reference icone |
| `color` | INT | Couleur ARGB |
| `type` | TEXT | `income`, `expense` |
| `is_default` | BOOL | Non supprimable si true |

#### `transactions`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Auto-genere |
| `user_id` | UUID (FK) | Proprietaire |
| `account_id` | UUID (FK) | Compte associe |
| `category_id` | UUID (FK) | Categorie |
| `recurring_id` | UUID (FK, nullable) | Lien vers recurrence |
| `amount` | TEXT | Montant (chiffre si Vault actif) |
| `date` | TIMESTAMPTZ | Date |
| `note` | TEXT | Note (chiffree si Vault actif) |
| `is_encrypted` | BOOL | Donnees chiffrees ou non |
| `sync_status` | TEXT | `pending`, `synced` |

#### `recurring_transactions`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Auto-genere |
| `user_id` | UUID (FK) | Proprietaire |
| `account_id` | UUID (FK) | Compte associe |
| `category_id` | UUID (FK) | Categorie |
| `amount` | DECIMAL(12,2) | Montant |
| `note` | TEXT | Note |
| `original_day` | INT | Jour du mois (1-31) |
| `start_date` | TIMESTAMPTZ | Debut |
| `end_date` | TIMESTAMPTZ (nullable) | Fin optionnelle |
| `last_generated_date` | TIMESTAMPTZ | Derniere occurrence generee |
| `is_active` | BOOL | Active ou suspendue |

#### `user_budgets`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Auto-genere |
| `user_id` | UUID (FK) | Proprietaire |
| `category_id` | UUID (FK) | Categorie ciblee |
| `budget_limit` | DECIMAL(12,2) | Limite mensuelle |

Contrainte : `UNIQUE(user_id, category_id)`.

#### `user_settings`

Table cle-valeur pour les parametres utilisateur.

| Cle | Description |
|-----|-------------|
| `onboarding_completed` | Onboarding termine (bool) |
| `currency` | Devise (EUR, USD, GBP...) |
| `is_anonymous` | Mode local sans sync (bool) |
| `primary_account_id` | ID du compte principal |

### Row Level Security

Toutes les tables ont RLS active. Pattern identique sur chaque table :

```sql
CREATE POLICY "select" ON table FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "insert" ON table FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "update" ON table FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "delete" ON table FOR DELETE USING (auth.uid() = user_id);
```
