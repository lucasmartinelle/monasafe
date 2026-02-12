import 'package:monasafe/src/data/models/enums.dart';

/// Modèle représentant une transaction financière
///
/// Quand le vault est actif, `_rawAmount` et `_rawNote` contiennent des valeurs
/// chiffrées en Base64. Le getter `amount` retourne 0 si non déchiffré,
/// et `note` retourne null.
///
/// Utilisez `withDecrypted()` pour injecter les valeurs déchiffrées.
class Transaction {
  const Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required String rawAmount,
    required this.date,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    String? rawNote,
    this.recurringId,
    this.isEncrypted = false,
    double? decryptedAmount,
    String? decryptedNote,
  })  : _rawAmount = rawAmount,
        _rawNote = rawNote,
        _decryptedAmount = decryptedAmount,
        _decryptedNote = decryptedNote;

  /// Crée une Transaction depuis une Map JSON (Supabase)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'].toString();
    final isEncrypted = json['is_encrypted'] as bool? ?? false;

    // Si non chiffré, parser le montant directement
    double? decryptedAmount;
    String? decryptedNote;
    if (!isEncrypted) {
      decryptedAmount = double.tryParse(rawAmount) ?? 0.0;
      decryptedNote = json['note'] as String?;
    }

    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      categoryId: json['category_id'] as String,
      rawAmount: rawAmount,
      date: DateTime.parse(json['date'] as String),
      rawNote: json['note'] as String?,
      recurringId: json['recurring_id'] as String?,
      syncStatus: SyncStatus.fromString(json['sync_status'] as String? ?? 'synced'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isEncrypted: isEncrypted,
      decryptedAmount: decryptedAmount,
      decryptedNote: decryptedNote,
    );
  }

  final String id;
  final String userId;
  final String accountId;
  final String categoryId;
  final DateTime date;
  final String? recurringId;
  final SyncStatus syncStatus;

  /// Indique si cette transaction est liee a une recurrence
  bool get isRecurring => recurringId != null;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Indique si les données sensibles sont chiffrées
  final bool isEncrypted;

  /// Valeur brute du montant (nombre en string ou Base64 chiffré)
  final String _rawAmount;

  /// Valeur brute de la note (texte ou Base64 chiffré)
  final String? _rawNote;

  /// Montant déchiffré (injecté via withDecrypted)
  final double? _decryptedAmount;

  /// Note déchiffrée (injectée via withDecrypted)
  final String? _decryptedNote;

  /// Retourne le montant. Si chiffré et non déchiffré, retourne 0.
  double get amount => _decryptedAmount ?? 0;

  /// Retourne la note. Si chiffrée et non déchiffrée, retourne null.
  String? get note => _decryptedNote;

  /// Retourne la valeur brute du montant (pour le déchiffrement)
  String get rawAmount => _rawAmount;

  /// Retourne la valeur brute de la note (pour le déchiffrement)
  String? get rawNote => _rawNote;

  /// Crée une copie avec les valeurs déchiffrées injectées
  Transaction withDecrypted({required double amount, String? note}) {
    return Transaction(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      rawAmount: _rawAmount,
      date: date,
      rawNote: _rawNote,
      recurringId: recurringId,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEncrypted: isEncrypted,
      decryptedAmount: amount,
      decryptedNote: note,
    );
  }

  /// Convertit en Map JSON pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': _rawAmount,
      'date': date.toIso8601String(),
      'note': _rawNote,
      'recurring_id': recurringId,
      'sync_status': syncStatus.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_encrypted': isEncrypted,
    };
  }

  /// Crée une copie avec des valeurs modifiées
  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
    String? rawAmount,
    DateTime? date,
    String? rawNote,
    String? recurringId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEncrypted,
    double? decryptedAmount,
    String? decryptedNote,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      rawAmount: rawAmount ?? _rawAmount,
      date: date ?? this.date,
      rawNote: rawNote ?? _rawNote,
      recurringId: recurringId ?? this.recurringId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      decryptedAmount: decryptedAmount ?? _decryptedAmount,
      decryptedNote: decryptedNote ?? _decryptedNote,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
