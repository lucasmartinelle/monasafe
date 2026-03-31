import 'package:flutter/foundation.dart';

import 'package:monasafe/src/core/utils/constants.dart';

/// State immutable pour le formulaire de virement entre comptes.
@immutable
class TransferFormState {
  const TransferFormState({
    this.fromAccountId,
    this.toAccountId,
    this.amountCents = 0,
    this.date,
    this.note = '',
    this.isSubmitting = false,
    this.error,
  });

  final String? fromAccountId;
  final String? toAccountId;

  /// Montant en centimes (ex. 150 = 1,50€)
  final int amountCents;
  final DateTime? date;
  final String note;
  final bool isSubmitting;
  final String? error;

  DateTime get effectiveDate => date ?? DateTime.now();
  double get amount => amountCents / 100;

  String get displayAmount {
    final euros = amountCents ~/ 100;
    final cents = amountCents % 100;
    return '$euros,${cents.toString().padLeft(2, '0')}';
  }

  bool get isValid =>
      fromAccountId != null &&
      toAccountId != null &&
      fromAccountId != toAccountId &&
      amountCents > 0 &&
      amountCents <= kMaxAmountCents;

  TransferFormState copyWith({
    String? fromAccountId,
    String? toAccountId,
    int? amountCents,
    DateTime? date,
    String? note,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return TransferFormState(
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amountCents: amountCents ?? this.amountCents,
      date: date ?? this.date,
      note: note ?? this.note,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
