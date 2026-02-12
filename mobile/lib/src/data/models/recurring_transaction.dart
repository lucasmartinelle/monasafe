/// Modele representant une transaction recurrente mensuelle
///
/// Quand le vault est actif, `_rawAmount` et `_rawNote` contiennent des valeurs
/// chiffrees en Base64. Le getter `amount` retourne 0 si non dechiffre,
/// et `note` retourne null.
///
/// Utilisez `withDecrypted()` pour injecter les valeurs dechiffrees.
class RecurringTransaction {
  const RecurringTransaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required String rawAmount,
    required this.originalDay,
    required this.startDate,
    required this.isActive, required this.isEncrypted, required this.createdAt, required this.updatedAt, this.endDate,
    this.lastGenerated,
    String? rawNote,
    double? decryptedAmount,
    String? decryptedNote,
  })  : _rawAmount = rawAmount,
        _rawNote = rawNote,
        _decryptedAmount = decryptedAmount,
        _decryptedNote = decryptedNote;

  /// Cree une RecurringTransaction depuis une Map JSON (Supabase)
  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'].toString();
    final isEncrypted = json['is_encrypted'] as bool? ?? false;

    // Si non chiffre, parser le montant directement
    double? decryptedAmount;
    String? decryptedNote;
    if (!isEncrypted) {
      decryptedAmount = double.tryParse(rawAmount) ?? 0.0;
      decryptedNote = json['note'] as String?;
    }

    return RecurringTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      categoryId: json['category_id'] as String?,
      rawAmount: rawAmount,
      rawNote: json['note'] as String?,
      originalDay: json['original_day'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      lastGenerated: json['last_generated'] != null
          ? DateTime.parse(json['last_generated'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      isEncrypted: isEncrypted,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      decryptedAmount: decryptedAmount,
      decryptedNote: decryptedNote,
    );
  }

  final String id;
  final String userId;
  final String accountId;
  final String? categoryId;

  /// Jour d'origine de la recurrence (1-31)
  /// Utilise pour calculer les dates mensuelles
  final int originalDay;

  /// Date de debut de la recurrence
  final DateTime startDate;

  /// Date de fin optionnelle (null = infini)
  final DateTime? endDate;

  /// Derniere date generee
  final DateTime? lastGenerated;

  /// Indique si la recurrence est active
  final bool isActive;

  /// Indique si les donnees sensibles sont chiffrees
  final bool isEncrypted;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Valeur brute du montant (nombre en string ou Base64 chiffre)
  final String _rawAmount;

  /// Valeur brute de la note (texte ou Base64 chiffre)
  final String? _rawNote;

  /// Montant dechiffre (injecte via withDecrypted)
  final double? _decryptedAmount;

  /// Note dechiffree (injectee via withDecrypted)
  final String? _decryptedNote;

  /// Retourne le montant. Si chiffre et non dechiffre, retourne 0.
  double get amount => _decryptedAmount ?? 0;

  /// Retourne la note. Si chiffree et non dechiffree, retourne null.
  String? get note => _decryptedNote;

  /// Retourne la valeur brute du montant (pour le dechiffrement)
  String get rawAmount => _rawAmount;

  /// Retourne la valeur brute de la note (pour le dechiffrement)
  String? get rawNote => _rawNote;

  /// Cree une copie avec les valeurs dechiffrees injectees
  RecurringTransaction withDecrypted({required double amount, String? note}) {
    return RecurringTransaction(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      rawAmount: _rawAmount,
      rawNote: _rawNote,
      originalDay: originalDay,
      startDate: startDate,
      endDate: endDate,
      lastGenerated: lastGenerated,
      isActive: isActive,
      isEncrypted: isEncrypted,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
      'note': _rawNote,
      'original_day': originalDay,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'last_generated': lastGenerated?.toIso8601String().split('T').first,
      'is_active': isActive,
      'is_encrypted': isEncrypted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map pour insertion (sans id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': _rawAmount,
      'note': _rawNote,
      'original_day': originalDay,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'is_active': isActive,
      'is_encrypted': isEncrypted,
    };
  }

  /// Cree une copie avec des valeurs modifiees
  RecurringTransaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
    String? rawAmount,
    String? rawNote,
    int? originalDay,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastGenerated,
    bool? isActive,
    bool? isEncrypted,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? decryptedAmount,
    String? decryptedNote,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      rawAmount: rawAmount ?? _rawAmount,
      rawNote: rawNote ?? _rawNote,
      originalDay: originalDay ?? this.originalDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      isActive: isActive ?? this.isActive,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      decryptedAmount: decryptedAmount ?? _decryptedAmount,
      decryptedNote: decryptedNote ?? _decryptedNote,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
