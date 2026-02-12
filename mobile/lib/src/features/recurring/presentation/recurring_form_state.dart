import 'package:flutter/foundation.dart' hide Category;

import 'package:monasafe/src/data/models/models.dart';

/// Etat du formulaire de modification d'une transaction recurrente.
@immutable
class RecurringFormState {
  const RecurringFormState({
    required this.recurringId,
    required this.categoryId,
    this.category,
    this.account,
    this.amountCents = 0,
    this.note = '',
    this.endDate,
    this.isActive = true,
    this.isLoading = false,
    this.isDeleting = false,
    this.isToggling = false,
    this.error,
  });

  /// ID de la recurrence
  final String recurringId;

  /// ID de la categorie
  final String categoryId;

  /// Categorie (pour affichage)
  final Category? category;

  /// Compte (pour affichage)
  final Account? account;

  /// Montant en centimes (ex: 1234 = 12,34 EUR)
  final int amountCents;

  /// Note optionnelle
  final String note;

  /// Date de fin optionnelle
  final DateTime? endDate;

  /// Indique si la recurrence est active
  final bool isActive;

  /// Indique si une operation de mise a jour est en cours
  final bool isLoading;

  /// Indique si une suppression est en cours
  final bool isDeleting;

  /// Indique si un toggle actif/inactif est en cours
  final bool isToggling;

  /// Message d'erreur eventuel
  final String? error;

  /// Indique si le formulaire est valide (montant > 0)
  bool get isValid => amountCents > 0;

  /// Indique si une operation est en cours
  bool get isBusy => isLoading || isDeleting || isToggling;

  /// Montant en euros
  double get budgetLimit => amountCents / 100;

  /// Montant formate pour affichage (ex: "12,34")
  String get displayAmount {
    final euros = amountCents ~/ 100;
    final cents = amountCents % 100;
    return '$euros,${cents.toString().padLeft(2, '0')}';
  }

  RecurringFormState copyWith({
    String? recurringId,
    String? categoryId,
    Category? category,
    Account? account,
    int? amountCents,
    String? note,
    DateTime? endDate,
    bool? isActive,
    bool? isLoading,
    bool? isDeleting,
    bool? isToggling,
    String? error,
    bool clearError = false,
    bool clearEndDate = false,
  }) {
    return RecurringFormState(
      recurringId: recurringId ?? this.recurringId,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      account: account ?? this.account,
      amountCents: amountCents ?? this.amountCents,
      note: note ?? this.note,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      isToggling: isToggling ?? this.isToggling,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
