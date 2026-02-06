import 'package:simpleflow/src/data/models/enums.dart';

/// DTO pour les statistiques par catégorie
class CategoryStatistics {
  const CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.iconKey,
    required this.color,
    required this.type,
    required this.total,
    required this.transactionCount,
  });

  final String categoryId;
  final String categoryName;
  final String iconKey;
  final int color;
  final CategoryType type;
  final double total;
  final int transactionCount;
}

/// DTO pour les statistiques mensuelles
class MonthlyStatistics {
  const MonthlyStatistics({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double balance;
}

/// DTO pour les statistiques journalières
class DailyStatistics {
  const DailyStatistics({
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
  });

  final DateTime date;
  final double totalIncome;
  final double totalExpense;

  double get balance => totalIncome - totalExpense;

  /// Retourne le jour du mois (1-31)
  int get day => date.day;
}

/// DTO pour le résumé financier
class FinancialSummary {
  const FinancialSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  /// Crée un résumé financier vide
  const FinancialSummary.empty()
      : totalBalance = 0,
        totalIncome = 0,
        totalExpense = 0,
        monthlyIncome = 0,
        monthlyExpense = 0;

  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double monthlyIncome;
  final double monthlyExpense;
}
