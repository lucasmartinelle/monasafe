# SimpleFlow

Application de gestion de finances personnelles avec **Supabase** comme backend.

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
    │   ├── models/
    │   │   ├── models.dart              # Barrel export
    │   │   ├── account.dart
    │   │   ├── category.dart
    │   │   ├── enums.dart               # AccountType, CategoryType, SyncStatus
    │   │   ├── statistics.dart          # DTOs statistiques
    │   │   ├── transaction.dart
    │   │   ├── transaction_with_details.dart
    │   │   ├── user_budget.dart         # Budget par utilisateur/catégorie
    │   │   └── user_setting.dart
    │   ├── services/
    │   │   ├── services.dart            # Barrel export
    │   │   ├── account_service.dart     # CRUD comptes Supabase
    │   │   ├── auth_service.dart        # Authentification Supabase
    │   │   ├── budget_service.dart      # CRUD budgets utilisateur
    │   │   ├── category_service.dart    # CRUD catégories Supabase
    │   │   ├── seed_service.dart        # Données initiales
    │   │   ├── settings_service.dart    # Paramètres utilisateur
    │   │   ├── statistics_service.dart  # Agrégations et RPC
    │   │   └── transaction_service.dart # CRUD transactions
    │   ├── repositories/
    │   │   ├── account_repository.dart
    │   │   ├── category_repository.dart
    │   │   ├── settings_repository.dart
    │   │   └── transaction_repository.dart
    │   └── providers/
    │       └── database_providers.dart  # Providers Supabase + Services
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
        │   ├── stats.dart                   # Barrel export
        │   └── presentation/
        │       ├── stats_state.dart         # PeriodType enum + BudgetProgress model
        │       ├── stats_providers.dart     # Providers Riverpod
        │       ├── screens/
        │       │   └── stats_screen.dart    # Écran statistiques
        │       └── widgets/
        │           ├── period_selector.dart       # Sélecteur de période
        │           ├── cashflow_chart.dart        # LineChart revenus/dépenses
        │           ├── budget_list.dart           # Liste des budgets
        │           ├── budget_progress_tile.dart  # Tuile budget individuel
        │           └── create_budget_modal.dart   # Modal création budget
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
| **Backend** | `supabase_flutter` | 2.9.0 | BaaS PostgreSQL, Auth, Realtime |
| **UI** | `fl_chart` | 0.70.2 | Graphiques |
| | `intl` | 0.20.2 | Formatage dates/devises |
| | `cupertino_icons` | 1.0.8 | Icônes Cupertino |
| | `filesize` | 2.0.1 | Formatage taille fichiers |
| **Utils** | `uuid` | 4.5.1 | Génération UUID |
| | `fpdart` | 1.1.0 | Programmation fonctionnelle (Either, Option) |
| | `logger` | 2.5.0 | Logging |
| | `flutter_dotenv` | 5.2.1 | Variables d'environnement |

### Dev Dependencies

| Package | Version | Description |
|---------|---------|-------------|
| `build_runner` | 2.4.14 | Génération de code |
| `riverpod_generator` | 2.6.4 | Génère les providers Riverpod |
| `flutter_launcher_icons` | 0.14.3 | Génération des icônes d'app |
| `very_good_analysis` | 6.0.0 | Règles de linting strictes |

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

### Analytics & Budgets

Écran de statistiques avec graphiques et gestion des budgets par utilisateur.

**Composants :**

| Widget | Description |
|--------|-------------|
| **PeriodSelector** | Sélecteur de période (Ce mois, Mois dernier, Année) |
| **CashflowChart** | LineChart avec 2 lignes (revenus vs dépenses) |
| **BudgetList** | Liste des budgets avec progression |
| **BudgetProgressTile** | Tuile individuelle avec barre de progression |
| **CreateBudgetModal** | Modal pour créer un nouveau budget |

**Graphique Cashflow :**
- Ligne verte : revenus mensuels
- Ligne rouge : dépenses mensuelles
- Tooltips interactifs au tap sur un point
- Légende en bas du graphique
- **Rafraîchissement automatique** après création/modification de transaction

