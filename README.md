# SimpleFlow

Application de gestion de finances personnelles avec architecture **Local-First**.

## Architecture

```
lib/
├── main.dart
└── src/
    ├── core/
    │   ├── constants/
    │   │   └── app_constants.dart
    │   ├── theme/
    │   │   ├── app_colors.dart
    │   │   ├── app_text_styles.dart
    │   │   ├── app_theme.dart
    │   │   └── theme.dart
    │   └── utils/
    │       ├── currency_formatter.dart
    │       ├── icon_mapper.dart
    │       ├── logger_service.dart
    │       └── utils.dart
    ├── common_widgets/
    │   ├── app_button.dart                     # Bouton avec variantes
    │   ├── app_text_field.dart                 # Champ texte simple
    │   ├── app_text_input.dart                 # Champ texte style Glass
    │   ├── async_state_handler.dart            # Affichage de l'état
    │   ├── category_icon.dart                  # Icône catégorie circulaire
    │   ├── common_widgets.dart                 # Barrel export
    │   ├── glass_card.dart                     # Carte glassmorphism
    │   ├── icon_container.dart                 # Conteneur d'icône
    │   ├── icon_label_tile.dart                # Label avec paramètres (icone, sous-titre, ...)
    │   ├── selectable_badge.dart               # Badge/Chip avec fond sélectionnable
    │   └── selectable_option_container.dart    # Container animé avec état de sélection
    ├── data/
    │   ├── data.dart                    # Barrel export
    │   ├── local/
    │   │   ├── database.dart            # Configuration Drift
    │   │   ├── converters/
    │   │   │   └── type_converters.dart # Enums (AccountType, CategoryType, SyncStatus)
    │   │   ├── tables/
    │   │   │   ├── accounts_table.dart
    │   │   │   ├── categories_table.dart
    │   │   │   ├── transactions_table.dart
    │   │   │   └── user_settings_table.dart
    │   │   └── daos/
    │   │       ├── account_dao.dart
    │   │       ├── category_dao.dart
    │   │       ├── transaction_dao.dart
    │   │       ├── user_settings_dao.dart
    │   │       └── statistics_dao.dart
    │   ├── remote/                      # (Supabase - à implémenter)
    │   ├── repositories/
    │   │   ├── account_repository.dart
    │   │   ├── category_repository.dart
    │   │   ├── settings_repository.dart
    │   │   └── transaction_repository.dart
    │   └── providers/
    │       └── database_providers.dart
    └── features/
        ├── app_shell/
        │   └── presentation/
        │       ├── app_shell.dart           # Shell principal avec IndexedStack
        │       └── app_navigation_bar.dart  # Barre de navigation bottom
        ├── dashboard/
        │   └── presentation/
        │       ├── dashboard_providers.dart # Providers pour les données
        │       ├── screens/
        │       │   └── dashboard_screen.dart
        │       └── widgets/
        │           ├── account_selector.dart      # Sélecteur de compte horizontal
        │           ├── expense_breakdown_card.dart # Répartition des dépenses
        │           ├── net_worth_card.dart        # Carte solde total
        │           ├── recent_transactions_card.dart # Transactions récentes
        │           └── transaction_tile.dart      # Tuile transaction
        ├── onboarding/
        │   └── presentation/
        │       ├── onboarding_controller.dart
        │       ├── onboarding_flow.dart
        │       └── screens/
        │           ├── welcome_screen.dart
        │           ├── setup_account_screen.dart
        │           └── auth_choice_screen.dart
        ├── transactions/
        │   └── presentation/
        │       ├── transaction_form_provider.dart # État du formulaire
        │       ├── transaction_form_state.dart    # Modèle d'état
        │       ├── screens/
        │       │   ├── add_transaction_screen.dart  # Modal ajout
        │       │   └── edit_transaction_screen.dart # Modal édition
        │       └── widgets/
        │           ├── amount_display.dart        # Affichage montant
        │           ├── category_grid.dart         # Grille catégories
        │           ├── numeric_keypad.dart        # Clavier numérique
        │           ├── recurrence_toggle.dart     # Toggle récurrence
        │           ├── smart_note_field.dart      # Champ note intelligent
        │           ├── transaction_form.dart      # Formulaire complet
        │           └── transaction_type_tabs.dart # Onglets Income/Expense
        ├── stats/
        │   └── presentation/
        │       └── screens/
        │           └── stats_screen.dart    # Écran statistiques
        ├── wallet/
        │   └── presentation/
        │       └── screens/
        │           └── wallet_screen.dart   # Écran portefeuille/comptes
        └── settings/
            └── presentation/
                └── screens/
                    └── settings_screen.dart # Écran paramètres
```

