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

Le projet suit une architecture en couches avec une separation nette entre les donnees, le domaine metier et la presentation.

### Structure globale

```
lib/
├── main.dart
└── src/
    ├── core/                        # Fondations partagees
    │   ├── config/                  # Initialisation Supabase, env
    │   ├── middleware/              # Guards de navigation
    │   ├── services/               # Services transverses (encryption, invalidation, recurrence)
    │   ├── theme/                   # AppColors, AppTextStyles, AppTheme
    │   └── utils/                   # CurrencyFormatter, IconMapper, Logger
    ├── common_widgets/              # Composants UI reutilisables (AppButton, CategoryIcon, NumericKeypad...)
    ├── data/                        # Couche donnees
    │   ├── models/                  # Modeles de donnees (Account, Transaction, Category...)
    │   ├── remote/                  # Appels Supabase directs (un fichier par table)
    │   ├── services/                # Logique metier sur les donnees
    │   ├── repositories/            # Abstraction avec Either<Failure, T> (fpdart)
    │   └── providers/               # Providers Riverpod pour la couche data
    └── features/                    # Fonctionnalites, organisees en deux niveaux
        ├── domain/                  # Features metier autonomes
        │   ├── accounts/            # CRUD comptes bancaires
        │   ├── onboarding/          # Flow d'initialisation (devise, compte, auth)
        │   ├── recurring/           # Paiements recurrents
        │   ├── stats/               # Graphiques cashflow, budgets
        │   ├── transactions/        # Ajout/edition de transactions
        │   └── vault/               # Chiffrement E2E, lock screen, biometrie
        └── aggregators/             # Features qui composent plusieurs domaines
            ├── app_shell/           # Shell principal (IndexedStack + bottom nav)
            ├── dashboard/           # Soldes, graphique depenses, transactions recentes
            └── settings/            # Profil, categories, securite, donnees, a propos
```

### Domain vs Aggregators

Les features sont separees en deux categories :

- **`domain/`** : features autonomes qui encapsulent un concept metier unique (comptes, transactions, recurrences...). Elles n'importent pas d'autres features.
- **`aggregators/`** : features qui composent et orchestrent plusieurs features domain (le dashboard agrege comptes + transactions + stats, les settings accedent au vault + categories...).

### Structure d'une feature

Chaque feature suit la meme organisation interne :

```
feature_name/
└── presentation/
    ├── feature_providers.dart       # Providers Riverpod specifiques
    ├── feature_state.dart           # State immutable avec copyWith (si necessaire)
    ├── screens/                     # Ecrans (un widget = un ecran)
    └── widgets/                     # Sous-widgets extraits des ecrans
```

### Flux de donnees

```
Widget (ConsumerWidget)
  → ref.watch(provider)              # Lecture reactive
  → Repository                       # Abstraction avec Either<Failure, T>
    → Service / Remote               # Appels Supabase directs
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

### Decoupage des widgets

- Les fichiers dans `screens/` et `widgets/` ne doivent pas depasser **300 lignes**
- Quand un widget devient trop grand, extraire les sous-widgets dans le dossier `widgets/` de la feature
- Chaque fichier widget contient un seul widget public ; les widgets utilitaires internes restent prives (`_InfoRow`, `_AccountTypeOption`)

### UI

- `AppColors.error` pour les depenses, `AppColors.success` pour les revenus
- `CurrencyFormatter.format(amount)` pour l'affichage des montants
- Composants reutilisables dans `common_widgets/` : `AppButton`, `GlassCard`, `CategoryIcon`, `NumericKeypad`, etc.
- Barrel exports : `import 'package:monasafe/src/data/data.dart'` pour toute la couche data

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
