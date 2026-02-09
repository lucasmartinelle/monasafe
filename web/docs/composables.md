# API des Composables

Reference de tous les composables de SimpleFlow Web.

Convention : les composables portent la logique metier et les appels Supabase. Les stores ne contiennent que l'etat reactif pur.

---

## useAuth

Authentification (anonyme, Google OAuth).

| Propriete | Type | Description |
|-----------|------|-------------|
| `user` | `Ref<User \| null>` | Utilisateur Supabase courant |
| `isAuthenticated` | `ComputedRef<boolean>` | Authentifie ou non |
| `isAnonymous` | `ComputedRef<boolean>` | Compte anonyme |
| `isLoading` | `ComputedRef<boolean>` | Chargement en cours |
| `error` | `ComputedRef<string \| null>` | Erreur courante |
| `userId` | `ComputedRef<string \| null>` | ID utilisateur |
| `userEmail` | `ComputedRef<string \| null>` | Email |
| `hasGoogleProvider` | `ComputedRef<boolean>` | Compte lie a Google |

| Methode | Description |
|---------|-------------|
| `signInAnonymous()` | Connexion anonyme + redirect /onboarding |
| `signInGoogle()` | Connexion Google OAuth |
| `linkGoogle()` | Lier un compte anonyme a Google |
| `signOut()` | Deconnexion + redirect /auth |
| `clearError()` | Effacer l'erreur |

---

## useAccounts

CRUD comptes bancaires, soldes calcules, temps reel.

| Propriete | Type | Description |
|-----------|------|-------------|
| `accounts` | `ComputedRef<Account[]>` | Liste des comptes |
| `sortedAccounts` | `ComputedRef<Account[]>` | Comptes tries par nom |
| `totalBalance` | `ComputedRef<number>` | Solde initial total |
| `computedBalances` | `Ref<Record<string, number>>` | Soldes calcules (initial + transactions) |
| `totalComputedBalance` | `ComputedRef<number>` | Somme des soldes calcules |
| `selectedAccountId` | `ComputedRef<string \| null>` | Compte selectionne |
| `isLoading` | `ComputedRef<boolean>` | Chargement |
| `error` | `ComputedRef<string \| null>` | Erreur |
| `accountById` | `ComputedRef<(id: string) => Account \| undefined>` | Lookup par ID |

| Methode | Description |
|---------|-------------|
| `fetchAccounts()` | Charger tous les comptes |
| `createAccount(data)` | Creer un compte |
| `updateAccount(id, data)` | Mettre a jour un compte |
| `deleteAccount(id)` | Supprimer (echoue si transactions liees) |
| `refreshComputedBalances()` | Recalculer les soldes depuis les transactions |
| `subscribeRealtime()` | Ecouter les changements temps reel |
| `unsubscribeRealtime()` | Arreter l'ecoute |
| `setSelectedAccountId(id)` | Definir le compte selectionne |
| `setError(msg)` | Definir l'erreur |

---

## useTransactions

CRUD transactions, pagination, chiffrement vault.

| Propriete | Type | Description |
|-----------|------|-------------|
| `transactions` | `ComputedRef<Transaction[]>` | Transactions chargees |
| `recentTransactions` | `ComputedRef<Transaction[]>` | 5 dernieres |
| `isLoading` | `ComputedRef<boolean>` | Chargement |
| `error` | `ComputedRef<string \| null>` | Erreur |
| `hasMore` | `ComputedRef<boolean>` | Pages restantes |
| `transactionById` | `ComputedRef<(id: string) => Transaction \| undefined>` | Lookup |
| `transactionsByAccount` | `ComputedRef<(id: string) => Transaction[]>` | Par compte |
| `transactionsByPeriod` | `ComputedRef<(start: string, end: string) => Transaction[]>` | Par periode |

