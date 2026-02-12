import 'package:monasafe/src/data/models/account.dart';
import 'package:monasafe/src/data/models/category.dart';
import 'package:monasafe/src/data/models/transaction.dart';

/// DTO pour une transaction avec ses relations (compte et catégorie)
class TransactionWithDetails {
  const TransactionWithDetails({
    required this.transaction,
    required this.account,
    required this.category,
  });

  /// Crée depuis une Map JSON avec les relations jointes
  factory TransactionWithDetails.fromJson(Map<String, dynamic> json) {
    return TransactionWithDetails(
      transaction: Transaction.fromJson(json),
      account: Account.fromJson(json['accounts'] as Map<String, dynamic>),
      category: Category.fromJson(json['categories'] as Map<String, dynamic>),
    );
  }

  final Transaction transaction;
  final Account account;
  final Category category;
}
