import 'package:meta/meta.dart';
import 'package:monasafe/src/data/models/account.dart';
import 'package:monasafe/src/data/models/category.dart';
import 'package:monasafe/src/data/models/recurring_transaction.dart';

/// Agregat d'une transaction recurrente avec ses details (compte et categorie)
@immutable
class RecurringTransactionWithDetails {
  const RecurringTransactionWithDetails({
    required this.recurring,
    required this.account,
    this.category,
  });

  /// Cree depuis une Map JSON avec jointures Supabase
  factory RecurringTransactionWithDetails.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionWithDetails(
      recurring: RecurringTransaction.fromJson(json),
      account: Account.fromJson(json['accounts'] as Map<String, dynamic>),
      category: json['categories'] != null
          ? Category.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
    );
  }

  /// La transaction recurrente
  final RecurringTransaction recurring;

  /// Le compte associe
  final Account account;

  /// La categorie associee (peut etre null si supprimee)
  final Category? category;

  /// Cree une copie avec la recurrence dechiffree
  RecurringTransactionWithDetails withDecryptedRecurring(
    RecurringTransaction decrypted,
  ) {
    return RecurringTransactionWithDetails(
      recurring: decrypted,
      account: account,
      category: category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransactionWithDetails &&
          runtimeType == other.runtimeType &&
          recurring == other.recurring;

  @override
  int get hashCode => recurring.hashCode;
}