| Methode | Description |
|---------|-------------|
| `fetchTransactions(opts?)` | Charger les transactions (avec pagination, filtres) |
| `fetchAllTransactions()` | Charger toutes les transactions (sans pagination) |
| `fetchNextPage(opts?)` | Page suivante |
| `createTransaction(data)` | Creer (chiffre si vault actif) |
| `updateTransaction(id, data)` | Mettre a jour (chiffre si vault actif) |
| `deleteTransaction(id)` | Supprimer |
| `subscribeRealtime()` | Ecouter les changements |
| `unsubscribeRealtime()` | Arreter l'ecoute |
| `resetStore()` | Reinitialiser le store |
| `setError(msg)` | Definir l'erreur |

---

## useRecurring

CRUD recurrences, generation automatique de transactions.

| Propriete | Type | Description |
|-----------|------|-------------|
| `recurrings` | `ComputedRef<RecurringWithDetails[]>` | Recurrences avec details |
| `activeRecurrings` | `ComputedRef<RecurringWithDetails[]>` | Recurrences actives |
| `inactiveRecurrings` | `ComputedRef<RecurringWithDetails[]>` | Recurrences inactives |
| `isLoading` | `ComputedRef<boolean>` | Chargement |
| `error` | `ComputedRef<string \| null>` | Erreur |
| `recurringById` | `ComputedRef<(id: string) => RecurringWithDetails \| undefined>` | Lookup |

| Methode | Description |
|---------|-------------|
| `fetchRecurrings()` | Charger les recurrences |
| `createRecurring(data)` | Creer une recurrence |
| `updateRecurring(id, data)` | Mettre a jour |
| `toggleActive(id, active)` | Activer/desactiver |
| `deleteRecurring(id)` | Supprimer (detache les transactions) |
| `calculateNextDate(recurring)` | Prochaine date de generation |
| `generatePendingTransactions()` | Generer les transactions en attente |
| `subscribeRealtime()` | Ecouter les changements |
| `unsubscribeRealtime()` | Arreter l'ecoute |
| `setError(msg)` | Definir l'erreur |

---

## useCategories

CRUD categories (depenses/revenus).

| Propriete | Type | Description |
|-----------|------|-------------|
| `categories` | `ComputedRef<Category[]>` | Toutes les categories |
| `expenseCategories` | `ComputedRef<Category[]>` | Categories depenses |
| `incomeCategories` | `ComputedRef<Category[]>` | Categories revenus |
| `isLoading` | `ComputedRef<boolean>` | Chargement |
| `error` | `ComputedRef<string \| null>` | Erreur |
| `categoryById` | `ComputedRef<(id: string) => Category \| undefined>` | Lookup |

| Methode | Description |
|---------|-------------|
| `fetchCategories()` | Charger les categories |
| `createCategory(data)` | Creer (personnalisee) |
| `updateCategory(id, data)` | Mettre a jour |
| `deleteCategory(id)` | Supprimer (echoue si transactions liees ou par defaut) |
| `subscribeRealtime()` | Ecouter les changements |
| `unsubscribeRealtime()` | Arreter l'ecoute |
| `setError(msg)` | Definir l'erreur |

---

## useBudgets

CRUD budgets par categorie.

| Propriete | Type | Description |
|-----------|------|-------------|
| `budgets` | `ComputedRef<UserBudget[]>` | Liste des budgets |
| `isLoading` | `ComputedRef<boolean>` | Chargement |
| `error` | `ComputedRef<string \| null>` | Erreur |
| `budgetByCategory` | `ComputedRef<(catId: string) => UserBudget \| undefined>` | Lookup |

| Methode | Description |
|---------|-------------|
| `fetchBudgets()` | Charger les budgets |
| `upsertBudget(categoryId, limit)` | Creer ou mettre a jour |
| `deleteBudget(id)` | Supprimer |
| `subscribeRealtime()` | Ecouter les changements |
| `unsubscribeRealtime()` | Arreter l'ecoute |
| `setError(msg)` | Definir l'erreur |

---

## useStatistics

