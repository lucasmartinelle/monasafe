import 'package:flutter/foundation.dart';

import 'package:simpleflow/src/data/models/enums.dart';

/// État du formulaire de création/édition de catégorie.
@immutable
class CategoryFormState {
  const CategoryFormState({
    this.name = '',
    this.iconKey = 'other',
    this.color = 0xFF4CAF50,
    this.type = CategoryType.expense,
    this.isSubmitting = false,
    this.error,
    this.editingCategoryId,
  });

  final String name;
  final String iconKey;
  final int color;
  final CategoryType type;
  final bool isSubmitting;
  final String? error;
  final String? editingCategoryId;

  bool get isValid => name.trim().isNotEmpty;
  bool get isEditing => editingCategoryId != null;

  CategoryFormState copyWith({
    String? name,
    String? iconKey,
    int? color,
    CategoryType? type,
    bool? isSubmitting,
    String? error,
    String? editingCategoryId,
    bool clearError = false,
    bool clearEditingId = false,
  }) {
    return CategoryFormState(
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      type: type ?? this.type,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      editingCategoryId:
          clearEditingId ? null : (editingCategoryId ?? this.editingCategoryId),
    );
  }
}

/// Couleurs prédéfinies pour les catégories.
const List<int> categoryColors = [
  0xFF4CAF50, // Green
  0xFF2196F3, // Blue
  0xFFF44336, // Red
  0xFFFF9800, // Orange
  0xFF9C27B0, // Purple
  0xFF00BCD4, // Cyan
  0xFFE91E63, // Pink
  0xFF795548, // Brown
  0xFF607D8B, // Blue Grey
  0xFFFFEB3B, // Yellow
  0xFF8BC34A, // Light Green
  0xFF3F51B5, // Indigo
];
