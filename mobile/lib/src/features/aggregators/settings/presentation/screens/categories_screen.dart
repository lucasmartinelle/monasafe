import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/async_state_handler.dart';
import 'package:monasafe/src/common_widgets/selectable_badge.dart';
import 'package:monasafe/src/core/services/invalidation_service.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/aggregators/settings/presentation/widgets/category_form_modal.dart';
import 'package:monasafe/src/features/aggregators/settings/presentation/widgets/category_list_tile.dart';

/// Écran de gestion des catégories.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  CategoryType _selectedType = CategoryType.expense;

  /// Cache du nombre de transactions par catégorie.
  final Map<String, int> _transactionCounts = {};

  /// Charge le nombre de transactions pour une catégorie.
  Future<int> _getTransactionCount(String categoryId) async {
    if (_transactionCounts.containsKey(categoryId)) {
      return _transactionCounts[categoryId]!;
    }
    final service = ref.read(transactionServiceProvider);
    final count = await service.countTransactionsByCategory(categoryId);
    _transactionCounts[categoryId] = count;
    return count;
  }

  Future<void> _showDeleteConfirmation(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie'),
        content: Text(
          'Voulez-vous vraiment supprimer "${category.name}" ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.deleteCategory(category.id);
      InvalidationService.onCategoryDeletedFromWidget(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final categoriesAsync = _selectedType == CategoryType.expense
        ? ref.watch(expenseCategoriesStreamProvider)
        : ref.watch(incomeCategoriesStreamProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Catégories',
          style: AppTextStyles.h3(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Type selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SelectableBadgeGroup<CategoryType>(
              items: CategoryType.values,
              selectedItem: _selectedType,
              onSelected: (type) => setState(() => _selectedType = type),
              labelBuilder: (type) =>
                  type == CategoryType.expense ? 'Dépenses' : 'Revenus',
            ),
          ),

          // Categories list
          Expanded(
            child: AsyncStateHandler<List<Category>>(
              value: categoriesAsync,
              emptyCheck: (cats) => cats.isEmpty,
              emptyWidget: const EmptyStateWidget(
                message: 'Aucune catégorie',
                icon: Icons.category_outlined,
              ),
              builder: (categories) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: category.isDefault
                          ? CategoryListTile(category: category)
                          : FutureBuilder<int>(
                              future: _getTransactionCount(category.id),
                              builder: (context, snapshot) {
                                final hasTransactions =
                                    (snapshot.data ?? 0) > 0;
                                return CategoryListTile(
                                  category: category,
                                  hasTransactions: hasTransactions,
                                  onEdit: () async {
                                    await CategoryFormModal.show(
                                      context,
                                      category: category,
                                      categoryType: _selectedType,
                                    );
                                  },
                                  onDelete: () =>
                                      _showDeleteConfirmation(category),
                                );
                              },
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await CategoryFormModal.show(
            context,
            categoryType: _selectedType,
          );
        },
        backgroundColor: AppColors.process,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
