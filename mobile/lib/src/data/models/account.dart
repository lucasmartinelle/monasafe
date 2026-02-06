import 'package:simpleflow/src/data/models/enums.dart';

/// Modèle représentant un compte bancaire/portefeuille
class Account {
  const Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.color,
    required this.createdAt, required this.updatedAt, this.lastSyncedAt,
  });

  /// Crée un Account depuis une Map JSON (Supabase)
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: AccountType.fromString(json['type'] as String),
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      color: json['color'] as int,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final int color;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convertit en Map JSON pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
      'color': color,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crée une copie avec des valeurs modifiées
  Account copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    int? color,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
