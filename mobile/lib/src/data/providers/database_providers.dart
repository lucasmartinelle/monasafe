import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:monasafe/src/core/middleware/vault_middleware.dart';
import 'package:monasafe/src/core/services/recurrence_date_service.dart';
import 'package:monasafe/src/core/services/recurrence_generator_service.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/repositories/account_repository.dart';
import 'package:monasafe/src/data/repositories/category_repository.dart';
import 'package:monasafe/src/data/repositories/settings_repository.dart';
import 'package:monasafe/src/data/repositories/transaction_repository.dart';
import 'package:monasafe/src/data/services/recurring_transaction_service.dart';
import 'package:monasafe/src/data/services/services.dart';
import 'package:monasafe/src/features/vault/presentation/vault_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'database_providers.g.dart';

// ==================== SUPABASE CLIENT ====================

/// Provider pour le client Supabase
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

// ==================== SERVICES ====================

/// Provider pour le service d'authentification
@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService(ref.watch(supabaseClientProvider));
}

/// Provider pour le service des comptes
@Riverpod(keepAlive: true)
AccountService accountService(Ref ref) {
  return AccountService(ref.watch(supabaseClientProvider));
}

/// Provider pour le service des catégories
@Riverpod(keepAlive: true)
CategoryService categoryService(Ref ref) {
  return CategoryService(ref.watch(supabaseClientProvider));
}

/// Provider pour le service des transactions
/// Injecte automatiquement le VaultMiddleware si le vault est déverrouillé
@Riverpod(keepAlive: true)
TransactionService transactionService(Ref ref) {
  final dek = ref.watch(currentDekProvider);
  final vaultMiddleware = dek != null
      ? VaultMiddleware(ref.watch(encryptionServiceProvider), dek)
      : null;

  return TransactionService(
    ref.watch(supabaseClientProvider),
    vaultMiddleware: vaultMiddleware,
  );
}

/// Provider pour le service des statistiques
@Riverpod(keepAlive: true)
StatisticsService statisticsService(Ref ref) {
  return StatisticsService(ref.watch(supabaseClientProvider));
}

/// Provider pour le service des paramètres
@Riverpod(keepAlive: true)
SettingsService settingsService(Ref ref) {
  return SettingsService(ref.watch(supabaseClientProvider));
}

/// Provider pour le service des budgets
@Riverpod(keepAlive: true)
BudgetService budgetService(Ref ref) {
  return BudgetService(ref.watch(supabaseClientProvider));
}

/// Provider pour le service des données d'onboarding en attente (OAuth)
@Riverpod(keepAlive: true)
PendingOnboardingService pendingOnboardingService(Ref ref) {
  return PendingOnboardingService();
}

/// Provider pour le service de calcul des dates de recurrence
@Riverpod(keepAlive: true)
RecurrenceDateService recurrenceDateService(Ref ref) {
  return RecurrenceDateService();
}

/// Provider pour le service des transactions recurrentes
/// Injecte automatiquement le VaultMiddleware si le vault est deverrouille
@Riverpod(keepAlive: true)
RecurringTransactionService recurringTransactionService(Ref ref) {
  final dek = ref.watch(currentDekProvider);
  final vaultMiddleware = dek != null
      ? VaultMiddleware(ref.watch(encryptionServiceProvider), dek)
      : null;

  return RecurringTransactionService(
    ref.watch(supabaseClientProvider),
    vaultMiddleware: vaultMiddleware,
  );
}

/// Provider pour le service de generation des transactions recurrentes
@Riverpod(keepAlive: true)
RecurrenceGeneratorService recurrenceGeneratorService(Ref ref) {
  return RecurrenceGeneratorService(
    ref.watch(recurringTransactionServiceProvider),
    ref.watch(transactionServiceProvider),
    ref.watch(recurrenceDateServiceProvider),
  );
}

/// Provider pour le service de gestion des données (suppression)
@Riverpod(keepAlive: true)
DataManagementService dataManagementService(Ref ref) {
  return DataManagementService(
    transactionService: ref.watch(transactionServiceProvider),
    recurringTransactionService: ref.watch(recurringTransactionServiceProvider),
    budgetService: ref.watch(budgetServiceProvider),
    accountService: ref.watch(accountServiceProvider),
    categoryService: ref.watch(categoryServiceProvider),
  );
}

// ==================== REPOSITORIES ====================

/// Provider pour le repository des comptes
@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return AccountRepository(
    ref.watch(accountServiceProvider),
    ref.watch(transactionServiceProvider),
    ref.watch(statisticsServiceProvider),
  );
}

/// Provider pour le repository des catégories
@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepository(ref.watch(categoryServiceProvider));
}

/// Provider pour le repository des transactions
@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository(
    ref.watch(transactionServiceProvider),
    ref.watch(accountServiceProvider),
    ref.watch(categoryServiceProvider)
  );
}

/// Provider pour le repository des paramètres
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(settingsServiceProvider));
}

// ==================== AUTHENTICATION ====================

/// Stream de l'état d'authentification
@riverpod
Stream<AuthState> authStateStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

