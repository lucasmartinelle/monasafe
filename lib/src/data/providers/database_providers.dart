import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:simpleflow/src/data/local/daos/statistics_dao.dart';
import 'package:simpleflow/src/data/local/daos/transaction_dao.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/repositories/account_repository.dart';
import 'package:simpleflow/src/data/repositories/category_repository.dart';
import 'package:simpleflow/src/data/repositories/settings_repository.dart';
import 'package:simpleflow/src/data/repositories/transaction_repository.dart';

part 'database_providers.g.dart';

/// Provider singleton pour la base de données
///
/// Utilise keepAlive pour maintenir l'instance en vie durant toute
/// la durée de l'application
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();

  // Ferme la base de données quand le provider est disposé
  ref.onDispose(db.close);

  return db;
}

/// Provider pour le repository des comptes
@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AccountRepository(db);
}

/// Provider pour le repository des catégories
@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryRepository(db);
}

/// Provider pour le repository des transactions
@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepository(db);
}

/// Provider pour le repository des paramètres
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsRepository(db);
}

/// Stream de l'état de l'onboarding
@riverpod
Stream<bool> onboardingCompletedStream(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchOnboardingCompleted();
}

// ==================== STREAMS PROVIDERS ====================

/// Stream de tous les comptes
@riverpod
Stream<List<Account>> accountsStream(Ref ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchAllAccounts();
}

/// Stream de toutes les catégories
@riverpod
Stream<List<Category>> categoriesStream(Ref ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchAllCategories();
}

/// Stream des catégories de dépenses
@riverpod
Stream<List<Category>> expenseCategoriesStream(Ref ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchExpenseCategories();
}

/// Stream des catégories de revenus
@riverpod
Stream<List<Category>> incomeCategoriesStream(Ref ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchIncomeCategories();
}

/// Stream des transactions récentes (10 dernières)
@riverpod
Stream<List<TransactionWithDetails>> recentTransactionsStream(Ref ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchRecentTransactions(10);
}

/// Stream du résumé financier
@riverpod
Stream<FinancialSummary> financialSummaryStream(Ref ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchFinancialSummary();
}

/// Stream du solde calculé d'un compte (solde initial + transactions)
@riverpod
Stream<double> accountCalculatedBalanceStream(Ref ref, String accountId) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchCalculatedBalance(accountId);
}
