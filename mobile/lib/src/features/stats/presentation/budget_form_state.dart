import 'package:flutter/foundation.dart' hide Category;

import 'package:monasafe/src/data/models/models.dart' show Category;

/// État immutable du formulaire de modification de budget.
@immutable
class BudgetFormState {
  const BudgetFormState({
    required this.budgetId,
    required this.categoryId,
    required this.category,
    required this.currentSpending,
    this.amountCents = 0,
    this.isLoading = false,
    this.isDeleting = false,
  });

  /// ID du budget (UserBudget).
  final String budgetId;

  /// ID de la catégorie.
  final String categoryId;

  /// Catégorie associée au budget.
  final Category category;

  /// Montant du budget en centimes.
  final int amountCents;

  /// Dépenses actuelles pour la période.
  final double currentSpending;

  /// Indique si une opération de mise à jour est en cours.
  final bool isLoading;

  /// Indique si une opération de suppression est en cours.
  final bool isDeleting;

  /// Vérifie si le formulaire est valide.
  bool get isValid => amountCents > 0;

  /// Montant en euros.
  double get budgetLimit => amountCents / 100;

  /// Montant formaté pour l'affichage (ex: "100,00").
  String get displayAmount {
    final euros = amountCents ~/ 100;
    final cents = amountCents % 100;
    return '$euros,${cents.toString().padLeft(2, '0')}';
  }

  /// Crée une copie avec des valeurs modifiées.
  BudgetFormState copyWith({
    String? budgetId,
    String? categoryId,
    Category? category,
    int? amountCents,
    double? currentSpending,
    bool? isLoading,
    bool? isDeleting,
  }) {
    return BudgetFormState(
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      amountCents: amountCents ?? this.amountCents,
      currentSpending: currentSpending ?? this.currentSpending,
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}