**Budgets :**
- Stockés dans la table `user_budgets` (un budget par catégorie par utilisateur)
- Barre de progression colorée dynamiquement :
  - Vert (`AppColors.success`) : < 75% utilisé
  - Orange (`AppColors.warning`) : 75-99% utilisé
  - Rouge (`AppColors.error`) : >= 100% utilisé
- Affichage du montant restant ou du dépassement
- **Rafraîchissement automatique** après création/modification de transaction

```dart
// Ouvrir le modal de création de budget
final result = await CreateBudgetModal.show(context);

// Les budgets sont stockés dans la table user_budgets
// Récupérer les budgets avec catégories
final budgets = await budgetService.getBudgetsWithCategories();

// Créer ou mettre à jour un budget (upsert)
await budgetService.upsertBudget(
  categoryId: 'category-uuid',
  budgetLimit: 500.0,
);
```

## Installation

### Prérequis

- Flutter SDK >= 3.10.7
- Dart SDK >= 3.10.7
- Compte Supabase (projet configuré)

### Configuration Supabase

1. Créer un projet sur [supabase.com](https://supabase.com)
2. Copier `.env.example` vers `.env` et remplir les variables :

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

3. Exécuter les migrations SQL dans le SQL Editor de Supabase (voir section Base de Données)

### Étapes

```bash
# 1. Cloner le repository
git clone <repo-url>
cd simpleflow

# 2. Installer les dépendances
flutter pub get

# 3. Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos credentials Supabase

# 4. Générer le code (Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 5. Lancer l'application
flutter run
```

### Mode watch (développement)

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Base de Données (Supabase PostgreSQL)

### Schéma

#### Table `accounts`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Généré automatiquement |
| `user_id` | UUID (FK) | Référence auth.users |
| `name` | TEXT | Nom du compte |
| `type` | TEXT | `checking`, `savings`, `cash` |
| `balance` | DECIMAL(12,2) | Solde initial |
| `currency` | TEXT(3) | Code ISO 4217 (EUR, USD...) |
| `color` | INT | Couleur ARGB |
| `last_synced_at` | TIMESTAMPTZ | Dernière sync (nullable) |
| `created_at` | TIMESTAMPTZ | Date de création |
| `updated_at` | TIMESTAMPTZ | Date de modification |

#### Table `categories`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Généré automatiquement |
| `user_id` | UUID (FK) | NULL = catégorie par défaut |
| `name` | TEXT | Nom de la catégorie |
| `icon_key` | TEXT | Référence icône |
| `color` | INT | Couleur ARGB |
| `type` | TEXT | `income`, `expense` |
| `is_default` | BOOL | Catégorie par défaut (non supprimable) |
| `created_at` | TIMESTAMPTZ | Date de création |
| `updated_at` | TIMESTAMPTZ | Date de modification |

#### Table `transactions`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Généré automatiquement |
| `user_id` | UUID (FK) | Référence auth.users |
| `account_id` | UUID (FK) | Référence accounts |
| `category_id` | UUID (FK) | Référence categories |
| `amount` | DECIMAL(12,2) | Montant (toujours positif) |
| `date` | TIMESTAMPTZ | Date de la transaction |
| `note` | TEXT | Note optionnelle |
| `is_recurring` | BOOL | Transaction récurrente |
| `sync_status` | TEXT | `pending`, `synced` |
| `created_at` | TIMESTAMPTZ | Date de création |
| `updated_at` | TIMESTAMPTZ | Date de modification |

#### Table `user_budgets`

Table pour les budgets par utilisateur et catégorie.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID (PK) | Généré automatiquement |
| `user_id` | UUID (FK) | Référence auth.users |
| `category_id` | UUID (FK) | Référence categories |
| `budget_limit` | DECIMAL(12,2) | Limite mensuelle |
| `created_at` | TIMESTAMPTZ | Date de création |
| `updated_at` | TIMESTAMPTZ | Date de modification |

**Contrainte :** `UNIQUE(user_id, category_id)` - un seul budget par catégorie par utilisateur.

#### Table `user_settings`

Table clé-valeur pour stocker les paramètres utilisateur.

| Colonne | Type | Description |
|---------|------|-------------|
| `user_id` | UUID (PK) | Référence auth.users |
| `key` | TEXT (PK) | Clé unique du paramètre |
| `value` | TEXT | Valeur (stockée en string) |
| `updated_at` | TIMESTAMPTZ | Date de modification |

**Clés prédéfinies :**

| Clé | Type | Description |
|-----|------|-------------|
| `onboarding_completed` | bool | Onboarding terminé |
| `currency` | String | Devise utilisateur (EUR, USD, GBP) |
| `is_anonymous` | bool | Mode local only (sans sync cloud) |
| `primary_account_id` | String | ID du compte principal |

### Row Level Security (RLS)

Toutes les tables ont RLS activé. Chaque utilisateur ne peut voir/modifier que ses propres données :

```sql
-- Exemple pour user_budgets
CREATE POLICY "Users can view own budgets" ON user_budgets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own budgets" ON user_budgets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets" ON user_budgets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets" ON user_budgets
  FOR DELETE USING (auth.uid() = user_id);
```

### Index

| Index | Table | Colonnes | Justification |
|-------|-------|----------|---------------|
| `idx_accounts_user_id` | accounts | `user_id` | Filtrage par utilisateur |
| `idx_categories_user_id` | categories | `user_id` | Filtrage par utilisateur |
| `idx_transactions_user_id` | transactions | `user_id` | Filtrage par utilisateur |
| `idx_transactions_account_id` | transactions | `account_id` | JOIN avec accounts |
| `idx_transactions_category_id` | transactions | `category_id` | JOIN avec categories |
| `idx_transactions_date` | transactions | `date` | Filtrage par période |
| `idx_user_budgets_user_id` | user_budgets | `user_id` | Filtrage par utilisateur |
| `idx_user_budgets_category_id` | user_budgets | `category_id` | JOIN avec categories |

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

Après modification des providers Riverpod :

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Ajouter une migration Supabase

Les migrations se font directement dans le SQL Editor de Supabase :

1. Aller dans le SQL Editor du dashboard Supabase
2. Écrire et exécuter les requêtes SQL
3. Mettre à jour les modèles Dart correspondants dans `lib/src/data/models/`

**Exemple - Ajouter la table user_budgets :**

```sql
CREATE TABLE user_budgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  budget_limit DECIMAL(12, 2) NOT NULL CHECK (budget_limit > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, category_id)
);

-- Index
CREATE INDEX idx_user_budgets_user_id ON user_budgets(user_id);
CREATE INDEX idx_user_budgets_category_id ON user_budgets(category_id);

-- RLS
ALTER TABLE user_budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own budgets" ON user_budgets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own budgets" ON user_budgets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets" ON user_budgets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets" ON user_budgets
  FOR DELETE USING (auth.uid() = user_id);
```

## Debug

### Inspecter la base de données Supabase

Utilisez le **Table Editor** ou le **SQL Editor** dans le dashboard Supabase pour inspecter les données.

**Via SQL Editor :**
```sql
-- Voir tous les budgets d'un utilisateur
SELECT ub.*, c.name as category_name
FROM user_budgets ub
JOIN categories c ON c.id = ub.category_id
WHERE ub.user_id = 'your-user-uuid';

-- Voir les dépenses par catégorie
SELECT c.name, SUM(t.amount) as total
FROM transactions t
JOIN categories c ON c.id = t.category_id
WHERE t.user_id = 'your-user-uuid'
  AND c.type = 'expense'
GROUP BY c.name;
```

**Via Supabase CLI (optionnel) :**
```bash
# Installer Supabase CLI
npm install -g supabase

# Se connecter
supabase login

# Lister les tables
supabase db dump --schema public
```

## Licence

Propriétaire - Tous droits réservés