## Stack Technique

| Catégorie | Package | Version | Description |
|-----------|---------|---------|-------------|
| **State Management** | `flutter_riverpod` | 2.6.1 | Gestion d'état réactive |
| | `riverpod_annotation` | 2.6.1 | Annotations pour génération de code |
| **Navigation** | `go_router` | 14.8.1 | Navigation déclarative |
| **Base de Données** | `drift` | 2.23.1 | ORM SQLite type-safe |
| | `sqlite3_flutter_libs` | 0.5.28 | Binaires SQLite natifs |
| | `path_provider` | 2.1.5 | Accès au filesystem |
| **Backend** | `supabase_flutter` | 2.9.0 | BaaS pour sync & auth |
| **UI** | `fl_chart` | 0.70.2 | Graphiques |
| | `intl` | 0.20.2 | Formatage dates/devises |
| | `cupertino_icons` | 1.0.8 | Icônes Cupertino |
| | `filesize` | 2.0.1 | Formatage taille fichiers |
| **Utils** | `uuid` | 4.5.1 | Génération UUID |
| | `fpdart` | 1.1.0 | Programmation fonctionnelle (Either, Option) |
| | `logger` | 2.5.0 | Logging |

### Dev Dependencies

| Package | Version | Description |
|---------|---------|-------------|
| `build_runner` | 2.4.14 | Génération de code |
| `riverpod_generator` | 2.6.4 | Génère les providers Riverpod |
| `drift_dev` | 2.23.1 | Génère le code Drift |
| `flutter_launcher_icons` | 0.14.3 | Génération des icônes d'app |
| `very_good_analysis` | 6.0.0 | Règles de linting strictes |
| `sqlite3` | 2.4.6 | SQLite pour les tests |

### Typographie

L'application utilise deux familles de polices :

| Police | Poids | Usage |
|--------|-------|-------|
| **Inter** | 400, 500, 600, 700 | Corps de texte, labels, boutons |
| **Poppins** | 400, 500, 600, 700 | Titres, montants |

Les fichiers de polices sont dans `assets/fonts/`.

## Composants UI Atomiques

Composants réutilisables situés dans `lib/src/common_widgets/`.

```dart
import 'package:simpleflow/src/common_widgets/common_widgets.dart';
```

### AppButton

Bouton avec variantes et états multiples.

| Propriété | Type | Description |
|-----------|------|-------------|
| `label` | `String` | Texte du bouton |
| `variant` | `AppButtonVariant` | `primary` (plein), `secondary` (outline), `ghost` (texte) |
| `size` | `AppButtonSize` | `small`, `medium`, `large` |
| `isLoading` | `bool` | Affiche un spinner et désactive le bouton |
| `icon` | `IconData?` | Icône optionnelle |
| `iconPosition` | `IconPosition` | `left` ou `right` |
| `fullWidth` | `bool` | Prend toute la largeur disponible |

```dart
AppButton(
  label: 'Sauvegarder',
  variant: AppButtonVariant.primary,
  isLoading: isSaving,
  icon: Icons.save,
  onPressed: () => save(),
)
```

### AppTextInput

Champ de saisie avec style "Glass" (fond semi-transparent avec blur).

| Propriété | Type | Description |
|-----------|------|-------------|
| `label` | `String?` | Label au-dessus du champ |
| `hint` | `String?` | Placeholder |
| `errorText` | `String?` | Message d'erreur (bordure rouge) |
| `helperText` | `String?` | Texte d'aide |
| `prefixIcon` | `IconData?` | Icône à gauche |
| `suffixIcon` | `IconData?` | Icône à droite (cliquable) |
| `obscureText` | `bool` | Masque le texte (mot de passe) |

```dart
AppTextInput(
  label: 'Email',
  hint: 'exemple@mail.com',
  prefixIcon: Icons.email_outlined,
  errorText: emailError,
  keyboardType: TextInputType.emailAddress,
)
```

### GlassCard

Container avec effet glassmorphism (BackdropFilter + fond semi-transparent).

