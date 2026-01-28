import 'package:flutter/foundation.dart';

import 'package:simpleflow/src/data/models/models.dart';

/// Base state for transaction forms (add/edit).
@immutable
class TransactionFormState {
  const TransactionFormState({
    this.transactionId,
    this.type = CategoryType.expense,
    this.amountCents = 0,
    this.categoryId,
    this.note = '',
    this.date,
    this.isRecurring = false,
    this.selectedAccountId,
    this.isSubmitting = false,
    this.isDeleting = false,
    this.error,
  });

  /// Transaction ID (null for new transactions)
  final String? transactionId;
  final CategoryType type;

  /// Amount stored in cents (e.g., 150 = 1,50€)
  final int amountCents;
  final String? categoryId;
  final String note;
  final DateTime? date;
  final bool isRecurring;
  final String? selectedAccountId;
  final bool isSubmitting;
  final bool isDeleting;
  final String? error;

  /// Whether this is an edit (has existing transaction ID)
  bool get isEditMode => transactionId != null;

  /// Get the actual date, defaulting to now
  DateTime get effectiveDate => date ?? DateTime.now();

  /// Amount in euros (e.g., 150 cents = 1.50)
  double get amount => amountCents / 100;

  /// Display amount formatted with comma (e.g., "1,50")
  String get displayAmount {
    final euros = amountCents ~/ 100;
    final cents = amountCents % 100;
    return '$euros,${cents.toString().padLeft(2, '0')}';
  }

  /// Whether the form is valid for submission
  bool get isValid =>
      amountCents > 0 && categoryId != null && selectedAccountId != null;

  /// Whether any operation is in progress
  bool get isBusy => isSubmitting || isDeleting;

  TransactionFormState copyWith({
    String? transactionId,
    CategoryType? type,
    int? amountCents,
    String? categoryId,
    String? note,
    DateTime? date,
    bool? isRecurring,
    String? selectedAccountId,
    bool? isSubmitting,
    bool? isDeleting,
    String? error,
    bool clearCategoryId = false,
    bool clearError = false,
  }) {
    return TransactionFormState(
      transactionId: transactionId ?? this.transactionId,
      type: type ?? this.type,
      amountCents: amountCents ?? this.amountCents,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      note: note ?? this.note,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      selectedAccountId: selectedAccountId ?? this.selectedAccountId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
