import 'package:monasafe/src/data/models/models.dart';

/// Service Supabase pour les statistiques et agrégations
class StatisticsService {
  StatisticsService();

  // ==================== CALCULS CÔTÉ CLIENT ====================

  /// Calcule le résumé financier à partir d'une liste de transactions déchiffrées.
  ///
  /// Utilisé quand le vault est actif pour obtenir des calculs corrects
  /// à partir des données déjà déchiffrées côté client.
  FinancialSummary calculateFinancialSummaryFromTransactions(
    List<TransactionWithDetails> transactions,
    List<Account> accounts,
  ) {
    double totalIncome = 0;
    double totalExpense = 0;
    double monthlyIncome = 0;
    double monthlyExpense = 0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);

    for (final tx in transactions) {
      final amount = tx.transaction.amount;
      final isIncome = tx.category.type == CategoryType.income;

      if (isIncome) {
        totalIncome += amount;
        if (tx.transaction.date.isAfter(startOfMonth) ||
            tx.transaction.date.isAtSameMomentAs(startOfMonth)) {
          monthlyIncome += amount;
        }
      } else {
        totalExpense += amount;
        if (tx.transaction.date.isAfter(startOfMonth) ||
            tx.transaction.date.isAtSameMomentAs(startOfMonth)) {
          monthlyExpense += amount;
        }
      }
    }

    // Total balance = sum(initial balances) + totalIncome - totalExpense
    final totalInitialBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);
    final totalBalance = totalInitialBalance + totalIncome - totalExpense;

    return FinancialSummary(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
    );
  }

  /// Calcule les statistiques par catégorie à partir des transactions déchiffrées.
  List<CategoryStatistics> calculateCategoryStatsFromTransactions(
    List<TransactionWithDetails> transactions,
  ) {
    final categoryTotals = <String, _CategoryAccumulator>{};

    for (final tx in transactions) {
      final category = tx.category;
      final amount = tx.transaction.amount;

      final existing = categoryTotals[category.id];
      if (existing != null) {
        existing.total += amount;
        existing.count += 1;
      } else {
        categoryTotals[category.id] = _CategoryAccumulator(
          categoryId: category.id,
          categoryName: category.name,
          iconKey: category.iconKey,
          color: category.color,
          type: category.type,
          total: amount,
          count: 1,
        );
      }
    }

    return categoryTotals.values
        .map(
          (acc) => CategoryStatistics(
            categoryId: acc.categoryId,
            categoryName: acc.categoryName,
            iconKey: acc.iconKey,
            color: acc.color,
            type: acc.type,
            total: acc.total,
            transactionCount: acc.count,
          ),
        )
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  /// Calcule les statistiques mensuelles à partir des transactions déchiffrées.
  List<MonthlyStatistics> calculateMonthlyStatsFromTransactions(
    List<TransactionWithDetails> transactions,
    int year,
  ) {
    final monthlyMap = <int, ({double income, double expense})>{};

    for (final tx in transactions) {
      final date = tx.transaction.date;
      if (date.year != year) continue;

      final amount = tx.transaction.amount;
      final isIncome = tx.category.type == CategoryType.income;
      final month = date.month;

      final existing = monthlyMap[month] ?? (income: 0.0, expense: 0.0);
      monthlyMap[month] = (
        income: existing.income + (isIncome ? amount : 0),
        expense: existing.expense + (isIncome ? 0 : amount),
      );
    }

    return monthlyMap.entries
        .map((entry) => MonthlyStatistics(
              year: year,
              month: entry.key,
              totalIncome: entry.value.income,
              totalExpense: entry.value.expense,
              balance: entry.value.income - entry.value.expense,
            ))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  /// Calcule les statistiques journalières à partir des transactions déchiffrées.
  List<DailyStatistics> calculateDailyStatsFromTransactions(
    List<TransactionWithDetails> transactions,
    int year,
    int month,
  ) {
    final dailyMap = <int, ({double income, double expense})>{};

    for (final tx in transactions) {
      final date = tx.transaction.date;
      if (date.year != year || date.month != month) continue;

      final amount = tx.transaction.amount;
      final isIncome = tx.category.type == CategoryType.income;
      final day = date.day;

      final existing = dailyMap[day] ?? (income: 0.0, expense: 0.0);
      dailyMap[day] = (
        income: existing.income + (isIncome ? amount : 0),
        expense: existing.expense + (isIncome ? 0 : amount),
      );
    }

    return dailyMap.entries
        .map((entry) => DailyStatistics(
              date: DateTime(year, month, entry.key),
              totalIncome: entry.value.income,
              totalExpense: entry.value.expense,
            ))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));
  }

  /// Calcule le total des dépenses d'une catégorie à partir des transactions.
  double calculateCategorySpendingFromTransactions(
    List<TransactionWithDetails> transactions,
    String categoryId,
  ) {
    double total = 0;
    for (final tx in transactions) {
      if (tx.transaction.categoryId == categoryId) {
        total += tx.transaction.amount;
      }
    }
    return total;
  }
}

/// Helper class for accumulating category statistics
class _CategoryAccumulator {
  _CategoryAccumulator({
    required this.categoryId,
    required this.categoryName,
    required this.iconKey,
    required this.color,
    required this.type,
    required this.total,
    required this.count,
  });

  final String categoryId;
  final String categoryName;
  final String iconKey;
  final int color;
  final CategoryType type;
  double total;
  int count;
}
