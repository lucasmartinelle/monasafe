import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/stats/presentation/stats_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_providers.g.dart';

/// Provider for the currently selected period.
/// Defaults to "This Month".
@riverpod
class SelectedPeriod extends _$SelectedPeriod {
  @override
  PeriodType build() => PeriodType.thisMonth;

  void select(PeriodType period) {
    state = period;
  }
}

/// Données du graphique de flux de trésorerie.
/// Peut contenir soit des données mensuelles (vue année) soit journalières (vue mois).
sealed class CashflowData {
  const CashflowData();
}

class MonthlyCashflowData extends CashflowData {
  const MonthlyCashflowData(this.data);
  final List<MonthlyStatistics> data;
}

class DailyCashflowData extends CashflowData {
  const DailyCashflowData(this.data);
  final List<DailyStatistics> data;
}

/// Stream of cashflow data adapted to the selected period.
/// Returns monthly data for year view, daily data for month views.
/// Uses client-side calculations (amount is TEXT in DB).
@riverpod
Stream<CashflowData> cashflowDataStream(Ref ref) async* {
  final period = ref.watch(selectedPeriodProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);
  final transactionService = ref.watch(transactionServiceProvider);

  // Refresh when transactions change
  ref.watch(transactionsRefreshTriggerProvider);

  if (period == PeriodType.yearToDate) {
    // Vue année : données mensuelles (calculs côté client)
    final year = DateTime.now().year;
    await for (final transactions
        in transactionService.watchAllTransactionsWithDetails()) {
      final stats = statisticsService.calculateMonthlyStatsFromTransactions(
        transactions,
        year,
      );
      yield MonthlyCashflowData(stats);
    }
  } else {
    // Vue mois : données journalières (calculs côté client)
    final (startDate, _) = period.dateRange;
    await for (final transactions
        in transactionService.watchAllTransactionsWithDetails()) {
      final stats = statisticsService.calculateDailyStatsFromTransactions(
        transactions,
        startDate.year,
        startDate.month,
      );
      yield DailyCashflowData(stats);
    }
  }
}

/// Future provider for budget progress list.
/// Combines user budgets with their spending for the selected period.
/// Uses client-side calculations (amount is TEXT in DB).
@riverpod
Future<List<BudgetProgress>> budgetProgressList(Ref ref) async {
  // Refresh when transactions change
  ref.watch(transactionsRefreshTriggerProvider);

  final period = ref.watch(selectedPeriodProvider);
  final budgetService = ref.watch(budgetServiceProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);
  final transactionService = ref.read(transactionServiceProvider);
  final (startDate, endDate) = period.dateRange;

  // Get all user budgets with categories
  final budgetsWithCategories = await budgetService.getBudgetsWithCategories();

  // Get spending per category for the period (client-side)
  final transactions = await transactionService.getTransactionsByPeriod(
    startDate,
    endDate,
  );
  final spending = statisticsService.calculateCategoryStatsFromTransactions(transactions);

  // Multiplier for yearly view (budget is defined monthly)
  final budgetMultiplier = period == PeriodType.yearToDate ? 12 : 1;

  // Combine into BudgetProgress list
  return budgetsWithCategories.map((data) {
    final budget = UserBudget.fromJson(data);
    final category = Category.fromJson(data['categories'] as Map<String, dynamic>);
    final categorySpending = spending
        .where((CategoryStatistics s) => s.categoryId == category.id)
        .firstOrNull;

    return BudgetProgress(
      budgetId: budget.id,
      category: category,
      budgetLimit: budget.budgetLimit * budgetMultiplier,
      monthlyBudgetLimit: budget.budgetLimit,
      currentSpending: categorySpending?.total ?? 0,
    );
  }).toList();
}

/// Stream version of budget progress for real-time updates.
/// Uses client-side calculations (amount is TEXT in DB).
@riverpod
Stream<List<BudgetProgress>> budgetProgressStream(Ref ref) async* {
  // Refresh when transactions change
  ref.watch(transactionsRefreshTriggerProvider);

  final period = ref.watch(selectedPeriodProvider);
  final budgetService = ref.watch(budgetServiceProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);
  final transactionService = ref.read(transactionServiceProvider);
  final (startDate, endDate) = period.dateRange;

  // Multiplier for yearly view (budget is defined monthly)
  final budgetMultiplier = period == PeriodType.yearToDate ? 12 : 1;

  // Watch user budgets with categories
  await for (final budgetsData in budgetService.watchBudgetsWithCategories()) {
    // Get current spending for each category (client-side)
    final transactions = await transactionService.getTransactionsByPeriod(
      startDate,
      endDate,
    );
    final spending = statisticsService.calculateCategoryStatsFromTransactions(transactions);

    yield budgetsData
        .where((data) => data['category'] != null)
        .map((data) {
      final budget = data['budget'] as UserBudget;
      final category = data['category'] as Category;
      final categorySpending = spending
          .where((CategoryStatistics s) => s.categoryId == category.id)
          .firstOrNull;

      return BudgetProgress(
        budgetId: budget.id,
        category: category,
        budgetLimit: budget.budgetLimit * budgetMultiplier,
        monthlyBudgetLimit: budget.budgetLimit,
        currentSpending: categorySpending?.total ?? 0,
      );
    }).toList();
  }
}

/// Provider pour récupérer les transactions d'une catégorie pour une période donnée.
@riverpod
Future<List<TransactionWithDetails>> transactionsByCategory(
  Ref ref,
  String categoryId,
  DateTime startDate,
  DateTime endDate,
) async {
  final transactionService = ref.watch(transactionServiceProvider);
  final transactions = await transactionService.getTransactionsByPeriod(
    startDate,
    endDate,
  );
  return transactions
      .where((tx) => tx.transaction.categoryId == categoryId)
      .toList();
}
