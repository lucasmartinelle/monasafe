# Contribuer a Monasafe

Merci de votre interet pour Monasafe ! Ce guide explique comment contribuer au projet (mobile et web).

## Prerequis

### Mobile (Flutter)

- Flutter SDK >= 3.10.7
- Dart SDK >= 3.10.7
- Un projet Supabase (pour les tests avec le backend)

### Web (Nuxt)

- Node.js >= 18
- npm >= 9
- Un projet Supabase (pour les tests avec le backend)

## Installation

```bash
git clone <repo-url>
cd monasafe
```

### Mobile

```bash
cd mobile
flutter pub get
cp .env.example .env
# Remplir les variables Supabase dans .env
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Web

```bash
cd web
npm install
cp .env.example .env
# Remplir SUPABASE_URL et SUPABASE_ANON_KEY dans .env
```

## Developpement

### Mobile

```bash
cd mobile

# Lancer l'application
flutter run

# Regenerer le code (apres modification des providers Riverpod)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Mode watch (regeneration automatique)
flutter packages pub run build_runner watch --delete-conflicting-outputs

# Verifier les erreurs de compilation
flutter analyze
```

### Web

```bash
cd web

# Lancer le serveur de dev
npm run dev

# Verifier les types avant de commit
npm run typecheck

# Build production
npm run build
```

## Structure du code

Avant de contribuer, familiarisez-vous avec l'architecture de la plateforme concernee.

### Mobile (Flutter + Riverpod)

- **`lib/src/data/models/`** : Modeles de donnees (Account, Transaction, Category, etc.)
- **`lib/src/data/services/`** : Appels Supabase (CRUD, RPC)
- **`lib/src/data/repositories/`** : Couche d'abstraction avec gestion d'erreurs (Either)
- **`lib/src/data/providers/`** : Providers Supabase et services
- **`lib/src/features/`** : Ecrans et widgets, organises par domaine (`dashboard/`, `transactions/`, `recurring/`, etc.)
- **`lib/src/common_widgets/`** : Composants UI reutilisables (AppButton, GlassCard, CategoryIcon, etc.)
- **`lib/src/core/`** : Theme, config, services utilitaires, constantes

Voir [`mobile/README.md`](mobile/README.md) pour la reference complete.

### Web (Nuxt + Pinia)

- **`stores/`** : Etat reactif pur (Pinia). Pas de logique metier, pas d'appels API.
- **`composables/`** : Logique metier. Appels Supabase, validation, chiffrement. C'est ici que vit le code "intelligent".
- **`components/`** : UI. Organises par domaine (`dashboard/`, `transactions/`, etc.). Les composants dans `common/` sont prefixes automatiquement par Nuxt (ex: `common/AppButton.vue` -> `CommonAppButton`).
- **`pages/`** : Routes. Orchestrent les composables et affichent les composants.
- **`utils/`** : Fonctions pures sans etat (crypto, dates, formatage).

Voir [`web/README.md`](web/README.md) pour la reference complete.

## Conventions

### Code

- **UI en francais** : tous les textes utilisateur sont en francais
- **Pas de sur-ingenierie** : la solution la plus simple est souvent la meilleure
- **Securite** : ne jamais stocker de secrets dans le code, valider les entrees utilisateur

#### Mobile

- `@riverpod` pour les providers auto-dispose, `@Riverpod(keepAlive: true)` pour les providers persistants
- Les fichiers generes (`.g.dart`) ne doivent pas etre commites manuellement
- `CurrencyFormatter.format(amount)` pour l'affichage des montants

#### Web

- **TypeScript strict** : pas de `any` sauf cas justifie
- **Pas de logique dans les stores** : un store expose state, getters et mutations simples
- **Composables pour la logique** : les appels Supabase, la validation et les transformations vont dans les composables

### Nommage

#### Mobile

| Element | Convention | Exemple |
|---------|-----------|---------|
| Features | snake_case (dossier) | `transactions/`, `recurring/` |
| Widgets | PascalCase | `TransactionTile` |
| Providers | camelCase avec annotation | `@riverpod accountsStream(...)` |
| Models | PascalCase | `TransactionWithDetails` |

#### Web

| Element | Convention | Exemple |
|---------|-----------|---------|
| Composables | `use` + PascalCase | `useTransactions` |
| Stores | camelCase | `useAccountsStore` |
| Composants | PascalCase | `TransactionTile.vue` |
| Pages | kebab-case | `settings/categories.vue` |
| Utils | camelCase | `formatMonthYear` |

### Commits

Format recommande :

```
type: description courte

Corps optionnel avec plus de details.
```

Types : `feat`, `fix`, `refactor`, `docs`, `style`, `perf`, `chore`

Exemples :
```
feat: ajout du toggle dark mode dans les parametres
fix: correction validation mot de passe vault
docs: mise a jour README avec instructions d'installation
```

## Soumettre une contribution

1. **Fork** le projet
2. **Creer une branche** depuis `main` : `git checkout -b feat/ma-fonctionnalite`
3. **Developper** en suivant les conventions ci-dessus
4. **Verifier** :
   - Mobile : `flutter analyze`
   - Web : `npm run typecheck`
5. **Tester manuellement** les fonctionnalites impactees
6. **Commit** avec un message clair
7. **Push** et ouvrir une **Pull Request** vers `main`

## Bonnes pratiques

- **Lire avant de modifier** : comprendre le code existant avant de le changer
- **Minimal** : ne modifier que ce qui est necessaire, eviter le refactoring non demande
- **Pas de sur-ingenierie** : la solution la plus simple est souvent la meilleure
- **Securite** : ne jamais stocker de secrets dans le code, valider les entrees utilisateur

## Signaler un bug

Ouvrir une issue avec :
- Plateforme concernee (mobile / web / les deux)
- Description du probleme
- Etapes pour reproduire
- Comportement attendu vs observe
- Appareil / navigateur et version

## Proposer une fonctionnalite

Ouvrir une issue avec :
- Description de la fonctionnalite
- Cas d'usage
- Plateforme(s) concernee(s)
- Proposition d'implementation (optionnel)
