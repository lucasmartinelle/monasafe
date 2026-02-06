import 'package:flutter/foundation.dart' hide Category;

import 'package:simpleflow/src/data/models/models.dart' show Category;

export 'package:simpleflow/src/data/models/models.dart' show Category;

/// Période de filtrage pour les statistiques.
enum PeriodType {
  thisMonth('Ce mois'),
  lastMonth('Mois dernier'),
  yearToDate('Année');

  const PeriodType(this.label);

  /// Label affiché dans l'UI.
  final String label;

  /// Retourne la plage de dates pour cette période.
  (DateTime start, DateTime end) get dateRange {
    final now = DateTime.now();
    return switch (this) {
      PeriodType.thisMonth => (
          DateTime(now.year, now.month),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        ),
      PeriodType.lastMonth => (
          DateTime(now.year, now.month - 1),
          DateTime(now.year, now.month, 0, 23, 59, 59),
        ),
      PeriodType.yearToDate => (
          DateTime(now.year),
          now,
        ),
    };
  }
}

/// Statut du budget selon le pourcentage utilisé.
enum BudgetStatus {
  /// Moins de 75% utilisé.
  safe,

  /// Entre 75% et 99% utilisé.
  warning,

  /// 100% ou plus utilisé.
  exceeded,
}

/// Progression d'un budget pour une catégorie.
@immutable
class BudgetProgress {
  const BudgetProgress({
    required this.budgetId,
    required this.category,
    required this.budgetLimit,
    required this.monthlyBudgetLimit,
    required this.currentSpending,
  });

  /// L'ID du budget (UserBudget).
  final String budgetId;

  /// La catégorie concernée.
  final Category category;

  /// Limite de budget pour la période sélectionnée (peut être multipliée).
  final double budgetLimit;

  /// Limite de budget mensuelle originale (non multipliée).
  final double monthlyBudgetLimit;

  /// Dépenses actuelles pour la période.
  final double currentSpending;

  /// Pourcentage du budget utilisé (0.0 - 1.0+).
  double get percentageUsed =>
      budgetLimit > 0 ? currentSpending / budgetLimit : 1.0;

  /// Montant restant (peut être négatif si dépassé).
  double get remaining => budgetLimit - currentSpending;

  /// Indique si le budget est dépassé.
  bool get isOverBudget => currentSpending > budgetLimit;

  /// Statut du budget selon le pourcentage utilisé.
  BudgetStatus get status {
    if (percentageUsed >= 1.0) return BudgetStatus.exceeded;
    if (percentageUsed >= 0.75) return BudgetStatus.warning;
    return BudgetStatus.safe;
  }
}
