import 'package:monasafe/src/core/services/invalidation_service.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/aggregators/settings/presentation/category_form_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_form_provider.g.dart';

/// Provider pour la gestion du formulaire de catégorie.
@riverpod
class CategoryFormNotifier extends _$CategoryFormNotifier {
  @override
  CategoryFormState build() => const CategoryFormState();

  /// Réinitialise le formulaire.
  void reset({CategoryType? type}) {
    state = CategoryFormState(
      type: type ?? CategoryType.expense,
    );
  }

  /// Charge une catégorie existante pour édition.
  void loadCategory(Category category) {
    state = CategoryFormState(
      name: category.name,
      iconKey: category.iconKey,
      color: category.color,
      type: category.type,
      editingCategoryId: category.id,
    );
  }

  /// Met à jour le nom.
  void setName(String name) {
    state = state.copyWith(name: name, clearError: true);
  }

  /// Met à jour l'icône.
  void setIconKey(String iconKey) {
    state = state.copyWith(iconKey: iconKey);
  }

  /// Met à jour la couleur.
  void setColor(int color) {
    state = state.copyWith(color: color);
  }

  /// Met à jour le type.
  void setType(CategoryType type) {
    state = state.copyWith(type: type);
  }

  /// Crée une nouvelle catégorie.
  Future<bool> create() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Le nom est requis');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    final repository = ref.read(categoryRepositoryProvider);
    final result = await repository.createCategory(
      name: state.name.trim(),
      iconKey: state.iconKey,
      color: state.color,
      type: state.type,
    );

    return result.fold(
      (error) {
        state = state.copyWith(isSubmitting: false, error: error.message);
        return false;
      },
      (_) {
        state = state.copyWith(isSubmitting: false);
        InvalidationService.onCategoryChanged(ref);
        return true;
      },
    );
  }

  /// Met à jour une catégorie existante.
  Future<bool> update() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Le nom est requis');
      return false;
    }

    if (state.editingCategoryId == null) {
      state = state.copyWith(error: 'Aucune catégorie à modifier');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    final repository = ref.read(categoryRepositoryProvider);
    final result = await repository.updateCategory(
      id: state.editingCategoryId!,
      name: state.name.trim(),
      iconKey: state.iconKey,
      color: state.color,
    );

    return result.fold(
      (error) {
        state = state.copyWith(isSubmitting: false, error: error.message);
        return false;
      },
      (_) {
        state = state.copyWith(isSubmitting: false);
        InvalidationService.onCategoryChanged(ref);
        return true;
      },
    );
  }
}
