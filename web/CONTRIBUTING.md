# Contribuer a SimpleFlow Web

Merci de votre interet pour SimpleFlow ! Ce guide explique comment contribuer au projet.

## Prerequis

- Node.js >= 18
- npm >= 9
- Un projet Supabase (pour les tests avec le backend)

## Installation

```bash
git clone <repo-url>
cd simpleflow/web
npm install
cp .env.example .env
# Remplir SUPABASE_URL et SUPABASE_ANON_KEY dans .env
```

## Developpement

```bash
# Lancer le serveur de dev
npm run dev

# Verifier les types avant de commit
npm run typecheck
```

## Structure du code

Avant de contribuer, familiarisez-vous avec l'architecture :

- **`stores/`** : Etat reactif pur (Pinia). Pas de logique metier, pas d'appels API.
- **`composables/`** : Logique metier. Appels Supabase, validation, chiffrement. C'est ici que vit le code "intelligent".
- **`components/`** : UI. Organises par domaine (`dashboard/`, `transactions/`, etc.). Les composants dans `common/` sont prefixes automatiquement par Nuxt (ex: `common/AppButton.vue` → `CommonAppButton`).
- **`pages/`** : Routes. Orchestrent les composables et affichent les composants.
- **`utils/`** : Fonctions pures sans etat (crypto, dates, formatage).

Voir [docs/composables.md](docs/composables.md) pour la reference API des composables.

## Conventions

### Code

- **TypeScript strict** : pas de `any` sauf cas justifie
- **UI en francais** : tous les textes utilisateur sont en francais
- **Pas de logique dans les stores** : un store expose state, getters et mutations simples
- **Composables pour la logique** : les appels Supabase, la validation et les transformations vont dans les composables

### Nommage

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
4. **Verifier les types** : `npm run typecheck`
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
- Description du probleme
- Etapes pour reproduire
- Comportement attendu vs observe
- Navigateur et version

## Proposer une fonctionnalite

Ouvrir une issue avec :
- Description de la fonctionnalite
- Cas d'usage
- Proposition d'implementation (optionnel)