| Propriété | Type | Description |
|-----------|------|-------------|
| `child` | `Widget` | Contenu de la carte |
| `padding` | `EdgeInsets?` | Padding interne (défaut: 20) |
| `borderRadius` | `double` | Rayon des coins (défaut: 16) |
| `blurSigma` | `double` | Intensité du flou (défaut: 10) |
| `opacity` | `double` | Opacité du fond (défaut: 0.7) |
| `onTap` | `VoidCallback?` | Rend la carte cliquable |

```dart
// Carte simple
GlassCard(
  child: Text('Solde: €12,450.23'),
)

// Carte avec header
GlassCardWithHeader(
  header: Text('Transactions récentes'),
  trailing: TextButton(child: Text('Voir tout')),
  child: TransactionList(),
)
```

### CategoryIcon

Cercle coloré avec icône centrée pour représenter les catégories.

| Propriété | Type | Description |
|-----------|------|-------------|
| `icon` | `IconData` | Icône à afficher |
| `color` | `Color` | Couleur de fond (appliquée avec opacité) |
| `size` | `CategoryIconSize` | `small` (32px), `medium` (44px), `large` (56px), `extraLarge` (72px) |

```dart
CategoryIcon(
  icon: Icons.restaurant,
  color: Colors.orange,
  size: CategoryIconSize.medium,
)

// Picker pour sélection d'icône
CategoryIconPicker(
  icons: availableIcons,
  color: selectedColor,
  selectedIcon: currentIcon,
  onIconSelected: (icon) => setState(() => currentIcon = icon),
)
```

### Thème

Les composants utilisent les couleurs définies dans `AppColors` :

| Couleur | Hex | Usage |
|---------|-----|-------|
| `primary` | `#1B5E5A` | Teal foncé - Boutons principaux, sidebar |
| `process` | `#E87B4D` | Orange/Corail - CTA, actions |
| `backgroundLight` | `#E8E8E8` | Fond de l'application |
| `cardLight` | `#FFFFFF` | Fond des cartes |

## Navigation

L'application utilise une navigation conditionnelle basée sur l'état de l'onboarding :

```
┌─────────────────────────────────────────┐
│              _AppRoot                    │
│  (onboardingCompletedStreamProvider)     │
├─────────────────────────────────────────┤
│                                          │
│   completed = false    completed = true  │
│         ↓                    ↓           │
│   OnboardingFlow         AppShell        │
│         │                    │           │
│   ┌─────┴─────┐        ┌─────┴─────┐     │
│   │ Welcome   │        │ Dashboard │     │
│   │ Setup     │        │ Stats     │     │
│   │ AuthChoice│        │ Wallet    │     │
│   └───────────┘        │ Settings  │     │
│                        └───────────┘     │
└─────────────────────────────────────────┘
```

L'`AppShell` utilise un `IndexedStack` pour préserver l'état des écrans lors de la navigation entre les onglets.

## Features

### Onboarding

Flow d'accueil en 3 étapes pour les nouveaux utilisateurs :

| Étape | Écran | Description |
|-------|-------|-------------|
| 1 | **Welcome** | Écran de bienvenue avec présentation de l'app |
| 2 | **Setup Account** | Configuration du compte principal (devise, solde initial, type de compte) |
| 3 | **Auth Choice** | Choix du mode : Google Auth (sync cloud) ou Local Only |

**Données collectées :**
- `currency` : Devise (EUR, USD, GBP...)
- `initialBalance` : Solde initial du compte
- `accountType` : Type de compte (checking, savings)
- `isAnonymous` : Mode local uniquement (sans sync)

**Persistance :**
- Crée le compte principal dans la table `Accounts`
- Sauvegarde les préférences dans `UserSettings` (`currency`, `is_anonymous`, `primary_account_id`)
- Marque `onboarding_completed` pour ne plus afficher le flow

```dart
// Vérifier si l'onboarding est complété
final isCompleted = await settingsRepo.isOnboardingCompleted();

// Utiliser le flow
OnboardingFlow(
  onComplete: () => context.go('/dashboard'),
)
```

### App Shell

Structure principale de navigation avec `IndexedStack` pour préserver l'état des écrans.

| Composant | Description |
|-----------|-------------|
| **AppShell** | Container principal avec IndexedStack et FAB central |
| **AppNavigationBar** | Barre de navigation bottom avec 4 destinations |

