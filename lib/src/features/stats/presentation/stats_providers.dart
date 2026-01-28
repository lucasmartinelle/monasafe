import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';
import 'package:simpleflow/src/features/stats/presentation/stats_state.dart';

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
@riverpod
Stream<CashflowData> cashflowDataStream(Ref ref) async* {
  final period = ref.watch(selectedPeriodProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);

  // Refresh when transactions change
  ref.watch(transactionsRefreshTriggerProvider);

  if (period == PeriodType.yearToDate) {
    // Vue année : données mensuelles
    final year = DateTime.now().year;
    await for (final data in statisticsService.watchMonthlyStatistics(year)) {
      yield MonthlyCashflowData(data);
    }
  } else {
    // Vue mois : données journalières
    final (startDate, _) = period.dateRange;
    await for (final data in statisticsService.watchDailyStatistics(
      startDate.year,
      startDate.month,
    )) {
      yield DailyCashflowData(data);
    }
  }
}

/// Future provider for budget progress list.
/// Combines user budgets with their spending for the selected period.
/// Note: budgetLimit is monthly, so we multiply by 12 for yearly view.
@riverpod
Future<List<BudgetProgress>> budgetProgressList(Ref ref) async {
  // Refresh when transactions change
  ref.watch(transactionsRefreshTriggerProvider);

  final period = ref.watch(selectedPeriodProvider);
  final budgetService = ref.watch(budgetServiceProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);
  final (startDate, endDate) = period.dateRange;

  // Get all user budgets with categories
  final budgetsWithCategories = await budgetService.getBudgetsWithCategories();

  // Get spending per category for the period
  final spending =
      await statisticsService.getTotalByCategory(startDate, endDate);

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
      category: category,
      budgetLimit: budget.budgetLimit * budgetMultiplier,
      currentSpending: categorySpending?.total ?? 0,
    );
  }).toList();
}

/// Stream version of budget progress for real-time updates.
/// Note: budgetLimit is monthly, so we multiply by 12 for yearly view.
@riverpod
Stream<List<BudgetProgress>> budgetProgressStream(Ref ref) async* {
  // Refresh when transactions change
  ref.watch(transactionsRefreshTriggerProvider);

  final period = ref.watch(selectedPeriodProvider);
  final budgetService = ref.watch(budgetServiceProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);
  final (startDate, endDate) = period.dateRange;

  // Multiplier for yearly view (budget is defined monthly)
  final budgetMultiplier = period == PeriodType.yearToDate ? 12 : 1;

  // Watch user budgets with categories
  await for (final budgetsData in budgetService.watchBudgetsWithCategories()) {
    // Get current spending for each category
    final spending =
        await statisticsService.getTotalByCategory(startDate, endDate);

    yield budgetsData
        .where((data) => data['category'] != null)
        .map((data) {
      final budget = data['budget'] as UserBudget;
      final category = data['category'] as Category;
      final categorySpending = spending
          .where((CategoryStatistics s) => s.categoryId == category.id)
          .firstOrNull;

      return BudgetProgress(
        category: category,
        budgetLimit: budget.budgetLimit * budgetMultiplier,
        currentSpending: categorySpending?.total ?? 0,
      );
    }).toList();
  }
}
