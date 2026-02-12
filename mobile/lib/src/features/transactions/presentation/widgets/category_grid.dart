import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/async_state_handler.dart';
import 'package:monasafe/src/common_widgets/category_icon.dart';
import 'package:monasafe/src/common_widgets/selectable_option_container.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/transactions/presentation/transaction_form_provider.dart';

/// Horizontal scrolling grid of categories filtered by transaction type.
///
/// Can be used in two modes:
/// 1. Connected to transactionFormNotifierProvider (default, when no parameters provided)
/// 2. Standalone with explicit categories, selectedCategoryId, and onCategorySelected
class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({
    super.key,
    this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  /// Optional list of categories. If null, loads from provider based on transaction type.
  final List<Category>? categories;

  /// Optional selected category ID. If null, reads from provider.
  final String? selectedCategoryId;

  /// Optional callback when a category is selected. If null, uses provider.
  final ValueChanged<String>? onCategorySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If categories are provided directly, use them
    if (categories != null) {
      return _buildGrid(
        context,
        ref,
        categories!,
        selectedCategoryId,
        onCategorySelected,
      );
    }

    // Otherwise, load from provider (default behavior)
    final state = ref.watch(transactionFormNotifierProvider);
    final categoriesAsync = state.type == CategoryType.expense
        ? ref.watch(expenseCategoriesStreamProvider)
        : ref.watch(incomeCategoriesStreamProvider);

    return AsyncStateHandler<List<Category>>(
      value: categoriesAsync,
      emptyCheck: (cats) => cats.isEmpty,
      emptyWidget: const SizedBox(
        height: 100,
        child: EmptyStateWidget(
          message: 'Aucune catégorie',
          padding: EdgeInsets.zero,
          iconSize: 32,
        ),
      ),
      loadingWidget: const SizedBox(
        height: 100,
        child: LoadingStateWidget(padding: EdgeInsets.zero),
      ),
      errorBuilder: (_, __) => const SizedBox(
        height: 100,
        child: ErrorStateWidget(
          message: 'Erreur de chargement',
          padding: EdgeInsets.zero,
        ),
      ),
      builder: (cats) => _buildGrid(context, ref, cats, state.categoryId, null),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<Category> categoryList,
    String? selectedId,
    ValueChanged<String>? onSelected,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          final category = categoryList[index];
          final isSelected = category.id == selectedId;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CategoryItem(
              category: category,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                if (onSelected != null) {
                  onSelected(category.id);
                } else {
                  ref
                      .read(transactionFormNotifierProvider.notifier)
                      .setCategory(category.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final categoryColor = Color(category.color);

    return SizedBox(
      width: 76,
      child: SelectableOptionContainer(
        isSelected: isSelected,
        onTap: onTap,
        selectedColor: categoryColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        enableHapticFeedback: false, // Already handled above
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon.fromHex(
              icon: IconMapper.getIcon(category.iconKey),
              colorHex: category.color,
              size: CategoryIconSize.small,
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? textColor : subtitleColor,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