Calculs financiers en lecture seule depuis les stores.

| Methode | Params | Retour | Description |
|---------|--------|--------|-------------|
| `calculateFinancialSummary()` | `startDate?, endDate?` | `FinancialSummary` | Resume global (solde, revenus/depenses totaux et mensuels) |
| `calculateCategoryStats()` | `startDate, endDate, type?, accountId?` | `CategoryStatistics[]` | Repartition par categorie |
| `calculateMonthlyStats()` | `year` | `MonthlyStatistics[]` | Revenus/depenses par mois |
| `calculateDailyStats()` | `startDate, endDate` | `DailyStatistics[]` | Revenus/depenses par jour |
| `calculateBudgetProgress()` | `startDate, endDate, periodType?` | `BudgetProgress[]` | Progression des budgets |
| `calculatePeriodTotals()` | `startDate, endDate` | `{ income, expense }` | Totaux pour une periode |

Les maps de categories sont memoizees via `computed` (recalculees uniquement quand les categories changent).

---

## useVault

Chiffrement E2E (AES-256-GCM, PBKDF2).

| Propriete | Type | Description |
|-----------|------|-------------|
| `isEnabled` | `ComputedRef<boolean>` | Vault active |
| `isLocked` | `ComputedRef<boolean>` | Vault verrouille |
| `isUnlocked` | `ComputedRef<boolean>` | Vault deverrouille (enabled && !locked) |
| `isLoading` | `ComputedRef<boolean>` | Operation en cours |
| `error` | `ComputedRef<string \| null>` | Erreur |

| Methode | Description |
|---------|-------------|
| `init()` | Charger l'etat vault depuis user_settings |
| `activate(password)` | Activer : genere salt+DEK, chiffre toutes les transactions |
| `unlock(password)` | Deverrouiller : derive KEK, dechiffre DEK en memoire |
| `lock()` | Verrouiller : efface DEK de la memoire |
| `clearError()` | Effacer l'erreur |
| `changeMasterPassword(current, new)` | Changer le mot de passe maitre |
| `deactivate(password)` | Desactiver : dechiffre tout, supprime les cles |
| `encryptTransactionData(amount, note)` | Chiffre montant + note |
| `decryptTransactionData(rawAmount, rawNote)` | Dechiffre montant + note |

---

## useSettings

Parametres utilisateur (user_settings Supabase).

| Propriete | Type | Description |
|-----------|------|-------------|
| `currency` | `ComputedRef<string>` | Devise (ex: "EUR") |
| `onboardingCompleted` | `ComputedRef<boolean>` | Onboarding fait |
| `isLoading` | `ComputedRef<boolean>` | Chargement |
| `formattedCurrency` | `ComputedRef<string>` | Devise formatee |

| Methode | Description |
|---------|-------------|
| `loadSettings()` | Charger les settings depuis Supabase |
| `updateSetting(key, value)` | Upsert un setting |
| `getSetting(key)` | Recuperer un setting par cle |
| `deleteSetting(key)` | Supprimer un setting |
| `completeOnboarding()` | Marquer l'onboarding termine |

---

## useCurrency

Formatage des montants.

| Propriete | Type | Description |
|-----------|------|-------------|
| `currency` | `ComputedRef<string>` | Code devise |

| Methode | Description |
|---------|-------------|
| `format(amount)` | Formater un nombre en devise (ex: `1 234,56 EUR`) |

---

## useDataManagement

Suppression de donnees.

| Propriete | Type | Description |
|-----------|------|-------------|
| `isLoading` | `Ref<boolean>` | Operation en cours |
| `error` | `Ref<string \| null>` | Erreur |

| Methode | Description |
|---------|-------------|
| `deleteTransactions()` | Supprimer toutes les transactions |
| `deleteRecurrings()` | Supprimer toutes les recurrences |
| `deleteBudgets()` | Supprimer tous les budgets |
| `deleteAllData()` | Supprimer toutes les donnees + reset stores |
