import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/repositories/account_repository.dart';
import 'package:simpleflow/src/data/repositories/category_repository.dart';
import 'package:simpleflow/src/data/repositories/settings_repository.dart';
import 'package:simpleflow/src/data/repositories/transaction_repository.dart';
import 'package:simpleflow/src/data/services/services.dart';

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
@Riverpod(keepAlive: true)
TransactionService transactionService(Ref ref) {
  return TransactionService(ref.watch(supabaseClientProvider));
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
    ref.watch(categoryServiceProvider),
    ref.watch(statisticsServiceProvider),
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

/// Provider pour vérifier si l'utilisateur est authentifié
@riverpod
bool isAuthenticated(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated;
}

/// Stream de l'état de l'onboarding
@riverpod
Stream<bool> onboardingCompletedStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);

  // Si pas authentifié, retourner false
  if (!authService.isAuthenticated) {
    return Stream.value(false);
  }

  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchOnboardingCompleted();
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
@riverpod
Stream<FinancialSummary> financialSummaryStream(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value(const FinancialSummary.empty());
  }

  // Watch le trigger pour se rafraîchir après chaque transaction
  ref.watch(transactionsRefreshTriggerProvider);

  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchFinancialSummary();
}

/// Stream du solde calculé d'un compte (solde initial + transactions)
@riverpod
Stream<double> accountCalculatedBalanceStream(Ref ref, String accountId) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) {
    return Stream.value(0);
  }

  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchCalculatedBalance(accountId);
}