**Onglets de navigation :**

| Index | Icône | Écran | Description |
|-------|-------|-------|-------------|
| 0 | `home` | Dashboard | Aperçu financier |
| 1 | `bar_chart` | Stats | Statistiques et graphiques |
| 2 | `account_balance_wallet` | Wallet | Gestion des comptes |
| 3 | `settings` | Settings | Paramètres de l'application |

**FAB central :** Bouton flottant orange pour ajouter rapidement une transaction.

### Dashboard

Écran principal affichant l'aperçu financier de l'utilisateur.

| Widget | Description |
|--------|-------------|
| **NetWorthCard** | Affiche le solde total avec variation mensuelle |
| **AccountSelector** | Liste horizontale scrollable des comptes |
| **ExpenseBreakdownCard** | Graphique en anneau des dépenses par catégorie |
| **RecentTransactionsCard** | Liste des dernières transactions |

**Salutation dynamique :** Le header affiche "Bonjour", "Bon après-midi" ou "Bonsoir" selon l'heure.

### Transactions

Système complet de gestion des transactions avec formulaire en modal bottom sheet.

| Écran | Description |
|-------|-------------|
| **AddTransactionScreen** | Modal pour créer une nouvelle transaction |
| **EditTransactionScreen** | Modal pour modifier une transaction existante |

**Composants du formulaire :**

| Widget | Description |
|--------|-------------|
| **TransactionTypeTabs** | Onglets Income/Expense |
| **AmountDisplay** | Affichage du montant avec devise |
| **NumericKeypad** | Clavier numérique personnalisé |
| **CategoryGrid** | Grille de sélection des catégories |
| **SmartNoteField** | Champ de note avec suggestions |
| **RecurrenceToggle** | Toggle pour transaction récurrente |

```dart
// Ouvrir le modal d'ajout
final result = await AddTransactionScreen.show(context);
if (result == true) {
  // Transaction créée avec succès
}

// Ouvrir le modal d'édition
final result = await EditTransactionScreen.show(context, transactionId: 'uuid');
```

## Installation

### Prérequis

- Flutter SDK >= 3.10.7
- Dart SDK >= 3.10.7

### Étapes

```bash
# 1. Cloner le repository
git clone <repo-url>
cd simpleflow

# 2. Installer les dépendances
flutter pub get

# 3. Générer le code (Drift + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 4. Lancer l'application
flutter run
```

### Mode watch (développement)

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Base de Données

### Schéma

#### Table `Accounts`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | TEXT (PK) | UUID v4 |
| `name` | TEXT | Nom du compte |
| `type` | INT | 0=Checking, 1=Savings, 2=Cash |
| `balance` | REAL | Solde initial |
| `currency` | TEXT(3) | Code ISO 4217 (EUR, USD...) |
| `color` | INT | Couleur hexadécimale |
| `last_synced_at` | DATETIME | Dernière sync (nullable) |
| `created_at` | DATETIME | Date de création |
| `updated_at` | DATETIME | Date de modification |

#### Table `Categories`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | TEXT (PK) | UUID v4 |
| `name` | TEXT | Nom de la catégorie |
| `icon_key` | TEXT | Référence icône |
| `color` | INT | Couleur hexadécimale |
| `type` | INT | 0=Income, 1=Expense |
| `budget_limit` | REAL | Limite mensuelle (Premium, nullable) |
| `created_at` | DATETIME | Date de création |
| `updated_at` | DATETIME | Date de modification |

#### Table `Transactions`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | TEXT (PK) | UUID v4 |
| `account_id` | TEXT (FK) | Référence compte |
| `category_id` | TEXT (FK) | Référence catégorie |
| `amount` | REAL | Montant (toujours positif) |
| `date` | DATETIME | Date de la transaction |
| `note` | TEXT | Note optionnelle |
| `is_recurring` | BOOL | Transaction récurrente |
| `sync_status` | INT | 0=Pending, 1=Synced |
| `created_at` | DATETIME | Date de création |
| `updated_at` | DATETIME | Date de modification |

#### Table `UserSettings`

Table clé-valeur pour stocker les paramètres utilisateur.

| Colonne | Type | Description |
|---------|------|-------------|
| `key` | TEXT (PK) | Clé unique du paramètre |
| `value` | TEXT | Valeur (stockée en JSON string) |
| `updated_at` | DATETIME | Date de modification |

