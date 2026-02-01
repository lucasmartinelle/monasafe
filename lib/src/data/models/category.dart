import 'package:simpleflow/src/data/models/enums.dart';

/// Modèle représentant une catégorie de transaction
class Category {
  const Category({
    required this.id,
    required this.name, required this.iconKey, required this.color, required this.type, required this.isDefault, required this.createdAt, required this.updatedAt, this.userId,
    this.budgetLimit,
  });

  /// Crée une Category depuis une Map JSON (Supabase)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      iconKey: json['icon_key'] as String,
      color: json['color'] as int,
      type: CategoryType.fromString(json['type'] as String),
      budgetLimit: (json['budget_limit'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String? userId;
  final String name;
  final String iconKey;
  final int color;
  final CategoryType type;
  final double? budgetLimit;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convertit en Map JSON pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon_key': iconKey,
      'color': color,
      'type': type.name,
      'budget_limit': budgetLimit,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crée une copie avec des valeurs modifiées
  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? iconKey,
    int? color,
    CategoryType? type,
    double? budgetLimit,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      type: type ?? this.type,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
