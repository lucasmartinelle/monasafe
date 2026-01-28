import 'package:simpleflow/src/data/models/enums.dart';

/// Modèle représentant une transaction financière
class Transaction {
  const Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note,
    required this.isRecurring,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une Transaction depuis une Map JSON (Supabase)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      syncStatus: SyncStatus.fromString(json['sync_status'] as String? ?? 'synced'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String accountId;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String? note;
  final bool isRecurring;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convertit en Map JSON pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'is_recurring': isRecurring,
      'sync_status': syncStatus.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crée une copie avec des valeurs modifiées
  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    bool? isRecurring,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