**Clés prédéfinies :**

| Clé | Type | Description |
|-----|------|-------------|
| `onboarding_completed` | bool | Onboarding terminé |
| `currency` | String | Devise utilisateur (EUR, USD, GBP) |
| `is_anonymous` | bool | Mode local only (sans sync cloud) |
| `primary_account_id` | String | ID du compte principal |

### Index et Optimisations

| Index | Table | Colonnes | Justification |
|-------|-------|----------|---------------|
| `idx_accounts_name` | Accounts | `name` | Recherche rapide par nom |
| `idx_categories_type` | Categories | `type` | Filtrage Income/Expense O(log n) |
| `idx_transactions_account_id` | Transactions | `account_id` | JOIN avec Accounts O(log n) |
| `idx_transactions_category_id` | Transactions | `category_id` | JOIN avec Categories O(log n) |
| `idx_transactions_date` | Transactions | `date` | Filtrage par période |
| `idx_transactions_account_date` | Transactions | `account_id, date` | **Index composite** pour requêtes combinées |
| `idx_transactions_sync_status` | Transactions | `sync_status` | Identification rapide des "Pending" |

## Usage

### Imports simplifiés

```dart
// Import unique pour toute la couche data
import 'package:simpleflow/src/data/data.dart';
```

### Providers Riverpod

```dart
// Dans un widget
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Stream réactif des comptes
  final accountsAsync = ref.watch(accountsStreamProvider);

  // Stream du résumé financier
  final summaryAsync = ref.watch(financialSummaryStreamProvider);

  return accountsAsync.when(
    data: (accounts) => ListView.builder(...),
    loading: () => CircularProgressIndicator(),
    error: (e, st) => Text('Erreur: $e'),
  );
}
```

### Repositories avec Either

```dart
final repository = ref.read(accountRepositoryProvider);

// Création d'un compte
final result = await repository.createAccount(
  name: 'Compte Courant',
  type: AccountType.checking,
  initialBalance: 1000.0,
  currency: 'EUR',
  color: 0xFF4CAF50,
);

result.fold(
  (error) => showSnackBar('Erreur: ${error.message}'),
  (account) => showSnackBar('Compte créé: ${account.name}'),
);
```

### Catégories par défaut

L'application inclut 12 catégories par défaut :

**Dépenses:**
- Alimentation, Transport, Shopping, Loisirs, Santé, Factures, Autres dépenses

**Revenus:**
- Salaire, Freelance, Investissements, Cadeaux, Autres revenus

## Développement

### Régénérer le code

Après modification des tables Drift ou des providers Riverpod :

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Ajouter une migration

1. Incrémenter `schemaVersion` dans `database.dart`
2. Ajouter la migration dans `onUpgrade`:

```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Migration v1 -> v2
        await m.addColumn(transactions, transactions.newColumn);
      }
    },
  );
}
```

## Debug

### Inspecter la base de données SQLite

App Inspection d'Android Studio peut ne pas fonctionner avec Drift. Utilisez `adb` et `sqlite3` pour inspecter la BDD directement.

**Lister les appareils connectés :**
```bash
adb devices
```

**Requête unique :**
```bash
adb -s <device_id> shell run-as com.lurieldev.simpleflow.simpleflow cat databases/simpleflow.db > /tmp/simpleflow.db && sqlite3 /tmp/simpleflow.db ".tables"
```

**Watch en temps réel (rafraîchissement toutes les 2 secondes) :**
```bash
watch -n 2 'adb -s <device_id> shell run-as com.lurieldev.simpleflow.simpleflow cat databases/simpleflow.db > /tmp/simpleflow.db && sqlite3 /tmp/simpleflow.db ".mode column" ".headers on" "SELECT * FROM accounts;" "SELECT * FROM categories;" "SELECT * FROM transactions;"'
```

**Shell SQLite interactif :**
```bash
adb -s <device_id> shell run-as com.lurieldev.simpleflow.simpleflow cat databases/simpleflow.db > /tmp/simpleflow.db && sqlite3 /tmp/simpleflow.db
```

Puis utilisez les commandes SQLite : `.tables`, `.schema`, `SELECT * FROM accounts;`, etc.

## Licence

Propriétaire - Tous droits réservés