/// Provider pour vérifier si l'utilisateur est authentifié.
/// Écoute le stream d'auth pour être réactif aux changements.
@riverpod
Stream<bool> isAuthenticated(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map(
    (state) => state.session?.user != null,
  );
}

/// Stream de l'état de l'onboarding.
/// Retourne false si non authentifié, sinon écoute le setting onboarding_completed.
@riverpod
Stream<bool> onboardingCompletedStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);

  // Écouter le stream d'auth pour réagir aux déconnexions
  return authService.authStateChanges.asyncExpand((authState) {
    // Si pas authentifié, retourner false
    if (authState.session?.user == null) {
      return Stream.value(false);
    }

    // Sinon, écouter le setting onboarding_completed
    final repository = ref.read(settingsRepositoryProvider);
    return repository.watchOnboardingCompleted();
  });
}

// ==================== REFRESH TRIGGER ====================

/// Trigger de rafraîchissement pour les données liées aux transactions.
/// Incrémenté après chaque création/modification/suppression de transaction.
/// Les providers qui watchent ce trigger se recalculent automatiquement.
@Riverpod(keepAlive: true)
class TransactionsRefreshTrigger extends _$TransactionsRefreshTrigger {
  @override
  int build() => 0;

  void refresh() => state++;
}

// ==================== STREAMS PROVIDERS ====================

/// Stream de tous les comptes
@riverpod
Stream<List<Account>> accountsStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value([]);
  }

  // Watch le trigger pour se rafraîchir après chaque transaction
  ref.watch(transactionsRefreshTriggerProvider);

  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchAllAccounts();
}

/// Stream de toutes les catégories
@riverpod
Stream<List<Category>> categoriesStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value([]);
  }

  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchAllCategories();
}

/// Stream des catégories de dépenses
@riverpod
Stream<List<Category>> expenseCategoriesStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value([]);
  }

  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchExpenseCategories();
}

/// Stream des catégories de revenus
@riverpod
Stream<List<Category>> incomeCategoriesStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value([]);
  }

  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchIncomeCategories();
}

/// Stream des transactions récentes (10 dernières)
@riverpod
Stream<List<TransactionWithDetails>> recentTransactionsStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value([]);
  }

  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchRecentTransactions(10);
}

/// Stream du résumé financier
/// Utilise les calculs côté client pour supporter les colonnes TEXT.
@riverpod
Stream<FinancialSummary> financialSummaryStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value(const FinancialSummary.empty());
  }

  // Watch le trigger pour se rafraîchir après chaque transaction
  ref.watch(transactionsRefreshTriggerProvider);

  // Toujours utiliser les calculs côté client (amount est TEXT en BDD)
  final transactionService = ref.watch(transactionServiceProvider);
  final accountService = ref.watch(accountServiceProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);

  return transactionService.watchAllTransactionsWithDetails().asyncMap(
    (transactions) async {
      final accounts = await accountService.getAllAccounts();
      return statisticsService.calculateFinancialSummaryFromTransactions(
        transactions,
        accounts,
      );
    },
  );
}

/// Stream du solde calculé d'un compte (solde initial + transactions)
/// Utilise le filtrage côté serveur pour de meilleures performances.
@riverpod
Stream<double> accountCalculatedBalanceStream(Ref ref, String accountId) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value(0);
  }

  // Watch le trigger pour se rafraîchir après chaque transaction
  ref.watch(transactionsRefreshTriggerProvider);

  final transactionService = ref.watch(transactionServiceProvider);
  final accountService = ref.watch(accountServiceProvider);

  // Utilise watchTransactionsByAccount pour filtrer côté serveur
  return transactionService.watchTransactionsByAccount(accountId).asyncMap(
    (transactions) async {
      final account = await accountService.getAccountById(accountId);
      if (account == null) return 0.0;

      double income = 0;
      double expense = 0;

      for (final tx in transactions) {
        final amount = tx.transaction.amount;
        if (tx.category.type == CategoryType.income) {
          income += amount;
        } else {
          expense += amount;
        }
      }

      return account.balance + income - expense;
    },
  );
}

/// Provider pour vérifier si l'utilisateur a un compte Google lié.
/// Fait un appel API pour récupérer les identities à jour.
@riverpod
Future<bool> hasGoogleIdentity(Ref ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return false;
  }
  return authService.fetchHasGoogleProvider();
}

// ==================== RECURRING TRANSACTIONS ====================

/// Stream des transactions recurrentes actives
@riverpod
Stream<List<RecurringTransaction>> activeRecurringStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value([]);
  }

  final service = ref.watch(recurringTransactionServiceProvider);
  return service.watchActiveRecurring();
}

/// Provider pour la generation des transactions recurrentes au demarrage.
/// Retourne le nombre de transactions generees.
@riverpod
Future<int> generateRecurringTransactions(Ref ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return 0;
  }

  final generator = ref.watch(recurrenceGeneratorServiceProvider);
  final count = await generator.generatePendingTransactions();

  if (count > 0) {
    // Rafraichir les transactions
    ref.read(transactionsRefreshTriggerProvider.notifier).refresh();
  }

  return count;
}
