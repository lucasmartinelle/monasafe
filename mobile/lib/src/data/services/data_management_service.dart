import 'package:monasafe/src/data/services/account_service.dart';
import 'package:monasafe/src/data/services/budget_service.dart';
import 'package:monasafe/src/data/services/category_service.dart';
import 'package:monasafe/src/data/services/recurring_transaction_service.dart';
import 'package:monasafe/src/data/services/transaction_service.dart';

/// Service pour la gestion des données utilisateur (suppression).
class DataManagementService {
  DataManagementService({
    required this.transactionService,
    required this.recurringTransactionService,
    required this.budgetService,
    required this.accountService,
    required this.categoryService,
  });

  final TransactionService transactionService;
  final RecurringTransactionService recurringTransactionService;
  final BudgetService budgetService;
  final AccountService accountService;
  final CategoryService categoryService;

  /// Supprime toutes les transactions de l'utilisateur.
  Future<void> deleteAllTransactions() async {
    await transactionService.deleteAllTransactions();
  }

  /// Supprime toutes les récurrences de l'utilisateur.
  /// Les transactions déjà générées sont conservées.
  Future<void> deleteAllRecurringTransactions() async {
    await recurringTransactionService.deleteAll();
  }

  /// Supprime tous les budgets de l'utilisateur.
  Future<void> deleteAllBudgets() async {
    await budgetService.deleteAllBudgets();
  }

  /// Supprime toutes les données de l'utilisateur.
  /// Respecte l'ordre des contraintes de clés étrangères.
  Future<void> deleteAllUserData() async {
    // 1. Transactions (dépendent des comptes et catégories)
    await transactionService.deleteAllTransactions();

    // 2. Récurrences
    await recurringTransactionService.deleteAll();

    // 3. Budgets
    await budgetService.deleteAllBudgets();

    // 4. Comptes
    await accountService.deleteAllAccounts();

    // 5. Catégories personnalisées
    await categoryService.deleteAllCustomCategories();
  }
}
