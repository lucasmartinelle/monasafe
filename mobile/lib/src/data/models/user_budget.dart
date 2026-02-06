/// Modèle représentant un budget utilisateur pour une catégorie
class UserBudget {
  const UserBudget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.budgetLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée un UserBudget depuis une Map JSON (Supabase)
  factory UserBudget.fromJson(Map<String, dynamic> json) {
    return UserBudget(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      budgetLimit: (json['budget_limit'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String categoryId;
  final double budgetLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convertit en Map JSON pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'budget_limit': budgetLimit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map pour insertion (sans id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'budget_limit': budgetLimit,
    };
  }

  /// Crée une copie avec des valeurs modifiées
  UserBudget copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? budgetLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserBudget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBudget &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
